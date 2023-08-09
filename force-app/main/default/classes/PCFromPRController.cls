public without sharing class PCFromPRController {

    @AuraEnabled
    public static void updatePRStatus(String pricingRequestId){
        System.debug('updatePRStatus');
        List<buildertek__Pricing_Request__c> pricingRequestList= [SELECT Id, buildertek__Date_Pricing_Returned__c, buildertek__Selections_Manager__c, buildertek__Status__c ,(SELECT Id ,buildertek__Status__c  From buildertek__Pricing_Request_Lines__r) From buildertek__Pricing_Request__c WHERE Id=:pricingRequestId];
        List<buildertek__Pricing_Request_Line__c> pricingRequestLineList = new List<buildertek__Pricing_Request_Line__c>();
        Set<Id> contactIdSet = new Set<Id>();
        String[] toAddresses = new String[]{};


        for(buildertek__Pricing_Request__c pricingRequest:pricingRequestList){
            pricingRequest.buildertek__Status__c='Returned';
            for(buildertek__Pricing_Request_Line__c pricingRequestLine: pricingRequest.buildertek__Pricing_Request_Lines__r){
                pricingRequestLine.buildertek__Status__c='Pricing Complete';
                pricingRequestLineList.add(pricingRequestLine);
            }

            if(pricingRequest.buildertek__Selections_Manager__c != null){
                contactIdSet.add(pricingRequest.buildertek__Selections_Manager__c);
            }
        }
        update pricingRequestList;
        update pricingRequestLineList;

        List<Messaging.SingleEmailMessage> lstMail=new List<Messaging.SingleEmailMessage>();
        OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress Limit 1];
        EmailTemplate emailTemplate = [SELECT DeveloperName, Name, Id FROM EmailTemplate WHERE DeveloperName ='Pricing_Complete' LIMIT 1];
        if (owea.size() > 0  && emailTemplate.Id != null && contactIdSet.size() > 0) {

            List<Contact> conList= [Select Id , Name , Email From Contact WHERE Id=:contactIdSet];
            for(Contact con :conList){
                toAddresses.add(con.Email);
            }
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
            mail.setToAddresses(toAddresses); 
            mail.setTemplateID(emailTemplate.Id); 
            mail.setWhatId(pricingRequestId);                        
            mail.setTargetObjectId(conList[0].Id);       
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
            lstMail.add(mail);    
            if(lstMail.size()>0){
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');                
                } 
                else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);                
                }           
            }
            else{
                System.debug('No Record Found');
            }

            System.debug(pricingRequestList);
        }
    }
   
}