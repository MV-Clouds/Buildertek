public class TrainingCertificateController {
      
     public string templateBody{
     get{
     //templateBody = 'TEST IS THIS';
            List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
            List<String> templateList = new List<String>();
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            contact con=null;
            con = [SELECT Id, Email
                   FROM Contact
                   WHERE Email != null
                   Order By CreatedDate DESC
                   LIMIT 1];            
            String templateId;
            system.debug('Con-----------'+con.Id);
            templateId = [SELECT Id
                           FROM EmailTemplate
                           WHERE DeveloperName = 'TestTemplate'].Id;
            system.debug('templateId----------'+templateId);
         
            email.setTemplateId(templateId);
            email.setWhatId('a4Z1K000000HdsfUAC');
            email.setTargetObjectId(con.Id);
            email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
            msgList.add(email);
            SavePoint sp = Database.setSavePoint();
            Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
            for (Messaging.SingleEmailMessage emailNew : msgList){
            templateBody = emailNew.getHTMLBody(); 
            system.debug('templateBody----------'+templateBody);
            //emailNew.getHTMLBody();
                     
            }
            Database.rollback(sp);
            return templateBody;
          
        }
        set;
     }


}