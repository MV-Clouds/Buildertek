@isTest
public class ChooseBTChecklistTest {
 
     @isTest static void test1(){
            buildertek__Checklist_Objects__c btChecklistObj = new buildertek__Checklist_Objects__c();
            btChecklistObj.Name ='Checklist Logo';
            btChecklistObj.buildertek__Object_Label__c='Opportunity';
            btChecklistObj.buildertek__Object_API_Name__c = 'Opportunity';
            insert btChecklistObj;
         
         buildertek__Checklist_Configuration__c btcheckconfig = new buildertek__Checklist_Configuration__c();
         btcheckconfig.Name = 'Contact checklist';
         btcheckconfig.buildertek__Object_Name__c ='ActivityRecurrence2Share';
         insert btcheckconfig;
         buildertek__MSA_Settings__c msasettings=new buildertek__MSA_Settings__c();
         msasettings.Name='MSA Settings';
         msasettings.buildertek__Site_URL__c='https://builderteklightning-developer-edition.na75.force.com/';
         insert msasettings;
         list<string> qlist = new List<string>();
         buildertek__Questions__c btquestion = new buildertek__Questions__c();
         btquestion.buildertek__Customize__c = 'How are you?';
         btquestion.buildertek__Options__c  = 'ok';
         btquestion.buildertek__Question_Type__c = 'Single Select Answer';
         insert btquestion; 
         qlist.add(btquestion.id);
         
         buildertek__Checklist_Questions__c btcheckquestion = new buildertek__Checklist_Questions__c();
         btcheckquestion.buildertek__Questions__c = btquestion.id;
         btcheckquestion.buildertek__Checklist_Configuration__c  = btcheckconfig.id; 
         insert btcheckquestion;
         
         ChooseBTChecklist.getchecklistObjects();
         ChooseBTChecklist.getQuestions();
         ChooseBTChecklist.createQuestions('Single Select Answer','How are you?','Good#$#Averager#$#Poor');
        ChooseBTChecklist.getPickValues('Account','Name');
         //ChooseBTChecklist.saveQuestion('Single Select Answer','How are you?','Yes#$#No','test','test',btquestion.id);
         ChooseBTChecklist.getCheckListCofigRecords();
         ChooseBTChecklist.geteditRecord(btcheckconfig.id);
          ChooseBTChecklist.getDeleteRecord(btcheckconfig.id);
         ChooseBTChecklist.ChecklistConfiguration(qlist,'Contact checklist','buildertek__Checklist_Questions__c',btcheckconfig.id);
         ChooseBTChecklist.getDeleteQuestion(btquestion.id);
          ChooseBTChecklist.createlookup('Account');
         //ChooseBTChecklist.createlookup('buildertek__Checklist_Questions__c');
          //ChooseBTChecklist.createlookup('buildertek__Checklist_Response__c');
         
         Test.Starttest();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
         ChooseBTChecklist.createlookup('Account');
         Test.stopTest();
        }

}