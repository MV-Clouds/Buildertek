@isTest
public class MSAFormControllerTest {
    public static testMethod void MSAForm(){
        List<buildertek__MSA_Settings__c> MSAList = new List<buildertek__MSA_Settings__c>();
        buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
        msaSettings.Name = 'MSA Settings';
        msaSettings.buildertek__City__c = 'TestCity';
        msaSettings.buildertek__Company_Full_Name__c = 'TestName';
        msaSettings.buildertek__MSA_Email__c = 'sagar@buildertek.com'; 
        msaSettings.buildertek__MSA_Sign_Contractor_Template_Name__c = 'MSA Sign Contractor Template';
        MSAList.add(msaSettings);
        insert MSAList;
        List<Account> accList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Sample Account 1';
        account1.Type = 'TestType';
        account1.NumberOfEmployees = 10;
        account1.buildertek__MSA_Additional_Email__c='test@gmail.com';
        account1.buildertek__Qualification_Stage__c = 'Email Received';
        accList.add(account1);
        insert accList;
        
        MSAFormController.getMSASettings(account1.id,'YES');
        
       
        
        ContentVersion contentVersion = new ContentVersion(
            Title = 'Penguins',
            PathOnClient = 'Penguins.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;    
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = account1.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        blob blobz= Blob.valueOf('Test Content');
        string content =  EncodingUtil.base64Encode(blobz);
        
        MSAFormController.saveSign(account1.Id,'content','Test','CompanySignature','content',true);
        MSAFormController.getJSonString('Sample',account1.Id,account1.Name,'YES','YES');
        //MSAFormController.setAttachmentBody('SampleJSON',account1.Type, msaSettings);
    }

}