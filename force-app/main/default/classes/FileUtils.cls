/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Utils Class: FileUtils
* Created by Sagar: 25/09/2017
*
* - All utility method for file.

* - Modifications:
* - Sagar, 25/09/2017 – Initial Development
************************************************************************** */
public with sharing class FileUtils {
    /*
    *   Executed:   On before insert/update of file
    *   Purpose:    Set the extension if missing
    *   Parameters: 
    *   UnitTests:  
    */
    public static void setFileNameWithExtension(List<File__c> files){
        for(File__c file : files){
            String extension = '.undefined';
            if(file.Name.contains('.')){
                extension = file.Name.substring(file.Name.lastIndexOf('.'), file.Name.length());
            } else{
                extension = file.Extension__c;
            }
            
            if(extension == null || extension == '' || extension == '.'){
                if(file.Extension__c == null){
                    extension = '.undefined';
                } else{
                    extension = file.Extension__c;
                }
            }
            
            file.Extension__c = extension;
            if(file.Name.contains('.')){
                if(file.Name.lastIndexOf('.') == file.Name.length() - 1){
                    file.Name = file.Name.substring(0, file.Name.length()-1)+file.Extension__c;
                }
            } else{
                file.Name = file.Name+file.Extension__c;
            }
        }
    }
    
    /*
    *   Executed:   On before insert of file
    *   Purpose:    Setting the Amazon File Path
    *   Parameters: 
    *   UnitTests:  
    */
    public static void setAmazonFilePath(List<File__c> files){
    
        // Parent folder ids
        Set<Id> parentFolderIds = new Set<Id>();
        for(File__c file: files){
            parentFolderIds.add(file.Folder__c);
        }
        
        // Get the parent folders.
        Map<Id, Folder__c> parentFoldersById = new Map<Id, Folder__c>();
        List<String> fields = new List<String>{'Id', 'Name', 'Amazon_File_Key__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        for(Folder__c folder : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Folder__c Where Id In: parentFolderIds'))){
            parentFoldersById.put(folder.Id, folder);
        }
        
        for(File__c file : files){
            if(file.Folder__c != null){
                Folder__c parentFolder = parentFoldersById.get(file.Folder__c);
                file.Amazon_File_Key__c = (parentFolder != null && parentFolder.Amazon_File_Key__c != null ? parentFolder.Amazon_File_Key__c+'/'+file.Name : file.Name);
            }
        }
    }
    
    /*
    *   Executed:   On before insert/update of file
    *   Purpose:    Set the Encode Presigned URL for files
    *   Parameters: 
    *   UnitTests:  
    */
    public static void setPresignedURL(List<File__c> files){
        // Get AWS credentials
        AmazonS3Credential s3Credentials = new AmazonS3Credential();
        
        for(File__c objFile : files){
            if(!objFile.Public_On_Amazon__c){
                
                if(objFile.Allow_to_Download_by_Presigned_URL__c){
                    // Current time
                    Datetime now = DateTime.now();
                        
                    // Get the days as per the frequency
                    Integer days = BT_Constants.FREQUENCY_MAP.get(objFile.Presigned_URL_Frequency__c);
                    
                    // If null set it to 30 by default
                    days = days != null ? days : 30;
                    
                    // Set Next Date For Presigned URL 
                    objFile.Presigned_URL_Expire_Date__c = System.today().addDays(days);
                    
                    Datetime expiryDate = now.addDays(days);
                    
                    // Set as Presigned file URL
                    objFile.File_Presigned_URL__c = FileUtils.getPresignedURL(objFile.Bucket_Name__c, objFile.Amazon_File_Key__c, expiryDate, s3Credentials.key, s3Credentials.secret);
                
                }
                    
            } else{
                
                // If file is public noe need to add signature
                objFile.File_Presigned_URL__c = 'https://s3.amazonaws.com/'+objFile.Bucket_Name__c+'/'+BT_EncodingUtil.urlEncode(objFile.Amazon_File_Key__c);
            }
        }
    }
    
    /*
    *   Purpose:    Get the Encode Presigned URL for files
    *   Parameters: 
    *   UnitTests:  
    */
    public static string getPresignedURL(String bucket, String fileKey, Datetime expiryDate, String accessKey, String secretKey){
        String encodedFileKey = BT_EncodingUtil.urlEncode(fileKey);
        
        // Get the time in Long
        Long Lexpires = expiryDate.getTime()/1000;
        
        // String to sign
        String stringToSign = 'GET\n\n\n'+Lexpires+'\n/'+bucket+'/'+encodedFileKey;
        
        // Signature to pass as get request
        String singature = BT_CryptoUtils.createSignature(stringToSign, secretKey);
        
        // Encoding of signature 
        String codedsigned = EncodingUtil.urlEncode(singature,'UTF-8');
        
        // Set as Presigned file URL
        return 'https://s3.amazonaws.com/'+bucket+'/'+encodedFileKey+'?AWSAccessKeyId='+accessKey+'&Expires='+Lexpires+'&Signature='+codedsigned;
    }
    
    /*
    *   Purpose:    Get the Amazon Folder Path With Bucket
    *   Parameters: 
    *   UnitTests:  
    */
    public static string getAmazonFilePathWithBucket(File__c file){
        String filePathWithBucket = '';
        If(file.Bucket_Name__c != null && file.Bucket_Name__c != ''){
            filePathWithBucket = file.Bucket_Name__c+'/';
        }
        filePathWithBucket += (file.Amazon_File_Key__c != null && file.Amazon_File_Key__c != '' ? file.Amazon_File_Key__c : file.Name);
        return filePathWithBucket;
    }
    
    /*
    *   Executed:   On before insert/update of file
    *   Purpose:    Check for dupliacate file path
    *   Parameters: 
    *   UnitTests:  
    */
    public static Boolean skipDuplicateFileNameValidation = false;
    public static void checkForDuplicateFileName(List<File__c> files){
        // Check for the duplicate file name
        Set<String> newFileNames = new Set<String>();
        for(File__c file: files){
              newFileNames.add(file.Name);          
        }
        
        // Get other file id with the same name
        Map<String, String> existingFileIdsByPath = new Map<String, String>();
        List<String> fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Key__c'};
        SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
        for(File__c file : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File__c Where Name In: newFileNames'))){
            existingFileIdsByPath.put(file.Bucket_Name__c+'/'+file.Amazon_File_Key__c, file.Id);
        }
        
        // Check if there is any duplicate file found
        if(!existingFileIdsByPath.values().isEmpty()){
            for(File__c file: files){
                /*if(!skipDuplicateFileNameValidation && existingFileIdsByPath.get(file.Bucket_Name__c+'/'+file.Amazon_File_Key__c) != file.Id){
                    file.addError(String.format(system.Label.Duplicate_File_Name_Message, new String[]{File.Name}));
                }*/
                if(file.Name.contains('>') || file.Name.contains('<') || file.Name.contains('?') || file.Name.contains('&') || file.Name.contains('/')){
                    file.addError(System.Label.Invalid_File_Name_Message);
                }
            }
        }
    }
}