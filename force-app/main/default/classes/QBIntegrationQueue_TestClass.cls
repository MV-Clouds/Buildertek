@isTest
public without sharing class QBIntegrationQueue_TestClass {

    @isTest
    public static void QBcallouts_Test(){

        Account acc = new Account(
            Name = 'QB Test Acc',
            Description = 'QB Test Description',
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
        insert acc;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = acc.Id;
        inv.buildertek__Tax_Rate__c = 15;
        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for sales Invoice customer account is empty than use project's customer account as account reference
    @isTest
    public static void QBcallouts_Test1(){

        
        Account acc = new Account(
            Name = 'QB Test Acc',
            QBO_ID__c = '1',
            Description = 'QB Test Description',
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
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'QB Test Project';
        project.buildertek__Customer__c = acc.Id;
        project.buildertek__Project_Tax_Rate__c = null;
        insert project;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = null;
        inv.buildertek__Tax_Rate__c = 15;
        inv.buildertek__Project__c = project.Id;
        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for if account qb id is null than create acc in qb first
    @isTest
    public static void QBcallouts_Test2(){

        Account acc = new Account(
            Name = 'QB Test Acc',
              QBO_ID__c = null,
            Description = 'QB Test Description',
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
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'QB Test Project';
        project.buildertek__Customer__c = acc.Id;
        project.buildertek__Project_Tax_Rate__c = null;
        insert project;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = null;
        inv.buildertek__Tax_Rate__c = 15;
        inv.buildertek__Project__c = project.Id;
        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for  if SI.buildertek__Tax_Rate__c != null && (SI.buildertek__QBO_Tax_Rate_ID__c == null || SI.buildertek__Tax_Rate__c != SI.buildertek__QBO_Tax_Rate__c)
    @isTest
    public static void QBcallouts_Test3(){

        // account rec for buildertek__QBO_ID__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            QBO_ID__c = '1',
            Description = 'QB Test Description',
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
        insert acc;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = acc.Id;
        inv.buildertek__Tax_Rate__c = 15;
        inv.buildertek__QBO_Tax_Rate_ID__c = null;
        inv.buildertek__QBO_Tax_Rate__c = 15;
        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method foe sales Invoice tax rate is null
    @isTest
    public static void QBcallouts_Test4(){

        // account rec for buildertek__QBO_ID__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            QBO_ID__c = '1',
            Description = 'QB Test Description',
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
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'QB Test Project';
        project.buildertek__Customer__c = acc.Id;
        project.buildertek__Project_Tax_Rate__c = null;
        insert project;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = acc.Id;
        inv.buildertek__Project__c = project.Id;
        inv.buildertek__Tax_Rate__c = null;

        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for sales invoice tax rate not null and has tax rate in qb and sf and qb tax rate are same on invoice
    @isTest
    public static void QBcallouts_Test5(){

        // account rec for buildertek__QBO_ID__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            QBO_ID__c = '1',
            Description = 'QB Test Description',
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
        insert acc;

        // Invoice record without null taxRate
        buildertek__Billings__c inv = new buildertek__Billings__c();
        inv.Name = 'QB Test Invoice';
        inv.buildertek__Customer_Account__c = acc.Id;
        inv.buildertek__Tax_Rate__c = 15;
        inv.buildertek__QBO_Tax_Rate_ID__c = '1';
        inv.buildertek__QBO_Tax_Rate__c = 15;

        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        SILines.add(item1);

        insert SILines;

        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;


        Test.startTest();
       QBIntegrationQueue.QBcallouts(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
}