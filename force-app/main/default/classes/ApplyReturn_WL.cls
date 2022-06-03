global class ApplyReturn_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Return Dummy에서 BatchFlag가 N인 Order Id 끌고옴
        String query = 
        'SELECT Id, Order_ID__c FROM WL_Dummy_Return__c';
        query += ' WHERE BatchFlag__c = \'N\''; 
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Dummy_Return__c> dummyReturnList) {
        Map<String, WL_Orders2__c> orderMap = new Map<String, WL_Orders2__c>();
        Map<String, WL_Dummy_Return__c> dummyReturnMap = new Map<String, WL_Dummy_Return__c>();
        
        // 더미 오브젝트에 있는 내용 기반으로 Order만들기
        for(WL_Dummy_Return__c dummyItem : dummyReturnList) {
            // 더미 batch flag 변경 후, Map에 저장
            dummyItem.BatchFlag__c = 'Y';
            dummyReturnMap.put(dummyItem.Id, dummyItem);

            // create order obj
            // 더미에 있는 Order Id 확인하기 위해 Order 생성 후, Map에 저장
            WL_Orders2__c orderItem = new WL_Orders2__c();
            orderItem.Order_ID__c = dummyItem.Order_ID__c;
            orderMap.put(dummyItem.Order_ID__c, orderItem);
        }

        // 존재하는 Order 중에, 리턴에있는 OrderId 있는지 확인 후, 값 변경 적용
        List<WL_Orders2__c> orderList = [SELECT Id, Order_ID__c, IsReturned__c FROM WL_Orders2__c WHERE Order_ID__c in : orderMap.keySet()];
        Map<String, WL_Orders2__c> orgOrderMap = new Map<String, WL_Orders2__c>();
        for(WL_Orders2__c orgOrderItem : orderList){
            orgOrderMap.put(orgOrderItem.Order_ID__c, orgOrderItem);
        }
        for(String orderIdItem : orderMap.keySet()){
            // WL_Orders2__c 오브젝트의 Return Flag = Yes & 가격정보 = 0 반영하기
            if(orgOrderMap.containsKey(orderIdItem)) {
                if(orgOrderMap.get(orderIdItem).Order_ID__c == orderMap.get(orderIdItem).Order_ID__c) {
                    orgOrderMap.get(orderIdItem).IsReturned__c = true;
                    orgOrderMap.get(orderIdItem).SalesPrice__c = 0;
                }
            }
        }
        try {
            // Update 과정 (Order -> Return Dummy)
            Database.update(orgOrderMap.values(), true); // order obj
            Database.update(dummyReturnMap.values(), true); // dummy obj
        } catch (Exception e) {
            System.debug(e);
        } 
}

    global void finish(Database.BatchableContext context) {
    }
}