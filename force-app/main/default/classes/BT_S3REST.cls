/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Util Class: BT_S3REST
* Created by Sagar
*
* - Utils for REST

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_S3REST {
    
    //  Method to PUT object on Amazon Server
    /*
    @future(callout=true)
    public static void PutFile(String EmailMsgId, String relatedToId, Blob fileContent, String filekey, String bucketName, String contentType, String region, String key, String secret){
        
        List<Folder__c> configuredBuckets = Database.query('Select Id, Name From Folder__c Where Parent__c = null');
        List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c'};
        SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
        
        bucketName = configuredBuckets[0].Name;
        
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Denver');
        String filename = filekey;
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setHeader('Content-Type', contentType);
        req.setMethod('PUT');
        //req.setHeader('x-amz-acl', 'public-read-write');
        req.setHeader('Host','s3' + region + '.amazonaws.com');
        req.setEndpoint('https://s3' + region + '.amazonaws.com' + '/'+ bucketName + '/' + filename);
        req.setHeader('Date', formattedDateString);
        String stringToSign = 'PUT\n\n'+contentType+'\n'+formattedDateString+'\n/'+bucketName+'/'+filename;
        req.setHeader('Authorization',createAuthHeader(stringToSign, key, secret));
        if(fileContent != null ){
            system.debug('---fileContent---'+fileContent);
            req.setBodyAsBlob(fileContent);
            req.setHeader('Content-Length', string.valueOf(fileContent.size()));
            // Execute web service call
            try {
                if(!Test.isRunningTest()){
                    HTTPResponse res = http.send(req);
                    system.debug(res);
                    system.debug('https://s3' + region + '.amazonaws.com' + '/'+ bucketName + '/' + filename);
                    
                    BT_UploadFileController.File fileObj = new BT_UploadFileController.File();
                    fileObj.Name = filekey;
                    fileObj.Size = fileContent.size();
                    fileObj.Folder = configuredBuckets[0].Id;
                    fileObj.ContentType = contentType;
                    //fileObj.Extension = bAttachment.Extension;
                    fileObj.AccessType = 'Public Download Only';
                    fileObj.AllowCopy = true;
                    fileObj.PublicOnAmazon = true;
                    fileObj.Replace = false;
                    fileobj.BucketName = bucketName;
                    fileobj.AllowShareViaURL = true;
                    fileobj.TrackDownload = true;
                    
                    String baseObject = Id.valueOf(relatedToId).getSObjectType().getDescribe().getName();
                    Id fileID = BT_UploadFileController.insertFiles(fileobj, baseObject, relatedToId);
                    
                    system.debug('---EmailMsgId---'+EmailMsgId);
                    EmailMessage Email = [SELECT HasAttachment, Subject, Id, ActivityId, TextBody, HtmlBody FROM EmailMessage where id =:EmailMsgId];
                    
                    fields = new List<String>{'Id','Name', 'OwnerId', 'Amazon_File_Key__c', 'File_Presigned_URL__c', 'Bucket_Name__c', 'Access_Type__c', 'Track_Download_History__c'};
                    SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
                    List<File__c> selectedFiles = Database.query('SELECT '+ BT_Utils.buildSelectListFragment(BT_EmailFilesToUsersController.fileEmailFields(), null, fields)+' FROM File__c where Id =:fileID');
                    Email.HtmlBody = Email.HtmlBody +  prepareEmailContentForFilesDownloadLink(selectedFiles, System.now().addDays(10));
                    
                    update Email;
                } 
            } catch(System.CalloutException e) {
                system.debug('***ERROR: ' + e.getMessage());
            }
        }
    }
    
    //  Method to PUT object on Amazon Server
    public static Boolean PutBucket(String bucketName, String contentType, String key, String secret){
        String formattedDateString = Datetime.now().format('EEE, dd MMM yyyy HH:mm:ss z','America/Denver');
        
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        
        req.setHeader('Content-Type', contentType);
        req.setMethod('PUT');
        req.setHeader('Host','s3.amazonaws.com');
        req.setEndpoint('https://s3.amazonaws.com/'+bucketName);
        req.setHeader('Date', formattedDateString);
        String stringToSign = 'PUT\n\n'+contentType+'\n'+formattedDateString+'\n/'+bucketName;
        req.setHeader('Authorization', createAuthHeader(stringToSign, key, secret));
        
        try {
            if(!Test.isRunningTest()){
                HTTPResponse res = http.send(req);
            } else{
                return false;
            }
        } catch(System.CalloutException e) {
            system.debug('***ERROR: ' + e.getMessage());
            return false;
        }
        return true;
    }
    
    // Create authorization header for Amazon S3 REST API
    public static string createAuthHeader(String stringToSign, String key, String secret){
        string auth;
        Blob mac = Crypto.generateMac('HMACSHA1', blob.valueof(stringToSign),blob.valueof(secret));
        String sig = EncodingUtil.base64Encode(mac);
        auth = 'AWS' + ' ' + key + ':' + sig;
        return auth;
    }
    
    
    public static string prepareEmailContentForFilesDownloadLink(List<File__c> files, DateTime expiryDate){
        // Get AWS credentials
        AmazonS3Credential s3Credentials = new AmazonS3Credential();
        
        String emailContent = '';
        emailContent +='<table cellpadding="5"><tr style="background-color:#007fcc;color:white;font-weight:bold;">';
        List<Schema.FieldSetMember> emailFileFields = BT_EmailFilesToUsersController.fileEmailFields();
        for(Schema.FieldSetMember field : emailFileFields){
            emailContent +='<th>'+field.getLabel()+'</th>';
        }
        emailContent +='<th>'+System.Label.Expiry_Date+'</th>';
        emailContent +='<th>'+System.Label.Action+'</th><tr>';
        for(File__c file : files){
            emailContent +='<tr>';
            String fileDownloadLinkHTML = '';
            String expiryDateString = '';
            //Check for file access type and encript the link if the file is private
            fileDownloadLinkHTML ='<a href="'+ FileUtils.getPresignedURL(file.Bucket_Name__c, file.Amazon_File_Key__c, expiryDate, s3Credentials.key, s3Credentials.secret)+'">'+System.Label.Download+'</a>';
            expiryDateString =  expiryDate.format();
            for(Schema.FieldSetMember field : emailFileFields){
                String fieldValue = file.get(field.getFieldPath()) != null ? String.valueOf(file.get(field.getFieldPath())) : '';
                if(field.getFieldPath() == 'Name'){
                    emailContent +='<td style="font-weight: bold;">'+ fieldValue+'</td>';
                } else if(field.getType() == Schema.DisplayType.Boolean){
                    emailContent +='<td>'+(fieldValue == 'true'? Label.Yes : Label.No)+'</td>';
                } else{
                    emailContent +='<td>'+fieldValue+'</td>';
                }
            }
            emailContent +='<td>'+expiryDateString+'</td>';
            emailContent +='<td>'+fileDownloadLinkHTML+'</td>';
            emailContent +='</tr>';
        }
        emailContent +='</table>';
        return emailContent;
    }
    */
}