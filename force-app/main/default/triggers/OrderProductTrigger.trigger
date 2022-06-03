trigger OrderProductTrigger on WL_OrderProduct2__c (before insert, before update, after delete) {
    List<WL_Orders2__c> orderObj = [SELECT Id, Order_ID__c, SalesPrice__c FROM WL_Orders2__c];
    Map<Id,WL_Orders2__c> orderMap = new Map<Id,WL_Orders2__c>(orderObj);
    Map<Id,WL_Orders2__c> updateOrderMap = new Map<Id,WL_Orders2__c>();
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            for (WL_OrderProduct2__c opItem : trigger.new) {
                orderMap.get(opItem.WL_Order2__c).SalesPrice__c += opItem.Sales__c;
                updateOrderMap.put(opItem.WL_Order2__c, orderMap.get(opItem.WL_Order2__c));
            }
        }
        if (Trigger.isUpdate) {
            for (WL_OrderProduct2__c opOldItem : trigger.old) {
                for (WL_OrderProduct2__c opNewItem : trigger.new) {
                    if(opOldItem.Sales__c != opNewItem.Sales__c){
                        orderMap.get(opNewItem.WL_Order2__c).SalesPrice__c += (opNewItem.Sales__c - opOldItem.Sales__c);
                        updateOrderMap.put(opNewItem.WL_Order2__c, orderMap.get(opNewItem.WL_Order2__c));
                    } 
                }
            }
        }
    if (Trigger.isAfter) {
        if (Trigger.isDelete){
            for (WL_OrderProduct2__c opDeletedItem : trigger.new) {
                orderMap.get(opDeletedItem.WL_Order2__c).SalesPrice__c -= opDeletedItem.Sales__c;
                updateOrderMap.put(opDeletedItem.WL_Order2__c, orderMap.get(opDeletedItem.WL_Order2__c));
            }
        }
    }
}
    if (updateOrderMap.size() > 0) {
        Database.update(updateOrderMap.values(), true);
    }
}