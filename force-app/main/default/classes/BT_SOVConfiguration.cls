public class BT_SOVConfiguration {
    public string accountvalues {get;set;}
    public buildertek__Admin_Interface_Node_Configuration__c newrfi{ get; set; }
    public BT_SOVConfiguration (){
    newrfi = new buildertek__Admin_Interface_Node_Configuration__c();
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_SOV__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'SOV Configuration'];
        newrfi.buildertek__Default_Account_for_SOV__c= adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c;
    }
    public void onCreateChangeOrderonOverage(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Default_Account_for_SOV__c from 
                                                                                              buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'SOV Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Default_Account_for_SOV__c = newrfi.buildertek__Default_Account_for_SOV__c;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    } 
}