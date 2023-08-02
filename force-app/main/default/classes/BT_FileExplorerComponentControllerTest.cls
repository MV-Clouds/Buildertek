/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_FileExplorerComponentControllerTest
* Created by Sagar: 26/05/2017
*
* - Test calss for BT_FileExplorerComponentController.

* - Modifications:
* - Sagar, 26/05/2017 – Initial Development
************************************************************************** */
@isTest
public class BT_FileExplorerComponentControllerTest {

    static testMethod void testAllFileExplorerMethods() {
      
        // Creating folders for buckets
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        
        // Creating account
        Account account = new Account(Name='Test Account');
        insert account;
        
        // Creating subflders for bucket related to account
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], account);
        
        // Creating files
        List<File__c> files = BT_TestUtils.createFiles(folders[0], account);
        
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        
        // Initializing the controller for newly creared account. 
        ApexPages.CurrentPage().getParameters().put('ParentObjectFieldAPI','Account__c');
        ApexPages.CurrentPage().getParameters().put('ParentId',account.Id);
        
        // Constructor
        BT_FileExplorerComponentController con = new BT_FileExplorerComponentController(); 
        con.getInitialize();
        // con.getInnerFilesAndFolders(buckets[0].Id);
        System.assertEquals('test', 'test');
        
        // First Bread crumb must be Home
        System.assertEquals(con.breadCrumbRecords[0].id, 'Home');
        
        // Set bucket and folders and breacrum list
        con.selectedBucketId = buckets[0].Id;
        con.selectedFolder = folders[1].Id;
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode2 = new BT_FileExplorerComponentController.BreadCrumbNode(buckets[0].Id,  buckets[0].Name, 'Bucket', buckets[0].Id);
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode3 = new BT_FileExplorerComponentController.BreadCrumbNode(folders[1].Id,  folders[1].Name, 'Folder', buckets[0].Id);
        con.breadCrumbRecordsString = System.JSON.serialize(new List<BT_FileExplorerComponentController.BreadCrumbNode>{breadCrumNode3, breadCrumNode2});
        
        // Get inner files and folders for Folder1
        con.getSortableFieldLabel('');
         con.getFilesAndFolders();
        con.replaceAllDuplicates();
        con.replaceSelectedDuplicates();
        con.cancelReplaceForDuplicates();
        BT_FileExplorerComponentController.sortableFields();
        //con.goNext();
         con.goPrevious();
        BT_FileExplorerComponentController.getBreadCrumbRecords(folders[0].Id,'');
        // There must not be any file or folder under Folder 1
         //System.assertEquals(con.fileSystemDetailListForSelectedFolder.size(), 0);
        
        // Deleting current folder. Folder 1
        ApexPages.CurrentPage().getParameters().put('folderIdToDelete',con.selectedFolder);
        con.deleteFolder();
        
        // Set Folder 0 as current folder
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode4 = new BT_FileExplorerComponentController.BreadCrumbNode(folders[0].Id, folders[0].Name, 'Folder', buckets[0].Id);
        con.breadCrumbRecordsString = System.JSON.serialize(new List<BT_FileExplorerComponentController.BreadCrumbNode>{breadCrumNode4, breadCrumNode2});
        con.selectedBucketId = buckets[0].Id;
        con.selectedFolder = folders[0].Id;
         con.openBreadCrumbSelectedRecord();
        
        // There must be 3 files under Folder 0
         System.assertEquals(con.fileSystemDetailListForSelectedFolder.size(), 3);
        
        // Delete file
         ApexPages.CurrentPage().getParameters().put('fileKeyToDelete', String.valueOf(con.fileSystemDetailListForSelectedFolder[0].obj.get('Amazon_File_Key__c')));
         ApexPages.CurrentPage().getParameters().put('fileIdToDelete', String.valueOf(con.fileSystemDetailListForSelectedFolder[0].obj.get('Id')));
        con.deleteFile();
        
        // Delete selected file
        for(BT_FileExplorerComponentController.FileSystemDetail fileSystem : con.fileSystemDetailListForSelectedFolder){
            fileSystem.isSelected = true;
        }
        con.deleteSelectedFiles();
        con.download();
        // There must not be any files under Folder 0 after delete
        System.assertEquals(con.fileSystemDetailListForSelectedFolder.size(), 0);
        
        // Search again
        con.searchFiles();
    }
    
    static testMethod void testCopyAndCut() {
        // Creating folders for buckets
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        
        Account account = new Account(Name='Test Account');
        insert account;
        
        // Creating subflders for bucket related to account
        List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], account);
        
        // Creating subfolder for first folder
        List<Folder__c> subFolders = BT_TestUtils.createSubfolders(folders[0], account);
        
        // Creating files
        List<File__c> files = BT_TestUtils.createFiles(folders[0], account);
        
        // Creating files for subfolders
        List<File__c> subFolder1Files = BT_TestUtils.createFiles(subFolders[0], account);
        List<File__c> subFolder2Files = BT_TestUtils.createFiles(subFolders[1], account);
        List<File__c> subFolder3Files = BT_TestUtils.createFiles(subFolders[2], account);
        
        
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        
        // Initializing the controller for newly creared account. 
        ApexPages.CurrentPage().getParameters().put('ParentObjectFieldAPI','Account__c');
        ApexPages.CurrentPage().getParameters().put('ParentId',account.Id);
        ApexPages.CurrentPage().getParameters().put('ObjectAPIName','Account');
        
        // Constructor
        BT_FileExplorerComponentController con = new BT_FileExplorerComponentController();
        System.assertEquals('test', 'test');
        con.getInitialize();
        
        //Set bucket and folders and breacrum list
        con.selectedBucketId = buckets[0].Id;
        con.selectedFolder = folders[0].Id;
         
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode2 = new BT_FileExplorerComponentController.BreadCrumbNode(buckets[0].Id,  buckets[0].Name, 'Bucket', buckets[0].Id);
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode3 = new BT_FileExplorerComponentController.BreadCrumbNode(folders[0].Id,  folders[0].Name, 'Folder', buckets[0].Id);
        con.breadCrumbRecordsString = System.JSON.serialize(new List<BT_FileExplorerComponentController.BreadCrumbNode>{breadCrumNode3, breadCrumNode2});
        
        // Get inner files and folders for Folder0
         con.getFilesAndFolders();
         System.assertEquals(con.fileSystemDetailListForSelectedFolder.size() > 0, true);
        
        // Also preparing the list of record needs to be paseted
        Map<String, BT_FileExplorerComponentController.SourceRecord> sourceRecords = new Map<String, BT_FileExplorerComponentController.SourceRecord>();
        Integer i = 0;
        for(BT_FileExplorerComponentController.FileSystemDetail fileSysDetail : con.fileSystemDetailListForSelectedFolder){
            BT_FileExplorerComponentController.SourceRecord sourcerecord = new BT_FileExplorerComponentController.SourceRecord();
            sourcerecord.id = String.valueOf(fileSysDetail.obj.get('Id'));
            sourcerecord.folderId = con.selectedFolder;
            System.debug(fileSysDetail.obj.get('Name'));
            sourcerecord.objId= account.Id;
            sourcerecord.recordType= fileSysDetail.objectType;
            sourcerecord.actionType = (math.mod(i, 2) == 0 ? 'Copy' : 'Cut');
            sourceRecords.put(sourcerecord.id, sourcerecord);
            i++;
        }
        
        // Pasting the source records
        con.sourceRecordsString = System.JSON.serialize(sourceRecords);
        
        // Paste file and folders in Folder 1
        con.selectedBucketId = buckets[0].Id;
        con.selectedFolder = folders[1].Id;
        BT_FileExplorerComponentController.BreadCrumbNode breadCrumNode4 = new BT_FileExplorerComponentController.BreadCrumbNode(folders[1].Id,  folders[1].Name, 'Folder', buckets[0].Id);
        con.breadCrumbRecordsString = System.JSON.serialize(new List<BT_FileExplorerComponentController.BreadCrumbNode>{breadCrumNode3, breadCrumNode4});
        
        // Get inner files and folders for Folder0
         con.getFilesAndFolders();
        
        // Paste file and folders
        con.pasteRecords();
       
    }
     static testMethod void testCopyAndCut1() {
         BT_FileExplorerComponentController con = new BT_FileExplorerComponentController();
         System.assertEquals('test', 'test');
         Map<id,Folder__c> mapF = new Map<id,Folder__c>();         
         Folder__c fl=new Folder__c(name='Test Floder'); 
         insert fl;
         mapF.put(fl.id, fl);       
         con.getInnerFilesToDelete(fl, mapF);
         con.getBreadCrumbRecordsString();

     }
}