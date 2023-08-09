@isTest
public class StripeSettingsControllerTest {
    static testMethod void test(){
        buildertek__Stripe_Settings__c msaSettings = new buildertek__Stripe_Settings__c();
        msaSettings.Name = 'Tset';
        insert msaSettings;
        test.startTest();
        StripeSettingsController.getMSASettings();
        StripeSettingsController.saveSettings(msaSettings);
         test.stopTest();
    }

}