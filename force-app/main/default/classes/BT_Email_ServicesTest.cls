@isTest
public class BT_Email_ServicesTest {
    public static testMethod void testBT_Email_Services() {
        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user 
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
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
            
            buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
            rfq1.buildertek__Project__c=project1.Id;
            insert rfq1;
            
            buildertek__RFQ_To_Vendor__c vendor1= new buildertek__RFQ_To_Vendor__c();
            vendor1.name='test vendor';
            vendor1.buildertek__RFQ__c = rfq1.Id;
            vendor1.buildertek__Vendor__c = currAccount.Id;
            insert vendor1; 
            
            buildertek__RFQ__c rfq2= new buildertek__RFQ__c();
            rfq2.buildertek__Project__c=project1.Id;
            rfq2.buildertek__Vendor__c=vendor1.Id;
            insert rfq2;
            
            buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
            groupRef.Name = 'test';
            insert groupRef;
            
            buildertek__Contract__c cont = new buildertek__Contract__c();
            cont.Name = 'Test Contract';
            //cont.Email='test@gmail.com'
            insert cont;
            
            buildertek__Quote__c quote=new buildertek__Quote__c();
            quote.Name='Test Quote';
            quote.buildertek__Sales_Rep__c =u.Id;
            insert quote;
            
            buildertek__Change_Order__c co=new buildertek__Change_Order__c();
            co.name='test';
            insert co;

            Test.startTest();
            
               buildertek__Purchase_Order__c po=new buildertek__Purchase_Order__c();
            //po.Name='test';
            po.buildertek__Change_Order__c=co.Id;
            po.buildertek__Vendor__c = currAccount.id;
            insert po;
            
            buildertek__Billings__c billing=new buildertek__Billings__c();
            billing.name='Test Billing';
            billing.buildertek__Change_Order__c=co.Id;
            billing.buildertek__Sender_Email_Response__c='test@gmail.com';
            insert billing;
            
            buildertek__Contract_Item__c bContractRec = new buildertek__Contract_Item__c();
            bContractRec.Name = 'test'; 
            bContractRec.buildertek__contract__c = cont.Id;
            bContractRec.buildertek__Contract_Item_Group__c =groupRef.id;
            bContractRec.buildertek__Unit_Price__c =20;
            bContractRec.buildertek__Quantity__c =10;
            insert bContractRec;
            
            buildertek__Account_Payable__c acpay=new buildertek__Account_Payable__c();
            acpay.buildertek__Project__c=project1.Id;
            acpay.buildertek__Purchase_Order__c=po.Id;
            insert acpay;
            
            EmailMessage em=new EmailMessage();
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
            email.plainTextBody = 'accepted\nTitle';
            
            email.subject = '[ref:' + billing.Id + ']Create Contact';
            email.fromAddress = 'someaddress@email.com';
            email.plainTextBody = 'accepted\nTitle';
            
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
            
            // The following code runs as user 'u'
            // 
            //testInbound.handleInboundEmail(email, env);
            
            email.plainTextBody = 'canceled\nTitle';
         //  testInbound.handleInboundEmail(email, env);
            
            /*List<buildertek__change_order__c> coList = new List<buildertek__change_order__c>();
            buildertek__change_order__c ch = new buildertek__change_order__c();
            ch.Name='test';
            ch.buildertek__Customer_Account__c=currAccount.Id;
            ch.buildertek__Status__c = 'Customer Approved';
            ch.buildertek__Contract__c = cont.Id;
            coList.add(ch); 
            insert coList;*/
            
            email.subject = '[ref:' + cont.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            
            email.plainTextBody = 'rejected\nTitle';
            testInbound.handleInboundEmail(email, env);
            
            buildertek__Submittal__c submittal1 = new buildertek__Submittal__c(); 
            insert submittal1;
            
            email.subject = '[ref:' + submittal1.Id+ ']Create Contact'; 
            email.plainTextBody = 'approved\nTitle';
            testInbound.handleInboundEmail(email, env);
            
            buildertek__RFI__c rfi1 = new buildertek__RFI__c();
            rfi1.buildertek__Subject__c='test subject';
            rfi1.buildertek__Assigned_To__c=currContact.Id;
            rfi1.buildertek__Due_Date__c=System.now().date();
            insert rfi1;
            
            email.subject = '[ref:' + rfi1.Id+ ']Create Contact';  
           // testInbound.handleInboundEmail(email, env);
            
            buildertek__Warranty__c warranty1 = new buildertek__Warranty__c();
            insert warranty1;
            
            email.subject = '[ref:' + warranty1.Id+ ']Create Contact';  
            //testInbound.handleInboundEmail(email, env);
            
            buildertek__Punch_List__c punchRec1 = new buildertek__Punch_List__c();
            punchRec1.buildertek__Description__c='test description';
            insert punchRec1;
            
            email.subject = '[ref:' + punchRec1.Id+ ']Create Contact';  
           // testInbound.handleInboundEmail(email, env);
            
            System.debug('Current User: ' + UserInfo.getUserName());
            System.debug('Current Profile: ' + UserInfo.getProfileId());

            Test.stopTest();  
        } 
        System.assertEquals('Test','Test');
    }
    
    
}