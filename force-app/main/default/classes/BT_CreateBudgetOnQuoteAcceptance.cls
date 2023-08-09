public class BT_CreateBudgetOnQuoteAcceptance {
    public Boolean isCreateChangeOrderonOverage{get;set;}
    public Boolean isCreateexpense{get;set;}
    public Boolean isCreateTimeCard{get;set;}
    public Boolean isCostCode{get;set;}
    public Boolean isGroupByVendor{get;set;}
    public String selectedGrouping{get;set;}

    
 // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    //public string  emailsubject {get;set;} 
    
    public BT_CreateBudgetOnQuoteAcceptance(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Create_Budget_on_Quote_Acceptance__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                              buildertek__Automatically_add_Time_Card_to_Budget__c,buildertek__Group_by_Cost_Code__c , 
                                                                                              buildertek__Group_by_vendor__c, buildertek__Budget_Grouping_Data__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Budget Configuration'];

        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Create_Budget_on_Quote_Acceptance__c	;
        isCreateexpense = adminInterfaceNodeConfigurations.buildertek__Automatically_add_Expense_to_Budget__c;
        isCreateTimeCard = adminInterfaceNodeConfigurations.buildertek__Automatically_add_Time_Card_to_Budget__c;
        isCostCode = adminInterfaceNodeConfigurations.buildertek__Group_by_Cost_Code__c;
        isGroupByVendor = adminInterfaceNodeConfigurations.buildertek__Group_by_vendor__c;
        selectedGrouping = adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Data__c;

    }
    
    public void onQuoteAccepted(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Create_Budget_on_Quote_Acceptance__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                              buildertek__Automatically_add_Time_Card_to_Budget__c,buildertek__Group_by_Cost_Code__c , 
                                                                                              buildertek__Group_by_vendor__c, buildertek__Budget_Grouping_Data__c 
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Budget Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Create_Budget_on_Quote_Acceptance__c	=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Automatically_add_Expense_to_Budget__c = isCreateexpense;
        adminInterfaceNodeConfigurations.buildertek__Automatically_add_Time_Card_to_Budget__c = isCreateTimeCard;
         adminInterfaceNodeConfigurations.buildertek__Group_by_Cost_Code__c = isCostCode;
         adminInterfaceNodeConfigurations.buildertek__Group_by_vendor__c = isGroupByVendor;
         adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Data__c = selectedGrouping;

        
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}