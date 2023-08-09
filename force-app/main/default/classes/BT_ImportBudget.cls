/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Pavan Kumar Uddarraju
 Date:  18-Mar-2019
 */
public with sharing class BT_ImportBudget{
    public List<masterBudget> masterBudgets{ get; set; }

    public Project__c Project{ get; set; }

    public integer totalRecs = 0;
    public integer OffsetSize = 0;
    public integer LimitSize = 10;
    public List<Budget__c> budget{ get; set; }

    public Boolean IsDisableNext{ get; set; }

    public Boolean IsDisablePrev{ get; set; }

    List<masterBudget> budgetList{ get; set; }

    String projectId1;
    String projectId;
    public BT_ImportBudget(ApexPages.StandardController controller){

        Budget__c record = (Budget__c)controller.getRecord();
        projectId = record.Project__c;
        System.debug('----------projectId---' + projectId);

        Project = new Project__c();
        if (projectId != null){
            if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
                project = [Select Id, Name
                           from buildertek__Project__c
                           where Id = :projectId];
            }

        }

        masterBudgets = new List<masterBudget>();
        List<Budget__c> bdList;
        if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Original_Budget__c.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isAccessible()){

            bdList = [Select Id, Name, buildertek__Project__c, buildertek__Original_Budget__c
                      from buildertek__Budget__c
                      where buildertek__Type__c = 'Master'
                      ORDER BY Name ASC];
        }

        for (Budget__c bud : bdList){
            masterBudget mb = new masterBudget();
            mb.budget = bud;
            mb.isSelected = false;
            masterBudgets.add(mb);
        }

        List<buildertek__Master_Budget__c> mbdList;
        if (Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Original_Budget__c.isAccessible()){
            mbdList = [Select Id, Name, buildertek__Project__c, buildertek__Original_Budget__c
                       from buildertek__Master_Budget__c
                       ORDER BY Name ASC
                       Limit 50000];
        }

        for (buildertek__Master_Budget__c masterBud : mbdList){
            masterBudget mb = new masterBudget();
            mb.masterBudget = masterBud;
            mb.isSelected = false;
            masterBudgets.add(mb);
        }

        totalRecs = masterBudgets.size();
    }

    public BT_ImportBudget(ApexPages.StandardSetController budget){
        System.debug('----------26---');
        System.debug('check project Id here ==> ' + Apexpages.currentPage().getParameters().get('Id'));
        projectId1 = Apexpages.currentPage().getParameters().get('Id');
        project = new Project__c();

        if (projectId != null){
            projectId = projectId1.escapeHtml4();
            if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
                project = [Select Id, Name
                           from project__c
                           where Id = :projectId];
            }
        }

        masterBudgets = new List<masterBudget>();
        List<Budget__c> bdList;
        if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Original_Budget__c.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Type__c.isAccessible()){

            bdList = [Select Id, Name, buildertek__Project__c, buildertek__Original_Budget__c
                      from buildertek__Budget__c
                      where buildertek__Type__c = 'Master'
                      ORDER BY Name ASC
                      LIMIT :LimitSize
                      OFFSET :OffsetSize];
        }
        for (Budget__c bud : bdList){
            masterBudget mb = new masterBudget();
            mb.budget = bud;
            mb.isSelected = false;
            masterBudgets.add(mb);
        }

        List<buildertek__Master_Budget__c> mbdList;
        if (Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Original_Budget__c.isAccessible()){
            mbdList = [Select Id, Name, buildertek__Project__c, buildertek__Original_Budget__c
                       from buildertek__Master_Budget__c
                       ORDER BY Name ASC
                       LIMIT :LimitSize
                       OFFSET :OffsetSize];
        }

        for (buildertek__Master_Budget__c masterBud : mbdList){
            masterBudget mb = new masterBudget();
            mb.masterBudget = masterBud;
            mb.isSelected = false;
            masterBudgets.add(mb);
        }
    }

    public void goback(){
    }

    public void save(){
        //String selectedIds = '';
        System.debug('budgetList -------------> ' + masterBudgets);
        System.debug('Project Id -------------> ' + Apexpages.currentPage().getParameters().get('Id'));
        List<String> selectedIds = new List<String>();
        List<buildertek__Budget__c> masterBudgetItemList = new List<buildertek__Budget__c>();
        List<buildertek__Master_Budget__c> masterBudgetLineItemList = new List<buildertek__Master_Budget__c>();
        for (masterBudget mb : masterBudgets){
            if (mb.isSelected){
                if (mb.budget != null){
                    selectedIds.add(mb.budget.Id);
                } else if (mb.masterBudget != null){
                    selectedIds.add(mb.masterBudget.Id);
                }

                if (Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable()){
                    buildertek__Budget__c budget = new buildertek__Budget__c();
                    if (mb.budget != null){
                        budget.Name = mb.budget.Name;
                    } else if (mb.masterBudget != null){
                        budget.Name = mb.masterBudget.Name;
                    }

                    budget.buildertek__Project__c = Apexpages.currentPage().getParameters().get('Id');
                    masterBudgetItemList.add(budget);
                }
            }
        }
        System.debug('selectedIds -------------> ' + selectedIds);
        System.debug('masterBudgetItemList -------------> ' + masterBudgetItemList);
        insert masterBudgetItemList;
        Map<String, String> budgetMap = new Map<String, String>();
        Map<String, String> budgetNameMap = new Map<String, String>();
        List<buildertek__Quote_Line_Group__c> budgetGroupList = new List<buildertek__Quote_Line_Group__c>();
        for (buildertek__Budget__c bud : masterBudgetItemList){
            budgetMap.put(bud.Name, bud.Id);
            budgetNameMap.put(bud.Id, bud.Name);
        }
        //insert budgetGroup;
        Map<String, String> groupMap = new Map<String, String>();
        String groupId;
        List<buildertek__Quote_Line_Group__c> budgetGroup;
        if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){

            budgetGroup = [Select Id, Name
                           from buildertek__Quote_Line_Group__c
                           WHERE Name = 'No Grouping'];
        }

        if (budgetGroup.size() > 0){
            groupId = budgetGroup[0].Id;
        } else{
            buildertek__Quote_Line_Group__c budGroup = new buildertek__Quote_Line_Group__c();
            if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                budGroup.Name = 'No Grouping';
            }
            System.debug('budGroup -------------> ' + budGroup);
            insert budGroup;
            groupId = budGroup.Id;
        }

        List<buildertek__Budget_Item__c> budgetItem;
        if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Item_Name__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isAccessible() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isAccessible()){

            budgetItem = [select Id, Name, buildertek__Budget__c, buildertek__Budget__r.Name, buildertek__Product__c, buildertek__Item_Name__c, buildertek__Cost_Code__c, buildertek__Quantity__c, buildertek__Budget_Line_Group__c, buildertek__Unit_Price__c, buildertek__Tax__c, buildertek__Markup__c
                          from buildertek__Budget_Item__c
                          where buildertek__Budget__c IN:selectedIds];
        }


        List<buildertek__Master_Budget_Line__c> masterItem;
        if (Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Product__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Cost_Code__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Quantity__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item_Group__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Budget_Item_Name__c.isAccessible() && Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Unit_Price__c.isAccessible()){

            masterItem = [select Id, Name, buildertek__Master_Budget__c, buildertek__Master_Budget__r.Name, buildertek__Product__c, buildertek__Cost_Code__c, buildertek__Quantity__c, buildertek__Master_Budget_Item_Group__c, buildertek__Budget_Item_Name__c, buildertek__Unit_Price__c
                          from buildertek__Master_Budget_Line__c
                          where buildertek__Master_Budget__c IN:selectedIds];
        }

        List<buildertek__Budget_Item__c> budgetItemToInsert = new List<buildertek__Budget_Item__c>();

        for (buildertek__Budget_Item__c budgetItems : budgetItem){
            System.debug('Budget Id ----------> ' + budgetMap.get(budgetItems.buildertek__Budget__r.Name));
            //System.debug('Group Name ----------> '+budgetItems.buildertek__Group__r.Name);
            if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Item_Name__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isCreateable()){
                buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                budgetLine.Name = budgetItems.Name;
                budgetLine.buildertek__Budget__c = budgetMap.get(budgetItems.buildertek__Budget__r.Name);
                budgetLine.buildertek__Product__c = budgetItems.buildertek__Product__c;
                budgetLine.buildertek__Item_Name__c = budgetItems.buildertek__Item_Name__c;
                budgetLine.buildertek__Cost_Code__c = budgetItems.buildertek__Cost_Code__c;
                budgetLine.buildertek__Quantity__c = budgetItems.buildertek__Quantity__c;
                budgetLine.buildertek__Unit_Price__c = budgetItems.buildertek__Unit_Price__c;
                budgetLine.buildertek__Tax__c = budgetItems.buildertek__Tax__c;
                budgetLine.buildertek__Markup__c = budgetItems.buildertek__Markup__c;
                if (budgetItems.buildertek__Budget_Line_Group__c != null){
                    budgetLine.buildertek__Budget_Line_Group__c = budgetItems.buildertek__Budget_Line_Group__c;
                } else{
                    budgetLine.buildertek__Budget_Line_Group__c = groupId;
                }
                budgetItemToInsert.add(budgetLine);
            }
        }
        for (buildertek__Master_Budget_Line__c masterbudgetItems : masterItem){
            System.debug('Budget Id ----------> ' + budgetMap.get(masterbudgetItems.buildertek__Master_Budget__r.Name));
            //System.debug('Group Name ----------> '+masterbudgetItems.buildertek__Group__r.Name);
            if (Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Item_Name__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget_Line_Group__c.isCreateable()){
                buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                budgetLine.Name = masterbudgetItems.buildertek__Budget_Item_Name__c; //masterbudgetItems.Name;
                budgetLine.buildertek__Budget__c = budgetMap.get(masterbudgetItems.buildertek__Master_Budget__r.Name);
                budgetLine.buildertek__Product__c = masterbudgetItems.buildertek__Product__c;
                budgetLine.buildertek__Cost_Code__c = masterbudgetItems.buildertek__Cost_Code__c;
                budgetLine.buildertek__Item_Name__c = masterbudgetItems.buildertek__Budget_Item_Name__c;
                budgetLine.buildertek__Quantity__c = masterbudgetItems.buildertek__Quantity__c;
                budgetLine.buildertek__Unit_Price__c = masterbudgetItems.buildertek__Unit_Price__c;
                if (masterbudgetItems.buildertek__Master_Budget_Item_Group__c != null){
                    budgetLine.buildertek__Budget_Line_Group__c = masterbudgetItems.buildertek__Master_Budget_Item_Group__c;
                } else{
                    budgetLine.buildertek__Budget_Line_Group__c = groupId;
                }
                budgetItemToInsert.add(budgetLine);
            }
        }
        System.debug('budgetItemToInsert -------> ' + budgetItemToInsert);
        insert budgetItemToInsert;
        //}
    }

    public class masterBudget{
        public Budget__c budget{ get; set; }

        public buildertek__Master_Budget__c masterBudget{ get; set; }

        public Boolean isSelected{ get; set; }

    }

}