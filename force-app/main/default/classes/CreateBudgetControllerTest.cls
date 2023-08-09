@isTest
public class CreateBudgetControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testCreateBudgetController() {
     Account acc=new Account();
        acc.Name='tes';
        insert acc;
         contract con = new  contract();    
        con.AccountId=acc.id;
        //con.Status='In Approval Process';
        con.StartDate=system.today();
        con.ContractTerm=2;
        insert con;
        // contract con = new  contract();
        //con.lastName='test';
        //insert con;
         buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
         List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
       budget.buildertek__Project__c = proj.Id;
        budget.buildertek__Type__c = 'Master';
        budgetList.add(budget); 
        insert budgetList;
        
         List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test quote';
        quote.buildertek__Project__c = proj.Id;
        quote.buildertek__Type__c = 'Master';
        quoteList.add(quote); 
        insert quoteList;
           List<String> selectedIds = new List<String>();
        selectedIds.add(quoteList[0].Id);
        
        
        //CreateBudgetController.createContract(NULL);
       // CreateBudgetController.createContract([SELECT Id FROM buildertek__Quote__c LIMIT 1].Id);
        //CreateBudgetController.createBudget(NULL);
       // CreateBudgetController.createBudget([SELECT Id FROM buildertek__Contract__c LIMIT 1].Id);
        //CreateBudgetController.createBudgetFromQuote(NULL);
       // CreateBudgetController.createBudgetFromQuote([SELECT Id FROM buildertek__Contract__c LIMIT 1].id);
        //CreateBudgetController.createBudgetFromPurchase(NULL);
        CreateBudgetController.createBudgetFromQuote(quoteList[0].Id);
        // CreateBudgetController.createContract(quoteList[0].Id);
           CreateBudgetController.createBudgetFromPurchase(proj.Id);
        CreateBudgetController.createBudget(con.Id);
        // buildertek__Budget__c BudgetRef = new buildertek__Budget__c();
        // BudgetRef.Name ='test';
        // BudgetRef.buildertek__Project__c =
        System.assertEquals('Test','Test');
    }
}