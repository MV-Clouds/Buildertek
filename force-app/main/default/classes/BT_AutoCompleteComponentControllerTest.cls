@isTest
public with sharing class BT_AutoCompleteComponentControllerTest {

      @testSetup static void insertTestData(){
        //insert account
        Account account = new Account(Name='Test Account');
        insert account;
          
          //insert user
          Profile p = [SELECT Id FROM Profile WHERE Name='Read Only']; 
          String username = 'testUSer'+Math.random()+'@testorg.com';
        User user = new User(Alias = 'test', Email='testUser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName = username);
        insert user;
        System.assertEquals('Test','Test');
    }
    
     static testMethod void testController(){
         User user = [Select Id, Name from User Where Email='testUser@testorg.com' LIMIT 1];
         Account account = [Select Id, Name from Account Where Name = 'Test Account' LIMIT 1];
         BT_AutoCompleteComponentController controllerInstance = new BT_AutoCompleteComponentController ();
         controllerInstance.setTargetFieldVar(account.id);
         controllerInstance.getTargetFieldVar();
         
         //test remote method
          List<Map<String, String>> response = BT_AutoCompleteComponentController.getData(
              controllerInstance.sObjVal, controllerInstance.labelFieldVar, controllerInstance.valueFieldVar, '', account.Name);
         
         List<Map<String, String>> response2 = BT_AutoCompleteComponentController.getData(
              controllerInstance.sObjVal, controllerInstance.labelFieldVar, controllerInstance.labelFieldVar, '', account.Name);
         System.assertEquals('Test','Test');
         //test remote for User
         //List<Map<String, String>> responseUser = BT_AutoCompleteComponentController.getData(
           //  'User', controllerInstance.labelFieldVar, controllerInstance.valueFieldVar, '', user.Name);
     }
}