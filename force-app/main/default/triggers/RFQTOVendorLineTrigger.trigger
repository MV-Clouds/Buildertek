trigger RFQTOVendorLineTrigger on RFQ_Vendor_Item__c (before insert, before update,after update) {
RFQTOVendorLineTriggerHandler handler = new RFQTOVendorLineTriggerHandler();
    if(Trigger.isInsert && Trigger.isBefore){
        handler.beforeInsert(Trigger.new);
    }
    if (Trigger.isUpdate && Trigger.isBefore){
        handler.beforeUpdate(Trigger.new);
    }
    
   /* if (Trigger.isUpdate && Trigger.isAfter){
        handler.afterUpdate(Trigger.new);
    } */
}