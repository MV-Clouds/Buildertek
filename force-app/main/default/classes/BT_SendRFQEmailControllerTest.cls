@isTest
public class BT_SendRFQEmailControllerTest {
    @testSetup
    static void setupMethod(){
        Contact con = new Contact();
        con.LastName = 'Test';
        con.Email = 'test@gmail.com';
        insert con;
        
        buildertek__RFQ__c	rfq = new buildertek__RFQ__c();
        rfq.Name='test';
        insert rfq;
        
        buildertek__Admin_Interface_Node_Configuration__c AINC = new buildertek__Admin_Interface_Node_Configuration__c();
        AINC.Name = 'RFQ Configuration';
        AINC.buildertek__Update_Price_Book__c = true;
        insert AINC;
        
        buildertek__RFQ_To_Vendor__c rfqToVendor = new buildertek__RFQ_To_Vendor__c();
        rfqToVendor.Name = 'Test 1';
        rfqToVendor.buildertek__Contact__c = con.Id;
        rfqToVendor.buildertek__RFQ__c = rfq.Id;
        rfqToVendor.buildertek__Status__c = 'Email Sent';
        insert rfqToVendor;
        
        rfqToVendor.buildertek__Status__c = 'Awarded';
        update rfqToVendor;
        
         rfqToVendor.buildertek__Status__c = 'Rejected';
        update rfqToVendor;
        
         rfqToVendor.buildertek__Status__c = 'Accepted';
        update rfqToVendor;
        
         rfqToVendor.buildertek__Status__c = 'Email Sent';
        update rfqToVendor;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__RFQ_To_Vendor__c> rfqToVendor = [Select Id
                                                          FROM buildertek__RFQ_To_Vendor__c
                                                          LIMIT 1];
        List<String> rfqToVendorId = new List<String>();
        rfqToVendorId.add(rfqToVendor[0].Id);
        BT_SendRFQEmailController.sendRFQEmail(rfqToVendorId);
        
    }
}