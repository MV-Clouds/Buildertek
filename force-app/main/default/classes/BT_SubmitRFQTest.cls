@isTest(SeeAllData=false)
public with sharing class BT_SubmitRFQTest {
	@TestSetup
    static void testVendor(){

        Id pId = [select id from profile where name='Partner Community User'].id;
    
        Account acc = new Account() ;
        acc.name = 'Grazitti';
        insert acc; 
    
        Contact con = new Contact();
        con.LastName = 'testCon'; 
        con.AccountId = acc.Id;
        insert con;  
                
        User user = new User();
        user.alias = 'test123';
        user.email = 'test123@noemail.com';
        user.emailencodingkey = 'UTF-8';
        user.lastname = 'Testing';
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'en_US';
        user.profileid = pId;
        user.country = 'United States';
        user.IsActive = true;
        user.ContactId = con.Id;
        user.timezonesidkey = 'America/Los_Angeles';
        user.username = 'tester0@noemail.com';
        insert user;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.Name = 'Testing';
        insert rfq;          
        
        buildertek__RFQ_To_Vendor__c rfqV = new buildertek__RFQ_To_Vendor__c();
        rfqV.Name = 'Test Vendor';
        rfqV.buildertek__Contact__c = con.Id;
        rfqV.buildertek__Vendor__c = acc.Id;
        rfqV.buildertek__RFQ__c = rfq.Id;
        insert rfqV;       
        
    }

    @isTest
    static void testVendor2(){

        user usr = [SELECT Id, FirstName, LastName, Username, Email, ContactId, AccountId FROM User WHERE email =: 'test123@noemail.com'];
        
        System.runAs(usr) {
            buildertek__RFQ__c rfq = new buildertek__RFQ__c();
            rfq.Name = 'Testing';
            insert rfq;          
            
            buildertek__RFQ_To_Vendor__c rfqV = new buildertek__RFQ_To_Vendor__c();
            rfqV.Name = 'Test Vendor';
            rfqV.buildertek__Contact__c = usr.ContactId;
            rfqV.buildertek__Vendor__c = usr.AccountId;
            rfqV.buildertek__RFQ__c = rfq.Id;
            insert rfqV;

            buildertek__RFQ_Vendor_Item__c rfqVendor = new buildertek__RFQ_Vendor_Item__c();
            rfqVendor.buildertek__Vendor__c = rfqV.Id;
            insert rfqVendor;

            BT_SubmitRFQ.UpdateRFQ(rfqV.Id);
            BT_SubmitRFQ.getobjectName(rfqV.Id);
            BT_SubmitRFQ.getrfq(rfqV.Id);
            BT_SubmitRFQ.getRQToAccount(rfqV.Id);
            BT_SubmitRFQ.validateRFIs(rfqV.Id);
            BT_SubmitRFQ.checkduedate(rfqV.Id);
        }
       
    }
}