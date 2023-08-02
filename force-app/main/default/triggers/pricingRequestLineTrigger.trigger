trigger pricingRequestLineTrigger on buildertek__Pricing_Request_Line__c(after update , before update) {
   
    if(trigger.isUpdate && pricingRequestLineTriggerHandler.firstRun){
        pricingRequestLineTriggerHandler.afterEvent(Trigger.New , Trigger.oldMap);
     }

}