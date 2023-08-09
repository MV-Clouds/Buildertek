@isTest
public with sharing class CO_From_Selection_CategoryTest {

    @TestSetup
    static void testData(){
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Project Testing';
        insert project;

        buildertek__Selection__c selection = new buildertek__Selection__c();
        selection.Name = 'Selection Sheet Testing';
        selection.buildertek__Project__c = project.Id;
        insert selection;

        buildertek__Section__c section = new buildertek__Section__c();
        section.Name = 'Selection Category Testing';
        section.buildertek__Selection__c = selection.Id;
        insert section;

        buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
        selectionType.Name = 'Selection Type Testing';
        selectionType.buildertek__Section__c = section.Id;
        insert selectionType;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Optoin Testing';
        option.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__Upgrade_Costs__c = 35;
        option.buildertek__Quantity__c = 10;
        option.buildertek__Upgrade__c = true;
        insert option;
    }

    @isTest
    static void testMethod1(){

        buildertek__Section__c section = [SELECT Id, Name FROM buildertek__Section__c LIMIT 1];

        List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Quantity__c, buildertek__Upgrade_Costs__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c];

        buildertek__Change_Order__c co = new buildertek__Change_Order__c();
        co.Name = 'Testing CO';
        co.buildertek__Due_Date__c = System.Today();

        CO_From_Selection_Category.getOption(section.Id, true);
        CO_From_Selection_Category.createCO(co, optionList);
    }
}