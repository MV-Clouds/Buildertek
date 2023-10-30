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

        List<ContentVersion> contentVersionList = [SELECT Id, Title, ContentDocumentId, ContentUrl, FileType, FileExtension, VersionNumber, Description, ContentSize FROM ContentVersion WHERE Id IN: fileMap.keySet()];

        List<FileWrapper> fileWrapperList = new List<FileWrapper>();

        for (ContentVersion conv : contentVersionList) {
            FileWrapper fw = new FileWrapper();
            fw.publicFile = fileMap.get(conv.Id);
            fw.cv = conv;
            fileWrapperList.add(fw);
        }

        folderWrap.publicFolder = folder;
        folderWrap.publicJunctionList = junctionList;
        folderWrap.fileWrapperList = fileWrapperList;

        return folderWrap;
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



}