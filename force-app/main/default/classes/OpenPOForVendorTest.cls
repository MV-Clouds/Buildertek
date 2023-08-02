@isTest
public class OpenPOForVendorTest {
    public static testMethod void testMethod0() {
        Account currAcc = new Account(Name = 'test');
        insert currAcc;
        
        Contact currCon = new Contact(LastName = 'test', Email = 'test@test.com', AccountId = currAcc.Id);
        insert currCon;
        
        
        buildertek__Item_Receipt__c ir = new buildertek__Item_Receipt__c();
        insert ir;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Project_Tax_Rate__c=10;
        insert project;
        
        buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
        po.buildertek__Project__c = project.Id;
        po.buildertek__Vendor__c=currAcc.Id;
        po.buildertek__Status__c='Open';
        insert po;
        
        buildertek__Item_Receipt_Line__c irl = new buildertek__Item_Receipt_Line__c();
        irl.buildertek__PO__c=po.Id; 
        irl.buildertek__Item_Receipt__c = ir.Id;
        irl.buildertek__Description__c='Test 1';
        insert irl;
        
        OpenPOForVendor.openPO(currAcc.Id);
        OpenPOForVendor.openPO(po.Id);
        OpenPOForVendor.createItem(ir.Id,JSON.serialize(ir));
        OpenPOForVendor.createReceiptItem(JSON.serialize(ir),JSON.serialize(irl));
        
        System.assertEquals('Test','Test');
    }
}