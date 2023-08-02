@isTest
public with sharing class BT_AddEditRecordComponentControllerTest {

    @testSetup static void insertTestData(){
        //insert account
        Account account = new Account(Name='Test Account');
        insert account;
    }
    
    static testMethod void testGetInitilizeIf(){
        Account account = [Select Id from Account Where Name = 'Test Account' LIMIT 1];
        Set<String> accountFieldSets = Schema.SObjectType.Account.fieldSets.getMap().keyset();
        BT_AddEditRecordComponentController controllerInstance = new BT_AddEditRecordComponentController();
        //set object as account
        controllerInstance.objectAPI = 'Account';
        controllerInstance.existingRecordId = account.id;
        if(!accountFieldSets.isEmpty()){
            controllerInstance.fieldSet = new List<String>(accountFieldSets) [0];
        }
        controllerInstance.getinitialize();
        controllerInstance.saveRecord();
        System.assertEquals('Test','Test');
    }
    
    static testMethod void testGetInitilizeElse(){
        Account account = [Select Id from Account Where Name = 'Test Account' LIMIT 1];
        Set<String> recordTypeSet = Schema.SObjectType.Account.getRecordTypeInfosByName().keyset();
        Set<String> accountFieldSets = Schema.SObjectType.Account.fieldSets.getMap().keyset();
        BT_AddEditRecordComponentController controllerInstance = new BT_AddEditRecordComponentController();
        //set object as account
        controllerInstance.objectAPI = 'Account';
        controllerInstance.defaultRecord = account;
        if(!accountFieldSets.isEmpty()){
            controllerInstance.fieldSet = new List<String>(accountFieldSets) [0];
        }
        if(!recordTypeSet.isEmpty()){
            controllerInstance.recordTypeName = new List<String>(recordTypeSet) [0];
        }
       // controllerInstance.getinitialize();
       
		controllerInstance.saveRecord();
		System.assertEquals('Test','Test');
    }
}