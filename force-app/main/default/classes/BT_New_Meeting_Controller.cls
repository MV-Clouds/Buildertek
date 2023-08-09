public class BT_New_Meeting_Controller {
    @AuraEnabled
    public static void saveActionItems(List<buildertek__Action_Item__c> actItemsList, Id MeetingId){
        System.debug('actItemsList-----------------------> '+actItemsList);
        for(buildertek__Action_Item__c rec : actItemsList){
            rec.buildertek__Meeting__c = MeetingId; 
            rec.buildertek__Status__c  = 'Open';            
        }
        
        Insert actItemsList;
        
        List<buildertek__Action_Item__c> actionItemListNew=[SELECT Id, Name, buildertek__Meeting__c,buildertek__Meeting__r.buildertek__Subject__c, buildertek__Owner__c,buildertek__Owner__r.Email FROM buildertek__Action_Item__c where id in : actItemsList];
       
        if(actionItemListNew.size()>0){
         string theTemplate = [SELECT Id, Name, DeveloperName, Subject, Body, HtmlValue, IsActive FROM EmailTemplate where DeveloperName='Send_Meeting_Email_New'].Id;
        System.debug('actionItemListNew------------------------------- '+actionItemListNew); 
         
         List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>(); 
         
            for(buildertek__Action_Item__c acItem: actionItemListNew){
            System.debug('acItem------------------------------- '+acItem); 
            System.debug('acItem------------------------------- '+acItem.buildertek__Owner__r.Email); 
                   if(acItem.buildertek__Owner__r.Email!=null){
                    Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                    //message.toAddresses(acItem.buildertek__Owner__r.Email);
                    message.setToAddresses(new List<String>{acItem.buildertek__Owner__r.Email});
                    // message.toAddresses(acItem.buildertek__Owner__r.Email);
                   // message.setSubject(acItem.buildertek__Meeting__r.buildertek__Subject__c);
                    message.setTemplateID(theTemplate);     
                    message.setSaveAsActivity(false);
                    message.setWhatId(acItem.buildertek__Meeting__c);
                    message.setTargetObjectId(acItem.buildertek__Owner__c);
                   
                    messageList.add(message);
                    }
                   
            }
            if(messageList.size()>0){
               Messaging.sendEmail(messageList);
            }
    }
    }
     
    
    @AuraEnabled
    public static string getLookupName(Id recId){
        string lookupfieldname = '';
        String sObjName = recId.getSObjectType().getDescribe().getName();
        string MeetingsObjName = 'buildertek__Meeting__c';

         Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try{
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(MeetingsObjName).getDescribe().fields.getMap();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug(dfield.getLabel()+'-------'+dfield.getType());
                if(String.ValueOf(dfield.getType()) == 'REFERENCE'){
                    if(String.ValueOf(dfield.getType()) == 'REFERENCE'){
                        system.debug('label'+'-------'+string.valueOf(dfield.getLabel()));
                        system.debug('api name'+'-------'+dfield.getReferenceTo()[0].getDescribe().getName()); 
                        if(sObjName == dfield.getReferenceTo()[0].getDescribe().getName()){
                          lookupfieldname = string.valueOf(dfield.getName());
                          break;
                        }            
                    }
                }
            }
            
           system.debug('lookupfieldname'+'-------'+lookupfieldname);
        }catch(Exception ex){
            
        }
        
       return lookupfieldname;
        
    }
    
    
    
    
}