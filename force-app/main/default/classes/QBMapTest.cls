@isTest
public class QBMapTest {
    @isTest
    static void testMapAccountData() {
        Account testAccount = new Account(
            Name = 'Test Account',
            buildertek__QB_Id__c = 'QBO123',
            QBO_SyncToken__c = 'SyncToken123',
            Description = 'Test Description',
            ShippingCity = 'TestCity',
            ShippingStreet = 'TestStreet',
            ShippingState = 'TestState',
            ShippingPostalCode = '12345',
            ShippingLatitude = 37.7749,
            ShippingLongitude = -122.4194,
            ShippingCountry = 'TestCountry',
            buildertek__Email_Address__c = 'test@example.com',
            Fax = '123-456-7890',
            Phone = '987-654-3210',
            BillingCity = 'BillingCity',
            BillingStreet = 'BillingStreet',
            BillingState = 'BillingState',
            BillingPostalCode = '54321',
            BillingLatitude = 37.7749,
            BillingLongitude = -122.4194,
            BillingCountry = 'BillingCountry'
        );
        Insert testAccount;

        String result = QBMap.mapAccountData(testAccount, 1);

        System.assertNotEquals(null, result);
        System.assert(result.contains('Test Account'));
    }

    @isTest
    static void testmapTaxRateData(){
        buildertek__Billings__c testtax = new buildertek__Billings__c(
        );

        String result = QBMap.mapTaxRateData(testtax);

        System.assertNotEquals(null, result);
    }
    @isTest
    static void testMapInvoiceLineToBatch(){
        List<buildertek__Billable_Lines__c> linelist = new List<buildertek__Billable_Lines__c>();
        String result = QBMap.MapInvoiceLineToBatch(linelist);
        buildertek__Billable_Lines__c line1 = new buildertek__Billable_Lines__c(
            buildertek__Item_Name__c = 'service',
            buildertek__Quantity__c = 40.18,
            Unit_Price__c = 30
        );
        linelist.add(line1);

        String result1 = QBMap.MapInvoiceLineToBatch(linelist);

        System.assertNotEquals(null, result1);

    }

    @isTest
    public static void testmapInvoiceDataBatch(){
        Account testAccount = new Account(Name = 'Test Account');
        Insert testAccount;

        buildertek__Billings__c testBilling = new buildertek__Billings__c(
            Name = 'Test Billing',
            buildertek__QB_Id__c = 'QBO12345'
            );
        Insert testBilling;

        Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
        List<String> qbIdAndNameList = new List<String>{'1', 'Product A', '50.0'};
        lineIdsMap.put(testBilling.Id, qbIdAndNameList);

        // String result = QBMap.mapInvoiceDataBatch(testBilling, '123DFF', lineIdsMap, '12345679');
        String result;
        System.assertNotEquals(null, result, 'Result should not be null');
    }

    @isTest
    public static void testmapReceipt_PaymetData(){
        buildertek__Billings__c testBilling1 = new buildertek__Billings__c(
            Name = 'Test Billing2',
            buildertek__QB_Id__c = 'QBO12345'
            );
        Insert testBilling1;

        buildertek__Receipt__c testReceipt = new buildertek__Receipt__c(
            buildertek__Amount__c = 50.0,
            buildertek__Billing__c	= testBilling1.Id
        );
        Insert testReceipt;

        String invoiceQBID = '123'; // Replace with a valid invoice QuickBooks ID
        String customerId = '456'; // Replace with a valid customer ID

        String result = buildertek.QBMap.mapReceipt_PaymetData(testReceipt, customerId, invoiceQBID);

        System.assertNotEquals(null, result, 'Result should not be null');

    }

}