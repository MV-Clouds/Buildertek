public class BT_CreateContractOnQuoteAcceptance {
    public Boolean isCreateChangeOrderonOverage{get;set;}
   // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    public string  emailsubject {get;set;} 
    public Boolean  isCreateInvoice {get;set;} 
    
    
    public BT_CreateContractOnQuoteAcceptance(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_Create_Inv_from_ConSigning__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Create Contract on Quote Acceptance'];
        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c;
        emailsubject = adminInterfaceNodeConfigurations.buildertek__Email_Subject__c;
        isCreateInvoice = adminInterfaceNodeConfigurations.buildertek__Automatically_Create_Inv_from_ConSigning__c;
    }
    
    public void onQuoteAccepted(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Change_Order_Configuration__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_Create_Inv_from_ConSigning__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Create Contract on Quote Acceptance'];
        adminInterfaceNodeConfigurations.buildertek__Change_Order_Configuration__c=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = emailsubject;
        adminInterfaceNodeConfigurations.buildertek__Automatically_Create_Inv_from_ConSigning__c = isCreateInvoice;
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}