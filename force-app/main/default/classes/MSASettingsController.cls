public class MSASettingsController {
    @AuraEnabled
    public static buildertek__MSA_Settings__c getMSASettings(){
        buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
        List<buildertek__MSA_Settings__c> msaSettingsList = [Select Id, 
                                                            buildertek__City__c,
                                                            buildertek__Company_Full_Name__c,
                                                            buildertek__Company_Name__c,
                                                            buildertek__Fax__c,
                                                            buildertek__MSA_Template__c,
                                                            buildertek__Phone__c,
                                                            buildertek__State__c,
                                                            buildertek__Street__c,
                                                            buildertek__Website__c,
                                                            buildertek__Zipcode__c,
                                                            buildertek__MSA_PDF_Template__c,
                                                            buildertek__MSA_Email__c,
                                                            buildertek__Site_URL__c,
                                                            buildertek__Pre_Qual_Template_Name__c,
                                                            buildertek__Submit_MSA_template_Name__c,
                                                            buildertek__Send_MSA_Template_Name__c,
                                                            buildertek__MSA_Sign_Template_Name__c,
                                                            buildertek__From_Email_Address__c,
                                                            buildertek__MSA_Sign_Contractor_Template_Name__c
                                                             
                                                            from buildertek__MSA_Settings__c
                                                            WHERE Name = :'MSA Settings'];
        if(msaSettingsList.size() > 0){
            msaSettings = msaSettingsList[0];   
        }else{
             msaSettings.Name = 'MSA Settings';
             insert msaSettings;  
        }                                                
        return msaSettings;
    }

    @AuraEnabled
    public static List<ApexPage> getPages(){
        List<ApexPage> pages = [SELECT MasterLabel, Name, NamespacePrefix FROM ApexPage Order By Name ASC];
        return pages;    
    }
    
    @AuraEnabled
    public static void saveSettings(buildertek__MSA_Settings__c msaSettings){
        upsert msaSettings;
    }

    
}