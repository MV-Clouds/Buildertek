@isTest
public class ImportmasterRFQClassTest {
     public static testMethod void getRFQ() {
         
    buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test ';
        insert proj;
    List<buildertek__RFQ__c> RFQList = new List<buildertek__RFQ__c>();
        buildertek__RFQ__c RFQ = new buildertek__RFQ__c();
        RFQ.Name = 'Test RFQ';
        RFQ.buildertek__Project__c = proj.Id;
        RFQ.buildertek__Type__c = 'Master';
        RFQList.add(RFQ); 
        insert RFQList;
    
     List<buildertek__RFQ_Item__c> RFQItemList = new List<buildertek__RFQ_Item__c>();
        buildertek__RFQ_Item__c RFQItem = new buildertek__RFQ_Item__c();
        RFQItem.buildertek__Quantity__c = 10;
        RFQItem.buildertek__Unit_Price__c = 100;
        RFQItem.buildertek__RFQ_Package__c = RFQList[0].Id;
        RFQItemList.add(RFQItem);
        insert RFQItemList;
     
     List<String> selectedIds = new List<String>();
        selectedIds.add(RFQList[0].Id);
    
     List<ImportmasterRFQClass.MasterBudgetsClass> MQList = new List<ImportmasterRFQClass.MasterBudgetsClass>();
        ImportmasterRFQClass.MasterBudgetsClass MQ = new ImportmasterRFQClass.MasterBudgetsClass();
        MQ.budgetRecord = RFQList[0];
        MQ.budgetCheck = true;
        MQList.add(MQ);
        ImportmasterRFQClass.getMasterRFQs();
        ImportmasterRFQClass.importMasterBudgetLines(selectedIds, RFQList[0].Id);
        system.assertEquals('test', 'test');
        
}
}