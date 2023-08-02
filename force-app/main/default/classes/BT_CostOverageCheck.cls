public class BT_CostOverageCheck {
    public Boolean isCreateChangeOrderonOverage{get;set;}
    
    public BT_CostOverageCheck(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Turn off Cost Option Allowance Check'];
        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c;
    }
    
    public void onQuoteAccepted(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Turn off Cost Option Allowance Check'];
        adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c=isCreateChangeOrderonOverage;
        update adminInterfaceNodeConfigurations;
    }
}