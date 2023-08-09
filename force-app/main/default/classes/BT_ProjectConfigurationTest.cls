@isTest
private class BT_ProjectConfigurationTest {
    private static testMethod void Method1() {
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = NEW buildertek__Admin_Interface_Node_Configuration__c(Name= 'Project Configuration',
                                                                                                                                                  buildertek__Retreive_Aerial_Photo_of_project__c = true,
                                                                                                                                                   buildertek__Google_Map_API_Key__c = 'Test'
                                                                                                                                                  );
        insert adminInterfaceNodeConfigurations;
        BT_ProjectConfiguration handler = new BT_ProjectConfiguration();
        handler.onCreateChangeOrderonOverage();
    }
}