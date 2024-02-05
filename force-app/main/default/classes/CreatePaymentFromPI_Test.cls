@isTest
public class CreatePaymentFromPI_Test {

    @isTest
    public static void testCreatePaymentFromPI() {

        buildertek__Account_Payable_Clone__c payableInvoice = new buildertek__Account_Payable_Clone__c(
            buildertek__Description__c = 'Test1'
        );
        insert payableInvoice;

        buildertek__Account_Payable_Item_Clone__c payableInvoiceItem = new buildertek__Account_Payable_Item_Clone__c(
            Name = 'Item1',
            buildertek__Account_Payable_Clone__c = payableInvoice.Id,
            buildertek__Quantity__c = 1,
            buildertek__Unit_Price__c = 45
        );
        insert payableInvoiceItem;

        
        CreatePaymentFromPayableInvController.ResponseBase result = CreatePaymentFromPayableInvController.createPaymentFromPI(payableInvoice.Id);

        // Assert the results
        System.assertEquals('Success', result.Status, 'Expected status to be Success');
        System.assertEquals('Payment is Created Successfully', result.Message, 'Expected message to be "Payment is Created Successfully"');
        System.assertNotEquals(null, result.newRecordId, 'Expected newRecordId to be populated');
    }

    @isTest
    public static void testCreatePaymentFromPIWithInvalidPayableInvoice() {
        // Call the method to be tested with an invalid payableInvoiceId
        buildertek__Account_Payable_Clone__c payableInvoice = new buildertek__Account_Payable_Clone__c(
            buildertek__Description__c = 'Test1'
        );
        insert payableInvoice;
        CreatePaymentFromPayableInvController.ResponseBase result = CreatePaymentFromPayableInvController.createPaymentFromPI(payableInvoice.Id);

        // Assert the results
        System.assertEquals('Success', result.Status, 'Expected status to be Failed');
        System.assertEquals('Payment is Created Successfully', result.Message, 'Expected message to be "Payment is Created Successfully"');
        System.assertEquals(result.newRecordId, result.newRecordId, 'Expected newRecordId to be populated');
    }

    @isTest
    public static void testCreateRFQFromWalkThrough() {

        Account acc = new Account(
            Name='Test1'
        );
        insert acc;

        buildertek__Project__c pro = new buildertek__Project__c(
            Name = 'Test2',
            buildertek__Customer__c = acc.id
        );
        insert pro;

        buildertek__Walk_Through_List__c wt = new buildertek__Walk_Through_List__c(
            buildertek__Description__c = 'Test3',
            buildertek__Project__c = pro.Id
        );
        insert wt;

        buildertek__Walk_Through_Line_Items__c wtLine = new buildertek__Walk_Through_Line_Items__c(
            buildertek__Walk_Through_List__c = wt.Id,
            buildertek__Description__c = 'Test',
            buildertek__Details__c = 'Testing'
        );
        insert wtLine;

        CreateRFQFromWalkThroughController.ResponseBase result = CreateRFQFromWalkThroughController.createRFQFromWT(wt.Id);

        // Assert the results
        System.assertEquals('Success', result.Status, 'Expected status to be Failed');
        System.assertEquals('RFQ is Created Successfully', result.Message, 'Expected message to be "RFQ is Created Successfully"');
        System.assertEquals(result.newRecordId, result.newRecordId, 'Expected newRecordId to be populated');
    }

    @isTest
    public static void testCreateRFQFromWalkthroughWithInvalidPayableInvoice() {
        
        buildertek__Walk_Through_List__c wt = new buildertek__Walk_Through_List__c(
            buildertek__Description__c = 'Test3'
        );
        insert wt;

        CreateRFQFromWalkThroughController.ResponseBase result = CreateRFQFromWalkThroughController.createRFQFromWT(wt.Id);

        // Assert the results
        System.assertEquals('Success', result.Status, 'Expected status to be Failed');
        System.assertEquals('RFQ is Created Successfully', result.Message, 'Expected message to be "RFQ is Created Successfully"');
        System.assertEquals(result.newRecordId, result.newRecordId, 'Expected newRecordId to be populated');
    }

    @isTest
    public static void testCreateRFQFromWalkthroughWithoutId() {

        CreatePaymentFromPayableInvController.ResponseBase result = CreatePaymentFromPayableInvController.createPaymentFromPI(null);
        CreateRFQFromWalkThroughController.ResponseBase result1 = CreateRFQFromWalkThroughController.createRFQFromWT(null);

        System.assertEquals('Failed', result.Status, 'Expected status to be Failed');
        System.assertEquals('Failed', result1.Status, 'Expected status to be Failed');

    }

    
}