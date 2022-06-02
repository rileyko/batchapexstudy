global class CreateOrder_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // 기존 Order 리스트 쿼리로 끌고옴
        String query = 
        'SELECT '+
        'Order_ID__c, Order_Date__c, Ship_Date__c, CustomerID__c, City__c, State__c, Postal_Code__c, Product_ID__c, SalesPersonID__c' + 
        'FROM' + 
        '더미';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<더미> dummyOrderList) {
        Schema.SObjectField externalIdContact = WL_Contact__c.Fields.CustomerID__c; //External Key

        Map<String, WL_Order__c> orderMap = new Map<String, WL_Order__c>();
        Map<String, WL_Order__c> newOrderMap = new Map<String, WL_Order__c>();
        Map<String, WL_Contact__c> contactMap = new Map<String, WL_Contact__c>();
        Map<String, WL_Contact__c> newContactMap = new Map<String, WL_Contact__c>();
        Map<String, WL_OrderProduct2__c> orderProductMap = new Map<String, WL_OrderProduct2__c>();
        Set<String> storeSet = new Set<String>();
        for(WL_Order__c dummyItem : dummyOrderList) {
            
            //create contact obj
            WL_Contact__c contact = new WL_Contact__c(CustomerID__c = dummyItem.CustomerID__c, );
            contactMap.put(dummyItem.CustomerID__c, contact);
            storeSet.add(dummyItem.Postal_Code__c);
            
            //create store obj

            // create order obj
            WL_Order__c orderItem = new WL_Order__c();
            orderItem.Order_ID__c = dummyItem.Order_ID__c;
            orderItem.Order_Date__c = dummyItem.Order_Date__c;
            orderItem.CustomerID__c = contact;
            // 2020-11-03 > 11/3/20
            orderMap.put(dummyItem.Order_ID__c, orderItem);

            //
        }

        List<WL_Contact__c> contactList = [SELECT Id, CustomerID__c, Name, Segement FROM WL_Contact__c WHERE CustomerID__c in : contactSet];
        Map<String, WL_Contact__c> orgContactMap = new Map<String, WL_Contact__c>();
        for(WL_Contact__c orgContactItem : contactList){
            orgContactMap.put(orgContactItem.CustomerID__c, orgContactItem);
        }
        for(String contactIdItem : contactMap.keySet()){
            if(orgContactMap.containsKey(contactIdItem)) {
                if(orgContactMap.get(contactIdItem).Name == contactMap.get(contactIdItem).Name) {
                    continue;
                }else {
                    newContactMap.put(contactIdItem);
                }
            }else {
                newContactMap.put(contactIdItem);
            }
        }




        Database.upsert(newContactMap.values(), externalIdContact, true);
        Database.upsert(newOrderMap.values(), externalIdContact, true);

        //1. (Data 파싱 (날짜 정보 -> Date, 가격정보 -> Number))
        //2. for Loop 통해 OrderID, OrderDate, CustomerID, SalesPersonID 같은지 확인
            // Order에서 OrderID, OrderDate, CustomerID, SalesPersonID 가 동일한 경우, 같은 Order로 취급 --> 어디서 비교할 수 있음?
        //3. 있으면 Update -> 
        // Date : OrderDate, ShipDate
        // Product, 가격 정보들, SalesPerson 정보 업데이트
        //4. 없으면 Insert
        for(WL_Order__c ord : orderList) {        
            // 배송 & 주문 날짜 Update 
            // 배송일 = (오늘 - 주문일) + 배송일
            ord.Ship_Date__c = ord.Ship_Date__c.replace('/','-');
            ord.Order_Date__c = ord.Order_Date__c.replace('/','-');
            // ord.Ship_Date__c = (System.today() - Date.valueOf(ord.Order_Date__c) + Date.valueOf(ord.Ship_Date__c)).format('yyyy/MM/dd');
            ord.Order_Date__c = System.now().format('yyyy/MM/dd');
            // 이외 사항들 어케비교해요?
            //ord.Product_ID__c = ????
        try {
            // DML - Update Order
            update orderList;     
        } catch(Exception e) {
            System.debug(e);
        }
    }   
}

     
    global void finish(Database.BatchableContext context) {
        // ApplyReturn으로 배치체인
        ApplyReturn_WL ret = new ApplyReturn_WL();
        Database.executeBatch(ret);
    }
}