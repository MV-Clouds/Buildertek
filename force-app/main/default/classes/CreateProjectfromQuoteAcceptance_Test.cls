@isTest
private class CreateProjectfromQuoteAcceptance_Test {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Quote Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true);
        insert adminInterfaceNodeConfigurations;
        CreateProjectfromQuoteAcceptanceonOpp handler = new CreateProjectfromQuoteAcceptanceonOpp();
        handler.onCreateProjectfromQuoteAcceptanceonOpp();
    }
}