public class StripeSettingsController {
   @AuraEnabled
    public static buildertek__Stripe_Settings__c getMSASettings(){
        buildertek__Stripe_Settings__c msaSettings = new buildertek__Stripe_Settings__c();
        List<buildertek__Stripe_Settings__c> msaSettingsList = [Select Id,Name, 
                                                            buildertek__Is_Live_Environment__c,
                                                            buildertek__Stripe_Publishable_Live_Key__c,
                                                            buildertek__Stripe_Publishable_Test_Key__c,
                                                            buildertek__Stripe_Secret_Live_Key__c,
                                                            buildertek__Stripe_Secret_Test_Key__c,
                                                            buildertek__Email_Template_Name__c 
                                                            
                                                            from buildertek__Stripe_Settings__c
                                                            WHERE Name = :'Stripe Settings'];
        system.debug('msaSettingsList-------'+msaSettingsList);
        if(msaSettingsList.size() > 0){
            msaSettings = msaSettingsList[0];   
        }else{
             //msaSettings.Name = 'Test Stripe'; 
             //insert msaSettings;  
        }                                                
        return msaSettings;
    }
    
    @AuraEnabled
    public static void saveSettings(buildertek__Stripe_Settings__c msaSettings){
        system.debug('msaSettings------'+msaSettings);
        msaSettings.Name = 'Stripe Settings';
        upsert msaSettings;
    }

    
}