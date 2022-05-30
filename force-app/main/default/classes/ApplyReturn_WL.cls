global class ApplyReturn_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Return 레코드 끌고옴
        String query = 
        'SELECT '+
        'Id' + 
        'Order_ID__c, Returned__c' + 
        'WL_Return__c WHERE Returned__c = "Yes"';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Orders2__c> orderList) {
        // Order에 있는 Return Flag값이 True인 제품의 가격을 0원으로 바꿔주기
        // order return flag yes로 바꿔주기
        for(WL_Orders2__c ord : orderList) {   
            // if (ord.return__c = 'True') {
            //     ord.product2.pricebook2.profit = '0'
            //     ord.product2.pricebook2.quantity = '0'
            //     ord.product2.pricebook2.sales = '0'
            //     ord.product2.pricebook2.discount = '0'
            // }
            // ord.return__c = 'True'
        try {
            // DML - Update Order (return 반영해서 가격 없애기)
            update orderList;     
        } catch(Exception e) {
            System.debug(e);
        }
    }   
}

     
    global void finish(Database.BatchableContext context) {
        // execute any post-processing operations like sending email
    }
}