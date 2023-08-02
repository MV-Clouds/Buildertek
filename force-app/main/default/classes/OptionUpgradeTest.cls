@isTest
public with sharing class OptionUpgradeTest {

    @TestSetup
    static void testData(){
        Account acc = new Account();
        acc.Name = 'Testing Account';
        insert acc;

        buildertek__Section__c section = new buildertek__Section__c();
        section.Name = 'Selection Category Testing';
        insert section;

        buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
        selectionType.Name = 'Selection Type Testing';
        selectionType.buildertek__Section__c = section.Id;
        insert selectionType;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Optoin Testing';
        option.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__Section__c = section.Id;
        option.buildertek__Upgrade_Costs__c = 35;
        option.buildertek__Quantity__c = 10;
        option.buildertek__Upgrade__c = true;
        option.buildertek__Manufacturer__c = acc.Id;
        insert option;

        buildertek__Product_Type__c prodType = new buildertek__Product_Type__c();
        prodType.Name = 'Product Type Testing';
        insert prodType;

        Product2 prod = new Product2();
        prod.Name = 'Testing Product';
        prod.buildertek__Manufacturer__c = acc.Id;
        prod.buildertek__Product_Type__c = prodType.Id;
        prod.Family = 'Framing';
        prod.buildertek__Selection_Category_Lookup__c = section.Id;
        insert prod;

        buildertek__Category__c category = new buildertek__Category__c();
        category.Name = 'testing category';
        insert category;
        
    }

    @isTest
    static void testMethod1(){
        buildertek__Question__c option = new buildertek__Question__c();
        option = [select id,Name,buildertek__Question_Group__c from buildertek__Question__c LIMIT 1];
        
        Product2 prod = new Product2();
        prod = [select Id,Name,buildertek__Manufacturer__c from Product2 LIMIT 1];

        Test.startTest();

        OptionUpgrade.getProductDetails(option.Id, 'a', 'b', 'c', 'd', 'e', 'f', true);
        OptionUpgrade.upgradeOption(option, prod);
        OptionUpgrade.getProductFamily('f');
        OptionUpgrade.getProductType('p');
        OptionUpgrade.getProductName('t');
        OptionUpgrade.getManufacturer('t');
        OptionUpgrade.getProductCategory('t');
        OptionUpgrade.getOptionRecord(option.Id);
        OptionUpgrade.cloneOptionRecord(option, option.Id);


		
        Test.stopTest();

    }

    @isTest
    static void testMethod2(){
        buildertek__Question__c option = new buildertek__Question__c();
        option = [select id,Name,buildertek__Question_Group__c from buildertek__Question__c LIMIT 1];

        Test.startTest();

        OptionUpgrade.getProductDetails(option.Id, 'a', 'b', 'c', 'd', 'e', 'f', false);
        OptionUpgrade.getProductDetails(option.Id, '', '', '', '', '' , '', true);
        OptionUpgrade.getProductFamily('');
        OptionUpgrade.getProductType('');
        OptionUpgrade.getProductName('');
        OptionUpgrade.getManufacturer('');
        OptionUpgrade.getProductCategory('');
		
        Test.stopTest();

    }
}