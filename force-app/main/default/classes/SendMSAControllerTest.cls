@isTest
public class SendMSAControllerTest {
      public static testMethod void MSAForm(){
      List<Account> accList = new List<Account>();
       Account account1 = new Account();
        account1.Name = 'Sample Account 1';
        account1.Type = 'TestType';
        account1.NumberOfEmployees = 10;
        account1.buildertek__MSA_Additional_Email__c ='test@gmail.com';
        account1.buildertek__Qualification_Stage__c = 'Email Received';
        accList.add(account1);
        insert accList;
        
        List<buildertek__MSA_Settings__c> MSAList = new List<buildertek__MSA_Settings__c>();
        buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
        msaSettings.Name = 'MSA Settings';
        msaSettings.buildertek__City__c = 'TestCity';
        msaSettings.buildertek__Company_Full_Name__c = 'TestName';
        msaSettings.buildertek__MSA_Email__c = 'sagar@buildertek.com'; 
        msaSettings.buildertek__MSA_Sign_Contractor_Template_Name__c = 'MSA Sign Contractor Template';
        msaSettings.buildertek__Send_MSA_Template_Name__c = 'Send MSA Template';
        MSAList.add(msaSettings);
        insert MSAList;
        
        SendMSAController.getCurrentStage(account1.id);
        SendMSAController.sendEmail(account1.id);
   }
}