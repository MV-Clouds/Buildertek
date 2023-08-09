public With Sharing class UploadImagesController {
   /* @AuraEnabled
    public static Id saveTheFile(String parentId, String fileName, String base64Data, String contentType) { 
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment att = new Attachment();
        att.ParentId = parentId;
        att.Name = fileName;
        att.Body = EncodingUtil.base64Decode(base64Data);
        att.ContentType = contentType;
        insert att;
        return att.Id;
    }
    
    @AuraEnabled
    public static Id insertProposalImages(String parentId, String description, String attachmentId){
        system.debug('attachmentId ----------> '+attachmentId);
        String myUrl = '/servlet/servlet.FileDownload?file='+attachmentId;
        buildertek__Proposal_Images__c proposalImages = new buildertek__Proposal_Images__c();
        proposalImages.buildertek__Image__c = myUrl;
        proposalImages.buildertek__Proposal__c = parentId;
        proposalImages.buildertek__Description__c = description;
        insert proposalImages;
        return proposalImages.Id;   
    }*/
    
    
    
    @AuraEnabled  
    public static List<ContentDocument> getFiles(List<string> recordIds){ 
        //Set<Id> recordIds=new Set<Id>{recordId};
        Set<Id> documentIds = new Set<Id>(); 
        List<ContentDocumentLink> cdl;
       /* if(Schema.sObjectType.ContentDocumentLink.fields.Id.isAccessible()&&
            Schema.sObjectType.ContentDocumentLink.fields.LinkedEntityId.isAccessible()&&
            Schema.sObjectType.ContentDocumentLink.fields.ContentDocumentId.isAccessible()){ */
            cdl=[SELECT id,LinkedEntityId,ContentDocumentId FROM ContentDocumentLink WHERE ContentDocumentId IN:recordIds]; 
        // }
        for(ContentDocumentLink cdLink:cdl){  
            documentIds.add(cdLink.ContentDocumentId);  
        }  
        List<ContentDocument> contentdoc ;
       /* if(Schema.sObjectType.ContentDocument.fields.Id.isAccessible()&&
            Schema.sObjectType.ContentDocument.fields.Title.isAccessible()&&
            Schema.sObjectType.ContentDocument.fields.FileType.isAccessible()){*/
            contentdoc = [SELECT Id, Title, FileType FROM ContentDocument WHERE id IN: documentIds];
           // }
        return contentdoc;  
    } 
    
    @AuraEnabled
    public static void deleteFiles(list<ContentDocument> filesList){
        if(filesList.size() > 0){
            if(ContentDocument.sObjectType.getDescribe().isDeletable()){
                DELETE filesList; 
            }
        }    
    }
    
    @AuraEnabled
    public static List<buildertek__Proposal_Images__c> insertProposalImages(String parentId, String description, list<ContentDocument> filesList){
        //system.debug('attachmentId ----------> '+attachmentId);
        List<buildertek__Proposal_Images__c> proposalImagesList = new List<buildertek__Proposal_Images__c>();
        List<Attachment> attList = new List<Attachment>();
        //List<ContentVersion> fileAttachments = new List<ContentVersion>();
        SET<Id> ContentDocumentSet = new SET<Id>();
        for(ContentDocument filesInserted : filesList){
            ContentDocumentSet.add(filesInserted.Id);           
        }
        List<ContentVersion> fileAttachments;
       /* if(Schema.sObjectType.ContentVersion.fields.Id.isAccessible()&&
            Schema.sObjectType.ContentVersion.fields.ContentDocumentId.isAccessible()&&
            Schema.sObjectType.ContentVersion.fields.Title.isAccessible()&&
            Schema.sObjectType.ContentVersion.fields.VersionData.isAccessible()&&
			Schema.sObjectType.ContentVersion.fields.FileType.isAccessible()){*/
           // fileAttachments = [Select Id, ContentDocumentId, Title, VersionData, FileType from ContentVersion where ContentDocumentId IN :ContentDocumentSet];
           fileAttachments = [select Title, Description, FileType,Owner.Name, VersionNumber,CreatedDate,PathOnClient,FileExtension,VersionData,ContentDocumentId from ContentVersion 
                                      where ContentDocumentId IN :ContentDocumentSet];
			//}
        for(ContentVersion contentVer : fileAttachments){
           /* if(Schema.sObjectType.Attachment.fields.ParentId.isCreateable() 
               && Schema.sObjectType.Attachment.fields.Name.isCreateable() 
               && Schema.sObjectType.Attachment.fields.Body.isCreateable()
               && Schema.sObjectType.Attachment.fields.ContentType.isCreateable()){*/
                   
                Attachment att = new Attachment();
                att.ParentId = parentId;
                att.Name = contentVer.Title;
                att.Body = contentVer.VersionData;
                att.ContentType = contentVer.FileType; 
                attList.add(att);
            ContentVersion con= new contentversion();
            con.ContentLocation = 'S'; 
            con.PathOnClient = contentVer.PathOnClient; 
            con.VersionData = contentVer.VersionData; 
            con.Title = contentVer.Title;
            insert con;
            Id conDoc = [SELECT ContentDocumentId,Title FROM ContentVersion WHERE Id =:con.Id].ContentDocumentId;
            ContentDocumentLink CDL = new ContentDocumentLink();
            CDL .ContentDocumentId = conDoc;
            CDL .LinkedEntityId = parentId; 
            CDL .ShareType = 'I'; 
            CDL .Visibility = 'AllUsers'; 
            insert CDL; 
                                 
           // }
        }
        if(attList.size() > 0){
            insert attList;
            for(Attachment at : attList){
                system.debug('&&&&'+at.Id);
                String myUrl = '/servlet/servlet.FileDownload?file='+at.Id;
                system.debug('myUrl'+myUrl);
                buildertek__Proposal_Images__c proposalImages = new buildertek__Proposal_Images__c();
                proposalImages.buildertek__Image__c = myUrl;
                proposalImages.buildertek__Base_URL__c = URL.getSalesforceBaseUrl().toExternalForm();
                String objectAPIName = '';
                string keyPrefix = parentId.substring(0,3);
                 for( Schema.SObjectType obj : Schema.getGlobalDescribe().Values() ){
                      String prefix = obj.getDescribe().getKeyPrefix();
                       //if(prefix == keyPrefix){
                         if(keyPrefix.equals(prefix)){
                            objectAPIName = obj.getDescribe().getName();
                            break;
                        }
                 }
				system.debug('&&&&'+objectAPIName);
                if(objectAPIName.contains('Contract')){
                    proposalImages.buildertek__Contract__c = parentId;
                }
                else{
                    proposalImages.buildertek__Proposal__c = parentId;
                }
                proposalImages.buildertek__Description__c = description;
                proposalImagesList.add(proposalImages);    
            }
            if(proposalImagesList.size() > 0){
                /*if (Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Image__c.isCreateable()
                    && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Contract__c.isCreateable()
                    && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Proposal__c.isCreateable()
                    && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Description__c.isCreateable()) {*/
                    
                    insert proposalImagesList;    
               // }
                
                if(ContentDocument.sObjectType.getDescribe().isDeletable()){
                    DELETE filesList;    
                }
                
            }
        }
        return proposalImagesList;
        
    }
    
    @AuraEnabled  
    public static List<ContentDocument> getUploadedFiles(String productId){ 
        String imageId='';
        String documentId='';
        if(String.isNotBlank(productId)){
            List<buildertek__Question__c> questions = [SELECT Id, buildertek__Image_Id__c, buildertek__Document_Id__c From buildertek__Question__c WHERE buildertek__Product__c =: productId LIMIT 1];
            if(questions.size()>0){
                imageId=questions[0].buildertek__Image_Id__c!=null?questions[0].buildertek__Image_Id__c:'';
                documentId=questions[0].buildertek__Document_Id__c!=null?questions[0].buildertek__Document_Id__c:'';
                if(String.isNotBlank(documentId)){
                    return [SELECT Id, Title, FileType FROM ContentDocument WHERE Id = :documentId];        
    	        }
            }
        }
        return null;
    }
    
    @AuraEnabled  
    public static void deleteProductFile(String contentDocumentId,String productId){ 
        if(String.isNotBlank(contentDocumentId) && String.isNotBlank(productId)){
            List<buildertek__Question__c> questionRecs = new List<buildertek__Question__c>();
            List<buildertek__Question__c> questions = [SELECT Id, buildertek__Image_Id__c,buildertek__Document_Id__c From buildertek__Question__c WHERE buildertek__Product__c =: productId];
            if(questions.size()>0){
                for(buildertek__Question__c question:questions){
                    question.buildertek__Image_Id__c='';
                    question.buildertek__Document_Id__c='';
                    questionRecs.add(question);
                }
                try{
	                update questionRecs;
                }catch(Exception e){
                 	System.debug('Error::'+e.getMessage());   
                }
            }
            delete [SELECT Id from ContentDocument WHERE Id = :contentDocumentId];       
        }
    }  
    
    @AuraEnabled  
    public static Boolean updateQuestions(String documentId,String productId){
        if(String.isNotBlank(productId) && String.isNotBlank(documentId)){
            List<buildertek__Question__c> questionRecs=new List<buildertek__Question__c>();
            List<buildertek__Question__c> questions = [SELECT Id, buildertek__Image_Id__c,buildertek__Document_Id__c From buildertek__Question__c WHERE buildertek__Product__c =: productId];
            if(questions.size()>0){
                ContentVersion newContentVersion = [SELECT Id, ContentDocumentId FROM ContentVersion where contentDocumentId =: documentId LIMIT 1];
                for(buildertek__Question__c questionRec:questions){
                    questionRec.buildertek__Image_Id__c = newContentVersion.Id;
                    questionRec.buildertek__Document_Id__c = documentId;
                    questionRecs.add(questionRec);
                }
                update questionRecs;
                return true;
            }   
        }
        return false;
    }
}