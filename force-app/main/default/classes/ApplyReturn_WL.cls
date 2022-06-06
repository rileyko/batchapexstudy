global class ApplyReturn_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Return Dummy에서 BatchFlag가 N인 Order Id 끌고옴
        String query = 
        'SELECT Id, Order_ID__c FROM WL_Dummy_Return__c';
        // query += ' WHERE BatchFlag__c = \'N\''; 
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Dummy_Return__c> dummyReturnList) {
        Set<String> orderSet = new Set<String>();
        List<WL_OrderProduct2__c> orderProductList = new List<WL_OrderProduct2__c>();
        Map<String, WL_Dummy_Return__c> dummyReturnMap = new Map<String, WL_Dummy_Return__c>();
        
        // 더미 오브젝트에 있는 내용 기반으로 Order만들기
        for(WL_Dummy_Return__c dummyItem : dummyReturnList) {
            // 더미 batch flag 변경 후, Map에 저장
            dummyItem.BatchFlag__c = 'Y';
            dummyReturnMap.put(dummyItem.Id, dummyItem);

            // create order obj
            // 더미에 있는 Order Id 확인하기 위해 Order 생성 후, Map에 저장
            orderSet.add(dummyItem.Order_ID__c);
        }

        // 존재하는 Order 중에, 리턴에있는 OrderId 있는지 확인 후, 값 변경 적용
        List<WL_Orders2__c> orderList = [SELECT Id, Order_ID__c, IsReturned__c, (SELECT Id, Sales__c FROM WL_OrderProduct2s__r) FROM WL_Orders2__c WHERE Order_ID__c in : orderSet];
        
        Map<String, WL_Orders2__c> orgOrderMap = new Map<String, WL_Orders2__c>();
        for(WL_Orders2__c orgOrderItem : orderList){
            // OrderProduct 생성
            orgOrderMap.put(orgOrderItem.Order_ID__c, orgOrderItem);
        }

        for(String orderIdItem : orderSet){
            // WL_Orders2__c 오브젝트의 Return Flag = Yes & 가격정보 = 0 반영하기
            if(orgOrderMap.containsKey(orderIdItem)) {
                orgOrderMap.get(orderIdItem).IsReturned__c = true;
                for(WL_OrderProduct2__c orderProductIdItem : orgOrderMap.get(orderIdItem).WL_OrderProduct2s__r){
                    orderProductIdItem.Sales__c = 0;
                    orderProductList.add(orderProductIdItem);
                }
            }
        }
        try {
            // Update 과정 (Order -> Return Dummy)
            Database.update(orgOrderMap.values(), true); // order obj
            Database.update(orderProductList, true); // orderProduct obj
            Database.update(dummyReturnMap.values(), true); // dummy obj
        } catch (Exception e) {
            System.debug(e);
        } 
}

    global void finish(Database.BatchableContext context) {
    }
}