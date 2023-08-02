/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_CleanupFilesController
* Created by Sagar
*
* Clean up the files from slaeforceorg to sync with Amazon server

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_CleanupFilesController {
    public String S3Key;
    public Boolean isNoAmazonCredential{get; set;}
    public Boolean isJobQueued{get; set;}
    public S3.AmazonS3 as3;    //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
    public S3.ListBucketResult listbucket;
    public String treeNodesString {get; set;}
    List<File__c> filesNeedsToDeleted;
    public Boolean isSuccess{get; set;} 
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_CleanupFilesController(){
        isSuccess = false;
        isJobQueued = false;
        getFilesNeedsToCleanUp();
    }
    
    /*
    *   Purpose:    Get the checkable object type for cleanup
    *   Parameters: 
    *   UnitTests:  
    */
    public List<String> getCleanupObjectTypes() {
        List<String> checkableNodes = new List<String>();
        checkableNodes.add('AmazonFile');
        checkableNodes.add('AmazonFolder');
        return checkableNodes;
    }
    
    /*
    *   Purpose:    Get the JSON for tree nodes for cleanup tree
    *   Parameters: 
    *   UnitTests:  
    */
    public void getFilesNeedsToCleanUp(){
        // Check that user is System Admin
        try{
            User currentUser;
            if (Schema.sObjectType.Profile.fields.Name.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                currentUser = [Select Id, Profile.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];    
            }
            if(currentUser.Profile.Name != 'System Administrator'){
                throw new BT_ApplicationException(System.Label.Page_Access_Error);
            }
        } catch(Exception e){
            isNoAmazonCredential = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        }
        
        // Check if the job for import is already queued or not
        String jobId = BT_HomeUtils.getFileCleanupJobId();
        List<AsyncApexJob> jobsQueuedForCleanupFiles;
        if (Schema.sObjectType.AsyncApexJob.fields.id.isAccessible()) {
            jobsQueuedForCleanupFiles = [Select Id From AsyncApexJob Where Id = :jobId AND Status = 'Queued'];    
        }
        if(!jobsQueuedForCleanupFiles.isEmpty()){
            isJobQueued = true;
            return;
        }
        
        //Get all files available in amazon
        Datetime now = Datetime.now();
        AmazonS3Credential credential;
        try{
            credential = new AmazonS3Credential();
        }catch(AmazonS3Credential.AmazonS3CredentialException AmazonS3CredentialEx){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, AmazonS3CredentialEx.getMessage());
            ApexPages.addMessage(errorMsg);
            isNoAmazonCredential = true;
            return;
        }
        S3.AmazonS3 amazonS3 = new S3.AmazonS3(credential.key,credential.secret);
        as3 = new S3.AmazonS3(amazonS3.key,amazonS3.secret);
        
        //List for files needs to delete
        filesNeedsToDeleted = new List<File__c>();
        
        //Nodes for files needs to be deleted
        treeNodesString = '';
        
        //Get the configured buckets
        List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields); 
        List<Folder__c> configuredBuckets = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Parent__c = null'));
        Set<String> configuredBucketNames = new Set<String>();
        for(Folder__c configuredBucket : configuredBuckets){
            configuredBucketNames.add(configuredBucket.Name);   
        }
        
        //This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. 
        S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(amazonS3.key,now,as3.signature('ListAllMyBuckets',now));
        S3.ListAllMyBucketsList bucketList = allBuckets.Buckets;
        S3.ListAllMyBucketsEntry[] buckets = bucketList.Bucket;
       
        //Loop through each bucket entry to get the bucket name and store file path in string set. 
        Set<String> bucketFiles = new Set<String>();
        
        //File by path
        Map<String, S3.ListEntry> bucketEntryByPath = new Map<String, S3.ListEntry>();
        
        for(S3.ListAllMyBucketsEntry bucket: buckets){
            Integer maxNumberToList = 125000;       //Set the number of Objects to return for a specific Bucket
            String prefix = null;                   //Limits the response to keys that begin with the indicated prefix. You can use prefixes to separate a bucket into different sets of keys in a way similar to how a file system uses folders. This is an optional argument.
            String marker = null;                   //Indicates where in the bucket to begin listing. The list includes only keys that occur alphabetically after marker. This is convenient for pagination: To get the next page of results use the last key of the current page as the marker. The most keys you'd like to see in the response body. The server might return less than this number of keys, but will not return more. This is an optional argument.
            String delimiter = null;                //Causes keys that contain the same string between the prefix and the first occurrence of the delimiter to be rolled up into a single result element in the CommonPrefixes collection. These rolled-up keys are not returned elsewhere in the response. 
            
            if(configuredBucketNames.contains(bucket.Name)){
                //This performs the Web Service call to Amazon S3 and retrieves all the objects in the specified bucket
                S3.ListBucketResult objectsForBucket = as3.ListBucket(bucket.Name, prefix, marker,maxNumberToList, delimiter, amazonS3.key,now,as3.signature('ListBucket',now),amazonS3.secret);
                if(objectsForBucket.Contents != null){
                    for(S3.ListEntry bucketEntry : objectsForBucket.Contents){
                        bucketFiles.add(bucket.Name+'/'+bucketEntry.Key);
                        bucketEntryByPath.put(bucket.Name+'/'+bucketEntry.Key, bucketEntry);
                    }
                }
            }
        }
        
        //Query all those files which are not on amazon server.
        fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Key__c', 'Amazon_File_Path_With_Bucket__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        List<File__c> files = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', Folder__r.Amazon_File_Key__c From File__c LIMIT 1000000'));
        
        //Prepare list of orphaned files
        Set<String> filePathNeedsToDelete = new Set<String>();
        
        Map<String, String> fileIdByPath = new Map<String, String>();
        for(File__c file : files){
            String filePathWithBucket = FileUtils.getAmazonFilePathWithBucket(file);
            if(!bucketFiles.contains(filePathWithBucket)){
                filesNeedsToDeleted.add(file);
                filePathNeedsToDelete.add(filePathWithBucket);
                fileIdByPath.put(filePathWithBucket, file.Id);
            }
        }
        
        // JSON for tree nodes for clean up files tree
        treeNodesString = BT_TreeRemotingModel.getTreeNodesFromFilePath(filePathNeedsToDelete, fileIdByPath, new Map<String, Double>());
    }
    
    /*
    *   Purpose:    Delete  files from Salesforce
    *   Parameters: Salesforce file ids
    *   UnitTests:  
    */
    public void cleanUp(){
        isSuccess = false;
        // Salesfroce files ids
        String selectedNodeKeys = ApexPages.CurrentPage().getParameters().Get('selectedNodeKeys');
        Map<String, String> selectedNodeIdsByKeys = new Map<String, String>();
        selectedNodeIdsByKeys = (Map<String, String>)JSON.deserialize(selectedNodeKeys, Map<String, String>.class);
        List<String> setFileIdsToCleanUp = selectedNodeIdsByKeys.values(); 
        
        // Queues job for file clenup
        Id jobId = System.enqueueJob(new BT_CleanupFilesQueueable(setFileIdsToCleanUp));
        
        // Set the job id
        BT_HomeUtils.setFileCleanupJobId(jobId);
        
        // Set success message
        isSuccess = true;
        return;
    }
}