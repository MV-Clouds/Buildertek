@isTest
public class QualifiedEmailControllerTestclass {
    @isTest public static void sendemailtest(){
        set<Id> Accountid=new set<id>();
        buildertek__MSA_Settings__c msasetting =new buildertek__MSA_Settings__c();
        msasetting.Name='MSA Settings';
        msasetting.buildertek__MSA_PDF_Template__c='buildertek__MSAFormPDF';
        msasetting.buildertek__MSA_Template__c='buildertek__MSASite';
        insert msasetting;
        
        buildertek__BT_ConfirmatioPageURL__c buldertekurl=new buildertek__BT_ConfirmatioPageURL__c();
        buldertekurl.buildertek__Public_Site_Url__c='https://builderteklightning-developer-edition.na75.force.com/';
        insert buldertekurl;
        
        Account accountrec=new Account();
        accountrec.name='testrecord';
        accountrec.buildertek__Email_Address__c='testsync@gmail.com';
        accountrec.buildertek__MSA_Additional_Email__c='testrec@gmail.com';
        insert accountrec;
        Accountid.add(accountrec.id);
        list<Account> Accountlist=new list<account>();
        Accountlist=[select id,Name,buildertek__MSA_Additional_Email__c from Account where Id=: accountrec.Id];
        
        QualifiedEmailController.sendEmail(Accountid);
        
    }
}