@isTest
public with sharing class Pricing_Request_From_SectionTest {

    @isTest
    static void testMethod1() {

        buildertek__Section__c section = new buildertek__Section__c();
        section.Name = 'Selection Category Testing';
        insert section;

        buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
        selectionType.Name = 'Selection Type Testing';
        selectionType.buildertek__Section__c = section.Id;
        insert selectionType;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Optoin Testing';
        option.buildertek__Question_Group__c = selectionType.Id;
        option.buildertek__Section__c = section.Id;
        insert option;

        buildertek__Pricing_Request__c pricingRequest = new buildertek__Pricing_Request__c();
        pricingRequest.Name = 'Testing PR';

        List<buildertek__Question_Group__c> selectionTypeList = new List<buildertek__Question_Group__c>{selectionType};
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>{option};

        Pricing_Request_From_Section.getRecord(section.Id);
        Pricing_Request_From_Section.createPR(section.Id, pricingRequest, selectionTypeList, optionList);

    }
}