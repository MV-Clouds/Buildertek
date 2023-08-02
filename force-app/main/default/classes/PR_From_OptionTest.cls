@isTest
public with sharing class PR_From_OptionTest {
    @isTest
    static void testMethod1(){
        buildertek__Question_Group__c section = new buildertek__Question_Group__c();
        section.Name = 'Testing Section';
        insert section;

        buildertek__Question__c option = new buildertek__Question__c();
        option.Name = 'Testing Option';
        option.buildertek__Question_Group__c = section.Id;
        insert option;
        
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>{option};

        // For Pricing_Request_From_Option Class
        buildertek__Pricing_Request__c PR1 = new buildertek__Pricing_Request__c();
        PR1.Name = 'Testing Pricing';

        Pricing_Request_From_Option.createPR(option.Id, PR1);

        // For Pricing_Request_From_SectionType Class
        buildertek__Pricing_Request__c PR2 = new buildertek__Pricing_Request__c();
        PR2.Name = 'Testing Pricing';

        Pricing_Request_From_SectionType.getRecord(section.Id);
        Pricing_Request_From_SectionType.createPR(section.Id, PR2, optionList);
    }
}