@isTest
private class Pre_Qual_Object_Qualification_Test {
    @TestSetup
    static void makeData(){
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

        Contact c = new Contact();
        c.firstName='fname';
        c.lastName='lname';
        c.Email='lname@gmail.com';
        insert c;


        buildertek__Pre_Qual__c pq = new buildertek__Pre_Qual__c();
        pq.buildertek__Account__c = acc.Id;
        pq.buildertek__Pre_Qual_Contact__c=c.Id;
        pq.buildertek__MSA_Additional_Email__c='test@gmail.com';
        insert pq;
        buildertek__Pre_Qual__c pq1 = new buildertek__Pre_Qual__c();
        pq1.Id = pq.Id;
        pq1.buildertek__Qualification_Stage__c = 'Fully Executed';
        update pq1;

        Attachment attach=new Attachment();   	
    	attach.Name='Unit Test Attachment';
    	Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
    	attach.body=bodyBlob;
        attach.parentId=acc.id;
        insert attach;

     

    }

    @isTest
    public static void testMethod1(){
        buildertek__MSA_Settings__c msa = new buildertek__MSA_Settings__c();
        msa.Name = 'MSA Settings';
        msa.buildertek__Site_URL__c = 'https://test.com/';
        msa.buildertek__Send_MSA_Template_Name__c = 'MSA Settings';
        insert msa;

        buildertek__Pre_Qual__c pq  =[Select Id , Name , buildertek__Account__c , buildertek__Qualification_Stage__c From buildertek__Pre_Qual__c LIMIT 1];
        Test.startTest();
        PreQualObjectQualificationController.getPreQualStage(pq.Id);
        PreQualObjectQualificationController.ChangeAccountStatus(pq.Id);
        PreQualObjectQualificationController.ChangeAccountStatustoOld(pq.Id , 'Fully Executed');
        PreQualObjectQualificationController.saveFile(pq.Id ,'test' ,'Unit Test Attachment Body' ,'Text' , '');
        PreQualObjectQualificationController.sendEmail(pq.Id , '[{"fileName":"testFile Name " , "fileContent":"Test File Content"}]');

        Test.stopTest();

    }

    @isTest
    public static void testMethod2(){

      
        buildertek__MSA_Settings__c msa = new buildertek__MSA_Settings__c();
        msa.Name = 'MSA Settings';
        msa.buildertek__Site_URL__c = 'https://test.com/';
        msa.buildertek__Send_MSA_Template_Name__c = 'MSA Settings';
        msa.buildertek__From_Email_Address__c='info@buildertek.com';
        insert msa;

        // buildertek__MSA_Settings__c msa = [Select Id ,buildertek__From_Email_Address__c ,  name From  buildertek__MSA_Settings__c LIMIT 1];
        Attachment attach =[Select Id , Name , Body From  Attachment Limit 1];
        buildertek__Pre_Qual__c pq  =[Select Id , Name , buildertek__Account__c , buildertek__Qualification_Stage__c From buildertek__Pre_Qual__c LIMIT 1];
        Test.startTest();
        PreQualObjectQualificationController.saveFile(pq.Id ,'test' ,'Unit Test Attachment Body' ,'Text' , attach.Id);
        PreQualObjectQualificationController.sendEmail(pq.Id , '[{"fileName":"testFile Name " , "fileContent":"Test File Content"}]');
        Test.stopTest();
        
        

    }

    @isTest
    public static void testMethod3(){

      
        buildertek__MSA_Settings__c msa = new buildertek__MSA_Settings__c();
        msa.Name = 'MSA Settings';
        msa.buildertek__Site_URL__c = 'https://test.com/';
        msa.buildertek__Send_MSA_Template_Name__c = 'MSA Settings';
        insert msa;

        Account acc = new Account();
        acc.Name = 'test';
        insert acc;

    
        buildertek__Pre_Qual__c pq = new buildertek__Pre_Qual__c();
        pq.buildertek__Account__c = acc.Id;
        pq.buildertek__MSA_Additional_Email__c='test@gmail.com';
        pq.buildertek__Qualification_Stage__c = 'MSA Sent';    
        pq.buildertek__Qualification_Date__c = system.now();

        insert pq;       
       
        Test.startTest();
        PreQualObjectQualificationController.sendEmail(pq.Id , null);
        Test.stopTest();

    }
    
}