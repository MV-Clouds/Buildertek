@IsTest
public with sharing class BOMLineSettingsControllerTest {
    @IsTest
    static void testMethod1(){

        buildertek__BOM_Line_Setting__c bomLs = new buildertek__BOM_Line_Setting__c();
        bomLs.Name = 'BOM Test';
        bomLs.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Pricebook_Name__c","label":"Pricebook Name"},{"value":"buildertek__BL_LIST_PRICE__c","label":"List Price"},{"value":"buildertek__Tax__c","label":"Tax"}]';
        bomLs.buildertek__BOM_Line_Filter_Fields__c = '[{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Product_Type__c","label":"Product Type"}]';

        insert bomLs;

        Test.startTest();
            BOMLineSettingsController.getDefaultSettings();
            BOMLineSettingsController.saveBOMSetting('field1','field2');
        Test.stopTest();

    }
}