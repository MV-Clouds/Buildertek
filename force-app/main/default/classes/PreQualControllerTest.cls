@isTest
public class PreQualControllerTest {
    public static testMethod void PreQualForm(){
        List<buildertek__Admin_Interface_Node_Configuration__c> BDList = new List<buildertek__Admin_Interface_Node_Configuration__c>();
        buildertek__Admin_Interface_Node_Configuration__c BD = new buildertek__Admin_Interface_Node_Configuration__c();
        BD.buildertek__Selected_Templates__c = 'Pre Qualification Configuration';
        BDList.add(BD);
        insert BDList;
        
        buildertek__MSA_Settings__c Msasettings = new buildertek__MSA_Settings__c();
         Msasettings.Name = 'MSA setting';
        Msasettings.buildertek__Site_URL__c = 'Www.test.com';
        insert Msasettings;
        
        List<Account> accList = new List<Account>();
        Account account1 = new Account();
        account1.Name = 'Sample Account 1';
        account1.NumberOfEmployees = 10;
        account1.buildertek__Qualification_Stage__c = 'Email Received'; 
        account1.buildertek__MSA_Additional_Email__c = 'sagar@buildertek.com';
        account1.buildertek__Email_Address__c = 'sagar@buildertek.com';
        accList.add(account1);
        insert accList;
        List<Contact> ConList = new List<Contact>();
        Contact contact1 = new Contact();
        contact1.AccountId = account1.Id;
        contact1.LastName = 'LastName1';
        contact1.email='sagar@buildertek.com';
        contact1.buildertek__Primary_Contact__c = true; 
        ConList.add(contact1);
        insert ConList;
        
        buildertek__BT_ConfirmatioPageURL__c BT = new buildertek__BT_ConfirmatioPageURL__c();
        BT.buildertek__Public_Site_Url__c = 'TestUrl';
        insert BT;
        
        List<String> StringTo = new List<String>();
        StringTo.add('sagar@buildertek.com');
        
        List<String> StringCC = new List<String>();
        StringCC.add('Test@gmail.com');
        
        List<String> StringemailIds = new List<String>();
        StringemailIds.add('Test@gmail.com');
        StringemailIds.add('Test01@gmail.com');
        
        PreQualController.getPrimaryContacts(account1.Id);
     //   PreQualController.sendEmailToVendor(account1.Id,account1.buildertek__Email_Address__c,StringTo,StringCC,StringemailIds,'');
      //  PreQualController.getTemplates(); 
        
    }

}