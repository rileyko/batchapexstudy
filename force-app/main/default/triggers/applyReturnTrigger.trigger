trigger applyReturnTrigger on WL_Orders2__c (before update) {
    for (WL_Orders2__c orderItem : Trigger.new) {
        if (orderItem.IsReturned__c = Boolean.valueOf('true')) {
            orderItem.SalesPrice__c = 0;
        }
    }
}