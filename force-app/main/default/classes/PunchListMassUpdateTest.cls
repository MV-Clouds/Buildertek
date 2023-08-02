@isTest
public class PunchListMassUpdateTest{
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Punch_List__c punchList = new buildertek__Punch_List__c();
        punchList.buildertek__Description__c = 'Test 1';
        insert punchList;
        
        buildertek__Punch_List_Item__c punchListItem = new buildertek__Punch_List_Item__c();
        punchListItem.buildertek__Punch_List__c = punchList.Id;
        insert punchListItem;
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Punch_List__c> punchList = [Select Id
                                                FROM buildertek__Punch_List__c
                                                LIMIT 1];
        List<buildertek__Punch_List_Item__c> punchListItem = [Select Id
                                                     FROM buildertek__Punch_List_Item__c
                                                     LIMIT 1];
        PunchListMassUpdate.getCount(punchList[0].Id);
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        PunchListMassUpdate.getFieldSet();
        PunchListMassUpdate.getRecords(punchList[0].Id, JSON.serialize(fieldName), 1, 10);
        PunchListMassUpdate.updateRecords(punchList[0].Id, JSON.serialize(punchListItem), JSON.serialize(fieldName), 1, 10);
        PunchListMassUpdate.deleteProject(punchListItem[0].Id, punchList[0].Id,JSON.serialize(fieldName), 1, 10);
        PunchListMassUpdate.getDropDown('buildertek__Punch_List_Item__c','buildertek__Location__c');
    }
    
    @isTest
    static void testMethod2(){
        PunchListMassUpdate.getCount('');
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        PunchListMassUpdate.getFieldSet(); 
        PunchListMassUpdate.getRecords('', JSON.serialize(fieldName), 1, 10);
        PunchListMassUpdate.updateRecords('', '', JSON.serialize(fieldName), 1, 10);
        PunchListMassUpdate.deleteProject('', '',JSON.serialize(fieldName), 1, 10);
    }
}