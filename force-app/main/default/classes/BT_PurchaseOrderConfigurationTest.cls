@isTest
private class BT_PurchaseOrderConfigurationTest {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Purchase Order Configuration',
                                                                                                                                                  buildertek__Email_Subject__c = 'Test'
                                                                                                                                                  );
        insert adminInterfaceNodeConfigurations;
        BT_PurchaseOrderConfiguration handler = new BT_PurchaseOrderConfiguration();
        handler.onCreateChangeOrderonOverage();
    }
}