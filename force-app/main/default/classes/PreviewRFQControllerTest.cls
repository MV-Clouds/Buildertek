@isTest
public with sharing class PreviewRFQControllerTest {
    @TestSetup
    static void previewRFQ() {
        
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'test@gmail.com';
        insert con;
        
        Id pId = [select id from profile where name='System Administrator'].id;

        User user = new User();
        user.alias = 'test123';
        user.email = 'test123@noemail.com';
        user.emailencodingkey = 'UTF-8';
        user.lastname = 'Testing';
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'en_US';
        user.profileid = pId;
        user.country = 'United States';
        user.IsActive = true;
        user.timezonesidkey = 'America/Los_Angeles';
        user.username = 'tester@noemail.com';
        insert user;
        
		System.runAs(new User(Id=UserInfo.getUserId())){
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'Testing11'; 
            et.DeveloperName = 'Test_Template'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 
        }

        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName('MSAForm.pdf');
        efa.setBody(bodyBlob);

        List<String> to = new List<String>();
        List<String> cc = new List<String>();

        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendTo = new String[]{'XXXXXXXXX@gmail.com'};
        to.add(con.Email);
        cc.add(con.Email);
        email.setToAddresses(to);
        email.setCcAddresses(cc);
        email.setSubject('PurchaseOrder');
        email.setTemplateID(emailTemplate.Id);
        email.setTargetObjectId(con.Id);
        email.setHtmlBody(con.Name);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });

        ContentVersion contentVersion = new ContentVersion(
            Title = 'CompanySignature',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = con.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

        // EmailMessage message = new EmailMessage();
        // message.ToAddress = 'test@test.com';
        // message.Subject = 'Test';
        // message.TextBody = 'Testing';
        // message.Incoming = false;
        // insert message;

        Account ac = new Account();
        ac.Name = 'Test';
        insert ac;

        buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
        po.buildertek__Vendor__c = ac.Id;
       // po.buildertek__Ordered_By__c = con.Id;
        po.buildertek__Date_Confirmed__c = System.today();
        po.buildertek__Status__c = 'Vendor Accepted';
        insert po;
    }
    @isTest
    static void previewRFQ2(){

        buildertek__Purchase_Order__c po = [SELECT Id, Name FROM buildertek__Purchase_Order__c];
        
        EmailTemplate et = [SELECT Id FROM EmailTemplate Limit 1];
        Contact con = [select Id,Name,Email from Contact Limit 1];
        List<String> to = new List<String>();
        to.add(con.Id);
        List<String> cc = new List<String>();
        cc.add(con.Id);
        PreviewRFQController.getTemplates();
        // PreviewRFQController.getPurchaseOrderLines(con.Id,et.Id);
        PreviewRFQController.sendProposal('abc',con.Id,et.Id,to,cc,'f');
        PreviewRFQController.acceptandsendProposal('abc',con.Id,et.Id,to,cc,'sub','f');
        PreviewRFQController.saveSign(po.Id,'abc','abcd','ab');
        PreviewRFQController.rejectSign(po.Id,'abc','abcd','ab','rk');
        PreviewRFQController.rejectionWithReason(po.Id,'abc','abcd','ab','rk');
    }
}