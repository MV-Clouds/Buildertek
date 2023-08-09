@isTest
public class RFQToAccountClass_TC {
    
    static testMethod void test(){
    buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
RFIsetting.Name='RFI Settings';
RFIsetting.buildertek__Using_Communities__c = true;
RFIsetting.buildertek__Using_Email__c = true;
RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
RFIsetting.buildertek__Queue_Name__c = 'RFI';
insert RFIsetting;

        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User usr = new User();
        usr.Username = 'hulk@asf.com';
        usr.Alias = 'john';
        usr.Email = 'mani@gmail.com';
        usr.LastName = 'mani';
        usr.LocaleSidKey = 'en_US';
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.LanguageLocaleKey = 'en_US';
        usr.ProfileId = profileId.id;
        insert usr;
        
        buildertek__Project__c pro = new buildertek__Project__c();
        pro.Name = 'test6';
        //prorec.add(pro);
        insert pro;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = pro.id;
        rfq.Name = 'test8';
        insert rfq;
        
        Account acc=new Account();
        acc.Name='test';
        insert acc;
        
        Contact con = new Contact();
        con.Email = 'test@gmail.com';
        con.LastName = 'test4';
        insert con;
        
        buildertek__RFQ_To_Vendor__c rfqtovendor=new buildertek__RFQ_To_Vendor__c();
        rfqtovendor.Name='Test';
        rfqtovendor.buildertek__Vendor__c=acc.Id;
        rfqtovendor.buildertek__Accepted_Date__c=system.today();
        rfqtovendor.buildertek__Awarded_Date__c=system.today();
       // rfqtovendor.buildertek__Contact__c=con.Id;
        rfqtovendor.buildertek__Notes__c='Testing';
        rfqtovendor.buildertek__Submitted_Date__c=system.today();
        rfqtovendor.buildertek__Status__c='New';
        rfqtovendor.buildertek__RFQ__c=rfq.Id;
        
        insert rfqtovendor;
        
        buildertek__RFI__c rfi=new buildertek__RFI__c();
        rfi.buildertek__Subject__c='Test';
        rfi.buildertek__Due_Date__c=system.today();
        rfi.buildertek__Question__c='test';
        rfi.buildertek__RFI_Assigned_To__c=usr.Id;
        rfi.buildertek__Last_Responded_By__c=usr.Id;
        rfi.buildertek__Last_Responded_Date__c=system.today();
        rfi.buildertek__RFQ_To_Vendor__c=rfqtovendor.Id;
        rfi.buildertek__Assigned_To__c=con.Id;
        insert rfi;
        RFQToAccountClass.getRFIRecord(rfi.Id);
        RFQToAccountClass.getRFQRecord(rfqtovendor.Id);
        RFQToAccountClass.getquoterecord(rfqtovendor.Id);
    }
}