public class BT_ProjectConfiguration {
    public Boolean isCreateChangeOrderonOverage{get;set;}
   // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    public string  apikey {get;set;}
    
    public BT_ProjectConfiguration(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Retreive_Aerial_Photo_of_project__c,buildertek__Google_Map_API_Key__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Project Configuration'];
        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Retreive_Aerial_Photo_of_project__c;
        apikey = adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c;
    }
    
    public void onCreateChangeOrderonOverage(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Retreive_Aerial_Photo_of_project__c,buildertek__Google_Map_API_Key__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Project Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Retreive_Aerial_Photo_of_project__c=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Google_Map_API_Key__c = apikey;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}