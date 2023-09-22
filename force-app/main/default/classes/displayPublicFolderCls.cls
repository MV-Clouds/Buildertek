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

        List<buildertek__Public_File__c> fileList = [SELECT Id, buildertek__File_Name__c, buildertek__Public_URL__c, buildertek__Expiry_Date__c, buildertek__Content_Distrubution__c, buildertek__Content_Version__c FROM buildertek__Public_File__c WHERE Id IN: filesId];

        folderWrap.publicFolder = folder;
        folderWrap.publicJunctionList = junctionList;
        folderWrap.publicFileList = fileList;

        return folderWrap;
    }

    public class FolderWrapper{
        @AuraEnabled
        public buildertek__Public_Folder__c publicFolder;

        @AuraEnabled
        public List<buildertek__Public_File_Folder_Jn__c> publicJunctionList;  
        
        @AuraEnabled
        public List<buildertek__Public_File__c> publicFileList;        
    }

}