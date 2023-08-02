@isTest
public class MassUpdatePurchaseOrderLineItemTest{
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c();
        purchaseOrder.buildertek__Project__c = project.Id;
        insert purchaseOrder;
        
        buildertek__Purchase_Order_Item__c purchaseOrderItem = new buildertek__Purchase_Order_Item__c();
        purchaseOrderItem.buildertek__Purchase_Order__c = purchaseOrder.Id;
        insert purchaseOrderItem;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Project__c> project = [Select Id
                                                FROM buildertek__Project__c
                                                LIMIT 1];
        List<buildertek__Purchase_Order__c> purchaseOrder = [Select Id
                                                     FROM buildertek__Purchase_Order__c
                                                     LIMIT 1];
        List<buildertek__Purchase_Order_Item__c> purchaseOrderItem = [Select Id
                                                     FROM buildertek__Purchase_Order_Item__c
                                                     LIMIT 1];
        MassUpdatePurchaseOrderLineItem.getCount(purchaseOrder[0].Id);
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        fieldName.add('Name');
        MassUpdatePurchaseOrderLineItem.getFieldSet();
        MassUpdatePurchaseOrderLineItem.getRecords(purchaseOrder[0].Id, JSON.serialize(fieldName), 1, 10);
        MassUpdatePurchaseOrderLineItem.updateRecords(purchaseOrder[0].Id, JSON.serialize(purchaseOrderItem), JSON.serialize(fieldName), 1, 10);
        MassUpdatePurchaseOrderLineItem.deleteProject(purchaseOrderItem[0].Id, purchaseOrder[0].Id,JSON.serialize(fieldName), 1, 10);
        MassUpdatePurchaseOrderLineItem.getDropDown('buildertek__Asset_History__c','buildertek__Record_Type__c');
    }
}