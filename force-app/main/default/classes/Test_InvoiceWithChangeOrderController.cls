@isTest
public class Test_InvoiceWithChangeOrderController {
    
    public static testMethod void test1(){
        Account acc = new Account();
        acc.Name='test2';
        acc.buildertek__BT_Account_Type__c = 'Vendor';
        insert acc;
        
       
        buildertek__Project__c projectRec = new buildertek__Project__c();
        projectRec.Name = 'Test';
        projectRec.buildertek__Account__c = acc.Id;
        projectRec.buildertek__Address__c = '2705 NE';
        projectRec.buildertek__Zip__c =  '64014';
        projectRec.buildertek__Country__c = 'Unites States';
        projectRec.buildertek__State__c = 'MO';
        projectRec.buildertek__City__c = 'Blue Springs';
        projectRec.buildertek__Type__c = 'Master';
        insert projectRec;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Test';
        project.buildertek__Type__c = 'Master';
        project.buildertek__Master_Project__c = projectRec.id;
        insert project;
        
        Change_Order__c co = new Change_Order__c();
        co.Name = 'test2';
        co.Customer_Account__c=acc.id;
        co.buildertek__Status__c = 'Partially Paid';
        co.buildertek__Project__c = project.Id;
        // co.buildertek__CO_Number__c = 'test';
        // co.buildertek__Total_Amount__c = 1200;
        insert co;

        List<buildertek__Change_Order_Item__c> COLineItems = new List<buildertek__Change_Order_Item__c>();

        buildertek__Change_Order_Item__c COL1 = new buildertek__Change_Order_Item__c();
        COL1.buildertek__Change_Order__c = co.Id;
        COL1.buildertek__Vendor__c = acc.Id;
        COLineItems.add(COL1);

        buildertek__Change_Order_Item__c COL2 = new buildertek__Change_Order_Item__c();
        COL2.buildertek__Change_Order__c = co.Id;
        COL2.buildertek__Vendor__c = acc.Id;
        COLineItems.add(COL2);

        buildertek__Change_Order_Item__c COL3 = new buildertek__Change_Order_Item__c();
        COL3.buildertek__Change_Order__c = co.Id;
        COL3.buildertek__Vendor__c = acc.Id;
        COLineItems.add(COL3);

        insert COLineItems;
        
        buildertek__Billings__c billing = new buildertek__Billings__c();
        billing.Name='test2';
        billing.buildertek__Change_Order__c=co.id;
        billing.buildertek__Tax_Rate__c=2;
        billing.buildertek__Project__c=project.Id;
        insert billing;
        
        Billable_Lines__c billinglines= new Billable_Lines__c();
        billinglines.Billings__c=billing.id;
        billinglines.Quantity__c=2;
        billinglines.Unit_Price__c=10;
        insert billinglines;
        
        InvoiceWithChangeOrderController obj = new InvoiceWithChangeOrderController();
        obj.billingId = billing.Id;
        obj.getchangeOrder();
        obj.getbillingObj();
        
    }
}


// Class.buildertek.InvoiceWithChangeOrderController.getbillingObj: line 31, column 1
// Class.buildertek.Test_InvoiceWithChangeOrderController.test1: line 71, column 1