public class sendMeetingController {
    @AuraEnabled
    public static InnerClass getHTML(string EmaiValue,string ccValue,string SubjectValue,string recId){
        List<contact> conlist = [select id,name from contact limit 1];
        InnerClass inn = new InnerClass();
        string htmlbody = '';
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Send Meeting Email'];
        buildertek__Meeting__c met = [select id,buildertek__Subject__c from buildertek__Meeting__c where id =:recId];
        List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(et.Id);
        msg.setWhatId(recId);
        msg.setTargetObjectId(conlist[0].Id);
        msg.setToAddresses(new list<string>{EmaiValue});
        lstMsgs.add(msg);
        //Messaging.sendEmail(lstMsgs);
        Savepoint sp = Database.setSavepoint();
        Messaging.sendEmail(lstMsgs);
        Database.rollback(sp);
        
       
        for (Messaging.SingleEmailMessage email : lstMsgs) {
            //htmlbodylist.add(email.getHTMLBody());
            htmlbody = email.getHTMLBody();
        }
        inn.Innhtmlbody = htmlbody;
        inn.Innsubject = met.buildertek__Subject__c;
        return inn;
    }
    
    public class InnerClass{
        @AuraEnabled
        public string Innhtmlbody;
        @AuraEnabled
        public string Innsubject;
        
    }
    
    
    
    @AuraEnabled
    public static void sendMail(List<buildertek__Attendee__c> atendeeList,List<contact> ccContactList,string EmaiValue,string ccValue,string SubjectValue,string bodyvalue){
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Send Meeting Email'];
        /*List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
        Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
        msg.setTemplateId(et.Id);
        msg.setWhatId(recId);
        msg.setTargetObjectId('0031K0000365Z43QAE');
        msg.setToAddresses(new list<string>{EmaiValue});
        lstMsgs.add(msg);
        Messaging.sendEmail(lstMsgs);*/
        System.debug(atendeeList);
        System.debug('========atendeeList=======');

        List<string> emaillist = new List<string>();
        if(EmaiValue != null && EmaiValue != ''){
            //emaillist.add(EmaiValue);
            emaillist = EmaiValue.split(',');
        }
        // system.debug(contactList);
        if(atendeeList.size()>0){
            for(buildertek__Attendee__c atendee:atendeeList){
                emaillist.add(atendee.buildertek__Email_Address__c	); 
            }
        }
        system.debug(emaillist);
        if(ccContactList.size()>0){
            for(contact con:ccContactList){
                emaillist.add(con.Email);
            }
        }
        List<Messaging.SingleEmailMessage> lstMsgsToSend = new List<Messaging.SingleEmailMessage>();
        
        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
        emailToSend.setToAddresses(emaillist);
        //emailToSend.setPlainTextBody(email.getPlainTextBody());
        emailToSend.setHTMLBody(bodyvalue);
        emailToSend.setSubject(SubjectValue);
        lstMsgsToSend.add(emailToSend);
         Messaging.sendEmail(lstMsgsToSend);
    }
       
}