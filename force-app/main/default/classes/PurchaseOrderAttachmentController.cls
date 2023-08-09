public class PurchaseOrderAttachmentController {
    public string poId{get;set;}
    public string emailBody{get;set;}
    
    
    public void emailAttach(){
            poId = ApexPages.currentPage().getParameters().get('budgetId');
        
        system.debug('poId-------->'+poId);
        
        buildertek__Purchase_Order__c poRec = [Select Id, Name, buildertek__Vendor__c, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Vendor__r.Name, buildertek__Status__c,buildertek__PO_Total__c from buildertek__Purchase_Order__c Where Id =: poId];

        system.debug('poRec------->'+poRec);
        
        EmailTemplate et = [SELECT Id,Subject, Body FROM EmailTemplate WHERE name ='Purchase Order Template' limit 1];
        
          List<contact> conlist = [select id,name from contact limit 1];
        
        
        if (poRec.buildertek__Vendor__c != null && poRec.buildertek__Vendor__r.buildertek__Email_Address__c != null) {
                
            string htmlbody = '';
            List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
            msg.setTemplateId(et.Id);
            msg.setWhatId(poRec.Id);
            msg.setTargetObjectId(conlist[0].Id);
            msg.toAddresses = new String[] { poRec.buildertek__Vendor__r.buildertek__Email_Address__c };
                //msg.setToAddresses(new list<string>{EmaiValue});
                lstMsgs.add(msg);
            //Messaging.sendEmail(lstMsgs);
            Savepoint sp = Database.setSavepoint();
            Messaging.sendEmail(lstMsgs);
            Database.rollback(sp);
            
            emailBody = lstMsgs[0].getHTMLBody();
            
        
        system.debug('emailBody -------->'+emailBody );
        }
        
    } 
  
}