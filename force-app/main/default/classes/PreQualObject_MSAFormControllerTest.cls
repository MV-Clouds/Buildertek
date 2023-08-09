@isTest
public with sharing class PreQualObject_MSAFormControllerTest {
    @TestSetup
    static void MSAForm() {

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
        user.username = 'tester0@noemail.com';
        insert user;

        Account acc = new Account();
        acc.Name = 'Sample Account 1';
        acc.Type = 'TestType';
        acc.NumberOfEmployees = 10;
        acc.buildertek__MSA_Additional_Email__c='test@gmail.com';
        acc.buildertek__Qualification_Stage__c = 'Email Received';
        insert acc;
        
        buildertek__MSA_Settings__c ms =  new buildertek__MSA_Settings__c();
        ms.Name = 'MSA Settings';
        ms.buildertek__MSA_Sign_Contractor_Template_Name__c = 'MSA Sign Contractor Template';
        ms.buildertek__Submit_MSA_template_Name__c = 'Testing11';
        ms.buildertek__From_Email_Address__c='info@buildertek.com';
        ms.buildertek__MSA_Email__c = 'info@buildertek.com';
        insert ms;

        Contact con = new Contact();
        con.FirstName = 'Nm1';
        con.LastName = 'Test contact';
        con.email='test@test.com';
        insert con;
        
        System.runAs(user){
            buildertek__Pre_Qual__c preQual = new buildertek__Pre_Qual__c();
            preQual.buildertek__Company_Name__c='Test';
            preQual.buildertek__Account__c = acc.Id;
            preQual.buildertek__Pre_Qual_Contact__c=con.Id;
            preQual.buildertek__Is_ResendMSA__c = true;
            insert preQual;
        }

        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'test';
        insert quote;
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'CompanySignature',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;

        buildertek__Pre_Qual__c preQual = [SELECT Id FROM buildertek__Pre_Qual__c LIMIT 1];     

        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = preQual.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;

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

        List<OrgWideEmailAddress> specificOrgWideEmailAddress = new List<OrgWideEmailAddress>();
        OrgWideEmailAddress org = [SELECT Id, Address FROM OrgWideEmailAddress WHERE Address = 'info@buildertek.com'];
        specificOrgWideEmailAddress.add(org);
        integer si = specificOrgWideEmailAddress.size();
        System.debug('Size of OrgWideEmailAddress ===> '+si);
        System.debug('OrgWideEmailAddress Lisst ===> '+specificOrgWideEmailAddress);
        EmailTemplate emailTemplate = [SELECT Id FROM EmailTemplate LIMIT 1];
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        String[] sendTo = new String[]{'XXXXXXXXX@gmail.com'};
        email.setToAddresses(sendTo);
        email.setOrgWideEmailAddressId(org.Id);
        email.setTemplateID(emailTemplate.Id);
        email.setTargetObjectId(con.Id);
        email.setHtmlBody(con.Name);
        email.setFileAttachments(new Messaging.EmailFileAttachment[]{ efa });

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });      

    }

    @isTest
    static void MSAForm2(){
        Account acc = [SELECT id,Name,Type,NumberOfEmployees,buildertek__MSA_Additional_Email__c,buildertek__Qualification_Stage__c FROM Account LIMIT 1];
            
        buildertek__Pre_Qual__c preQual1 = [SELECT id,buildertek__Company_Name__c,buildertek__Phone__c,buildertek__Fax__c,buildertek__City__c,buildertek__State__c,buildertek__Zip_Code__c,buildertek__Federal_Tax_ID__c,buildertek__Contractor_License__c,buildertek__Office_Address__c,buildertek__Sub_Contract_By__c,buildertek__Sub_Contract_Printed_Name__c,buildertek__Sub_Contractor_Vendor_Name__c,buildertek__Contract_Signed__c,buildertek__Pre_Qual_Contact__c FROM buildertek__Pre_Qual__c LIMIT 1];     
        
        buildertek__Pre_Qual__c preQual2 = new buildertek__Pre_Qual__c();
        preQual2.buildertek__Company_Name__c='Test';
        preQual2.buildertek__Pre_Qual_Contact__c = 'abc';
        insert preQual2;

        buildertek__Quote__c quote = [SELECT Id, Name FROM buildertek__Quote__c LIMIT 1];

        Test.startTest();

        PreQualObject_MSAFormController.getMSASettings(preQual1.Id,'YES');
        PreQualObject_MSAFormController.getMSASettings(preQual2.Id,'YES');
        PreQualObject_MSAFormController.UpdateAccount(preQual1.id,'abc','1234567890','123','ahmedabad','Gujarat','1234','abcd','abcde','add','ewd','wedwr','fgtger','wed','03','YES','2022');
    	PreQualObject_MSAFormController.saveSign(quote.Id,'content','abcd','hello','content',true);
        PreQualObject_MSAFormController.saveSign(quote.Id,'content','abcd','hello','content',false);      
        PreQualObject_MSAFormController.getJSonString('abcdf',preQual1.Id,'abc','YES','YES');
        PreQualObject_MSAFormController.getJSonString('abcdf',preQual1.Id,'abc','NO','NO');
        PreQualObject_MSAFormController.getJSonString('abcdf',preQual2.Id,'abc','NO','NO');
        PreQualObject_MSAFormController.getErrorMsg();

        Test.stopTest();
    }


    @isTest
    static void MSAForm3(){
            
        buildertek__Pre_Qual__c preQual1 = [SELECT id,buildertek__Company_Name__c,buildertek__Phone__c,buildertek__Fax__c,buildertek__City__c,buildertek__State__c,buildertek__Zip_Code__c,buildertek__Federal_Tax_ID__c,buildertek__Contractor_License__c,buildertek__Office_Address__c,buildertek__Sub_Contract_By__c,buildertek__Sub_Contract_Printed_Name__c,buildertek__Sub_Contractor_Vendor_Name__c,buildertek__Contract_Signed__c,buildertek__Pre_Qual_Contact__c FROM buildertek__Pre_Qual__c LIMIT 1];     
        
        buildertek__MSA_Settings__c msa = [SELECT Id, Name, buildertek__From_Email_Address__c FROM buildertek__MSA_Settings__c LIMIT 1];
        msa.buildertek__From_Email_Address__c = 'demoTest@gmail.com';
        update msa;
        
        Test.startTest();
     
        PreQualObject_MSAFormController.getJSonString('abcdf',preQual1.Id,'abc','YES','YES');
        PreQualObject_MSAFormController.getJSonString('abcdf',preQual1.Id,'abc','NO','NO');

        Test.stopTest();
    }
}