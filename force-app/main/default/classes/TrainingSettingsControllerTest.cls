@isTest
public class TrainingSettingsControllerTest {
         static testMethod void test(){
         buildertek__Training_Settings__c bTSettings = new buildertek__Training_Settings__c();
         bTSettings.Name = 'Training Settings';
         bTSettings.buildertek__Contact_Info__c = 'Test ADD';
         bTSettings.buildertek__Course_Completed_Email_Template__c = 'TestCourseComplete';
         bTSettings.buildertek__Registration_Completed_Email_Template__c = 'CompleteEmail';
         bTSettings.buildertek__Registration_Email_Template__c = 'mail';
         insert bTSettings;
         
         buildertek__Checklist_Objects__c BTCheckList = new buildertek__Checklist_Objects__c();
         BTCheckList.Name = 'Checklist Logo';
         insert BTCheckList;
         BTCheckList.Name = ' ';
         update BTCheckList;
         
         
         
         
         TrainingSettingsController.getTSettings();
         TrainingSettingsController.saveSettings(bTSettings );
         TrainingSettingsController.saveChunk('Test','decodedB641','TestContent');
         TrainingSettingsController.getAttachmentData();
         }

}