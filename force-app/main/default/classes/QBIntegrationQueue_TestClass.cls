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
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for sales Invoice customer account is empty than use project's customer account as account reference
    @isTest
    public static void QBcallouts_Test1(){

        
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for if account qb id is null than create acc in qb first
    @isTest
    public static void QBcallouts_Test2(){

        Account acc = new Account(
            Name = 'QB Test Acc',
              buildertek__QB_Id__c = null,
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
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for  if SI.buildertek__Tax_Rate__c != null && (SI.buildertek__QBO_Tax_Rate_ID__c == null || SI.buildertek__Tax_Rate__c != SI.buildertek__QBO_Tax_Rate__c)
    @isTest
    public static void QBcallouts_Test3(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String JSONBody = 'body:{ }';
        String encodedQueryParam = EncodingUtil.urlEncode('Select * From TaxCode Where Name = \''+'Tax - 15.0000' + '\'', 'UTF-8');
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 

        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
        inv.buildertek__QBO_Tax_Rate__c = 16;
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
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,false);
        QBMockTest fakeResponse = new QBMockTest(200,'{"QueryResponse": {"TaxCode": [{"Name": "Tax - 15.00", "Description": "Tax - 15.00", "Active": true, "Hidden": false, "Taxable": true, "TaxGroup": true, "SalesTaxRateList": {"TaxRateDetail": [{"TaxRateRef": {"value": "42", "name": "Tax - 15.00"}, "TaxTypeApplicable": "TaxOnAmount", "TaxOrder": 0}]}, "PurchaseTaxRateList": {"TaxRateDetail": []}, "TaxCodeConfigType": "USER_DEFINED", "domain": "QBO", "sparse": false, "Id": "34", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-22T21:57:34-08:00", "LastUpdatedTime": "2023-11-22T21:57:34-08:00"}}], "startPosition": 1, "maxResults": 1, "totalCount": 1}, "time": "2023-11-27T05:02:00.121-08:00"}' );
		Test.setMock(HttpCalloutMock.class, fakeResponse);
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    @isTest
    public static void QBcallouts_Test30(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String JSONBody = 'body:{ }';
        String encodedQueryParam = EncodingUtil.urlEncode('Select * From TaxCode Where Name = \''+'Tax - 15.0000' + '\'', 'UTF-8');
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 

        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
        inv.buildertek__QBO_Tax_Rate__c = 16;
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
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,false);
        QBMockTest fakeResponse = new QBMockTest(200,'{"QueryResponse": {}, "time": "2023-11-28T04:18:08.627-08:00"}' );
		Test.setMock(HttpCalloutMock.class, fakeResponse);
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    @isTest
    public static void QBcallouts_Test31(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String JSONBody = 'body:{ }';
        String encodedQueryParam = EncodingUtil.urlEncode('Select * From TaxCode Where Name = \''+'Tax - 15.0000' + '\'', 'UTF-8');
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 
        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
        inv.buildertek__QBO_Tax_Rate__c = 16;
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
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,false);
        QBMockTest fakeResponse = new QBMockTest(401,'{"responseHeader": {"status": 401, "message": "ERROR", "intuitTid": "1-65648031-0f00000a00a0efc5000000e0", "realmID": "1111111111111111111"}}');
		Test.setMock(HttpCalloutMock.class, fakeResponse);
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method foe sales Invoice tax rate is null
    @isTest
    public static void QBcallouts_Test4(){

        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // test method for sales invoice tax rate not null and has tax rate in qb and sf and qb tax rate are same on invoice
    @isTest
    public static void QBcallouts_Test5(){

        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
       QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        Test.stopTest();
    }
    // sales invoice without salesinvoice lines
    @isTest
    public static void QBcallouts_Test6(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            
        String JSONBody = 'body:{ }';

        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = null,
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
        inv.buildertek__QB_Id__c = null;

        insert inv;


        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;

        Test.startTest();
        QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,false);
        QBMockTest fakeResponse = new QBMockTest(200,'{"Customer": {"Taxable": true, "BillAddr": {"Id": "395", "Line1": "Line1", "City": "BillingCity", "Country": "BillingCountry", "CountrySubDivisionCode": "CA", "PostalCode": "54321"}, "ShipAddr": {"Id": "396", "Line1": "Line1", "City": "TestCity", "Country": "TestCountry", "CountrySubDivisionCode": "CA", "PostalCode": "12345"}, "Job": false, "BillWithParent": false, "Balance": 0, "BalanceWithJobs": 0, "CurrencyRef": {"value": "USD", "name": "United States Dollar"}, "PreferredDeliveryMethod": "Print", "IsProject": false, "domain": "QBO", "sparse": false, "Id": "178", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-27T02:04:21-08:00", "LastUpdatedTime": "2023-11-27T02:04:21-08:00"}, "FullyQualifiedName": "QB Test Acc", "DisplayName": "QB Test Acc", "PrintOnCheckName": "QB Test Accdf", "Active": true, "PrimaryPhone": {"FreeFormNumber": "(987) 654-3210"}, "PrimaryEmailAddr": {"Address": "test@example.com"}, "DefaultTaxCodeRef": {"value": "7"}}, "time": "2023-11-27T02:04:21.172-08:00"}' );
		Test.setMock(HttpCalloutMock.class, fakeResponse);
        Test.stopTest();
    }
    @isTest
    public static void QBcallouts_Test7(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            
        String JSONBody = 'body:{ }';            
        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = null,
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
        inv.buildertek__QB_Id__c = null;

        insert inv;


        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;

        Test.startTest();
        QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,false);
        QBMockTest fakeResponse1 = new QBMockTest(401,'{"responseHeader": {"status": 401, "message": "ERROR", "intuitTid": "1-65648031-0f00000a00a0efc5000000e0", "realmID": "1111111111111111111"}}');
		Test.setMock(HttpCalloutMock.class, fakeResponse1);
        Test.stopTest();
    }
    @isTest
    public static void QBcallouts_Test8(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
        String JSONBody = 'body:{ }';            
        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
        inv.buildertek__Tax_Rate__c = null;
        inv.buildertek__QB_Id__c = null;

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
        QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,true);
        QBMockTest fakeResponse1 = new QBMockTest(200,'{"BatchItemResponse": [{"Item": {"Name": "QB Test Line 1", "Active": true, "FullyQualifiedName": "QB Test Line 1", "Taxable": true, "UnitPrice": 100, "Type": "Inventory", "IncomeAccountRef": {"value": "79", "name": "Sales of Product Income"}, "PurchaseCost": 0, "ExpenseAccountRef": {"value": "80", "name": "Cost of Goods Sold"}, "AssetAccountRef": {"value": "100", "name": "Test acc"}, "TrackQtyOnHand": true, "QtyOnHand": 1, "InvStartDate": "2023-11-28", "DeferredRevenue": false, "domain": "QBO", "sparse": false, "Id": "417", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-28T04:51:46-08:00", "LastUpdatedTime": "2023-11-28T04:51:46-08:00"}}, "bId": "a0u1K00000gwjZDQAY"}], "time": "2023-11-28T04:51:46.058-08:00"}');
		Test.setMock(HttpCalloutMock.class, fakeResponse1);
        Test.stopTest();
    }
    @isTest
    public static void QBcallouts_Test9(){

        buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__Qb_URL__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
        String QBEndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
        String JSONBody = 'body:{ }';            
        // account rec for buildertek__QB_Id__c != null
        Account acc = new Account(
            Name = 'QB Test Acc',
            buildertek__QB_Id__c = '1',
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
        inv.buildertek__Tax_Rate__c = null;
        inv.buildertek__QB_Id__c = null;

        insert inv;

        List<buildertek__Billable_Lines__c> SILines = new List<buildertek__Billable_Lines__c>();
        buildertek__Billable_Lines__c item1 = new buildertek__Billable_Lines__c();
        item1.buildertek__Item_Name__c = 'QB Test Line 1';
        item1.buildertek__Billings__c = inv.Id;
        item1.buildertek__Unit_Price__c = 100;
        item1.buildertek__Quantity__c = 1;
        item1.buildertek__QB_Id__c = '1';
        SILines.add(item1);

        insert SILines;


        buildertek__Receipt__c receipt = new buildertek__Receipt__c();
        receipt.buildertek__Amount__c = inv.buildertek__Total_Amount_Tax__c;
        receipt.buildertek__Billing__c = inv.Id;

        insert receipt;

        Test.startTest();
        QBIntegrationQueue.QB_Payment_Invoice_Flow_Callout(inv.Id, receipt.Id, true);
        HttpResponse res = QBCallOutService.QBAPICallOut(QBEndPoint,JSONBody,true);
        QBMockTest fakeResponse1 = new QBMockTest(200,'{"BatchItemResponse": [{"Item": {"Name": "QB Test Line 1", "Active": true, "FullyQualifiedName": "QB Test Line 1", "Taxable": true, "UnitPrice": 100, "Type": "Inventory", "IncomeAccountRef": {"value": "79", "name": "Sales of Product Income"}, "PurchaseCost": 0, "ExpenseAccountRef": {"value": "80", "name": "Cost of Goods Sold"}, "AssetAccountRef": {"value": "100", "name": "Test acc"}, "TrackQtyOnHand": true, "QtyOnHand": 1, "InvStartDate": "2023-11-28", "DeferredRevenue": false, "domain": "QBO", "sparse": false, "Id": "417", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-28T04:51:46-08:00", "LastUpdatedTime": "2023-11-28T04:51:46-08:00"}}, "bId": "a0u1K00000gwjZDQAY"}], "time": "2023-11-28T04:51:46.058-08:00"}');
		Test.setMock(HttpCalloutMock.class, fakeResponse1);
        Test.stopTest();
    }
}