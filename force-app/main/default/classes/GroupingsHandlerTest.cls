@isTest
public class GroupingsHandlerTest {

    @testSetup static void setup() {

        BT_Grouping__c grpRec = new BT_Grouping__c();
        grpRec.Name = 'group1';
        insert(grpRec);

        buildertek__Budget_Line_Group__c budgetgrp = new buildertek__Budget_Line_Group__c();
        budgetgrp.Name = 'test';
        insert budgetgrp;

        buildertek__Quote_Line_Group__c qutgrp = new buildertek__Quote_Line_Group__c();
        qutgrp.Name = 'test';
        insert qutgrp;

        buildertek__Contract_Line_Group__c contractgrp = new buildertek__Contract_Line_Group__c();
        contractgrp.Name = 'test';
        insert contractgrp;
        


    }
    public static  testMethod void testMethod1() {
        boolean m_isExecuting = false;
        integer BatchSize = 0;
        List<buildertek__Budget_Line_Group__c> BudgetLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sorting_Id__c FROM buildertek__Budget_Line_Group__c ];
        List<buildertek__Quote_Line_Group__c> QuoteLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Quote_Line_Group__c ];
        List<buildertek__Contract_Line_Group__c> ContractLineGroups = [SELECT Id, Name, buildertek__Description__c, buildertek__Sort_Id__c FROM buildertek__Contract_Line_Group__c ];

        GroupingsHandler grpHandler = new GroupingsHandler(m_isExecuting,BatchSize);
        // get list of grouping record 
        List<BT_Grouping__c> groupList = [SELECT Id, Name,buildertek__Description__c,buildertek__Sort_Id__c FROM BT_Grouping__c];
        Map<Id, BT_Grouping__c> idToGrpMap = new Map<Id, BT_Grouping__c>();
        for (BT_Grouping__c grp : groupList) {
            idToGrpMap.put(grp.id, grp);
            }
        List<BT_Grouping__c> groupListUpdated = new List<BT_Grouping__c>();
        for (BT_Grouping__c grp : [SELECT Id FROM BT_Grouping__c]) {
            grp.Name = 'grp1';
            grp.buildertek__Description__c = 'test';
            grp.buildertek__Sort_Id__c = 1;
            groupListUpdated.add(grp);
        }
        update groupListUpdated;
        Map<Id, BT_Grouping__c> updatedGrpMap = new Map<Id, BT_Grouping__c>();
        for (BT_Grouping__c grp : groupListUpdated) {
            updatedGrpMap.put(grp.id, grp);
            }


        //create map of grouping record Id and grouping record

        Test.startTest();
        grpHandler.afterInsert(groupList,idToGrpMap);
        grpHandler.afterUpdate(groupListUpdated,updatedGrpMap,groupList,idToGrpMap);
        grpHandler.beforeDelete(groupListUpdated,updatedGrpMap);
        Test.stopTest();
    }
}