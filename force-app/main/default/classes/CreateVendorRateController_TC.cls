@isTest
public class CreateVendorRateController_TC {
     static testMethod void test(){
         Account acc=new Account();
        acc.Name='test';
        insert acc;
 Profile profileId = [SELECT Id,Name FROM Profile WHERE Name = 'Standard User' LIMIT 1];
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
         
         //usr.AccountId=acc.Id;
        // usr.portalCode=true;
        insert usr;
        buildertek__Project__c pro = new buildertek__Project__c();
        pro.Name = 'test6';
        //prorec.add(pro);
        insert pro;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = pro.id;
        rfq.Name = 'test8';
        insert rfq;
        
        
        
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
         rfqtovendor.buildertek__Rating__c='2';
        
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
         
         
         CreateVendorRateController.getVendorAccountId();
         CreateVendorRateController.getDropDown('buildertek__RFQ_To_Vendor__c', 'buildertek__Vendor__c');
         CreateVendorRateController.getFieldSet('buildertek__RFQ_To_Vendor__c', 'BT Related List View Fields');
         CreateVendorRateController.getobjectName(rfqtovendor.Id);
         CreateVendorRateController.getParentObjRec(rfi.Id);
        // CreateVendorRateController.CreateVendorRateController();
     }
     
}