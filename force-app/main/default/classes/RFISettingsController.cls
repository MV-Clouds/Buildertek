public class RFISettingsController {
     @AuraEnabled
    public static buildertek__RFI_Settings__c getRFISettings(){
            buildertek__RFI_Settings__c msaSettings = new buildertek__RFI_Settings__c();
        List<buildertek__RFI_Settings__c> msaSettingsList = [Select Id,Name, 
                                                            buildertek__Using_Communities__c,
                                                            buildertek__Using_Email__c,
                                                            buildertek__New_RFI_Notification_Template__c,
                                                            buildertek__Vendor_Notification_Template__c,
                                                            buildertek__Recipient_Notification_Template__c,
                                                            buildertek__RFI_Default_Owner__c,
                                                            buildertek__Queue_Name__c
                                                            from buildertek__RFI_Settings__c
                                                            WHERE Name = :'RFI Settings'];
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
    public static void saveSettings(buildertek__RFI_Settings__c msaSettings){
        system.debug('msaSettings------'+msaSettings);
        msaSettings.Name = 'RFI Settings';
        upsert msaSettings;
    }
     /*@AuraEnabled
     public static void saveSettings(string communities ,string email){
       List<buildertek__RFI_Settings__c> sitesUrl = [SELECT Id, buildertek__Using_Communities__c,buildertek__Using_Email__c FROM buildertek__RFI_Settings__c LIMIT 1];
         if(sitesUrl.size()>0 ){
             sitesUrl[0].buildertek__Using_Communities__c = communities;
             sitesUrl[0].buildertek__Using_Email__c = email;
             update sitesUrl[0];
         }else{
            buildertek__RFI_Settings__c site = new buildertek__RFI_Settings__c(); 
             site.Name= 'RFI Settings';
             site.buildertek__Using_Communities__c = communities;
             site.buildertek__Using_Email__c = email;
             insert site;
         }
        
     }*/


}