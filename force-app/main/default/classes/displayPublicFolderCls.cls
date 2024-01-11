public without sharing class displayPublicFolderCls {

    @AuraEnabled
    public static FolderWrapper getDataFromFolder(String recId) {
        FolderWrapper folderWrap = new FolderWrapper();

        buildertek__Public_Folder__c folder = [SELECT Id, Name, buildertek__File_Count__c, buildertek__Description__c FROM buildertek__Public_Folder__c WHERE Id =: recId];

        List<buildertek__Public_File_Folder_Jn__c> junctionList = [SELECT Id, buildertek__Public_File__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c WHERE buildertek__Public_Folder__c =: recId];

        Set<Id> filesId = new Set<Id>();
        for (buildertek__Public_File_Folder_Jn__c junction : junctionList) {
            filesId.add(junction.buildertek__Public_File__c);
        }

        List<buildertek__Public_File__c> fileList = [SELECT Id, buildertek__File_Name__c, buildertek__Public_URL__c, buildertek__Expiry_Date__c, buildertek__Content_Distrubution__c, buildertek__Content_Version__c , CreatedDate FROM buildertek__Public_File__c WHERE Id IN: filesId];

        Map<Id, buildertek__Public_File__c> fileMap = new Map<Id, buildertek__Public_File__c>();
        for (buildertek__Public_File__c file : fileList) {
            fileMap.put(file.buildertek__Content_Version__c, file);
        }

        Set<Id> cvIds = new Set<Id>();
        List<ContentVersion> contentVersionList = [SELECT Id, Title, ContentDocumentId, ContentUrl, FileType, FileExtension, VersionNumber, Description, ContentSize FROM ContentVersion WHERE Id IN: fileMap.keySet()];
        for (ContentVersion cv : contentVersionList) {
            cvIds.add(cv.Id);
        }

        List<FileWrapper> fileWrapperList = new List<FileWrapper>();

        for (ContentVersion conv : contentVersionList) {
            FileWrapper fw = new FileWrapper();
            fw.publicFile = fileMap.get(conv.Id);
            fw.cv = conv;
            fileWrapperList.add(fw);
        }

        List<buildertek__Public_File__c> deleteList = new List<buildertek__Public_File__c>();
        for (buildertek__Public_File__c file : fileList) {
            if (!cvIds.contains(file.buildertek__Content_Version__c)) {
                deleteList.add(file);
            }
        }

        delete deleteList;

        folderWrap.publicFolder = folder;
        folderWrap.publicJunctionList = junctionList;
        folderWrap.fileWrapperList = fileWrapperList;

        return folderWrap;
    }

    @AuraEnabled
    public static DisplayImageControllerWrapper getDisplayImageData() {
        DisplayImageControllerWrapper result = new DisplayImageControllerWrapper();

        result.orgId = UserInfo.getOrganizationId();
        result.customLabelValue = System.Label.Company_Logo;
        result.confirmationURL = buildertek__ConfirmationPageSiteURL__c.getAll().values();

        if (result.confirmationURL.size() > 0) {
            result.siteUrl = result.confirmationURL[0].buildertek__SiteURL__c;
        }

        result.lstDocument = [SELECT Id, Name FROM Document WHERE Name = :result.customLabelValue LIMIT 1];

        List<buildertek__Display_Images_Setting__mdt> displayimagemetadatelist = [SELECT Id, DeveloperName, buildertek__Height__c, buildertek__Width__c FROM buildertek__Display_Images_Setting__mdt WHERE DeveloperName = 'Logo_Settings' LIMIT 1];

        if (displayimagemetadatelist.size() > 0) {
            result.height = displayimagemetadatelist[0].buildertek__Height__c;
            result.width = displayimagemetadatelist[0].buildertek__Width__c;
        }

        if (result.lstDocument.size() > 0) {
            result.documentId = result.lstDocument[0].Id;
        }

        system.debug('documentId-----' + result.documentId);

        return result;
    }

    public class FolderWrapper{
        @AuraEnabled
        public buildertek__Public_Folder__c publicFolder;

        @AuraEnabled
        public List<buildertek__Public_File_Folder_Jn__c> publicJunctionList;  
        
        @AuraEnabled
        public List<FileWrapper> fileWrapperList;  
    }

    public class FileWrapper{
        @AuraEnabled
        public buildertek__Public_File__c publicFile;  

        @AuraEnabled
        public ContentVersion cv;
    }

    public class DisplayImageControllerWrapper {
    
        @AuraEnabled
        public String orgId { get; set; }
    
        @AuraEnabled
        public String customLabelValue { get; set; }
    
        @AuraEnabled
        public List<buildertek__ConfirmationPageSiteURL__c> confirmationURL { get; set; }
    
        @AuraEnabled
        public String siteUrl { get; set; }
    
        @AuraEnabled
        public List<Document> lstDocument { get; set; }
    
        @AuraEnabled
        public Decimal height { get; set; }
    
        @AuraEnabled
        public Decimal width { get; set; }
    
        @AuraEnabled
        public String documentId { get; set; }
    
    }
}