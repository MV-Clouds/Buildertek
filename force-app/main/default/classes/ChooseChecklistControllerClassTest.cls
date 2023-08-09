@isTest
public class ChooseChecklistControllerClassTest {
    @isTest static void Test1(){
          buildertek__Checklist_Objects__c btChecklistObj = new buildertek__Checklist_Objects__c();
            btChecklistObj.Name ='Checklist Logo';
            btChecklistObj.buildertek__Object_Label__c='Opportunity';
            btChecklistObj.buildertek__Object_API_Name__c = 'Opportunity';
            insert btChecklistObj;
        
        ChooseChecklistControllerClass.getChecklistControllerRecords();
        ChooseChecklistControllerClass.deleterecord(btChecklistObj.id);
        ChooseChecklistControllerClass.saveChecklistControllerRecord('buildertek__Quote__c','Quote');
        ChooseChecklistControllerClass.getObjectName();
    }

}