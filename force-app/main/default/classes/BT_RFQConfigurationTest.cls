@isTest
private class BT_RFQConfigurationTest {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'RFQ Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test',
                                                                                                                                                  buildertek__Quote_Configuration__c = true);
        insert adminInterfaceNodeConfigurations;
        BT_RFQConfiguration handler = new BT_RFQConfiguration();
        handler.onCreateChangeOrderonOverage();
    }
}