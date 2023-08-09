@isTest
private class BT_GenerateQuotePDFTest {
    @TestSetup
    static void makeData(){
        Contact c = new Contact();
        c.firstName='test';
        c.lastName='test lname';
        c.email='testname@gmail.com';
        insert c;

        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Quote';
        insert quote;

        buildertek__Contract__c	buildertekContractRef = new buildertek__Contract__c	();
        buildertekContractRef.Name ='test';
        insert buildertekContractRef;
        
    }
    @isTest
    public static void testMethod1(){
          // Setup test data
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles',
         UserName=uniqueUserName);

        System.runAs(u) {
       

         buildertek__Contract__c buildertekContractRef=[Select Id , name From buildertek__Contract__c LIMIT 1];
        EmailTemplate emailTemp = new EmailTemplate();
        emailTemp.isActive = true;
        emailTemp.Name = 'name';
        emailTemp.DeveloperName = 'unique_name_addSomethingSpecialHere';
        emailTemp.TemplateType = 'text';
        emailTemp.FolderId = UserInfo.getUserId();
        insert emailTemp;

        Test.StartTest();

        BT_GenerateQuotePDF generateQuote = new BT_GenerateQuotePDF();
        generateQuote.fileid='test';
        generateQuote.filerecid='Test';
        generateQuote.imageURL='Test';

        

        PageReference pageRef = Page.buildertek__BT_GenerateQuotePDF;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('recordID', buildertekContractRef.id);
        ApexPages.currentPage().getParameters().put('templateId', emailTemp.id);
        ApexPages.currentPage().getParameters().put('fileId', 'test');



     
        generateQuote.createPDF();
        Test.stopTest();
        }
      
        
    }
    
}