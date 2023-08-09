public class EmailSendController {
    @AuraEnabled 
    public static String getEmails(String recordId ){
        
        String mailBody = URL.getSalesforceBaseUrl().toExternalForm()+ '/'+recordId;
        //system.debug(recordId);
        list<buildertek__Purchase_Order__c> email =[select id, Name ,buildertek__Project__c, buildertek__Project__r.buildertek__Project_Manager__r.email from buildertek__Purchase_Order__c WHERE id =:recordId];
        system.debug(email);
        if(email[0].buildertek__Project__c != null){
            if(email[0].buildertek__Project__r.buildertek__Project_Manager__r.email != null){
                processEmail(email[0].buildertek__Project__r.buildertek__Project_Manager__r.email,'Material has been delivered','Material has been delivered for '+ email[0].Name +'. Please review and confirm. '+'\n'+mailBody);
                return 'Success'; 
            }
            else{
                return 'noEmail';
            }
            
        }else{
            return 'noProject';
        }
        
    }  
    
    @AuraEnabled
    public static string processEmail(String email, String Subject, String Message){
        String sMessage='';
        try{
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            String[] toAddresses = new String[] {email}; 
                mail.setToAddresses(toAddresses);
            mail.setSubject(Subject);
            mail.setHtmlBody(Message);
            Messaging.SendEmailResult [] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            sMessage='Success';
        }
        catch(Exception ex){
            sMessage=ex.getLineNumber()+'\n'+ex.getCause()+'\n'+ex.getMessage()+'\n'+ex.getStackTraceString();
        }
        return sMessage;
    }
    
    
    
}