public without sharing class BT_SendRFQEmailController {
    @InvocableMethod
    public static void sendRFQEmail(List<String> recordId){
        System.debug('HI'+recordId);
        set<Id> rfoContactIds = new set<Id>();
        set<Id> contactIds = new set<Id>();
        
        set<Id> vendorIdstmp = new set<Id>();
        list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name = :'Email Configuration'];
        if (adminInterfaceNodeConfigurations.size() > 0){
            owea = [select Id from OrgWideEmailAddress where Address =: adminInterfaceNodeConfigurations[0].buildertek__Email_Address__c];
        }
        List<buildertek__RFQ_To_Vendor__c> rfqToVendor;
        rfqToVendor = [SELECT Id, buildertek__Contact__c ,
                       buildertek__Vendor__c,
                       buildertek__Status__c,buildertek__Contact__r.Email,
                       buildertek__RFQ__c,buildertek__isCommunityUser__c
                       FROM buildertek__RFQ_To_Vendor__c
                       WHERE Id IN:recordId];
        system.debug('rfqToVendor:::::'+rfqToVendor);
        system.debug('recordId:::::'+recordId);
        list<Id> rfqvendorIds = new list<Id>();
        map<Id,buildertek__RFQ_To_Vendor__c> vendorUserMap2 = new map<Id,buildertek__RFQ_To_Vendor__c>();
        List<String> LinkedConList = new List<String>();
        if (rfqToVendor.size() > 0){           
            for (RFQ_To_Vendor__c rfqVendor : rfqToVendor){
                if(rfqVendor.buildertek__Vendor__c!=null){
                    vendorIdstmp.add(rfqVendor.buildertek__Vendor__c);
                    rfqvendorIds.add(rfqVendor.Id);
                    LinkedConList.add(rfqVendor.buildertek__Contact__c);
                    vendorUserMap2.put(rfqVendor.buildertek__Vendor__c,rfqVendor);
                }
            }
        }
        set<Id> coRecs= new set<Id>();
        
        list<Contact> conlist = [Select id,Name,Email,AccountId from Contact where Id IN:LinkedConList 
                                 AND Email != null ];
        for(Contact contactRec : conlist){
            coRecs.add(contactRec.id);
        }
        list<buildertek__BT_Vendor_RFQ_Contacts__c> rfqvendorcontactlist = [Select id,Name,buildertek__Account__c,buildertek__Contact__c,
                                                                               buildertek__Vendor_RFQ__c  from buildertek__BT_Vendor_RFQ_Contacts__c
                                                                                where buildertek__Vendor_RFQ__c IN : rfqvendorIds];
           for(buildertek__BT_Vendor_RFQ_Contacts__c rfqcontactRec : rfqvendorcontactlist){
              coRecs.add(rfqcontactRec.buildertek__Contact__c);
              
           }
           system.debug('coRecs'+coRecs);
        map<Id,User> vendorUserMap1 = new map<Id,User>();
        
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
           system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry1 = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
                'FROM User Where ContactId IN : coRecs And isPortalEnabled=true ';    
            list<User> userList1= Database.query(strQry1);
            if(userList1.size() > 0){
                for(User usr: userList1){
                    vendorUserMap1.put(usr.ContactId,usr);
                }
            }
        }
        
            list<Contact> contactlist = [Select id,Name,Email,AccountId from Contact where Id IN: coRecs AND Email != null ];
        
        /*  map<Id,User> vendorUserMap = new map<Id,User>();
string strQry = 'SELECT Id, Username, LastName, FirstName, Name, ContactId, AccountId,Email,buildertek__Account_Id__c, isPortalEnabled '+
'FROM User Where AccountId In:vendorIdstmp  And isPortalEnabled=true  ';    
list<User> usersList = Database.query(strQry);
if(usersList.size() > 0){
for(User usr: usersList){
vendorUserMap.put(usr.AccountId,usr);
}
}*/
        
        
        string rfqInvitationTemplate;
        // if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        rfqInvitationTemplate = [SELECT Id,DeveloperName
                                 FROM EmailTemplate
                                 WHERE DeveloperName = 'RFQ_Invitation_Email_New'].Id;
        //} 
        string rfqRejectedTemplate;
        //if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        rfqRejectedTemplate = [SELECT Id,DeveloperName
                               FROM EmailTemplate
                               WHERE DeveloperName = 'RFQ_Rejected_Email'].Id;
        // } 
        string rfqAwardTemplate;
        // if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        rfqAwardTemplate = [SELECT Id,DeveloperName
                            FROM EmailTemplate
                            WHERE DeveloperName = 'RFQ_Award_Email_New'].Id;
        // } 
        string rfqAwardTemplateCommunity;
        // if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        rfqAwardTemplateCommunity = [SELECT Id,DeveloperName
                                     FROM EmailTemplate
                                     WHERE DeveloperName = 'RFQ_Awarded_Email_Community'].Id;
        // } 
        string rfqAccepetedTemplate;
        // if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
        rfqAccepetedTemplate = [SELECT Id,DeveloperName
                                FROM EmailTemplate
                                WHERE DeveloperName = 'RFQ_Thank_You_New'].Id;
        // } 
        String[] toaddres;
         map<Id,Contact> contactMap = new map<Id,Contact>();
        List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
        string duplicateid = '';
        for(buildertek__RFQ_To_Vendor__c rfq :rfqToVendor){
            for(Contact conRec : contactlist){
                if(conRec.Email != null){
                    if(rfq.buildertek__Status__c == 'Email Sent'){
                        if(!duplicateid.contains(conRec.Id)){
                            contactMap.put(conRec.Id,conRec);
                            buildertek__RFQ_To_Vendor__c vendorRec = vendorUserMap2.get(conRec.AccountId); 
                            if(vendorUserMap1.get(conRec.Id) == null){
                                string toemailadd = conRec.Email;
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.toAddresses = new String[] { toemailadd};
                                email.setTemplateId(rfqInvitationTemplate);
                                //email.setWhatId(rfq.Id);
                                email.setWhatId(vendorRec.Id);
                                email.setTargetObjectId(conRec.Id);
                                email.setSaveAsActivity(true);
                                msgList.add(email); 
                            }
                        }
                        duplicateid += conRec.Id;
                    }
                    else if(rfq.buildertek__Status__c == 'Awarded'){
                        if(conRec.Email != null){
                            if(!duplicateid.contains(conRec.Id)){
                                contactMap.put(conRec.Id,conRec);
                                buildertek__RFQ_To_Vendor__c vendorRec = vendorUserMap2.get(conRec.AccountId); 
                                string toemailadd = conRec.Email;
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                system.debug('vendorUserMap1.get(conRec.Id)'+vendorUserMap1.get(conRec.Id));
                                if(vendorUserMap1.get(conRec.Id) == null){
                                    system.debug('HI'+conRec.Name);
                                    email.setTemplateId(rfqAwardTemplate);
                                }else{
                                    system.debug('Hello'+conRec.Name);
                                    email.setTemplateId(rfqAwardTemplateCommunity);
                                }
                                email.toAddresses = new String[] { toemailadd};
                                 //email.setWhatId(rfq.Id);   
                                email.setWhatId(vendorRec.Id);
                                email.setTargetObjectId(conRec.Id);
                                email.setSaveAsActivity(true);
                                msgList.add(email);
                            }
                            duplicateid +=  conRec.Id;   
                        }
                        
                    }
                    else if(rfq.buildertek__Status__c == 'Rejected'){
                        if(conRec.Email != null){
                            if(!duplicateid.contains(conRec.Id)){
                                contactMap.put(conRec.Id,conRec);
                                buildertek__RFQ_To_Vendor__c vendorRec = vendorUserMap2.get(conRec.AccountId);
                                string toemailadd = conRec.Email;
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.toAddresses = new String[] { toemailadd};
                                email.setTemplateId(rfqRejectedTemplate);
                                if (owea.size() > 0 ) {
                                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                //email.setWhatId(rfq.Id);
                                email.setWhatId(vendorRec.Id);
                                email.setTargetObjectId(conRec.Id);
                                email.setSaveAsActivity(true);
                                msgList.add(email);
                            }
                            duplicateid +=  conRec.Id;
                        }    
                    }
                    else if(rfq.buildertek__Status__c == 'Accepted'){
                        if(conRec.Email != null){
                            if(!duplicateid.contains(conRec.Id)){
                                system.debug('uiojk;');
                                contactMap.put(conRec.Id,conRec);
                                buildertek__RFQ_To_Vendor__c vendorRec = vendorUserMap2.get(conRec.AccountId);
                                string toemailadd = conRec.Email;
                                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                                email.toAddresses = new String[] { toemailadd};
                                email.setTemplateId(rfqAccepetedTemplate);
                                //email.setWhatId(rfq.Id);
                                email.setWhatId(vendorRec.Id);
                                email.setTargetObjectId(conRec.Id);
                                email.setSaveAsActivity(true);
                                if (owea.size() > 0 ) {
                                    email.setOrgWideEmailAddressId(owea.get(0).Id);
                                }
                                msgList.add(email);
                            }
                            duplicateid +=  conRec.Id;
                        }
                    }
                }
            }
        }
        EmailServicesAddress eServices;
               eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                            FROM EmailServicesAddress
                            where LocalPart = 'projects'];
               
               String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
       			Savepoint sp = Database.setSavepoint();
        system.debug('msdList->'+msgList);
               List<Messaging.SendEmailResult> resultsemail = Messaging.sendEmail(msgList);
        	system.debug('resultsemail->'+resultsemail);
               Database.rollback(sp);
               List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                    for (Messaging.SingleEmailMessage email : msgList) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());
                        Contact contactReC = contactMap.get(email.getTargetObjectId());
                        string templatebody = email.getHTMLBody();
                        if(templatebody.contains('{replaceresponse}')){
                            templatebody = templatebody.replace('{replaceresponse}',+contactReC.Name);
                        }
                        emailToSend.setHTMLBody('<br/>'+templatebody); 
                        emailToSend.setFileAttachments(email.getFileAttachments());
                        emailToSend.setSubject(email.getSubject());
                        if(email.getOrgWideEmailAddressId() != null){
                             emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                        }
                        emailToSend.setSaveAsActivity(true);
                        emailToSend.setReplyTo(fromAddress);   
                        system.debug('&&&&'+emailToSend);
                        actualMessageList.add(emailToSend);
                    }
        system.debug('actualMessageList size->'+actualMessageList.size());
                    if(actualMessageList.size() > 0){
                      Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList); 
                        for(Messaging.SendEmailResult res : serList){
                            if(res.isSuccess() == false){
                                System.debug('--->'+res.geterrors().get(0).getMessage());
                            }else{
                                System.debug('&&&&');
                            }
                        }

                    }
      /*  if(msgList.size()>0){
            system.debug('^^^^msgList'+msgList);
            system.debug('^^^^ msgList.size'+ msgList.size());
            Messaging.sendEmail(msgList);
            //  Messaging.SendEmailResult[] results = Messaging.sendEmail(msgList);
        }*/
    }
}