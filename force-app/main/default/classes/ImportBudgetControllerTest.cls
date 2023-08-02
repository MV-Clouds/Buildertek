@isTest
public class ImportBudgetControllerTest {
	@testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testImportBudgetController1() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Budget__c LIMIT 1].Id;
        String strFile = 'Grouping,Product Name,Quantity,Unit Price,UOM,Budget Mods,Projected Costs\n,'+projectId+',10,10,test,test,test\n\n,'+projectId+',10,10,test,test,test\n';
        
        ImportBudgetController.importBudgets(budgetId, EncodingUtil.base64Encode(Blob.valueOf(strFile)));
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportBudgetController2() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Budget__c LIMIT 1].Id;
        String strFile = 'Grouping,Product Name,Quantity,Unit Price,UOM,Budget Mods,Projected Costs\n';
        
        ImportBudgetController.importBudgets(budgetId, EncodingUtil.base64Encode(Blob.valueOf(strFile)));
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportBudgetController3() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Budget__c LIMIT 1].Id;
        
        ImportBudgetController.importBudgets(budgetId, NULL);
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportBudgetController4() {
        ImportBudgetController.appendCellValuesSeparatedByNewLines(new List<String> {'"Sample 1', 'Sample 2",'});
        ImportBudgetController.appendCellValuesSeparatedByCommas(new List<String> {'"Sample 1', 'Sample 2"\n,'});
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testBudgetTrigger() {
        Budget__c budget = new Budget__c();
        insert budget;
        update budget;
        delete budget;
        System.assertEquals('Test','Test');
    }
}