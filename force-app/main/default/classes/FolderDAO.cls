/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Util Class: FolderDAO
* Created by Sagar: 06/08/2017
*
* - All DAO functions for Folder

* - Modifications:
* - Sagar, 06/08/2017 – Initial Development 
************************************************************************** */
public with sharing class FolderDAO {
    
    public static List<Folder__c> getChildren(Id id){
        Folder__c folder;
          
            folder = [SELECT id ,
                (SELECT id, name FROM Folder__c.Children__r order by name)
                FROM Folder__c WHERE id = :id];
            
        return folder.Children__r;
    }
    
    /**
    Returns the child folders. Only the id and name fields of the child folders are populated.
    **/
    public static List<Folder__c> getChildren(Set<Id> ids, List<String> fields){
        return FolderDAO.getChildren(ids, fields, null);
    }
    public static List<Folder__c> getChildren(Set<Id> ids, List<String> fields, List<String> sortFields){
        List<Folder__c> children = new List<Folder__c>();
        
        String soql = 'SELECT id ,(SELECT id';
        if(fields != null){
            // Check FLS
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        soql = soql + ' FROM Folder__c.Children__r order by createddate) FROM Folder__c WHERE id IN :ids';
        soql = soql + BT_SoqlUtils.buildOrderByClause(sortFields, true);
        
        List<Folder__c> folders = Database.query(soql);
        
        for(Folder__c folder :folders){
            children.addAll(folder.children__r);
        }
        return children;
    }
    
    /** Return the ids of all the children of the folders **/
    public static Set<Id> getChildrenIds(Set<Id> ids){      
        Map<Id, Folder__c> children = new Map<Id, Folder__c>([select id from Folder__c where parent__c in :ids]);
        return children.keySet();
    }
    
    /**
    Returns the child folder. All the specified fields of the child folder are populated.
    **/
    public static List<Folder__c> getChildren(Id id, List<String> fields){
        return FolderDAO.getChildren(id, fields, null, BT_Constants.TREE_UI_MAX_NODE , null);
    }
    public static List<Folder__c> getChildren(Id id, List<String> fields, List<String> sortFields, Integer maxRequestedCount, String queryParameters){
        String soql = 'SELECT id';
        String status = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
        if(fields != null){
            // Check FLS
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        soql = soql + ' FROM Folder__c WHERE Parent__c = :id AND Upload_Status__c  !=: status';
        
        if(queryParameters != '' && queryParameters != null){
            Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParametersByObject = (Map<String, List<BT_TreeRemotingModel.QueryParameter>>)JSON.deserialize(queryParameters.unescapeHtml4(), Map<String, List<BT_TreeRemotingModel.QueryParameter>>.class);
            List<BT_TreeRemotingModel.QueryParameter> lstQueryParameters = queryParametersByObject.get('Folder__c');
            soql = soql + BT_TreeRemotingModel.buildWhereClauseUsingQueryParameters(lstQueryParameters);
        }
        
        soql = soql + BT_SoqlUtils.buildOrderByClause(sortFields, true);
        if(maxRequestedCount != null){
            soql = soql + ' limit ' + maxrequestedCount;
        }
        List<Folder__c> subFolders = Database.query(soql);
        system.debug('subFolders ---------> '+subFolders);
        return subFolders;
    }
    /**
    Returns folders. All the specified fields of the child folder are populated.
    **/
    public static List<Folder__c> getFolders(List<String> folderIds, List<String> fields, List<String> sortFields, Integer maxRequestedCount, String queryParameters){
        String soql = 'SELECT id';
        String status = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
        if(fields != null){
            // Check FLS
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        soql = soql + ' FROM Folder__c WHERE Upload_Status__c  !=: status';
        if(!folderIds.isEmpty()){
            soql = soql + ' AND Id In: folderIds ';
        }
        if(queryParameters != '' && queryParameters != null){
            Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParametersByObject = (Map<String, List<BT_TreeRemotingModel.QueryParameter>>)JSON.deserialize(queryParameters.unescapeHtml4(), Map<String, List<BT_TreeRemotingModel.QueryParameter>>.class);
            List<BT_TreeRemotingModel.QueryParameter> lstQueryParameters = queryParametersByObject.get('Folder__c');
            soql = soql + BT_TreeRemotingModel.buildWhereClauseUsingQueryParameters(lstQueryParameters);
        }
        
        soql = soql + BT_SoqlUtils.buildOrderByClause(sortFields, true);
        if(maxRequestedCount != null){
            soql = soql + ' limit ' + maxrequestedCount;
        }
        List<Folder__c> folders = Database.query(soql);
        return folders;
    }
    /**
    Returns the child files. All the specified fields of the child files are populated.
    **/
    public static List<File__c> getChildrenFiles(Id id, List<String> fields){
        return FolderDAO.getChildrenFiles(id, fields, false, null, null, null);
    }
    public static List<File__c> getChildrenFiles(Id id, List<String> fields, Boolean immediateChildrenOnly, List<String> sortFields){
        return FolderDAO.getChildrenFiles(id, fields, immediateChildrenOnly, sortFields, null, null);
    }
    public static List<File__c> getChildrenFiles(Id id, List<String> fields, Boolean immediateChildrenOnly, List<String> sortFields, Integer maxRequestedCount, String queryParameters){
        String status = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
        String soql = 'SELECT id';
        if(fields != null){
            // Check FLS
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            for(String field : fields){
                if(field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }
        soql = soql + ' FROM File__c WHERE Folder__c = :id AND Upload_Status__c  !=: status';
        
        if(queryParameters != '' && queryParameters != null){
            Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParametersByObject = (Map<String, List<BT_TreeRemotingModel.QueryParameter>>)JSON.deserialize(queryParameters.unescapeHtml4(), Map<String, List<BT_TreeRemotingModel.QueryParameter>>.class);
            List<BT_TreeRemotingModel.QueryParameter> lstQueryParameters = queryParametersByObject.get('File__c');
            soql = soql + BT_TreeRemotingModel.buildWhereClauseUsingQueryParameters(lstQueryParameters);
        }
        
        soql = soql + BT_SoqlUtils.buildOrderByClause(sortFields, true);
        if(maxRequestedCount != null){
            soql = soql + ' limit ' + maxrequestedCount;
        }
        return (List<File__c>)Database.query(soql);
    }
}