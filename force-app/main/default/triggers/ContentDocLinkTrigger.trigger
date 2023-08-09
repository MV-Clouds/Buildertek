trigger ContentDocLinkTrigger on ContentDocumentLink (before insert) {
    for(ContentDocumentLink contentdoclink:Trigger.new) {
        Id recordId= contentdoclink.LinkedEntityId;
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        //system.debug('sObjName'+sObjName);
        if(sObjName=='buildertek__RFQ__c' || sObjName=='buildertek__RFI__c' || sObjName== 'buildertek__RFQ_To_Vendor__c' || sObjName=='buildertek__RFI_Response__c'){
            contentdoclink.Visibility='AllUsers';    
        }        
}

/*if(Trigger.isBefore && Trigger.isInsert){
    system.debug('>>>>> Is after trigger');
    List<ContentDocumentLink> cdls  = Trigger.New;
    system.debug('>>>>> Is after trigger'+cdls);
    Set<ID> RFQparentIds = new Set<ID>();
    for (ContentDocumentLink cdl : cdls ) {
        String objectName = cdl.LinkedEntityId.getSObjectType().getDescribe().getName();
        system.debug('>>>>> objectName'+objectName);
        if(objectName == 'buildertek__RFQ__c'){
            system.debug('>>>>>'+cdl.LinkedEntityId);
          RFQparentIds.add( cdl.LinkedEntityId );  
        }
        //RFQparentIds.add( cdl.LinkedEntityId );
    }
    List<buildertek__RFQ_To_Vendor__c> vendorRFQ = [select id,buildertek__Status__c,buildertek__Contact__r.Email,buildertek__RFQ__r.buildertek__Status__c  from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c IN:RFQparentIds];
     system.debug('>>>>>'+vendorRFQ);
     //List<contact> con = [select id,name,Email from contact order by createdDate desc limit 1];
     List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
     List<string> emaillist = new List<string>();
     EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='EmailToVendor'];
     for(buildertek__RFQ_To_Vendor__c vr :vendorRFQ){
     if(vr.buildertek__Status__c == 'Email Sent' && vr.buildertek__RFQ__r.buildertek__Status__c != 'Accepted'){
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(et.Id);
            msg.setWhatId(vr.ID);
            msg.setTargetObjectId(vr.buildertek__Contact__c);
            //msg.setTargetObjectId(con[0].Id);
            msg.setToAddresses(new list<string>{vr.buildertek__Contact__r.Email});
            lstMsgs.add(msg);
     }
     }
      Messaging.sendEmail(lstMsgs);
    
    
}*/
}