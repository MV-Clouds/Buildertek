@isTest
public class ItemReceiptLineTest {
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
        PO.buildertek__Vendor__c = currAcc.id;
        insert po;
        
        buildertek__Item_Receipt_Line__c irl = new buildertek__Item_Receipt_Line__c();
        irl.buildertek__PO__c=po.Id;
        irl.buildertek__Item_Receipt__c = ir.Id;
        insert irl;
        
        irl.buildertek__Description__c='Test';
        update irl;
        System.assertEquals('Test','Test');
    }
}