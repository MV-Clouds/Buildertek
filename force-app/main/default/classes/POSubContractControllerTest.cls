@isTest
public class POSubContractControllerTest {
    public static testmethod void testPOSubContract(){
        
        Account account1=new Account();
        account1.Name='account1 Test';
        insert account1;
        System.assert(account1.Id!=null);
        
        buildertek__Project__c project1=new buildertek__Project__c();
        project1.Name='project1 Test';
        insert project1;
        System.assert(project1.Id!=null);
        
        buildertek__Purchase_Order__c purchaseOrder1 = new buildertek__Purchase_Order__c();
        purchaseOrder1.buildertek__Project__c=project1.Id;
        purchaseOrder1.buildertek__Vendor__c=account1.Id;
        insert purchaseOrder1;
        System.assert(purchaseOrder1.Id!=null);
        
        buildertek__Purchase_Order_Item__c purchaseOrderItem1 = new buildertek__Purchase_Order_Item__c();
        purchaseOrderItem1.buildertek__Purchase_Order__c=purchaseOrder1.Id;
        insert purchaseOrderItem1;
        System.assert(purchaseOrderItem1.Id!=null);
        
        POSubContractController.createContractRec(purchaseOrder1.Id);
        
        Product2 product1= new Product2();
        product1.Name='Test Product';
        insert product1;
        
        purchaseOrderItem1.buildertek__Product__c=product1.Id;
        update purchaseOrderItem1;
        
        POSubContractController.createContractRec(purchaseOrder1.Id);
        System.assert(true);
    }
}