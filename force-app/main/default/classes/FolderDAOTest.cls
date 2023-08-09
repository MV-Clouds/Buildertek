/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Test Class: FolderDAOTest
* Created by Sagar: 14/09/2017
* - Modifications:
* - Sagar, 14/09/2017 – Initial Development 
************************************************************************** */
@isTest
public with sharing class FolderDAOTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
        List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
        System.assertEquals(buckets.size() > 0, true);
    }
    static testMethod void testGetSubfolder() {
        // Get the children for bucket folder
        
        Folder__c bucket = [Select Id From Folder__c Where Name= 'Test_Bucket1' LIMIT 1];
        System.assertEquals(FolderDAO.getChildren(bucket.Id).size(), 3);
        Set<Id> ids = new Set<Id>();
        ids.add(bucket.Id);
        List<String> fields = new List<String>();
        fields.add('Name');
        FolderDAO.getChildren(ids,fields);
        
        System.assertEquals(FolderDAO.getChildrenIds(new Set<Id>{bucket.Id}).size(), 3);
        FolderDAO.getChildren(bucket.Id,fields);
        List<BT_TreeRemotingModel.QueryParameter> qpLst = new List<BT_TreeRemotingModel.QueryParameter>();
        BT_TreeRemotingModel.QueryParameter  qp = new BT_TreeRemotingModel.QueryParameter('Name','Test');
        qpLst.add(qp);
        Map<String, List<BT_TreeRemotingModel.QueryParameter>> qpMap = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
        qpMap.put('key', qpLst);
        String queryParameters =JSON.serialize(qpMap);
        FolderDAO.getChildren(bucket.Id, fields, null, BT_Constants.TREE_UI_MAX_NODE ,queryParameters);
        List<String> folderIds = new List<String>();
        folderIds.add('test Folder');
         List<String> sortFields = new List<String>();
        FolderDAO.getFolders(folderIds,fields,sortFields,1,queryParameters);
        FolderDAO.getChildrenFiles(bucket.Id,fields);
        FolderDAO.getChildrenFiles(bucket.Id, fields,true,sortFields);
        FolderDAO.getChildrenFiles(bucket.Id, fields,true, sortFields,5, queryParameters);
        
        /*
        List<Folder__c> folders1  = FolderDAO.getChildren(new Set<Id>{bucket.Id}, new List<String> {'Name'});
        List<Folder__c> folders2  = FolderDAO.getChildren(bucket.Id, new List<String> {'Name'});
        List<Folder__c> folders3  = FolderDAO.getChildren(bucket.Id, new List<String> {'Name'});
        Map<String, List<BT_TreeRemotingModel.QueryParameter>> folderQueryParameters = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
        folderQueryParameters.put('Folder__c', new List<BT_TreeRemotingModel.QueryParameter>{new BT_TreeRemotingModel.QueryParameter('Parent__c', folders1[0].Id)});
        List<Folder__c> folders4  = FolderDAO.getChildren(bucket.Id, new List<String> {'Name'}, null, JSON.serialize(folderQueryParameters));
        Folder__c folder = [Select Id From Folder__c Where Name = 'Test_Bucket1_Sub_Folder1' Limit 1];
        Map<String, List<BT_TreeRemotingModel.QueryParameter>> fileQueryParameters = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
        fileQueryParameters.put('File__c', new List<BT_TreeRemotingModel.QueryParameter>{new BT_TreeRemotingModel.QueryParameter('Folder__c', folder.Id)});
        List<File__c> files1  = FolderDAO.getChildrenFiles(folder.Id, new List<String> {'Name'}, false, null, 10, JSON.serialize(fileQueryParameters));
        */
    }
}