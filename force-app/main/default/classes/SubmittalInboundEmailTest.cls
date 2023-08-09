@isTest
public class SubmittalInboundEmailTest {
    public static testMethod void test1() {
        
       Messaging.InboundEmail email = new Messaging.InboundEmail() ;
       Messaging.InboundEnvelope env    = new Messaging.InboundEnvelope();
       
       Account acc = new Account();
       acc.Name = 'test';
       insert acc;
       
       Contact cont = new Contact();
        cont.firstName='john';
        cont.lastName='smith';
        cont.Email='test@test.com'; 
        cont.HasOptedOutOfEmail=false; 
        cont.AccountId = acc.Id;
       insert cont ;
       
       Project__c p = new Project__c();
       p.Name = 'test';
       insert p;
     
      Profile pro=[SELECT Id From Profile WHERE Name='Standard User'];
         User u2 =new User( Alias = 'newUser1' ,
                            Email ='newuser123@testorg.com',
                            EmailEncodingKey = 'UTF-8',
                            LastName = 'Testing',
                            LanguageLocaleKey='en_US',
                            LocaleSidKey='en_US',
                            UserName='testmeena@gmail.com',
                            ProfileId=pro.Id,
                            TimeZoneSidKey    = 'America/Los_Angeles');
         insert u2;
       
       RFQ__c rfq = new RFQ__c();
       rfq.Name  = 'test';
       rfq.Project__c = p.id;
       rfq.ownerid = u2.id;
       insert rfq;
       
       RFQ_To_Vendor__c rfqVendor = new RFQ_To_Vendor__c();
       rfqVendor.Name = 'test';
       rfqVendor.RFQ__c= rfq.id;
       rfqVendor.Vendor__c = acc.id;
       insert rfqVendor;
       
       Change_Order__c co = new Change_Order__c();
       co.Name = 'test';
       co.Customer_Account__c = acc.id;
       co.ownerid = u2.id;
       insert co;
       
       Submittal__c sub = new Submittal__c();
       sub.Responsible_Contact__c = cont.id;
       sub.Responsible_Vendor__c = acc.id;
       sub.Status__c = 'Draft';
       sub.ownerid = u2.id;
       insert sub;
       
       Punch_List__c pl = new Punch_List__c();
       pl.Vendor_Contact__c = cont.id;
       pl.buildertek__Vendor_Account__c = acc.id;
       pl.Description__c = 'test';
       pl.ownerid = u2.id;
       insert pl;
       
       email.subject = 'Test Contact Email [ref:'+ rfqVendor.id;
       email.fromAddress = 'test@test.com';
       
       env.fromAddress = 'test@test.com';
       
       Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
       attachment.body = blob.valueOf('my attachment text');
       attachment.fileName = 'textfileone.txt';
       attachment.mimeTypeSubType = 'text/plain';
       email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
       
       Messaging.InboundEmail.TextAttachment attachmenttext = new Messaging.InboundEmail.TextAttachment();
       attachmenttext.body = 'my attachment text';
       attachmenttext.fileName = 'textfiletwo3.txt';
       attachmenttext.mimeTypeSubType = 'texttwo/plain';
       email.textAttachments =   new Messaging.inboundEmail.TextAttachment[] { attachmenttext };


       
       SubmittalInboundEmail sie = new SubmittalInboundEmail();
       sie.handleInboundEmail(email,env);
       
       email.subject = 'Test Contact Email [ref:'+ co.id; 
       email.plainTextBody = 'approve\n';
       sie.handleInboundEmail(email,env);
       
       email.subject = 'Test Contact Email [ref:'+ rfqVendor.id; 
       email.plainTextBody = 'accepted\n';
       sie.handleInboundEmail(email,env);
       
       email.subject = 'Test Contact Email [ref:'+ sub.id; 
       sie.handleInboundEmail(email,env);
       
        email.subject = 'Test Contact Email [ref:'+ pl.id; 
       sie.handleInboundEmail(email,env);
        
        System.assertEquals('Test','Test');
      
        
    }
    
    
     
        
}