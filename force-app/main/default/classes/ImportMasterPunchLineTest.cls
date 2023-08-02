/*******************************************************
* Name          : test_ts_TimesheetController
* Author        : Nitin (MV Clouds)
* Create Date   : 03/11/2022
* UsedBy        : ImportMasterPunchLineTest
*******************************************************/
@isTest
public class ImportMasterPunchLineTest {
    
    @isTest
    public static void test1(){

        buildertek__Punch_List__c plMaster1 = new buildertek__Punch_List__c(
            buildertek__Description__c = 'test1',
            buildertek__Type__c = 'Master'
        );
        insert plMaster1;

        buildertek__Punch_List__c plMaster2 = new buildertek__Punch_List__c(
            buildertek__Description__c = 'test2',
            buildertek__Type__c = 'Master'
        );
        insert plMaster2;
        
        buildertek__Punch_List__c plStandard3 = new buildertek__Punch_List__c(
            buildertek__Description__c = 'test3',
            buildertek__Type__c = 'Standard'
        );
        insert plStandard3;

        buildertek__Punch_List_item__c pli1 = new buildertek__Punch_List_item__c(
            buildertek__Name__c = 'testPLI1',
            buildertek__Punch_List__c = plMaster1.Id,
            buildertek__Details__c = 'testDetails'
        );
        insert pli1; 


        ImportMasterPunchLine.getMasterPL();

        List<String> selectedMasterPLIds = new List<String>();
        selectedMasterPLIds.add(plMaster1.Id);

        List<String> selectedMasterNULChildPLIds = new List<String>();
        selectedMasterNULChildPLIds.add(plMaster2.Id);

        String recId = plStandard3.Id;
        ImportMasterPunchLine.importMasterPLRecords(selectedMasterPLIds, recId);
        ImportMasterPunchLine.importMasterPLRecords(selectedMasterNULChildPLIds, recId);


    }

}