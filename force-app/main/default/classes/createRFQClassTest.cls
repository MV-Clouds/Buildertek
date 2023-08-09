@isTest
public with sharing class createRFQClassTest {
    @TestSetup
    static void testRFQ(){

        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Test Project';
        insert project;
        
        buildertek__Selection__c selectionSheet = new buildertek__Selection__c();
        selectionSheet.Name = 'selectionSheet Testing';
        selectionSheet.buildertek__Project__c = project.Id;

        buildertek__Section__c selectionCategory = new buildertek__Section__c();
        selectionCategory.Name = 'selectionCategory Testing';
        selectionCategory.buildertek__Selection__c = selectionSheet.Id;

        buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
        selectionType.Name = 'Testing';
        selectionType.buildertek__Section__c = selectionCategory.Id;
        insert selectionType;
        
        buildertek__Question__c option=new buildertek__Question__c();
        option.Name='Option';
        option.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__RFQ__c=null;
        optionList.add(option);
        
        buildertek__Question__c option1=new buildertek__Question__c();
        option1.Name='Option2';
        option1.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__RFQ__c=null;
        optionList.add(option1);
        
        insert optionList;
    }
    @isTest
    static void testRFQ2(){
        
        buildertek__Question_Group__c selectionType = [SELECT Id,Name FROM buildertek__Question_Group__c LIMIT 1];
        
        List<buildertek__Question__c> optionLs = new List<buildertek__Question__c>();
        optionLs = [SELECT Id, Name, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c, buildertek__Question_Group__c FROM buildertek__Question__c where buildertek__Question_Group__c =:selectionType.Id];
        System.assertNotEquals(null,selectionType.Id,'selection id should not be null');
        
        Test.startTest();
        	Date sampleDate = Date.parse('12/27/2023');
        	buildertek__RFQ__c rf=new buildertek__RFQ__c();
        	rf.Name='Test';
        	rf.buildertek__Due_Date__c=sampleDate;
        	rf.buildertek__RFQ_Details__c='testing';
        	//insert rf;
        
        	createRFQClass.getOptionData(selectionType.Id);
            createRFQClass.RFQList(rf, optionLs);
        Test.stopTest();
    }
}