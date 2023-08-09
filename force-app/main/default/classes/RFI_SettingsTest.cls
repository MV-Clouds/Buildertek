@isTest
public class RFI_SettingsTest {
     public static testMethod void test1() {
         buildertek__RFI_Settings__c customsettings = new buildertek__RFI_Settings__c(buildertek__Using_Email__c = true,
                                                                                      buildertek__Using_Communities__c = true,
                                                                                      Name = 'test1',
                                                                                      buildertek__New_RFI_Notification_Template__c = 'test');
        insert customsettings;
         RFISettingsController.getRFISettings();
         RFISettingsController.saveSettings(customsettings);
     }
}