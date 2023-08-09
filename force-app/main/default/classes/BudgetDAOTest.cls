/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class BudgetDAOTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    public static testMethod void test1() {
        Account accRec = new Account(Name = 'Test');
        insert accRec;
        String budgetid = [Select ID from Budget__c LIMIT 1].Id;
        Purchase_Order__c po = [Select Id From Purchase_Order__c LIMIT 1];
        po.Budget__c = budgetid;
        update po;
        Project__c proj = [Select Id from Project__c LIMIT 1];
        BudgetDAO.createBudgetItemFromPOItem([Select Id,Purchase_Order__c,Item_Name__c,Description__c,Cost_Code__c,buildertek__Notes__c from Purchase_Order_Item__c]);

        Budget__c budgetRecs = new Budget__c();
        budgetRecs.Name = 'test';
        budgetRecs.Project__c =proj.id;
        insert budgetRecs;

        Budget_Item__c budgetITem = new Budget_Item__c();
        budgetITem.budget__c = budgetid;
        budgetITem.ITem_Name__c = 'Test';
        budgetITem.Name = 'Test';
        String myJSONbudgetITem = JSON.serialize(budgetITem);
        insert budgetITem;

        Budget_Item__c budgetITem1 = new Budget_Item__c();
        budgetITem1.budget__c = budgetid;
        budgetITem1.ITem_Name__c = 'Test';
        budgetITem1.Name = 'Test';
        insert budgetITem1;

        List<Budget_Item__c> budgetITemLst = new List<Budget_Item__c>();
        budgetITemLst.add(budgetITem);
        String myJSONbudgetITemLst = JSON.serialize(budgetITemLst);

        RFQ__c rfqRec = new RFQ__c();
        rfqRec.Budget__c = budgetRecs.Id;
        rfqRec.Project__c = proj.id;
        rfqRec.RFQ_Workflow_Stage__c = '3';
        String myJSON = JSON.serialize(rfqRec);

        List<RFQ_Item__c> rfqItemsLst = new List<RFQ_Item__c>();
        RFQ_Item__c rfqItems = new RFQ_Item__c();
        rfqItems.buildertek__Description__c ='test';
        rfqItemsLst.add(rfqItems);
        String myJSONRFQItems = JSON.serialize(rfqItemsLst);

        Purchase_Order__c porec = new Purchase_Order__c();
        porec.Project__c = proj.id;
        porec.Budget__c = budgetRecs.Id;
        porec.buildertek__Vendor__c = accRec.Id;
        String por = JSON.serialize(porec);

        List<Purchase_Order_Item__c> poItemsList = new List<Purchase_Order_Item__c>();
        Purchase_Order_Item__c poItem = new Purchase_Order_Item__c();
        poItem.Name = 'test';
        poItem.Purchase_Order__c =porec.id;
        poItemsList.add(poItem);
        String porItems = JSON.serialize(poItemsList);

        Change_Order__c coRec =new Change_Order__c();
        coRec.Name ='test';
        coRec.buildertek__Status__c ='Approved';
        coRec.buildertek__Customer_Account__c =accRec.id;
        String cor = JSON.serialize(coRec);

        List<Change_Order_Item__c> coItemsList = new List<Change_Order_Item__c>();
        Change_Order_Item__c coItems = new Change_Order_Item__c();
        coItems.Name ='test';
        coItems.Change_Order__c =coRec.id;
        coItemsList.add(coItems);
        String corItemJson = JSON.serialize(coItemsList);

        list<buildertek__Quote_Line_Group__c> grouplist = new list<buildertek__Quote_Line_Group__c>();
        buildertek__Quote_Line_Group__c GroupRef = new buildertek__Quote_Line_Group__c(Name='test');
        grouplist.add(GroupRef);
        insert GroupRef;
        budget_line_group__c budgetLineGroup = new budget_line_group__c();
        budgetLineGroup.name='test';
        insert budgetLineGroup;

        List<budget_line_group__c> budgetLineGroupList = new List<budget_line_group__c>();
        budgetLineGroupList.add(budgetLineGroup);


        List<buildertek__Budget_Item__c> budgetListRef = new List<buildertek__Budget_Item__c>();
        buildertek__Budget_Item__c budgetRef = new buildertek__Budget_Item__c();
        budgetRef.Name ='test';
        budgetRef.buildertek__Budget__c = budgetRecs.id ;
        budgetRef.buildertek__Budget_Line_Group__c =GroupRef.id;
        budgetListRef.add(budgetRef);
        insert budgetRef;
        update budgetRef;
        String BudgetJson = JSON.serialize(budgetRef);

        buildertek__Budget_Item__c budgetRef1 = new buildertek__Budget_Item__c();
        budgetRef1.Name ='test';
        budgetRef1.buildertek__Budget__c = budgetRecs.id ;
        budgetRef1.buildertek__Budget_Line_Group__c =GroupRef.id;
        insert budgetRef1;

        List<buildertek__Budget_Item__c> budgetListRef1 = new List<buildertek__Budget_Item__c>();
        budgetListRef1.add(budgetRef1);
        String BudgetJson1 = JSON.serialize(budgetListRef1);

        buildertek__Budget_Item__c budgetRef2 = new buildertek__Budget_Item__c();
        budgetRef2.Name ='test';
        budgetRef2.buildertek__Budget__c = budgetRecs.id ;
        budgetRef2.buildertek__Budget_Line_Group__c =GroupRef.id;
        insert budgetRef2;

        List<String> budgetLineRecords =new List<String>();
        budgetLineRecords.add(budgetRef2.Id);

        List<buildertek__Budget_Item__c> budgetListRef2 = new List<buildertek__Budget_Item__c>();
        budgetListRef2.add(budgetRef2);
        String BudgetJson2 = JSON.serialize(budgetListRef2);

        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        buildertek__Trade_Type__c tradeType = new buildertek__Trade_Type__c();
        tradeType.Name = 'Test';
        insert tradeType;

        List<buildertek__Budget_Modifications__c> budgetModList = new List<buildertek__Budget_Modifications__c>();
        buildertek__Budget_Modifications__c budgetMod = new buildertek__Budget_Modifications__c();
        budgetMod.buildertek__Budget__c = budgetRecs.Id;
        budgetMod.buildertek__To__c = budgetListRef[0].Id;
        budgetMod.buildertek__From__c = budgetListRef[0].Id;
        budgetModList.add(budgetMod);
        insert budgetModList;

        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        List<String> budgetItemIds = new List<String>();
        budgetItemIds.add(budgetListRef[0].Id);

        List<String> groupIds = new List<String>();
        groupIds.add(GroupRef.id);

        product2 p1=new product2();
        p1.name='test product';
        insert p1;

        List<String> currencyFields = new List<String>{'buildertek__Unit_Price__c', 'buildertek__Total_Costs__c', 'buildertek__Projected_Costs__c'};
        List<String> allFields = new List<String>{'Id', 'buildertek__Budget_Line_Group__c', 'buildertek__Quantity__c', 'buildertek__Unit_Price__c', 'buildertek__Total_Costs__c', 'buildertek__Projected_Costs__c'};

        //String fieldString;
        String fieldString = '[{"fieldName":"buildertek__Budget_Line_Group__c","fieldType":"reference","isEditable": false},'
                             +'{"fieldName":"Id","fieldType":"","isEditable": false},'
                             +'{"fieldName":"buildertek__Quantity__c","fieldType":"number","isEditable": true},'
                             +'{"fieldName":"buildertek__Unit_Price__c","fieldType":"currency","isEditable": true}]';

        BudgetDAO.saveBudgetLineItem(BudgetJson, budgetRecs.Id, acc.Id);
       // BudgetDAO.retrieveGroups(budgetListRef[0].Id, 1, 10);
    //    BudgetDAO.updateBudgetLinFromDataTable(myJSONbudgetITemLst, GroupRef.id, budgetITem.budget__c);
        BudgetDAO.updateGroupsOrder(budgetLineGroupList);
        BudgetDAO.deleteGroups(budgetLineGroupList);
      //  BudgetDAO.deleteBudgetItem(budgetITemLst,  GroupRef.id, budgetITem.budget__c);
       // BudgetDAO.getBudgetItem(String.valueOf(budgetITem1.Id));
        BudgetDAO.getpricebook(budgetRef.buildertek__Budget__c);
        BudgetDAO.getpricebooks(budgetRecs.Id);
        // BudgetDAO.deleteBudgetLineItem(budgetRef1.Id);
        BudgetDAO.prepareString(BudgetJson1);
        BudgetDAO.saveUpdatedValues(budgetListRef2);
       // BudgetDAO.massDuplicateBudgetLineItem(budgetLineRecords);

        BudgetDAO.updateBudgetLineItem(BudgetJson);
    //  BudgetDAO.createCOFromBudget(budgetRecs,cor,corItemJson);
        // BudgetDAO.getProductPrice(p1.Id);
        //BudgetDAO.createBudgetItem(JSON.serialize(new List<budget_item__c>{budgetITem}));
        BudgetDAO.createRFQFromBudget(budgetRecs,myJSON,myJSONRFQItems);
        BudgetDAO.createPOFromBudget(budgetRecs,por,porItems);
        BudgetDAO.getselectOptions();
        BudgetDAO.BudgetItemList(budgetItemIds);
        BudgetDAO.deleteLineItems(budgetItemIds);
        BudgetDAO.deleteSelectedItems(budgetItemIds);
        //BudgetDAO.deleteBudgetLineItem(budgetRef.Id);
        // BudgetDAO.groupValues(budgetRecs.Id, currencyFields, allFields, groupIds, 10, 0);
    //  BudgetDAO.getBudgetItemData(budgetRecs.Id, allFields, fieldString, 10, 0);
        BudgetDAO.updateBudgetItemModificationInAmount(budgetModList);
    //  BudgetDAO.getBudgetGroupDetails(budgetRecs.Id, GroupRef.id, 10, 0);
        BudgetDAO.getFieldSet('buildertek__BT_Related_List_View_Fields', 'buildertek__Budget_Item__c');

        // BudgetDAO.getContingencyBudgetItems(budgetRecs.id);
        // BudgetDAO.setProductNameToItemName(budgetListRef);
        //BudgetDAO.massDuplicateBudgetLineItem(budgetItemIds);
     //   BudgetDAO.createCOFromBudget(budgetRecs.id,'test','test');

        System.assertEquals('Test','Test');
    }
}