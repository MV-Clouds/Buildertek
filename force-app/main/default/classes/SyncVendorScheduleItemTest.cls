/**
 * Title
 *
 * @author Nishit Suthar
 * @version 1.0
 * @description
 * @uses
 * @history
 * 		2023-11-29 :
 */
@isTest
private class SyncVendorScheduleItemTest {
    @testSetup
    static void setup(){
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.Email = 'test@mvclouds.com';
        insert con;

        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        buildertek__Project__c proj1 = new buildertek__Project__c();
        proj1.Name = 'Test Project 1';
        insert proj1;

        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Initial_Start_Date__c = Date.today();
        sch.buildertek__Project__c = proj.Id;
        insert sch;

        buildertek__Schedule__c sch1 = new buildertek__Schedule__c();
        sch1.buildertek__Description__c = 'Test Schedule 1';
        sch1.buildertek__Initial_Start_Date__c = Date.today();
        sch1.buildertek__Project__c = null;
        insert sch1;

        buildertek__Cost_Codes__c cc = new buildertek__Cost_Codes__c();
        cc.Name = 'Test Cost Code';
        insert cc;

        buildertek__Trade_Type__c tt = new buildertek__Trade_Type__c();
        tt.Name = 'Test Trade Type';
        insert tt;

        buildertek__BT_Grouping__c btg = new buildertek__BT_Grouping__c();
        btg.Name = 'Test BT Grouping';
        insert btg;

        buildertek__Project_Vendors__c pv = new buildertek__Project_Vendors__c();
        pv.Name = 'Test Account';
        pv.buildertek__Account__c = acc.Id;
        pv.buildertek__BT_Project__c = proj.Id;
        pv.buildertek__BT_Cost_Code__c = cc.Id;
        pv.buildertek__Trade_Type__c = tt.Id;
        pv.buildertek__BT_Grouping__c = btg.Id;
        insert pv;

        List<buildertek__Project_task__c> schItemList = new List<buildertek__Project_task__c>();
        buildertek__Project_task__c si = new buildertek__Project_task__c();
        si.Name = 'Test Schedule Item';
        si.buildertek__Schedule__c = sch.Id;
        si.buildertek__Project__c = proj.Id;
        si.buildertek__Start__c = Date.today();
        si.buildertek__Duration__c = 1;
        si.buildertek__Finish__c = Date.today();
        si.buildertek__Cost_Code__c = cc.Id;
        si.buildertek__BT_Grouping__c = btg.Id;
        si.buildertek__Trade_Type__c = null;
        si.buildertek__Type__c = 'Task';
        schItemList.add(si);

        buildertek__Project_task__c si1 = new buildertek__Project_task__c();
        si1.Name = 'Test Schedule Item 1';
        si1.buildertek__Schedule__c = sch.Id;
        si1.buildertek__Project__c = proj.Id;
        si1.buildertek__Start__c = Date.today();
        si1.buildertek__Duration__c = 1;
        si1.buildertek__Finish__c = Date.today();
        si1.buildertek__Cost_Code__c = cc.Id;
        si1.buildertek__BT_Grouping__c = null;
        si1.buildertek__Trade_Type__c = null;
        si1.buildertek__Type__c = 'Task';
        schItemList.add(si1);

        insert schItemList;
    }

    @isTest
    static void myUnitTest() {
        Test.startTest();
        String schId = [SELECT Id FROM buildertek__Schedule__c WHERE buildertek__Project__c != null LIMIT 1].Id;
        String schId1 = [SELECT Id FROM buildertek__Schedule__c WHERE buildertek__Project__c = null LIMIT 1].Id;
        List<buildertek__Project_task__c> ListOfschItem = [SELECT Id FROM buildertek__Project_task__c LIMIT 2];
        SyncVendorScheduleItem.fetchVendorAndSchedulItemData(schId);
        SyncVendorScheduleItem.fetchVendorAndSchedulItemData(schId1);
        SyncVendorScheduleItem.fetchVendorAndSchedulItemData('');
        SyncVendorScheduleItem.fetchVendorAndSchedulItemData('test');
        SyncVendorScheduleItem.updateScheduleItemList(ListOfschItem);
        Test.stopTest();
    }
}