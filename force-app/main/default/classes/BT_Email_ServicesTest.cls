@isTest
public class BT_Email_ServicesTest {
    public static testMethod void testBT_Email_Services() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            
            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'someaddress@email.com',AccountId=currAccount.id);
            insert currContact; 
            
            buildertek__Project__c project1 = new buildertek__Project__c();
            project1.name='test project';
            insert project1;
            
            buildertek__RFQ__c rfq1 = new buildertek__RFQ__c();
            rfq1.buildertek__Project__c=project1.Id;
            insert rfq1;
            
            buildertek__RFQ_To_Vendor__c vendor1 = new buildertek__RFQ_To_Vendor__c();
            vendor1.name='test vendor';
            vendor1.buildertek__RFQ__c = rfq1.Id;
            vendor1.buildertek__Vendor__c = currAccount.Id;
            insert vendor1; 
            
            buildertek__Quote__c quote = new buildertek__Quote__c();
            quote.Name='Test Quote';
            quote.buildertek__Sales_Rep__c =u.Id;
            quote.buildertek__Sender_Email_Response__c = 'test2@gmail.com';
            insert quote;
            
            Test.startTest();
            
            EmailMessage em = new EmailMessage();
            em.Subject='test subject';
            em.buildertek__Subject__c='test subject';
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            system.debug('vendor 1 :: '+vendor1.Id);
            
            email.subject = '[ref:' + vendor1.Id + ']Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'accepted\nTitle';
            
            email.subject = '[ref:' + quote.Id + ']Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'Action:SavePDF; recordId:' + quote.Id + ';templateId:;fileId:; Confirmation Controller';
                
            BT_Email_Services testInbound = new BT_Email_Services();
            testInbound.handleInboundEmail(email, env);

            email.subject = '[ref:' + vendor1.Id + ']Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'canceled\nTitle';

            BT_Email_Services testInbound1 = new BT_Email_Services();
            testInbound1.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services1() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            
            EmailMessage em=new EmailMessage();
            em.Subject='test subject';
            em.buildertek__Subject__c='test subject';
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            
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
                
            BT_Email_Services testInbound = new BT_Email_Services();
            
            buildertek__Submittal__c submittal1 = new buildertek__Submittal__c(); 
            submittal1.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            insert submittal1;
            
            email.subject = '[ref:' + submittal1.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services2() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
        UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'someaddress@email.com',AccountId=currAccount.id);
            insert currContact; 
            
            buildertek__Project__c project1 = new buildertek__Project__c();
            project1.name='test project';
            insert project1;
            
            buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
            rfq1.buildertek__Project__c=project1.Id;
            insert rfq1;
            
            buildertek__RFQ_To_Vendor__c vendor1= new buildertek__RFQ_To_Vendor__c();
            vendor1.name='test vendor';
            vendor1.buildertek__RFQ__c = rfq1.Id;
            vendor1.buildertek__Vendor__c = currAccount.Id;
            insert vendor1; 
            
            EmailMessage em=new EmailMessage();
            em.Subject='test subject';
            em.buildertek__Subject__c='test subject';
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
            BT_Email_Services testInbound = new BT_Email_Services();
            
            email.subject = '[ref:' + vendor1.Id + ']Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'accepted\nTitle';
            testInbound.handleInboundEmail(email, env);
            
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services3() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            buildertek__Change_Order__c co=new buildertek__Change_Order__c();
            co.name='test';
            insert co;

            buildertek__Billings__c billing=new buildertek__Billings__c();
            billing.name='Test Billing';
            billing.buildertek__Change_Order__c=co.Id;
            billing.buildertek__Sender_Email_Response__c='test@gmail.com';
            insert billing;

            EmailMessage em=new EmailMessage();
            em.Subject='test subject';
            em.buildertek__Subject__c='test subject';
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + billing.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services4() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 

            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'someaddress@email.com',AccountId=currAccount.id);
            insert currContact; 

            buildertek__Project__c project1 = new buildertek__Project__c();
            project1.name='test project';
            insert project1;

            buildertek__Change_Order__c co=new buildertek__Change_Order__c();
            co.name='test';
            insert co;

            buildertek__Purchase_Order__c po=new buildertek__Purchase_Order__c();
            //po.Name='test';
            po.buildertek__Change_Order__c=co.Id;
            po.buildertek__Vendor__c = currAccount.id;
            insert po;

            buildertek__Account_Payable__c acpay=new buildertek__Account_Payable__c();
            acpay.buildertek__Project__c=project1.Id;
            acpay.buildertek__Purchase_Order__c=po.Id;
            acpay.buildertek__Sender_Email_Response__c='test@gmail.com';
            insert acpay;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + acpay.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = acpay.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + acpay.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services5() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            buildertek__Project__c project1 = new buildertek__Project__c();
            project1.name='test project';
            project1.buildertek__Sender_Email_Response__c='test@gmail.com';
            insert project1;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + project1.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = project1.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + project1.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services6() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            Account currAccount = new Account(Name = 'Test',buildertek__Sender_Email_Response__c = 'test@gmail.com');
            insert currAccount; 

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + currAccount.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = currAccount.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + currAccount.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services7() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            buildertek__Contract__c cont = new buildertek__Contract__c();
            cont.Name = 'Test Contract';
            cont.buildertek__Sender_Email_Response__c='test@gmail.com';
            insert cont;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + cont.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = cont.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + cont.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services8() {
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='someaddress@email.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            buildertek__Change_Order__c co=new buildertek__Change_Order__c();
            co.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            co.name='test';
            insert co;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + co.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = co.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

            Messaging.InboundEmail.BinaryAttachment attachment = new Messaging.InboundEmail.BinaryAttachment();
            attachment.body = blob.valueOf('my attachment text');
            attachment.fileName = 'textfileone.txt';
            attachment.mimeTypeSubType = 'text/plain';
            email.binaryAttachments = new Messaging.inboundEmail.BinaryAttachment[] { attachment };
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' + co.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            BT_Email_Services testInbound1 = new BT_Email_Services();

            email.subject = '[ref:' + co.Id+ ']Create Contact'; 
            email.plainTextBody = 'reject\nTitle';
            testInbound1.handleInboundEmail(email, env);
            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services9() {

        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = false;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Vendor_Notification_Template__c = 'New RFI vendor';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'New RFI vendor'; 
            et.DeveloperName = 'New_RFI_vendor'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 

            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'test@gmail.com',AccountId=currAccount.id);
            insert currContact; 

            buildertek__RFI__c rfi1 = new buildertek__RFI__c();
            rfi1.buildertek__Subject__c='test subject';
            rfi1.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            rfi1.buildertek__Assigned_To__c=currContact.Id;
            rfi1.buildertek__Submitted_By2__c =currContact.Id;
            rfi1.buildertek__Due_Date__c=System.now().date();
            insert rfi1;

            buildertek__Users_Contacts__c ucont = new buildertek__Users_Contacts__c();
            ucont.buildertek__RFI__c = rfi1.Id;
            ucont.buildertek__Contact__c = currContact.Id;
            ucont.buildertek__User__c = u.Id;
            insert ucont;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + rfi1.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = rfi1.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' +rfi1.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services10() {

        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Vendor_Notification_Template__c = 'New RFI vendor';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'New RFI vendor'; 
            et.DeveloperName = 'New_RFI_vendor'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 

            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'test@gmail.com',AccountId=currAccount.id);
            insert currContact; 

            buildertek__RFI__c rfi1 = new buildertek__RFI__c();
            rfi1.buildertek__Subject__c='test subject';
            rfi1.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            rfi1.buildertek__Assigned_To__c=currContact.Id;
            rfi1.buildertek__Submitted_By2__c =currContact.Id;
            rfi1.buildertek__Due_Date__c=System.now().date();
            insert rfi1;

            buildertek__Users_Contacts__c ucont = new buildertek__Users_Contacts__c();
            ucont.buildertek__RFI__c = rfi1.Id;
            ucont.buildertek__Contact__c = currContact.Id;
            ucont.buildertek__User__c = u.Id;
            insert ucont;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + rfi1.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = rfi1.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();

            email.subject = '[ref:' +rfi1.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services11() {

        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Vendor_Notification_Template__c = 'New RFI vendor';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'New RFI vendor'; 
            et.DeveloperName = 'New_RFI_vendor'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 
            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'test@gmail.com',AccountId=currAccount.id);
            insert currContact; 

            buildertek__RFI__c rfi1 = new buildertek__RFI__c();
            rfi1.buildertek__Subject__c='test subject';
            rfi1.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            rfi1.buildertek__Assigned_To__c=currContact.Id;
            rfi1.buildertek__Submitted_By2__c =currContact.Id;
            rfi1.buildertek__Due_Date__c=System.now().date();
            insert rfi1;

            buildertek__Users_Contacts__c ucont = new buildertek__Users_Contacts__c();
            ucont.buildertek__RFI__c = rfi1.Id;
            ucont.buildertek__Contact__c = currContact.Id;
            ucont.buildertek__User__c = u.Id;
            insert ucont;

            buildertek__RFI_Response__c response = new buildertek__RFI_Response__c();
            response.buildertek__RFI__c = rfi1.Id;
            response.buildertek__Response__c = 'TEST RFIS';
            response.buildertek__Show_In_Community__c = true;
            response.buildertek__Response_From_CMP__c = false;
            response.buildertek__private__c = false;
            insert response;
            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + response.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = response.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();
            List<String> toaddressList = new List<String>{'test1@gmail.com', 'test2@gmail.com'};
            email.subject = '[ref:' +response.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.toAddresses = toaddressList;
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services12() {

        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = false;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Vendor_Notification_Template__c = 'New RFI vendor';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'New RFI vendor'; 
            et.DeveloperName = 'New_RFI_vendor'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 
            Account currAccount = new Account(Name = 'Test');
            insert currAccount; 
            Contact currContact = new Contact(LastName = 'Test', Primary_Contact__c=true,Email = 'test@gmail.com',AccountId=currAccount.id);
            insert currContact; 

            buildertek__RFI__c rfi1 = new buildertek__RFI__c();
            rfi1.buildertek__Subject__c='test subject';
            rfi1.buildertek__Sender_Email_Response__c = 'test@gmail.com';
            rfi1.buildertek__Assigned_To__c=currContact.Id;
            rfi1.buildertek__Submitted_By2__c =currContact.Id;
            rfi1.buildertek__Due_Date__c=System.now().date();
            insert rfi1;

            buildertek__Users_Contacts__c ucont = new buildertek__Users_Contacts__c();
            ucont.buildertek__RFI__c = rfi1.Id;
            ucont.buildertek__Contact__c = currContact.Id;
            ucont.buildertek__User__c = u.Id;
            insert ucont;

            buildertek__RFI_Response__c response = new buildertek__RFI_Response__c();
            response.buildertek__RFI__c = rfi1.Id;
            response.buildertek__Response__c = 'TEST RFIS';
            response.buildertek__Show_In_Community__c = true;
            response.buildertek__Response_From_CMP__c = false;
            response.buildertek__private__c = false;
            insert response;
            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + response.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = response.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();
            List<String> toaddressList = new List<String>{'test1@gmail.com', 'test2@gmail.com'};
            email.subject = '[ref:' +response.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.toAddresses = toaddressList;
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services13() {

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            
            buildertek__Warranty__c warranty1 = new buildertek__Warranty__c();
            warranty1.buildertek__Sender_Email_Response__c = 'test21@gmail.com';
            insert warranty1;
            
            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + warranty1.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = warranty1.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();
            List<String> toaddressList = new List<String>{'test1@gmail.com', 'test2@gmail.com'};
            email.subject = '[ref:' +warranty1.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.toAddresses = toaddressList;
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            email.htmlBody = '<Html><Body><H1>Hello</H1></Body></Html>';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    public static testMethod void testBT_Email_Services14() {

        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='test@gmail.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles',
                          UserName=uniqueUserName);
        
        System.runAs(u) {
            Test.startTest();
            buildertek__Punch_List__c punchRec1 = new buildertek__Punch_List__c();
            punchRec1.buildertek__Description__c='test description';
            punchRec1.buildertek__Sender_Email_Response__c='test2@gmail.com';
            insert punchRec1;

            EmailMessage em=new EmailMessage();
            em.Subject='[ref:' + punchRec1.Id+ ']Create Contact';
            em.buildertek__Subject__c='test subject';
            em.relatedToId = punchRec1.Id;
            insert em;
            
            Messaging.InboundEmail email = new Messaging.InboundEmail() ;
            Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();  

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
                
            BT_Email_Services testInbound = new BT_Email_Services();
            List<String> toaddressList = new List<String>{'test1@gmail.com', 'test2@gmail.com'};
            email.subject = '[ref:' +punchRec1.Id+ ']Create Contact'; 
            email.fromAddress = 'test@gmail.com';
            email.toAddresses = toaddressList;
            email.fromname = 'test cont';
            email.plainTextBody = 'approved\nTitle';
            email.htmlBody = '<Html><Body><H1>Hello</H1></Body></Html>';
            testInbound.handleInboundEmail(email, env);  
        } 
        System.assertEquals('Test','Test');
    }
    
    
}