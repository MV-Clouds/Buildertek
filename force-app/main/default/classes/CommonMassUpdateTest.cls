@isTest
public class CommonMassUpdateTest{
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Asset_Manager__c assetManager = new buildertek__Asset_Manager__c();
        insert assetManager;
        
        buildertek__Asset_history__c assethistory = new buildertek__Asset_history__c();
        assethistory.buildertek__Asset_Manager__c = assetManager.Id;
        insert assethistory;
        
    }
    
    @isTest
    static void testMethod1(){
        List<buildertek__Project__c> project = [Select Id
                                                FROM buildertek__Project__c
                                                LIMIT 1];
        List<buildertek__Asset_history__c> assets = [Select Id
                                                     FROM buildertek__Asset_history__c
                                                     LIMIT 1];
        String objName = 'buildertek__Asset_History__c';
        String fieldSetName = 'buildertek__Asset_History';
        String parentField = 'buildertek__Project__c';
        CommonMassUpdate massUpdate = new CommonMassUpdate();
        CommonMassUpdate.getCount(objName,parentField,project[0].Id);
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        fieldName.add('buildertek__Record_Type__c');
        CommonMassUpdate.getFieldSet(objName,fieldSetName);
        CommonMassUpdate.getRecords(objName, parentField,project[0].Id,JSON.serialize(fieldName),1,10);
        CommonMassUpdate.updateRecords(objName, parentField,project[0].Id, JSON.serialize(assets), JSON.serialize(fieldName), 1, 10);
        CommonMassUpdate.deleteProject(objName,parentField,project[0].Id,assets[0].Id,JSON.serialize(fieldName), 1, 10);
        CommonMassUpdate.getDropDown('buildertek__Asset_History__c','buildertek__Record_Type__c');
    }
}