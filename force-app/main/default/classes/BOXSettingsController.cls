public class BOXSettingsController {
    @AuraEnabled
    public static buildertek__Box_Settings__c getBoxSettings(){
        buildertek__Box_Settings__c boxSettings = new buildertek__Box_Settings__c();
        List<buildertek__Box_Settings__c> boxsettingsList = [select id,buildertek__Access_Token__c,
                                                             buildertek__API_Key__c,
                                                             buildertek__Client_Id__c,
                                                             buildertek__Client_Secret__c,
                                                             buildertek__Enterprise_ID__c,
                                                             buildertek__Refresh_Token__c,
                                                             buildertek__Box_Parent_Folder_Id__c
                                                             from buildertek__Box_Settings__c
                                                             Where name='BOX API'];
        if(boxsettingsList.size() > 0){
            boxSettings = boxsettingsList[0];   
        }else{
            boxSettings.Name = 'BOX API';
            insert boxSettings;  
        } 
        return boxSettings;
        
    }
    @AuraEnabled
    public static List<ApexPage> getPages(){
        List<ApexPage> pages = [SELECT MasterLabel, Name, NamespacePrefix FROM ApexPage Order By Name ASC];
        return pages;    
    }
    @AuraEnabled
    public static void saveSettings(buildertek__Box_Settings__c boxSettings){
        upsert boxSettings;
    }
    
}