/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_HomeUtils
* Created by Sagar
*
* - Import files from Amazon to salesforce

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_ImportFilesController {
    public String S3Key;
    public Boolean isNoAmazonCredential{get; set;}
    public Boolean isJobQueued{get; set;}
    public S3.AmazonS3 as3;    //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
    public S3.ListBucketResult listbucket;
    public String treeNodesString {get; set;}
    public File__c file{get; set;}
    public Boolean isFileDownloadHistoryActivate{get; set;}
    Map<String, Double> fileSizeByPath;
    public Boolean isSuccess{get; set;} 
    
    //========================================================//
    //Constructor
    //Initialize variables and objects
    //========================================================//
    public BT_ImportFilesController(){
        isSuccess = false;
        isJobQueued = false;
        isFileDownloadHistoryActivate = BT_HomeUtils.getIsFileDownloadHistoryActivate();
        file = BT_HomeUtils.getDefaultFile();
        getFilesNeedsToImport();
    }
    
    /*
    *   Purpose:    Get the checkable object type for import
    *   Parameters:
    *   UnitTests:  
    */
    public List<String> getImportObjectTypes() {
        List<String> checkableNodes = new List<String>();
        checkableNodes.add('AmazonFile');
        checkableNodes.add('AmazonFolder');
        return checkableNodes;
    }
    
    /*
    *   Purpose:    Get the JSON for tree nodes for import tree
    *   Parameters: 
    *   UnitTests:  
    */
    public void getFilesNeedsToImport(){
        // Check that user is System Admin
        try{
            User currentUser;
            if(Schema.sObjectType.User.fields.Id.isAccessible()
                && Schema.sObjectType.Profile.fields.Name.isAccessible()){
                
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
        String jobId = BT_HomeUtils.getFileImportJobId();
        List<AsyncApexJob> jobsQueuedForImportFiles;
        if(Schema.sObjectType.AsyncApexJob.fields.Id.isAccessible()){
            jobsQueuedForImportFiles = [Select Id From AsyncApexJob Where Id = :jobId AND Status = 'Queued'];    
        }
        
        if(!jobsQueuedForImportFiles.isEmpty()){
            isJobQueued = true;
            return;
        }
        
        //Check for the amazon keys
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
        
        //Nodes for files needs to be deleted
        treeNodesString = '';
        
        //Get the configured buckets
        List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        List<Folder__c> configuredBuckets = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Parent__c = null'));
        
        // Set of configrued buckets
        Set<String> configuredBucketNames = new Set<String>();
        for(Folder__c configuredBucket : configuredBuckets){
            configuredBucketNames.add(configuredBucket.Name);   
        }
        
        //Get all files available in amazon
        //This performs the Web Service call to Amazon S3 and retrieves all the Buckets in your AWS Account. 
        S3.ListAllMyBucketsResult allBuckets = as3.ListAllMyBuckets(amazonS3.key,now,as3.signature('ListAllMyBuckets',now));
        S3.ListAllMyBucketsList bucketList = allBuckets.Buckets;
        S3.ListAllMyBucketsEntry[] buckets = bucketList.Bucket;
       
        //Loop through each bucket entry to get the bucket name and store file path in string set. 
        Set<String> bucketFiles = new Set<String>();
        
        //File by path
        Map<String, S3.ListEntry> bucketEntryByPath = new Map<String, S3.ListEntry>();
        
        // File Names to import
        Set<String> fileNames = new Set<String>();
        
        for(S3.ListAllMyBucketsEntry bucket: buckets){
            Integer maxNumberToList = 125000;     //Set the number of Objects to return for a specific Bucket
            String prefix = null;             //Limits the response to keys that begin with the indicated prefix. You can use prefixes to separate a bucket into different sets of keys in a way similar to how a file system uses folders. This is an optional argument.
            String marker = null;             //Indicates where in the bucket to begin listing. The list includes only keys that occur alphabetically after marker. This is convenient for pagination: To get the next page of results use the last key of the current page as the marker. The most keys you'd like to see in the response body. The server might return less than this number of keys, but will not return more. This is an optional argument.
            String delimiter = null;          //Causes keys that contain the same string between the prefix and the first occurrence of the delimiter to be rolled up into a single result element in the CommonPrefixes collection. These rolled-up keys are not returned elsewhere in the response. 
            
            if(configuredBucketNames.contains(bucket.Name)){
                //This performs the Web Service call to Amazon S3 and retrieves all the objects in the specified bucket
                S3.ListBucketResult objectsForBucket = as3.ListBucket(bucket.Name, prefix, marker,maxNumberToList, delimiter, amazonS3.key,now,as3.signature('ListBucket',now),amazonS3.secret);
                
                if(objectsForBucket.Contents != null){
                    for(S3.ListEntry bucketEntry : objectsForBucket.Contents){
                        String keyWithBucket = bucket.Name+'/'+bucketEntry.Key;
                        
                        // Don't add key for folder only
                        List<String> keyTokens = keyWithBucket.split('/');
                        
                        if(keyTokens.size() > 0 && keyTokens[keyTokens.size() - 1].indexOf('.') != -1){
                            fileNames.add(keyTokens[keyTokens.size() - 1]);
                            bucketFiles.add(keyWithBucket);
                            bucketEntryByPath.put(keyWithBucket, bucketEntry);
                        }
                    }
                }
            }
        }
        
        //Query all those files which are on amazon server.
        fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Key__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        List<File__c> files = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', Folder__r.Amazon_File_Key__c From File__c Where Name In: fileNames LIMIT 1000000'));
        
        //Check if File is there in Amazon
        for(File__c file : files){
            String filePathWithBucket = FileUtils.getAmazonFilePathWithBucket(file);
            if(bucketFiles.contains(filePathWithBucket)){
                bucketFiles.remove(filePathWithBucket);
            }
        }
        
        //Map for file size by file path
        fileSizeByPath = new Map<String, Double>();
        for(String filePath : bucketFiles){
            S3.ListEntry bucketEntry = bucketEntryByPath.get(filePath);
            fileSizeByPath.put(filePath,bucketEntry.size);
        }
        
        // JSON string for tree nodes for import file tree
        treeNodesString = BT_TreeRemotingModel.getTreeNodesFromFilePath(bucketFiles, new Map<String, String>(), fileSizeByPath);
    }
    
    /*
    *   Purpose:    Import files from Amazon to Salesforce
    *   Parameters: Amazon file keys to import
    *   UnitTests:  
    */
    public void importFiles(){
        isSuccess = false;
        // Amazon file keys
        String selectedNodeKeys = ApexPages.CurrentPage().getParameters().Get('selectedNodeKeys');
        
        // Queue the job to import.
        String jobId = System.enqueueJob(new BT_ImportFilesQueueable(selectedNodeKeys, file, fileSizeByPath));
        
        // Set the Job is so next time we can use it to track.
        BT_HomeUtils.setFileImportJobId(jobId); 
        
        // Set success message
        isSuccess = true;
        return;
    }
}