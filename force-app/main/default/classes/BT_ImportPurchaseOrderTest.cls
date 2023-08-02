@isTest
public with sharing class BT_ImportPurchaseOrderTest {
    @IsTest
    static void testMethod1(){

        List<Account> accList = new List<Account>();

        Account a = new Account();
        a.Name = 'test';
        accList.add(a);
        
        Account a2 = new Account();
        a2.Name = 'test2';
        accList.add(a2);
        insert accList;

        Contact c = new Contact();
        c.LastName = 'Mike';
        insert c;

        List<buildertek__Project__c> prod = new List<buildertek__Project__c>();

        Product2 pr = new Product2();
        pr.Name = 'Product';
        insert pr;

        buildertek__Inventory_Management__c im = new 	buildertek__Inventory_Management__c();
        im.buildertek__Product_Name__c = pr.Id;
        insert im;

        buildertek__Project__c prodObj1 = new buildertek__Project__c();
        prodObj1.Name = 'test';
        prod.add(prodObj1);
        
        buildertek__Project__c prodObj2 = new buildertek__Project__c();
        prodObj2.Name = 'test1';
        prod.add(prodObj2);
        insert prod;


        buildertek__Service_Request__c sr = new buildertek__Service_Request__c();
        sr.buildertek__City__c = 'Surat';
        sr.buildertek__Subject__c = 'Testing';
        sr.buildertek__Customer_Name__c = c.Id;
        insert sr;

        List<buildertek__Product__c> productList = new List<buildertek__Product__c>();
        buildertek__Product__c product1 = new buildertek__Product__c();
        product1.buildertek__Product_Name__c = 'none2';
        product1.buildertek__Product__c = im.Id;
        product1.buildertek__Service_Request__c = sr.Id;
        insert product1;
        
        buildertek__Product__c product2 = new buildertek__Product__c();
        product2.buildertek__Product_Name__c = 'none3';
        product2.buildertek__Product__c = im.Id;
        product2.buildertek__Service_Request__c = sr.Id;
        insert product2;

        String json=		'['+
		'  {'+
		'    "Description": "test",'+
		'    "Project": "test",'+
		'    "RequiredDeliveryDate": "2012-04-23",'+
		'    "Vendor": "test",'+
		'    "Status": "done",'+
		'    "PODescription": "dummy",'+
		'    "Discount": "30",'+
		'    "Product": "none2",'+
		'    "PurchaseOrder": "blank",'+
		'    "Quantity": "2",'+
		'    "Received": "2",'+
		'    "UnitCost": "100",'+
		'    "UOM": "fsdf"'+
		'  },'+
		'  {'+
		'    "Description": "test1",'+
		'    "Project": "test1",'+
		'    "RequiredDeliveryDate": "2012-04-23",'+
		'    "Vendor": "test2",'+
		'    "Status": "done",'+
		'    "PODescription": "dummy2",'+
		'    "Discount": "20",'+
		'    "Product": "none3",'+
		'    "PurchaseOrder": "blank",'+
		'    "Quantity": "1",'+
		'    "Received": "1",'+
		'    "UnitCost": "200",'+
		'    "UOM": "fsdf"'+
		'  }'+
		']';

        Test.startTest();
            BT_ImportPurchaseOrder.insertData(json);
        Test.stopTest();
        
    }
}