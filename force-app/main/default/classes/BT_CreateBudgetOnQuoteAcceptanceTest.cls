@isTest
private class BT_CreateBudgetOnQuoteAcceptanceTest {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Budget Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true,
                                                                                                                                                  buildertek__Automatically_add_Expense_to_Budget__c = true,
                                                                                                                                                  buildertek__Automatically_add_Time_Card_to_Budget__c = true);
        insert adminInterfaceNodeConfigurations;
        BT_CreateBudgetOnQuoteAcceptance handler = new BT_CreateBudgetOnQuoteAcceptance();
        handler.onQuoteAccepted();
    }
}