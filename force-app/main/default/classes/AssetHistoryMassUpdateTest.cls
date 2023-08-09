@isTest
public class AssetHistoryMassUpdateTest{
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        buildertek__Box_Settings__c boxsettings = new buildertek__Box_Settings__c(Name = 'BOX API',
                                                                                     buildertek__Client_Id__c = 'testclientid',
                                                                                     buildertek__Client_Secret__c = 'testclientsecret',
                                                                                     buildertek__API_Key__c = 'testapikey',
                                                                                     buildertek__Access_Token__c = 'testaccessToken',
                                                                                     buildertek__Refresh_Token__c = 'testrefreshtoken',
                                                                                     buildertek__Enterprise_ID__c = 'testenterpriseid');
            insert boxsettings;
        
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
        AssetHistoryMassUpdate.getCount(project[0].Id);
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        fieldName.add('buildertek__Record_Type__c');
        AssetHistoryMassUpdate.getFieldSet();
        AssetHistoryMassUpdate.getRecords(project[0].Id, JSON.serialize(fieldName), 1, 10);
        AssetHistoryMassUpdate.updateRecords(project[0].Id, JSON.serialize(assets), JSON.serialize(fieldName), 1, 10);
        AssetHistoryMassUpdate.deleteProject(assets[0].Id, project[0].Id,JSON.serialize(fieldName), 1, 10);
        AssetHistoryMassUpdate.getDropDown('buildertek__Asset_History__c','buildertek__Record_Type__c');
    }
    
    @isTest
    static void testMethod2(){
        AssetHistoryMassUpdate.getCount('');
        List<String> fieldName = new List<String>();
        fieldName.add('Id');
        fieldName.add('buildertek__Record_Type__c');
        AssetHistoryMassUpdate.getFieldSet(); 
        AssetHistoryMassUpdate.getRecords('', JSON.serialize(fieldName), 1, 10);
        AssetHistoryMassUpdate.updateRecords('', '', JSON.serialize(fieldName), 1, 10);
        AssetHistoryMassUpdate.deleteProject('', '',JSON.serialize(fieldName), 1, 10);
    }
}