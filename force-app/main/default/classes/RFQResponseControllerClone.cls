/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  13-Jul-2018
*/
public with sharing class RFQResponseControllerClone {
    
    public string rfqVendorId {get;set;}
    public RFQ_To_Vendor__c rfqToVendor {get;set;}
    public List<buildertek__RFQ_Item__c> rfqItems {get;set;}
    public String uploadFileURL {get;set;}
    public String rfqId {get;set;}
    public string selectedFolder {get;set;}
    public String quoteSubmitted {get; set;}
    public string parentFolder {get;set;}
    public string mainObjectFieldAPI {get;set;}
    public string mainObjectId {get;set;}
    public string otherObjectFieldAPI {get;set;}
    public string otherObjectId {get;set;}
    public buildertek__Project__c project { get; set; }
    public List<File__c> files {get;set;}
    
    public List<WrapperVerdorLineList> wrapList {get;set;}
    public Integer rowToRemove {get;set;}
    public Boolean displayPopUp { get; set; } 
    
    public string selectedBucket { get; set; }
    public string filename { get; set; }
    public string filekey { get; set; }
    public string s3AccessKey { get; set; }
    public string policy { get; set; }
    public string signedPolicy { get; set; }
    public string redirectUrl { get; set; }
    
    public RFQResponseControllerClone(){
        displayPopUp = false;
        wrapList = new List<WrapperVerdorLineList>();
        rfqVendorId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        rfqToVendor = new buildertek__RFQ_To_Vendor__c();
        files = new List<File__c> ();
        try{
            String query = 'Select RFQ__r.Due_Date__c,RFQ__r.Name,RFQ__r.RFQ_Details__c,RFQ__r.Auto_Number__c,RFQ__r.Project__c,RFQ__r.Project__r.Name,'+BT_Utils.getQueryStringForObjectWithAllFields('buildertek__RFQ_To_Vendor__c')+',(Select id,Name,Item_Name__c,Vendor_Note__c,Quantity__c,Unit_Price__c,Total_Price__c,Description__c,Budget_Line_Amount__c, buildertek__RFQ_Item__c from Vendor_Items__r),(Select Id, Name, File__r.Name, File__r.File_Presigned_URL__c,File__r.Description__c,File__r.Download_Link__c,File__r.Download_Link1__c from RFQ_To_Vendor_Document_Links__r), (Select Id, Name, File_Presigned_URL__c,Description__c from Files__r) From buildertek__RFQ_To_Vendor__c where ID =:rfqVendorId order by Name';
            
            rfqToVendor =  (buildertek__RFQ_To_Vendor__c)Database.query(query)[0];
            List<Folder__c> defaultBucketFolders;
            if(Schema.sObjectType.Folder__c.fields.Id.isAccessible() &&
               Schema.sObjectType.Folder__c.fields.Name.isAccessible()&&
               Schema.sObjectType.Folder__c.fields.buildertek__Description__c.isAccessible()){
                   defaultBucketFolders = [Select Id, Name From Folder__c Where Default__c = true AND Active__c = true];
               }
            if(defaultBucketFolders != null && !defaultBucketFolders.isEmpty()){
                String folderId = defaultBucketFolders[0].Id;
                String selectedBucketId = defaultBucketFolders[0].Id;
                
                selectedBucket = defaultBucketFolders[0].Name;
                parentFolder = defaultBucketFolders[0].Id;
                selectedFolder = defaultBucketFolders[0].Id;
                mainObjectFieldAPI = 'buildertek__RFQ_To_Vendor__c';
                mainObjectId = rfqToVendor.Id;
                quoteSubmitted = rfqToVendor.Status__c;
                
                if(Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible()
                   && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isAccessible() 
                   && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isAccessible()){
                       rfqItems = [SELECT Id, Name, buildertek__RFQ_Package__c, buildertek__Unit_Price__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Total_Price__c, buildertek__Notes_Details__c FROM buildertek__RFQ_Item__c WHERE buildertek__RFQ_Package__c =: rfqToVendor.buildertek__RFQ__c]; 
                   }
                
                
                uploadFileURL = '/apex/buildertek__BT_UploadFile?sf='+folderId+'&clr=false&sb='+selectedBucketId;
                uploadFileURL += '&mofa=buildertek__RFQ_To_Vendor__c&moi='+rfqToVendor.Id;
                uploadFileURL += '&retURL=/apex/buildertek__rfqresponse?id='+rfqVendorId;
            } 
            
            files = rfqToVendor.Files__r;
            
        } catch(Exception ex) {
            // throw exception
        }
    }
    
    public void submintQuote(){
        Integer numberOfDays;
        system.debug('Subsmitted Date ----------> '+rfqToVendor.Submitted_Date__c);
        rfqToVendor.Submitted_Date__c = system.now();
        rfqToVendor.Status__c = 'Quote Submitted';
        if (Schema.sObjectType.RFQ_To_Vendor__c.fields.Status__c.isUpdateable()
            && Schema.sObjectType.RFQ_To_Vendor__c.fields.Submitted_Date__c.isUpdateable()
           ){
               update rfqToVendor;
           }
        if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Quantity__c.isUpdateable()
           && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Unit_Price__c.isUpdateable()
           && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor_Note__c.isUpdateable()
           && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Description__c.isUpdateable()){ 
               update rfqToVendor.Vendor_Items__r;
           } 
        if(Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isUpdateable() &&
           Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() &&
           Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Description__c.isUpdateable() &&
           Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Notes_Details__c .isUpdateable() &&
           Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Total_Price__c.isUpdateable() ){
            update rfqItems;
        }
        system.debug('rfqToVendor.Vendor_Items__r ---------> '+rfqToVendor.Vendor_Items__r);
        system.debug('RFQ ---------> '+rfqToVendor.buildertek__RFQ__c);
        
        List<buildertek__RFQ_Vendor_Item__c> RecordsToBeInserted = new List<buildertek__RFQ_Vendor_Item__c>();
        
        system.debug('wrapList ---------> '+wrapList);
        if(wrapList !=null && !wrapList.isEmpty()){
            for(WrapperVerdorLineList eachRecord : wrapList ){
                
                buildertek__RFQ_Vendor_Item__c lineRec = eachRecord.record;
                lineRec.buildertek__Vendor__c = rfqVendorId;
                RecordsToBeInserted.add(lineRec);
                
                
            }
            
            
            if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.isCreateable() &&
               Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Quantity__c.isCreateable()
               && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Unit_Price__c.isCreateable()
               && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor__c.isCreateable()
               && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor_Note__c.isCreateable()
               && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Description__c.isCreateable()){
                   insert RecordsToBeInserted;
               }
            
            
            refreshFiles();
            wrapList = new List<WrapperVerdorLineList>();
            
        }
        if(rfqToVendor.buildertek__RFQ__c !=null){
            List<buildertek__RFQ__c> rfqreclst;
            if(Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()
               && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() 
               && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Replied_To__c.isAccessible()){
                   rfqreclst = [SELECT Id,
                                Name,
                                buildertek__RFQ_s_Replied_To__c
                                FROM buildertek__RFQ__c
                                WHERE Id =: rfqToVendor.buildertek__RFQ__c]; 
                   
               }
            if(rfqreclst.size()>0){
                if(rfqreclst[0].buildertek__RFQ_s_Replied_To__c != null){
                    rfqreclst[0].buildertek__RFQ_s_Replied_To__c +=1;
                }
                else{
                    rfqreclst[0].buildertek__RFQ_s_Replied_To__c = 1;
                }
                if(Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_s_Replied_To__c.isUpdateable()){
                    update rfqreclst;
                }
            }
        }
        
    }
    
    
    public pagereference uploadDocument(){
        return new pagereference('/' + uploadFileURL);
    }
    
    public void refreshFiles(){
        try{
            String query = 'Select RFQ__r.Due_Date__c,RFQ__r.Name,RFQ__r.RFQ_Details__c,RFQ__r.Auto_Number__c,RFQ__r.Project__r.Name,'+BT_Utils.getQueryStringForObjectWithAllFields('buildertek__RFQ_To_Vendor__c')+',(Select id,Name,Item_Name__c,Vendor_Note__c,Quantity__c,Unit_Price__c,Total_Price__c,Description__c,Budget_Line_Amount__c, buildertek__RFQ_Item__c from Vendor_Items__r),(Select Id, Name, File__r.Name, File__r.File_Presigned_URL__c,File__r.Description__c,File__r.Download_Link__c,File__r.Download_Link1__c from RFQ_To_Vendor_Document_Links__r), (Select Id, Name, File_Presigned_URL__c,Description__c from Files__r) From buildertek__RFQ_To_Vendor__c where ID =:rfqVendorId order by Name';
            buildertek__RFQ_To_Vendor__c rfqToVendor1;
            rfqToVendor1 =  (buildertek__RFQ_To_Vendor__c)Database.query(query)[0];
            rfqToVendor =  rfqToVendor1;
            files = rfqToVendor1.Files__r;
        } catch(Exception ex) {
        }
    }
    
    public void removefile(){
        String fileid = ApexPages.CurrentPage().getParameters().Get('fileid');
        if(File__c.sObjectType.getDescribe().isDeletable()){
            delete [Select Id from File__c where Id =:fileid];
        }
        refreshFiles();
    }
    
    
    public void removeRowFromList(){
        wrapList.remove(rowToRemove);
    }
    
    public void addNewRowToAccList(){
        WrapperVerdorLineList newRecord = new WrapperVerdorLineList();
        buildertek__RFQ_Vendor_Item__c newItemRecord = new buildertek__RFQ_Vendor_Item__c();        
        newRecord.record = newItemRecord;
        newRecord.index = wrapList.size();
        wrapList.add(newRecord);
        system.debug('wrapList -----------> '+wrapList);
    } 
    
    public class WrapperVerdorLineList{
        public Integer index {get;set;}
        public buildertek__RFQ_Vendor_Item__c record {get;set;}
    }  
    
    public void openPopup(){
        displayPopUp = true;
    }
    
    public void closePopup(){
        displayPopUp = false;
    }
    
    public void gets3Key(){
        List<Folder__c> defaultBucketFolders ;
        if(Schema.sObjectType.Folder__c.fields.Id.isAccessible() &&
           Schema.sObjectType.Folder__c.fields.Name.isAccessible()&&
           Schema.sObjectType.Folder__c.fields.buildertek__Description__c.isAccessible()){
               defaultBucketFolders = [Select Id, Name From Folder__c Where Default__c = true AND Active__c = true];
           }
        
        AmazonS3Credential s3LinkConfig;
        s3LinkConfig = new AmazonS3Credential();
        
        s3AccessKey = s3LinkConfig.Key;
        policy = EncodingUtil.base64Encode(Blob.valueOf(getUpdatedPolicy1(true, defaultBucketFolders[0].Name)));
        signedPolicy = make_sig1(policy); 
    }
    
    public static String getUpdatedPolicy1(Boolean isPublicOnAmazon, String selectedBucket){
        Datetime expire = system.now().addDays(1); 
        String formattedexpire =  expire.formatGmt('yyyy-MM-dd')+'T'+ expire.formatGmt('HH:mm:ss')+'.'+expire.formatGMT('SSS')+'Z';
        return 
            '{ "expiration": "'+formattedexpire+'","conditions": ['+
            '{"bucket": "'+selectedBucket+'" },'+
            '{ "acl": "'+(isPublicOnAmazon ? 'public-read' : 'private')+'" },'+
            //'{"success_action_status": "201" },'+
            '{"success_action_redirect":""},' +
            '["starts-with", "$key", ""] ]}'; 
    }
    
    public static String make_sig1(string canonicalBuffer) {        
        String macUrl ;
        //Get the AWS credetials
        S3.AmazonS3 amazonS3;
        AmazonS3Credential s3LinkConfig;
        s3LinkConfig = new AmazonS3Credential();
        amazonS3 = new S3.AmazonS3(s3LinkConfig.key,s3LinkConfig.secret);
        
        String signingKey = EncodingUtil.base64Encode(Blob.valueOf(amazonS3.secret));
        Blob mac = Crypto.generateMac('HMacSHA1', blob.valueof(canonicalBuffer),blob.valueof(amazonS3.Secret)); 
        macUrl = EncodingUtil.base64Encode(mac);                
        return macUrl;
    }
    
    public void insertFile(){
        String fileObjJSON = ApexPages.currentPage().getParameters().get('fileJSON');
        system.debug('---fileObjJSON---'+fileObjJSON);
        FileUtils.skipDuplicateFileNameValidation = true;
        Id fileId = insertFiles((File)JSON.deserializeStrict(fileObjJSON, File.class), mainObjectFieldAPI,  mainObjectId);
        system.debug('fileId ---------> '+fileId);
        FileUtils.skipDuplicateFileNameValidation = false;
    }
    
    public Id insertFiles(File fileObj, String mainObjectFieldAPI, String mainObjectId){
        List<File_Access_Control__c> fileAccessControls = new List<File_Access_Control__c>();
        
        
        // If file is replaced delete old file. skip trigger.
        if(fileObj.Replace){
            FileTriggerHandler.isSkipTrigger = true;
            Set<String> allFileAccessControlFields = File_Access_Control__c.sObjectType.getDescribe().fields.getMap().keySet();
            List<String> fields = new List<String>();
            fields.addAll(allFileAccessControlFields);
            SOQLManager.checkFieldAccess(File_Access_Control__c.sObjectType, fields);
            List<File__c> filesWithSameNames = BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, (select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File_Access_Control__r) From File__c Where Folder__c ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Folder)+' AND Name ='+BT_Utils.prepareQueryStringForEqualClause(fileObj.Name));
            
            // Get file access controls for all duplicate files
            for(File__c duplicateFile : filesWithSameNames){
                for(File_Access_Control__c fileAccessControl : duplicateFile.File_Access_Control__r){
                    File_Access_Control__c newFileAccessControl = fileAccessControl.clone(false, true, true, true);
                    fileAccessControls.add(newFileAccessControl);
                }
            }
            BT_NoSharingUtils.deleteSobjects(filesWithSameNames);
            FileTriggerHandler.isSkipTrigger = false;
        }
        
        
        File__c newFile = new File__c();
        newFile.Name = fileObj.Name;
        newFile.Folder__c = fileObj.Folder;
        newFile.Bucket_Name__c = fileObj.BucketName;
        newFile.Extension__c = fileObj.Extension;
        newFile.Size__c = Decimal.valueOf(fileObj.size);
        newFile.Content_Type__c = fileObj.ContentType;
        
        File__c defaultFile = BT_HomeUtils.getDefaultFile();
        
        newFile.Allow_to_Copy_Move__c = defaultFile.Allow_to_Copy_Move__c;
        newFile.Presigned_URL_Frequency__c = defaultFile.Presigned_URL_Frequency__c;
        newFile.Public_On_Amazon__c = fileObj.PublicOnAmazon;
        newFile.Allow_to_Download_by_Presigned_URL__c = fileObj.AllowShareViaURL;
        newFile.Track_Download_History__c = fileObj.TrackDownload;
        newFile.Allow_to_Copy_Move__c = fileObj.AllowCopy;
        newFile.Access_Type__c = fileObj.AccessType;
        newFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
        newFile.buildertek__Track_Download_History__c = true;
        
        // File needs to be linked to the passed salesforce record ID
        if(mainObjectFieldAPI != null && mainObjectFieldAPI != '' && mainObjectFieldAPI != 'null'){
            newFile.put(mainObjectFieldAPI, mainObjectId);
        }
        DMLManager.insertAsUser(newFile);
        Id newFileId = newFile.Id;
        
        // Also insert file access controls
        if(!fileAccessControls.isEmpty()){
            for(File_Access_Control__c fileAccessControl : fileAccessControls){
                fileAccessControl.File__c = newFile.Id;
            }
        } else if(!fileObj.Replace && newFile.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE){
            fileAccessControls = BT_HomeUtils.getDefaultFileAccessControls(newFile);
        }
        
        if(!fileAccessControls.isEmpty()){
            BT_NoSharingUtils.doInsert(fileAccessControls, true);
        }
        return newFileId;
    }
    
    /*
File object that is used to pass file detail from page to controller.
*/
    public class File{
        Public Integer Size{get; set;}
        Public String Name{get; set;}
        Public String Extension{get; set;}
        Public String ContentType{get; set;}
        Public String BucketName;
        Public String Folder;
        Public Boolean Replace;
        Public String AccessType;
        Public Boolean PublicOnAmazon;
        Public Boolean AllowCopy;
        Public Boolean AllowShareViaURL;
        Public Boolean TrackDownload;
        public File(){
        }
    }
}