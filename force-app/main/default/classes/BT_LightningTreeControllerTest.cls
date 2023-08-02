@isTest
private class BT_LightningTreeControllerTest {

    private static testMethod void test() {
        
        Selection__c selection = new Selection__c();
        insert selection;
        
        Section__c section1 = new Section__c(Selection__c = selection.Id);
        insert section1;
        
        Section__c section = new Section__c(Selection__c = selection.Id, Parent__c = section1.Id);
        insert section;
        
        Question_Group__c groupQuestion = new Question_Group__c(Section__c = section.Id);
        insert groupQuestion;
        
        Choice_Template__c choiceTemplate = new Choice_Template__c();
        insert choiceTemplate;
        
        Question__c question = new Question__c(Question_Group__c = groupQuestion.Id, Choice_Template__c = choiceTemplate.Id);
        insert question;
        String questionList = '['+question.Id+']';
        BT_LightningTreeController.getRootNodes('', '', '', true, '', '', true);
        BT_LightningTreeController.setRootNodeIcon(questionList);
        
        system.assertEquals('test', 'test');
    }
}