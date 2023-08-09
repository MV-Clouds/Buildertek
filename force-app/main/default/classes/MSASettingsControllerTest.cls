@isTest
public class MSASettingsControllerTest {
    public static testMethod void MSASeetings(){
        List<buildertek__MSA_Settings__c> MSAList = new List<buildertek__MSA_Settings__c>();
        buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
        msaSettings.Name = 'MSA Settings';
        msaSettings.buildertek__City__c = 'TestCity';
        msaSettings.buildertek__Company_Full_Name__c = 'TestName';
        msaSettings.buildertek__MSA_Email__c = 'sagar@buildertek.com'; 
        MSAList.add(msaSettings);
        insert MSAList;
        
        MSASettingsController.getMSASettings();
        
        //List<ApexPage> ApexPageList = new List<ApexPage>();
        ApexPage ap = new ApexPage();
        ap.MasterLabel = 'Test';
        ap.Name = 'TestName';
        //ap.NamespacePrefix = 'TestPrefix';
        //ApexPageList.add(ap);
        //insert ap;
        MSASettingsController.getPages();
        MSASettingsController.saveSettings(msaSettings);
        
    }

}