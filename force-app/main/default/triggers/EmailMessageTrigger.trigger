trigger EmailMessageTrigger on EmailMessage (after insert, before insert) {
    if(Trigger.isInsert && Trigger.isBefore){
        /*system.debug('---from name -->'+trigger.new[0].FromName);
system.debug('---From Address -->'+trigger.new[0].FromAddress);*/
    }
    
    else if(Trigger.isInsert && Trigger.isAfter){
        // here we are replacing the email service addess to current log in user
        // so this way it will look nice in email activity
        List<EmailMessageRelation> ers;
        
        ers = [Select Id,emailMessageId,relationAddress,relationId,relationType from EmailMessageRelation where emailMessageId IN: trigger.newmap.keyset() and relationType = 'FromAddress'];
        
       // System.debug('Email Message Id '+ers[0].Id);
        system.debug('ers---------->'+ers);
        
        
        List<EmailMessageRelation> emrs = new List<EmailMessageRelation>();
        for(EmailServicesAddress emailService :[SELECT Id, LocalPart, EmailDomainName FROM EmailServicesAddress where LocalPart = 'projects' limit 1]){
            
            system.debug('=-------------------------->'+emailService);
            
            for(EmailMessageRelation er: ers){
                if(er.relationAddress == emailService.LocalPart+'@'+emailService.EmailDomainName){
                    EmailMessageRelation emr = new EmailMessageRelation();
                    emr.emailMessageId = er.emailMessageId;
                    emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                    emr.relationType = er.relationType;
                    emr.relationAddress = er.relationAddress;
                    emrs.add(emr);
                }
            }
        }   
        
        if(!emrs.isEmpty()) {
            delete ers;
            insert emrs;
            
        }
    }
}