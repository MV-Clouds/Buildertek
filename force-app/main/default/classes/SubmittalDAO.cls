public with sharing class SubmittalDAO {
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    @AuraEnabled
    public static User getCurrentLoggedInUser(){
      User currentuser;
      if (Schema.sObjectType.User.fields.id.isAccessible() &&
      Schema.sObjectType.User.fields.Name.isAccessible() ){
      currentuser = [SELECT Id, Name FROM User WHERE Id =: UserInfo.getUserId()];
      }
        return currentuser;
    }
    
    @AuraEnabled
    public static String createNewSubmittal(String submittalRecord, String userId, String projectId){
        buildertek__Submittal__c submittalToInsert = (buildertek__Submittal__c)JSON.deserialize(submittalRecord, buildertek__Submittal__c.class);
        if (Schema.sObjectType.buildertek__Submittal__c.isCreateable()
           && Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Project__c.isCreateable()
            && Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Status__c.isCreateable()
            && Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Submitted_By__c.isCreateable()
            && Schema.sObjectType.buildertek__Submittal__c.fields.buildertek__Submitted_Date__c.isCreateable()) {
                
            submittalToInsert.buildertek__Project__c = projectId;
            submittalToInsert.buildertek__Status__c = 'Draft';
            submittalToInsert.buildertek__Submitted_By__c = userId;
            submittalToInsert.buildertek__Submitted_Date__c = system.today();
                
            insert submittalToInsert; 
            system.debug('Inserted Submittal ------> '+submittalToInsert);
            
        }
        return submittalToInsert.Id;  
    }
    
    
    
   /* @AuraEnabled
    public static String saveFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        //   
        
        system.debug(parentId);
        Id recID = Id.valueOf(parentId);
        if (fileId == '') {
            fileId = saveTheFile(recID, fileName, base64Data, contentType);
        } else {
            system.debug(fileId);
            appendToFile(Id.valueOf(fileId), base64Data);
        }
        system.debug(fileId);
        return Id.valueOf(fileId);        
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;  
         system.debug(oAttachment.Id);
        return oAttachment.Id;
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }*/
    
    
    
    @AuraEnabled                            
    public static Id saveTheChunkFile(Id parentId, String fileName, String base64Data, String contentType, String fileId){
        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        system.debug(parentId);
        Id recID = Id.valueOf(parentId);
        if ( String.isBlank(fileId) ) {
            fileId = saveFiles(recID, fileName, base64Data );
        } else {
            appendToFile(fileId, base64Data);
        }

        return Id.valueOf(fileId);
    }
    
    
    @AuraEnabled
    public static Id saveFiles(Id recordId, String fileName, String base64Data )  { 
        
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = recordId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        
        return contentToInsert.id;

    }


    @AuraEnabled
    public static void appendToFile(Id contentDocumentId, String base64Data) {
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :contentDocumentId
        ];

        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 

        update versionData;
    }
    
    
   /* @AuraEnabled
    public static String attachToRecord(String parentId, List<String> FileIdsList){
        try{
            List<ContentDocumentLink> cdl = new List<ContentDocumentLink>();
            cdl = [SELECT Id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:FileIdsList];  
            system.debug(cdl);
            List<ContentDocumentLink> updateCdl = new List<ContentDocumentLink>();
            for(ContentDocumentLink item: cdl){
                system.debug(item);
                ContentDocumentLink doc = new ContentDocumentLink();
                doc.LinkedEntityId = Id.valueOf(parentId);
                doc.Id = item.Id;
                updateCdl.add(doc);
            }
            update updateCdl;
            return 'SUCCESS';
        }catch(Exception ex){
            return ex.getMessage();
        }
        
        
    }*/
    
}