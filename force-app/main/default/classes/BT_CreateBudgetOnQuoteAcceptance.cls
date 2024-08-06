public class BT_CreateBudgetOnQuoteAcceptance {
    public Boolean isCreateChangeOrderonOverage{get;set;}
    public Boolean isCreateexpense{get;set;}
    public Boolean isCreateTimeCard{get;set;}
    public Boolean isCostCode{get;set;}
    public Boolean isGroupByVendor{get;set;}
    public String selectedGrouping{get;set;}

    public String GroupingLevel1 { get; set; }
    public String GroupingLevel2 { get; set; }
    public buildertek__Admin_Interface_Node_Configuration__c adminConfiguration { get; set; }
    public String selectedOption { get; set;}
    
    // public Boolean hideGlobalMargin{get;set;}
    public Boolean hideGlobalMarkup{get;set;}
    
 // public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;} 
    //public string  emailsubject {get;set;} 
    
    public BT_CreateBudgetOnQuoteAcceptance(){
        List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [SELECT Id, buildertek__Create_Budget_on_Quote_Acceptance__c,
                                                                                              buildertek__Email_Subject__c, buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                              buildertek__Automatically_add_Time_Card_to_Budget__c, buildertek__Group_by_Cost_Code__c, 
                                                                                              buildertek__Group_by_vendor__c, buildertek__Budget_Grouping_Data__c, buildertek__Budget_Grouping_Level_1__c, 
                                                                                              buildertek__Budget_Grouping_Level_2__c, buildertek__Hide_These_budget_Buttons__c, buildertek__Hide_Global_Margin__c, 
                                                                                              buildertek__Hide_Global_Markup__c
                                                                                              FROM buildertek__Admin_Interface_Node_Configuration__c 
                                                                                              WHERE Name = 'Budget Configuration'];
        if (!adminInterfaceNodeConfigurations.isEmpty()) {
            adminConfiguration = adminInterfaceNodeConfigurations[0];
            isCreateChangeOrderonOverage = adminConfiguration.buildertek__Create_Budget_on_Quote_Acceptance__c;
            isCreateexpense = adminConfiguration.buildertek__Automatically_add_Expense_to_Budget__c;
            isCreateTimeCard = adminConfiguration.buildertek__Automatically_add_Time_Card_to_Budget__c;
            isCostCode = adminConfiguration.buildertek__Group_by_Cost_Code__c;
            isGroupByVendor = adminConfiguration.buildertek__Group_by_vendor__c;
            selectedGrouping = adminConfiguration.buildertek__Budget_Grouping_Data__c;
            GroupingLevel1 = adminConfiguration.buildertek__Budget_Grouping_Level_1__c;
            GroupingLevel2 = adminConfiguration.buildertek__Budget_Grouping_Level_2__c;
            selectedOption = adminConfiguration.buildertek__Hide_These_budget_Buttons__c;
            // hideGlobalMargin = adminConfiguration.buildertek__Hide_Global_Margin__c;
            hideGlobalMarkup = adminConfiguration.buildertek__Hide_Global_Markup__c;
        }
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

    public void onQuoteAccepted() {
        adminConfiguration.buildertek__Create_Budget_on_Quote_Acceptance__c = isCreateChangeOrderonOverage;
        adminConfiguration.buildertek__Automatically_add_Expense_to_Budget__c = isCreateexpense;
        adminConfiguration.buildertek__Automatically_add_Time_Card_to_Budget__c = isCreateTimeCard;
        adminConfiguration.buildertek__Group_by_Cost_Code__c = isCostCode;
        adminConfiguration.buildertek__Group_by_vendor__c = isGroupByVendor;
        adminConfiguration.buildertek__Budget_Grouping_Data__c = selectedGrouping;
        adminConfiguration.buildertek__Budget_Grouping_Level_1__c = (GroupingLevel1 == 'None') ? null : GroupingLevel1;
        adminConfiguration.buildertek__Budget_Grouping_Level_2__c = (GroupingLevel2 == 'None') ? null : GroupingLevel2;
        // adminConfiguration.buildertek__Hide_Global_Margin__c = hideGlobalMargin;
        adminConfiguration.buildertek__Hide_Global_Markup__c = hideGlobalMarkup;

        if (GroupingLevel1 == GroupingLevel2 && GroupingLevel1 != null && GroupingLevel2 != null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Grouping Level 1 and Grouping Level 2 cannot be the same.'));
            return;
        }

        adminConfiguration.buildertek__Hide_These_budget_Buttons__c = selectedOption;
        update adminConfiguration;
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Updated Successfully'));
    }

    public List<SelectOption> getMSPicklist {
        get {
            List<SelectOption> options = new List<SelectOption>();
            for (Schema.PicklistEntry obj : buildertek__Admin_Interface_Node_Configuration__c.buildertek__Hide_These_budget_Buttons__c.getDescribe().getPicklistValues()) {
                options.add(new SelectOption(obj.getValue(), obj.getLabel()));
            }
            return options;
        }
        set;
    }

    public String[] MSItems { 
        get {
            List<String> selected = new List<String>();
            List<SelectOption> options = this.getMSPicklist;
            for (SelectOption obj : options) {
                if (this.adminConfiguration.buildertek__Hide_These_budget_Buttons__c != null && this.adminConfiguration.buildertek__Hide_These_budget_Buttons__c.contains(obj.getValue())) {
                    selected.add(obj.getValue());
                }
            }
            return selected;
        }
        public set {
            String selectedCheckBox = '';
            for (String s : value) {
                if (selectedCheckBox == '') 
                    selectedCheckBox += s;
                else selectedCheckBox += ';' + s;
            }
            selectedOption = selectedCheckBox;
        }
    }
}