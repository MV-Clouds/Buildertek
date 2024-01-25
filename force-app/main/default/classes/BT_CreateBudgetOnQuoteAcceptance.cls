public class BT_CreateBudgetOnQuoteAcceptance {
    public Boolean isCreateChangeOrderonOverage{get;set;}
    public Boolean isCreateexpense{get;set;}
    public Boolean isCreateTimeCard{get;set;}
    public Boolean isCostCode{get;set;}
    public Boolean isGroupByVendor{get;set;}
    public String selectedGrouping{get;set;}

    public String GroupingLevel1 { get; set; }
    public String GroupingLevel2 { get; set; }
    public String GroupingLevel3 { get; set; }

    
 // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    //public string  emailsubject {get;set;} 
    
    public BT_CreateBudgetOnQuoteAcceptance(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Create_Budget_on_Quote_Acceptance__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                              buildertek__Automatically_add_Time_Card_to_Budget__c,buildertek__Group_by_Cost_Code__c , 
                                                                                              buildertek__Group_by_vendor__c, buildertek__Budget_Grouping_Data__c ,buildertek__Budget_Grouping_Level_1__c , buildertek__Budget_Grouping_Level_2__c,
                                                                                              buildertek__Budget_Grouping_Level_3__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Budget Configuration'];

        isCreateChangeOrderonOverage=adminInterfaceNodeConfigurations.buildertek__Create_Budget_on_Quote_Acceptance__c	;
        isCreateexpense = adminInterfaceNodeConfigurations.buildertek__Automatically_add_Expense_to_Budget__c;
        isCreateTimeCard = adminInterfaceNodeConfigurations.buildertek__Automatically_add_Time_Card_to_Budget__c;
        isCostCode = adminInterfaceNodeConfigurations.buildertek__Group_by_Cost_Code__c;
        isGroupByVendor = adminInterfaceNodeConfigurations.buildertek__Group_by_vendor__c;
        selectedGrouping = adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Data__c;

        GroupingLevel1 = adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_1__c;
        GroupingLevel2 = adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_2__c;
        GroupingLevel3 = adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_3__c;


    }


    public List<SelectOption> getGroupingOptions() {
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult fieldResult = buildertek__Admin_Interface_Node_Configuration__c.buildertek__Budget_Grouping_Level_1__c.getDescribe();
        options.add(new SelectOption('None', '--None--'));
        for (Schema.PicklistEntry picklistEntry : fieldResult.getPicklistValues()) {
            options.add(new SelectOption(picklistEntry.getValue(), picklistEntry.getLabel()));
        }
        return options;
    }

    
    public void onQuoteAccepted(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Create_Budget_on_Quote_Acceptance__c,
                                                                                              buildertek__Email_Subject__c,buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                              buildertek__Automatically_add_Time_Card_to_Budget__c,buildertek__Group_by_Cost_Code__c , 
                                                                                              buildertek__Group_by_vendor__c, buildertek__Budget_Grouping_Data__c ,buildertek__Budget_Grouping_Level_1__c , buildertek__Budget_Grouping_Level_2__c,
                                                                                              buildertek__Budget_Grouping_Level_3__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Budget Configuration'];
        adminInterfaceNodeConfigurations.buildertek__Create_Budget_on_Quote_Acceptance__c	=isCreateChangeOrderonOverage;
        adminInterfaceNodeConfigurations.buildertek__Automatically_add_Expense_to_Budget__c = isCreateexpense;
        adminInterfaceNodeConfigurations.buildertek__Automatically_add_Time_Card_to_Budget__c = isCreateTimeCard;
         adminInterfaceNodeConfigurations.buildertek__Group_by_Cost_Code__c = isCostCode;
         adminInterfaceNodeConfigurations.buildertek__Group_by_vendor__c = isGroupByVendor;
         adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Data__c = selectedGrouping;

         if(GroupingLevel1 == 'None'){
            GroupingLevel1 = null;
        }
        if(GroupingLevel2 == 'None'){
            GroupingLevel2 = null;
        }
        if(GroupingLevel3 == 'None'){
            GroupingLevel3 = null;
        }
         adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_1__c = GroupingLevel1;
         adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_2__c = GroupingLevel2;
         adminInterfaceNodeConfigurations.buildertek__Budget_Grouping_Level_3__c = GroupingLevel3;
        
         if (GroupingLevel1 == GroupingLevel2 && GroupingLevel1 != null && GroupingLevel2 != null
         || GroupingLevel1 == GroupingLevel3 && GroupingLevel1 != null && GroupingLevel3 != null
         || GroupingLevel2 == GroupingLevel3 && GroupingLevel2 != null && GroupingLevel3 != null
         || GroupingLevel1 == GroupingLevel2 && GroupingLevel2 == GroupingLevel3 && GroupingLevel1 == GroupingLevel3 && GroupingLevel1 != null && GroupingLevel2 != null && GroupingLevel3 != null ) {
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Grouping Levels cannot be the same.'));
         return; // Validation fails, no data saving will be performed
     }
     

        
        update adminInterfaceNodeConfigurations;
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Updated Successfully'));
    }
}