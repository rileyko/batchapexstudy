trigger applyReturnTrigger on WL_Orders2__c (before update) {
    // Nope
    for (WL_Orders2__c orderItem : Trigger.new) {
        if (orderItem.IsReturned__c) {
            orderItem.SalesPrice__c = 0;
        }
    }
}