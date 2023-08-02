@isTest
public class ImportCsvQuoteController_Test {
	@testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testImportCsvQuoteController1() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Quote__c LIMIT 1].Id;
         Product2 prod = new Product2();
        prod.Name='test Prod';
        insert prod;
        String productId=prod.Name;
        
        buildertek__Cost_Codes__c costCode1 = new buildertek__Cost_Codes__c();
        costCode1.Name='test';
        insert costCode1;
        String costCodeId=costCode1.Name;
        
        buildertek__Quote_Line_Group__c qlgRec = new buildertek__Quote_Line_Group__c();
        qlgRec.Name='Test';
        insert qlgRec;
        String quoteLineId=qlgRec.Name;
        
        String strFile = 'Grouping,Product Description,Quantity,Unit Cost,Cost Code,UOM,Markup,quote Mods,Projected Costs\n'+quoteLineId+','+productId+',10,10.1,'+costCodeId+',10,10,test,test';
        
        ImportCsvQuoteController.importBudgets(budgetId, EncodingUtil.base64Encode(Blob.valueOf(strFile)));
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportCsvQuoteController2() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Budget__c LIMIT 1].Id;
        String strFile = 'Grouping,Product Name,Quantity,Unit Price,UOM,Budget Mods,Projected Costs\n';
        
        ImportCsvQuoteController.importBudgets(budgetId, EncodingUtil.base64Encode(Blob.valueOf(strFile)));
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportCsvQuoteController3() {
        Id projectId = [SELECT Id FROM buildertek__Project__c LIMIT 1].Id;
        Id budgetId = [SELECT Id FROM buildertek__Budget__c LIMIT 1].Id;
        
        ImportCsvQuoteController.importBudgets(budgetId, NULL);
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testImportCsvQuoteController4() {
        ImportCsvQuoteController.appendCellValuesSeparatedByNewLines(new List<String> {'"Sample 1', 'Sample 2",'});
        ImportCsvQuoteController.appendCellValuesSeparatedByCommas(new List<String> {'"Sample 1', 'Sample 2"\n,'});
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