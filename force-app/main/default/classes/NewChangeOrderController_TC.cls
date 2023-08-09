@isTest
public class NewChangeOrderController_TC {
    private static testMethod void createChangeOrderMethod() {
        Id CustomerRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        Id VendorRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();    
        
        Product2 prod1 = new Product2();
        prod1.Name='test product';
        insert prod1;
        Id pricebookId = Test.getStandardPricebookId();
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        proj.buildertek__Customer__c=acc.Id;
        insert proj;
        
        
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
        budget.buildertek__Project__c = proj.Id;
        budget.buildertek__Type__c = 'Master';
        insert budget;
        
        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        budItem.Name = 'Test Budget';
        budItem.buildertek__Budget__c = budget.Id;
        budItem.buildertek__Quantity__c = 10;
        budItem.buildertek__Unit_Price__c = 100;
        insert budItem;
        
        
        buildertek__Change_Order__c CO = new buildertek__Change_Order__c();
        CO.Name = 'Test CO';
        CO.buildertek__Project__c = proj.Id;
        CO.buildertek__Status__c = 'Pending';
        CO.buildertek__Customer_Account__c = acc.Id;
        CO.RecordTypeId=VendorRecordTypeId;
        insert CO;
        
        buildertek__Change_Order__c CO1 = new buildertek__Change_Order__c();
        CO1.Name = 'Test CO';
        CO1.buildertek__Project__c = proj.Id;
        CO1.buildertek__Status__c = 'Pending';
        CO1.buildertek__Customer_Account__c = acc.Id;
        
        List<buildertek__Change_Order_Item__c> coItemList = new List<buildertek__Change_Order_Item__c>();
        buildertek__Change_Order_Item__c coItem = new buildertek__Change_Order_Item__c();
        coItem.buildertek__Change_Order__c = CO.Id;
        coItem.Name = 'Test CO Item';
        coItem.buildertek__Quantity__c = 10;
        coItem.buildertek__Unit_Price__c = 100;
        coItem.Budget_Item__c = budItem.Id;
        coItemList.add(coItem);
        insert coItemList;
         
        buildertek__Project__c project=new buildertek__Project__c();
        project.Name='Test Project';
        project.buildertek__Account__c=acc.Id;
        project.buildertek__Active__c=true;
        project.buildertek__Customer__c=acc.Id;
        insert project;
        
        buildertek__Contract__c contract=new buildertek__Contract__c();
        contract.Name='Test Contract';
        contract.buildertek__Change_Order__c=CO.Id;
        contract.buildertek__Project__c=project.Id;
        insert contract;
        //SELECT Id, Name, buildertek__Stage__c, buildertek__Active__c, buildertek__Account__c FROM buildertek__Project__c
        
        NewChangeOrderController.getobjectName(CO.Id);
        NewChangeOrderController.getFieldSet(VendorRecordTypeId);
        NewChangeOrderController.getDropDown('buildertek__Change_Order_Item__c','buildertek__Markup__c');
        NewChangeOrderController.getNames(project.Id);
        //NewChangeOrderController.getCOType(VendorRecordTypeId);
        NewChangeOrderController.getContractNames(project.Id);
        NewChangeOrderController.getproject(contract.Id);
        NewChangeOrderController.getListViews();
    }
}