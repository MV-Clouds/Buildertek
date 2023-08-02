@isTest
public class Standard_PreQualFormController_TC {

    public static testMethod void PreQualForm(){
        Test.starttest();
        List<Account> accList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Sample Account 1';
        account1.NumberOfEmployees = 10;
        account1.buildertek__Qualification_Stage__c = 'Email Received';
        accList.add(account1);
        insert accList;
        
         buildertek__References__c bcref = new buildertek__References__c();
         insert bcref;
         
         buildertek__Past_Project__c pp = new buildertek__Past_Project__c();
         insert pp;
        
        
         buildertek__MSA_Settings__c Msasettings = new buildertek__MSA_Settings__c();
         Msasettings.Name = 'MSA setting';
        Msasettings.buildertek__Site_URL__c = 'Www.test.com';
        insert Msasettings;
        
        buildertek__Folder__c folderList = new buildertek__Folder__c();
         folderList.Name = 'TestMae' ;
        folderList.buildertek__Default__c = true;
        folderList.buildertek__Active__c = true;
        insert folderList;
        
        
        Standard_PreQualFormController.getAccountRecord(account1.Id);
        blob blobz= Blob.valueOf('Test Content');
        string content =  EncodingUtil.base64Encode(blobz);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
       
       // PreQualFormController.createPreQual('[{"fileName": "TestName","fileContent":"'+content+'","parentId":"'+account1.Id+'","fileType":"Test.pdf","fileSize":200}]','{"AccessToken":"x3nbZQcPwhBNWSsCtEir6YaC5CIiLGiM","client_secret":"XA9Eskirfnlqy1cMCegM52docJdODIYV","clientid":"tbuhd7qwlvkob08sp3yjpphlgwnpd754","EnterpriceId":"841079817","ViewAPI_Key":"3WatdV5wN6sKmHWNJltkOCSLkUwfasO8"}',account1.Id,account1);
        PreQualtest(content,account1.Id,bcref.Id,pp.Id);
        Test.stoptest();
    }
     @future(callout=true)
     public static void PreQualtest(string content,Id account1,Id refId,Id projId){
     Account acc = new Account();
     acc.id = account1;
        
         List<buildertek__Past_Project__c> pp = [select id from buildertek__Past_Project__c where id=:projId];
         List<buildertek__References__c> bcref = [select id from buildertek__References__c where id=:refId];
               Standard_PreQualFormController.dummy();

         
        // PreQualFormController.createPreQual('[{"fileName": "TestName","fileContent":"'+content+'","parentId":"'+account1+'","fileType":"Test.pdf","fileSize":200}]','{"AccessToken":"x3nbZQcPwhBNWSsCtEir6YaC5CIiLGiM","client_secret":"XA9Eskirfnlqy1cMCegM52docJdODIYV","clientid":"tbuhd7qwlvkob08sp3yjpphlgwnpd754","EnterpriceId":"841079817","ViewAPI_Key":"3WatdV5wN6sKmHWNJltkOCSLkUwfasO8"}',account1,acc);

        Standard_PreQualFormController.createPreQual('{"AccessToken":"x3nbZQcPwhBNWSsCtEir6YaC5CIiLGiM","client_secret":"XA9Eskirfnlqy1cMCegM52docJdODIYV","clientid":"tbuhd7qwlvkob08sp3yjpphlgwnpd754","EnterpriceId":"841079817","ViewAPI_Key":"3WatdV5wN6sKmHWNJltkOCSLkUwfasO8"}',acc.id,acc,'{"Id":"'+bcref[0].id+'"}','{"Id":"'+bcref[0].id+'"}','{"Id":"'+bcref[0].id+'"}','{"Id":"'+pp[0].id+'"}','{"Id":"'+pp[0].id+'"}','{"Id":"'+pp[0].id+'"}');
    }
}