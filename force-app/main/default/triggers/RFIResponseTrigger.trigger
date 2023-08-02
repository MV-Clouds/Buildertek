trigger RFIResponseTrigger on buildertek__RFI_Response__c (before insert , after insert/*,after update,before delete,after delete*/) {

    if(trigger.isbefore && trigger.isinsert ){
        for(buildertek__RFI_Response__c rfiresrec: Trigger.new){
            if(rfiresrec.buildertek__Responder__c==null){
                system.debug(rfiresrec.buildertek__Responder__c);
                rfiresrec.buildertek__Responder__c = userInfo.getUserId();
                system.debug(rfiresrec.buildertek__Responder__c);
            }
        }
        RFIresponsesHandler.Beforeinsertrfiresponse(Trigger.new);
     }
     if(trigger.isafter){
        if(trigger.isinsert){
            RFIresponsesHandler.insertrfiresponse(Trigger.new);
            
        }
        if(trigger.isupdate){
            RFIresponsesHandler.updaterfiresponse(Trigger.new);
        }
        if(trigger.isdelete){
            RFIresponsesHandler.deleterfiresponse(Trigger.old);
        }                
    }
    
    system.debug('test');
    RFIresponsesHandler.test();

    
    
}