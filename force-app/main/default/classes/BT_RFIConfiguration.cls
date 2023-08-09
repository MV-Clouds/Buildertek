public class BT_RFIConfiguration {
    public Boolean isusingcommunities{get;set;}
    public BT_RFIConfiguration(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Using_Communities__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'RFI Configuration'];
        isusingcommunities = adminInterfaceNodeConfigurations.buildertek__Using_Communities__c;
    }
    
    public void onCreateChangeOrderonOverage(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Using_Communities__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'RFI Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Using_Communities__c = isusingcommunities;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}