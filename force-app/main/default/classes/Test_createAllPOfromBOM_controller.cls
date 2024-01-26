@isTest
public class Test_createAllPOfromBOM_controller {

    public static buildertek__Project_Selection_Sheet_Takeoff__c createBOM(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = new buildertek__Project_Selection_Sheet_Takeoff__c(
            buildertek__Status__c = 'Open',
            buildertek__Name__c = 'test BOM 1'
        );
        insert BOM;
        return BOM;
    }
    public static Account createVendor(){
        Account vendor = new Account(
            Name = 'test vendor 1',
            buildertek__BT_Account_Type__c = 'Vendor'
        );
        insert vendor; 
        return vendor;
    }

    public static buildertek__Purchase_Order__c createPO(String vendorId){
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c(
            buildertek__Vendor__c = vendorId
        );
        insert PO;
        return PO;
    }

    @isTest
    public static void test1(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = createBOM();
        Account vendor = createVendor();
        buildertek__Purchase_Order__c PO = createPO(vendor.Id);

        buildertek__Select_Sheet__c BOMline1 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id
        );
        insert BOMline1;
        buildertek__Select_Sheet__c BOMline2 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id,
            buildertek__Vendor__c = vendor.Id
        );
        insert BOMline2;
        buildertek__Select_Sheet__c BOMline3 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id,
            buildertek__Vendor__c = vendor.Id,
            buildertek__Purchase_Order__c = PO.Id
        );
        insert BOMline3;
        buildertek__Select_Sheet__c BOMline4 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id
        );
        insert BOMline4;

        Test.startTest();
        createAllPOfromBOM_controller.createAllPO(BOM.Id);
        Test.stopTest();
    }
    @isTest
    public static void test_BOMWithoutLines(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = createBOM();

        Test.startTest();
        createAllPOfromBOM_controller.createAllPO(BOM.Id);
        Test.stopTest();
    }
    @isTest
    public static void test_ZeroVendorCondtion(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = createBOM();

        buildertek__Select_Sheet__c BOMline1 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id
        );
        insert BOMline1;

        Test.startTest();
        createAllPOfromBOM_controller.createAllPO(BOM.Id);
        Test.stopTest();
    }

    @isTest
    public static void test_ExceptionCondition(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = createBOM();
        Account vendor = createVendor();
        buildertek__Purchase_Order__c PO = createPO(vendor.Id);

        buildertek__Select_Sheet__c BOMline1 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id
        );
        insert BOMline1;

        Test.startTest();
        createAllPOfromBOM_controller.createAllPO(null);
        Test.stopTest();
    }

    @isTest
    public static void test_POAssigedToAllLinesCondition(){
        buildertek__Project_Selection_Sheet_Takeoff__c BOM = createBOM();
        Account vendor = createVendor();
        buildertek__Purchase_Order__c PO = createPO(vendor.Id);

        buildertek__Select_Sheet__c BOMline1 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id,
            buildertek__Purchase_Order__c = PO.Id,
            buildertek__Vendor__c = vendor.Id

        );
        insert BOMline1;

        buildertek__Select_Sheet__c BOMline2 = new buildertek__Select_Sheet__c(
            Name = 'test 1',
            buildertek__Selection_Sheet_Takeoff__c = BOM.Id
        );
        insert BOMline2;

        Test.startTest();
        createAllPOfromBOM_controller.createAllPO(BOM.Id);
        Test.stopTest();
    }

}