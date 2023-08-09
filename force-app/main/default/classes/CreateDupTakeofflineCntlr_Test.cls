@isTest
public with sharing class CreateDupTakeofflineCntlr_Test 
{


    @TestSetup
    static void createTestData()
    {

        List<buildertek__Project_Takeoff__c> takeOffs = new List<buildertek__Project_Takeoff__c>();

        buildertek__Project_Takeoff__c takeOff1 = new buildertek__Project_Takeoff__c();
        takeOff1.buildertek__Name__c = 'Test TakeOff1';
        takeOffs.add(takeOff1);
        insert takeOffs;


        List<buildertek__Project_Takeoff_Lines__c> takeOffLines = new List<buildertek__Project_Takeoff_Lines__c>();

        buildertek__Project_Takeoff_Lines__c takeOffLine1 = new buildertek__Project_Takeoff_Lines__c();
        takeOffLine1.buildertek__Project_Takeoff__c = takeOff1.Id;
        takeOffLines.add(takeOffLine1);

        insert takeOffLines;

    }
    @isTest
    static void createDupTakeofflineCntlr_Test1()
    {
        List<buildertek__Project_Takeoff__c> takeOffs = [Select Id,name,buildertek__Name__c from buildertek__Project_Takeoff__c];
        List<buildertek__Project_Takeoff_Lines__c> takeOffLines = [Select id,name from buildertek__Project_Takeoff_Lines__c];

        Test.startTest();
        buildertek__Project_Takeoff_Lines__c clonedRec = CreateDuplicateTakeofflineController.cloneTakeOffLine(takeOffLines[0].Id);
        String clonedRecId = CreateDuplicateTakeofflineController.saveTakeOffLineRecord(clonedRec);
        CreateDuplicateTakeofflineController.getTakeOffLines(takeOffs[0].Id);
        Test.stopTest();

        System.assert(clonedRecId != null);
    }
}