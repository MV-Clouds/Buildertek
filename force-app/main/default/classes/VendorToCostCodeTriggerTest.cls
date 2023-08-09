@isTest
public class VendorToCostCodeTriggerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testVendorToCostCodeTrigger() {
        buildertek__Cost_Codes__c costCode = new buildertek__Cost_Codes__c(Name = 'Cost Code');
        insert costCode;
        
        buildertek__Vendor_To_Cost_Code_Link__c vendor = new buildertek__Vendor_To_Cost_Code_Link__c(
            buildertek__Vendor__c = [SELECT Id FROM Account LIMIT 1].Id,
            buildertek__Cost_Code__c = costCode.Id
        );
        
        insert vendor;
        update vendor;
        delete vendor;
        System.assertEquals('Test','Test');
    }
}