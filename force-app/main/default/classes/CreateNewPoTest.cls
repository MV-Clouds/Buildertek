@isTest
public class CreateNewPoTest {
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
        
        buildertek__Contract__c contract = new buildertek__Contract__c();
        insert contract;
        
        buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
        contractItem.buildertek__Contract__c = contract.Id;
        insert contractItem;
    }
    
    @isTest
    static void testMethod1(){
        List<Account> acc = [Select Id
                             FROM Account
                             LIMIT 1];
        List<buildertek__Project__c> project = [Select Id
                                                FROM buildertek__Project__c
                                                LIMIT 1];
        List<buildertek__Purchase_Order__c> purchaseOrder = [Select Id
                                                     FROM buildertek__Purchase_Order__c
                                                     LIMIT 1];
        List<buildertek__Purchase_Order_Item__c> purchaseOrderItem = [Select Id
                                                     FROM buildertek__Purchase_Order_Item__c
                                                     LIMIT 1];
        List<buildertek__Contract__c> contract = [Select Id
                                                     FROM buildertek__Contract__c
                                                     LIMIT 1];
        
        CreateNewPO.getPOAddress(project[0].Id);
        Date requiredDeliverydate = System.today();
        CreateNewPO.contractdetails(acc[0].Id);
      //  CreateNewPO.saveNewPO(project[0].Id, acc[0].Id, null,'','',requiredDeliverydate,'','','','','',contract[0].Id);
    }
}