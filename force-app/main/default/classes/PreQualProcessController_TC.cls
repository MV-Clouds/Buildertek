@isTest
public class PreQualProcessController_TC {
    @isTest public static void prequaltest(){
      List<buildertek__MSA_Settings__c> MSAList = new List<buildertek__MSA_Settings__c>();
      buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
      msaSettings.Name = 'MSA Settings';
      msaSettings.buildertek__City__c = 'TestCity';
      msaSettings.buildertek__Company_Full_Name__c = 'TestName';
      msaSettings.buildertek__MSA_Email__c = 'sagar@buildertek.com'; 
      msaSettings.buildertek__MSA_Sign_Contractor_Template_Name__c = 'MSA Sign Contractor Template';
      MSAList.add(msaSettings);
      insert MSAList;
        buildertek__Check_List_Settings__c cl = new buildertek__Check_List_Settings__c();
        cl.Name ='Check List Settings';
        cl.buildertek__Site_URL__c = 'https://builderteklightning-developer-edition.na75.force.com/';
        insert cl;
      buildertek__Checklist_Objects__c bc = new buildertek__Checklist_Objects__c();
      bc.Name ='Checklist Logo';
      insert bc;
      Attachment att=new Attachment();
      att.ParentId=bc.Id;
      att.Name='ChecklistLogo';
      att.Body=Blob.valueof('/services/data/v52.0/sobjects/Attachment/uu/Body');
      insert att;
        buildertek__BT_ConfirmatioPageURL__c confirmationsetting=new buildertek__BT_ConfirmatioPageURL__c();
        confirmationsetting.buildertek__Public_Site_Url__c='https://builderteklightning-developer-edition.na75.force.com/';
        insert confirmationsetting;
        
      PreQualProcessController ppcontroller=new  PreQualProcessController(); 
    }
}