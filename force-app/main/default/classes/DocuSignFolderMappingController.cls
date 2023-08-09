public class DocuSignFolderMappingController {
 @AuraEnabled
    public static buildertek__Docusign_Folder_Mapping__c saveAccount (buildertek__Docusign_Folder_Mapping__c acc) {
        system.debug(acc);
        
        upsert acc;
      
        return acc;
    }
}