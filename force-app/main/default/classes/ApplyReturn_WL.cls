global class ApplyReturn_WL implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext context) {
        // Return에서 Flag가 Yes인 것들 끌고옴
        String query = 
        'SELECT '+
        'Id' + 
        'Order_ID__c, Returned__c' + 
        'WL_Return__c WHERE Returned__c = "Yes"';
        return Database.getQueryLocator(query);
    }
     
    global void execute(Database.BatchableContext context, List<WL_Order__c> orderList) {
        // Order 리스트 가져와서, Return에 있는 Order ID 매칭되는 것들 가격정보 바꿔주기
        for(WL_Order__c ord : orderList) {        
            // ret.Order_ID__c = '';
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