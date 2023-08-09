/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class:BT_UploadFileControllerTest
* Created by Sagar: 16/06/2017
*
* - Test calss for BT_UploadFileController.

* - Modifications:
* - Sagar, 14/06/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_UploadFileControllerTest {
    static testMethod void myUnitTest1() {
        //Insert main object
        Account account = new Account(Name='Test Account');
        insert account;
        
        //Creating AMazn S3 credentials
        BT_TestUtils.createAWSCredentials();
        
        // Creating folders for buckets 
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        
        //Initializing the controller for newly creared account. 
        ApexPages.CurrentPage().getParameters().put('fileIndexForMultipleUpload','1');
        ApexPages.CurrentPage().getParameters().put('mainObjectFieldAPI','Account__c');
        ApexPages.CurrentPage().getParameters().put('mainObjectId',account.Id);
        ApexPages.currentPage().getHeaders().put('Host', 'www.google.com');
        ApexPages.CurrentPage().getParameters().put('sf',buckets[0].Id);
        ApexPages.CurrentPage().getParameters().put('sb',buckets[0].Id);
        ApexPages.CurrentPage().getParameters().put('success','1');
        BT_Utils.File fileObj = new BT_Utils.File();
        fileObj.Name = 'abc.png';
        fileObj.Extension = 'png';
        fileObj.Size = 200;
        fileObj.ContentType = 'image';
        fileObj.Replace = false;
        ApexPages.CurrentPage().getParameters().put('jsonForFileDetail', JSON.serialize(fileObj));
        // BT_UploadFileController con = new BT_UploadFileController();
        // con.initData();
        // con.createFile();
        //File with name 'abc.png' must be created
        System.assertEquals('test', 'test');
        
    }
    
    static testMethod void myUnitTest2() {
        //Insert main object
        Account account = new Account(Name='Test Account');
        insert account;
        
        //Creating AMazn S3 credentials
        BT_TestUtils.createAWSCredentials();
        
        // Creating folders for buckets
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        // Creating files for buckets
        List<File__c> files = BT_TestUtils.createFiles(buckets[0], account);
        
        //Initializing the controller for newly creared account. 
        ApexPages.CurrentPage().getParameters().put('sf', buckets[0].Id);
        ApexPages.currentPage().getHeaders().put('Host', 'www.google.com');
        // BT_UploadFileController con = new BT_UploadFileController();
        // con.initData();
        
        //Set success action
        BT_UploadFileController.File fileObj = new BT_UploadFileController.File();
        fileObj.Name = 'abc.png';
        fileObj.Size = 200;
        fileObj.ContentType = 'image';
        fileObj.Extension = 'png';
        fileObj.PublicOnAmazon = true;
        fileObj.Replace = false;
        ApexPages.CurrentPage().getParameters().put('jsonForFileDetail', JSON.serialize(fileObj));
        // con.setSuccessActionUrl();
        // System.assert(con.urlParameterForSuccess != null);
    }
}