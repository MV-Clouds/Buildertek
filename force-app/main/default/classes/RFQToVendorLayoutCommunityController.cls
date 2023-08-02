public class RFQToVendorLayoutCommunityController {
    @AuraEnabled 
    public static buildertek__RFQ_To_Vendor__c getRFQStatus(string recordId){
        
        buildertek__RFQ_To_Vendor__c awardedRfq = [Select id, Name, buildertek__RFQ_Status__c,buildertek__Status__c,buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Status__c from buildertek__RFQ_To_Vendor__c where Id =:recordId ];
        
        system.debug(awardedRfq.buildertek__RFQ__r.buildertek__Status__c);
        system.debug(awardedRfq.buildertek__RFQ_Status__c);
       // return awardedRfq.buildertek__RFQ__r.buildertek__Status__c;
       return awardedRfq;
    }
    
    
    
    @AuraEnabled
    public static String acceptrfqAndChild(String recordId){
        
        buildertek__RFQ_To_Vendor__c awardedRfq = [Select id, Name,buildertek__RFQ__c, 
        buildertek__Status__c,buildertek__RFQ__r.buildertek__Status__c , buildertek__Contact__c,buildertek__Accepted_Date__c
        from buildertek__RFQ_To_Vendor__c where Id =:recordId ];
        system.debug(awardedRfq );
        awardedRfq.buildertek__Status__c = 'Accepted';
        awardedRfq.buildertek__Accepted_Date__c = system.now();
       //awardedRfq.buildertek__RFQ__r.buildertek__Status__c = 'Accepted';\
        
        update awardedRfq ;
        
        
        buildertek__RFQ__c parent = new buildertek__RFQ__c();
        
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__c  from buildertek__RFQ_To_Vendor__c where Id =: recordId];
            parent.Id = parentId.buildertek__RFQ__c;
        
        parent.buildertek__Status__c = 'Accepted';
        
        update parent;
        
        // list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
        // list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
        //                                                                                             from buildertek__Admin_Interface_Node_Configuration__c
        //                                                                                             WHERE Name = :'Email Configuration'];
        // if (adminInterfaceNodeConfigurations.size() > 0){
        //     owea = [select Id from OrgWideEmailAddress where Address =: adminInterfaceNodeConfigurations[0].buildertek__Email_Address__c];
        // }   

                   
        // buildertek__RFQ__c rfqrec = [select id,Name,buildertek__Project__c,buildertek__Project__r.Name,
        // buildertek__Project__r.OwnerId,buildertek__Project__r.Owner.Email
        // from buildertek__RFQ__c where Id =: awardedRfq.buildertek__RFQ__c ];

        // string toemailadd='';
        // if(rfqrec.buildertek__Project__c!=null){

        //     toemailadd = rfqrec.buildertek__Project__r.Owner.Email;
        //     System.debug('toemailadd--->'+toemailadd);
    
        //     string theTemplate;
    
        //     theTemplate = [SELECT Id
        //     FROM EmailTemplate
        //     WHERE Name  = 'Award Accept Manager Email'].Id;        
    
        //     system.debug('theTemplate>'+theTemplate);
    
        //     List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
        //     Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();
    
        //     message1.toAddresses = new String[] { toemailadd};
        //     message1.setTemplateID(theTemplate);     
        //     message1.setSaveAsActivity(false);
        //     message1.setWhatId(awardedRfq.Id);
        //     //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
        //     message1.setTargetObjectId(awardedRfq.buildertek__Contact__c);
        //     messageList.add(message1);
    
        //     Savepoint sp = Database.setSavepoint();
    
        //     Messaging.sendEmail(messageList);
    
        //     Database.rollback(sp);
        //     try{ 
    
        //     //List<string> CCAdresses = new List<string>();                    
        //     //CCAdresses.add('sowndarya.nittala@diligentforcelabs.com'); 
    
        //     List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
    
        //     // loop through the previous message list and set the email fields
        //     for (Messaging.SingleEmailMessage email : messageList) {
        //     Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        //     emailToSend.setToAddresses(email.getToAddresses());
        //     emailToSend.setHTMLBody(email.getHTMLBody());
        //     emailToSend.setSaveAsActivity(false);
        //     emailToSend.setSubject(email.getSubject());
        //         if ( owea.size() > 0 ) {
        //             emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
        //         }
        //     //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
        //     emailToSend.setFileAttachments(email.getFileAttachments());
        //     //emailToSend.setCcAddresses(CCAdresses);
        //     actualMessageList.add(emailToSend);
        //     system.debug('emailToSend--->'+emailToSend);
        //     }
    
    
        //     Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
        //     System.debug('The email was sent successfully.');
        //     }catch(Exception e){
        //     System.debug('The email failed to send: ');             
        //     }    

        // }
                    
        return 'success';
    }
   
    
    @AuraEnabled
    public static String rejectRfq(String recordId){
        
         buildertek__RFQ_To_Vendor__c awardedRfq = [Select id, Name,buildertek__RFQ__r.buildertek__Status__c,buildertek__Rejected_Date__c,buildertek__Status__c from buildertek__RFQ_To_Vendor__c where Id =:recordId ];
        system.debug(awardedRfq );
        awardedRfq.buildertek__Status__c = 'Rejected';
        awardedRfq.buildertek__Rejected_Date__c = system.now();
      //  awardedRfq.buildertek__RFQ__r.buildertek__Status__c = 'Accepted';
        update awardedRfq ;
        buildertek__RFQ__c parent = new buildertek__RFQ__c();
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__c  from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        parent.Id = parentId.buildertek__RFQ__c;
        parent.buildertek__Status__c = 'Canceled';
        update parent;
        return 'success';
    }
    
    
    @AuraEnabled
    public static String getRQToAccount(String recordId){
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c
                                                     from buildertek__RFQ_To_Vendor__c where Id =: recordId AND 
                                                     (buildertek__RFQ__r.buildertek__Status__c = 'Awarded' OR buildertek__RFQ__r.buildertek__Status__c = 'Accepted'
                                                     OR buildertek__RFQ__r.buildertek__Status__c = 'Canceled')];
        return rfqToAccount.buildertek__Status__c;
    }

    @AuraEnabled
    public static string getRfqTo(){
       return UserInfo.getDefaultCurrency();
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
       return UserInfo.isMultiCurrencyOrganization();
    }
    
     @AuraEnabled
    public static buildertek__RFQ_To_Vendor__c getrejectMessage(String recordId){
        buildertek__RFQ__c parent = new buildertek__RFQ__c();
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__c  from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        system.debug('parentId'+parentId);
        list<buildertek__RFQ_To_Vendor__c> rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =: parentId.buildertek__RFQ__c AND buildertek__RFQ__r.buildertek__Status__c = 'Awarded'];
        boolean isAccepted = false;
        system.debug('rfqToAccount'+rfqToAccount);
        for(buildertek__RFQ_To_Vendor__c rfqToVendor : rfqToAccount){
            if(rfqToVendor.buildertek__Status__c == 'Accepted'){
                isAccepted = true;
            }
        }
        buildertek__RFQ_To_Vendor__c vendorRec = [select Id,Name,buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Status__c from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        return vendorRec;
    }
     @AuraEnabled
    public static Boolean getrfqtovendorstatus(String recordId){
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__c  from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        list<buildertek__RFQ_To_Vendor__c> rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =: parentId.buildertek__RFQ__c AND buildertek__RFQ__r.buildertek__Status__c = 'Awarded'];
        boolean isAccepted = false;
        system.debug('rfqToAccount'+rfqToAccount);
        for(buildertek__RFQ_To_Vendor__c rfqToVendor : rfqToAccount){
            if(rfqToVendor.buildertek__Status__c == 'Accepted'){
                isAccepted = true;
            }
        }
       
        return isAccepted;
    } 
    @AuraEnabled
     public static Boolean checkduedate(String recordId){
        buildertek__RFQ_To_Vendor__c parentId = [select Id,Name,buildertek__RFQ__r.buildertek__Due_Date__c,buildertek__RFQ__c from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        system.debug('duedate'+parentId.buildertek__RFQ__r.buildertek__Due_Date__c);
         System.debug('today'+system.today());
         Boolean isdueexp = false;
         if(parentId.buildertek__RFQ__r.buildertek__Due_Date__c < system.today()){
             isdueexp = true;
         }
         return isdueexp;
        }
}