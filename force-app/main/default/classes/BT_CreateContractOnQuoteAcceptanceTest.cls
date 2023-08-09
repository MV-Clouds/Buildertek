@isTest
private class BT_CreateContractOnQuoteAcceptanceTest {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Create Contract on Quote Acceptance',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true);
        insert adminInterfaceNodeConfigurations;
        BT_CreateContractOnQuoteAcceptance handler = new BT_CreateContractOnQuoteAcceptance();
        handler.onQuoteAccepted();
    }
}