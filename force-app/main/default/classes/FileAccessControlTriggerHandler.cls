/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: FileAccessControlTriggerHandler
* Created by Sagar
*
* - File Access controt trigger handler

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class FileAccessControlTriggerHandler {
    public void onAfterInsert(List<File_Access_Control__c> newFileAccessControls) {
        createSharesForGrantee(newFileAccessControls);
    }
    public void onAfterUpdate(List<File_Access_Control__c > newFileAccessControls, List<File_Access_Control__c> oldFileAccessControls) {
        deleteSharesForGrantee(oldFileAccessControls);
        createSharesForGrantee(newFileAccessControls);
    }
    public void onAfterDelete(List<File_Access_Control__c> oldFileAccessControls) {
        deleteSharesForGrantee(oldFileAccessControls);
    }
    
    public void createSharesForGrantee(List<File_Access_Control__c> newFileAccessControls){
        List<buildertek__File__share> fileShares = new List<buildertek__File__share>();
        for(File_Access_Control__c fileAccessControl : newFileAccessControls){
            buildertek__File__share objFileShare = new buildertek__File__share(ParentId = fileAccessControl.File__c, 
                                UserOrGroupId = fileAccessControl.Grantee__c, 
                                AccessLevel = 'READ', 
                                RowCause = Schema.buildertek__File__Share.RowCause.File_Access_Grantee__c);
            fileShares.add(objFileShare);
        }
        if(!fileShares.isEmpty()){
            BT_NoSharingUtils.createFileShares(fileShares);
        }
    }
    
    public void deleteSharesForGrantee(List<File_Access_Control__c> oldFileAccessControls){
        /*
        List<Id> fileIds = new List<Id>();
        List<Id> granteeIds = new List<Id>();
        for(File_Access_Control__c fileAccessControl : oldFileAccessControls){
            fileIds.add(fileAccessControl.File__c);
            granteeIds.add(fileAccessControl.Grantee__c);
        }
        
        Map<String, File__share> sharesByGranteeIdFileId = new Map<String, File__share>();
        for(List<File__share> fileShare : [Select Id, ParentId, UserOrGroupId From File__share Where RowCause =: Schema.File__Share.RowCause.File_Access_Grantee__c AND ParentId In: fileIds AND UserOrGroupId In :granteeIds]){
            for(Integer i=0; i<fileShare.size(); i++){
                sharesByGranteeIdFileId.put(fileShare[i].ParentId+'-'+fileShare[i].UserOrGroupId, fileShare[i]);
            }
            
            List<File__share> sharesToDelete = new List<File__share>();
            for(File_Access_Control__c fileAccessControl : oldFileAccessControls){
                File__share shareForGrantee = sharesByGranteeIdFileId.get(fileAccessControl.File__c+'-'+fileAccessControl.Grantee__c);
                if( shareForGrantee != null){
                    sharesToDelete.add(shareForGrantee);
                }
            }
            if(!sharesToDelete.isEmpty()){
                BT_NoSharingUtils.deleteShares(sharesToDelete);
            }
        }
        */
    }
}