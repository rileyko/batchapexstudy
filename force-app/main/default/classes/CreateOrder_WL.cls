global class CreateOrder_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // 기존 Order 리스트 쿼리로 끌고옴
        String query = 
        'SELECT '+
        'Order_ID__c, Order_Date__c, Ship_Date__c, CustomerID__c, City__c, State__c, Postal_Code__c, Product_ID__c, SalesPersonID__c' + 
        'FROM' + 
        'WL_Order__c';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Order__c> orderList) {
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