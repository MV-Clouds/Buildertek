global class AddFilesToS3Batch implements Database.Batchable<ContentVersion>, Database.AllowsCallouts {
    global List<ContentVersion> contentVersionList = new List<ContentVersion>();
    global Map<string, string> filesNameMap = new Map<string, string>();
    global Map<string, Id> filesIdsMap = new Map<string, Id>();
    global AddFilesToS3Batch(List<Id> Ids){
        SET<Id> rfqIds = new SET<Id>();
        List<buildertek__RFQ__c> rfqsList = new List<buildertek__RFQ__c>();
        if(Ids.size() > 0){
            rfqsList = [SELECT Id, Name FROM buildertek__RFQ__c WHERE Id IN: Ids];    
        }else{
            rfqsList = [SELECT Id, Name FROM buildertek__RFQ__c];
        }
        for(buildertek__RFQ__c rfq : rfqsList){
            rfqIds.add(rfq.Id);     
        }
        //rfqIds.add('a1T1K000003VSigUAG');
        //rfqIds.add('a1T1K000003VSilUAG');
        List<buildertek__File__c> filesList = [SELECT Id, Name, buildertek__RFQ__c FROM buildertek__File__c WHERE buildertek__RFQ__c IN: rfqIds];
        system.debug('filesList -------> '+filesList.size());
        SET<Id> rfqFilesIds = new SET<Id>();
        for(buildertek__File__c file : filesList){
            rfqFilesIds.add(file.buildertek__RFQ__c);
            filesNameMap.put(file.Name, file.buildertek__RFQ__c);
            filesIdsMap.put(file.Name, file.Id);
        }
        system.debug('rfqFilesIds -----> '+rfqFilesIds);
        system.debug('rfqFilesIdssize -----> '+rfqFilesIds.size());
        List<ContentDocumentLink> cdlinkList = [SELECT Id, ContentDocumentId, ContentDocument.Title, LinkedEntityId, ContentDocument.FileExtension, ContentDocument.FileType from contentdocumentlink where linkedentityId IN: rfqFilesIds];
        system.debug('cdlinkList size -------> '+cdlinkList.size());
        SET<Id> contentDocumentIds = new SET<Id>();
        for(ContentDocumentLink cd : cdlinkList){
            contentDocumentIds.add(cd.ContentDocumentId);
        }
        contentVersionList = [SELECT Id, Title, FileExtension, FileType, FirstPublishLocationId, ContentSize FROM ContentVersion WHERE ContentDocumentId IN: contentDocumentIds];
        
    }
    
    global Iterable<ContentVersion> start(Database.BatchableContext BC){
        return contentVersionList;    
    }
    
    global void execute(Database.BatchableContext BC, List<ContentVersion> scope){
        List<ContentVersion> cvList = [SELECT Id, Title, VersionData, FileExtension, FileType, ContentDocument.ParentId, ContentSize FROM ContentVersion WHERE Id IN: scope];
        List<Buildertek__Folder__c> folderList = [Select Id, Name From buildertek__Folder__c Where buildertek__Default__c = true AND buildertek__Active__c = true];
        List<File__c> filesList = new List<File__c>();
        SET<Id> rfqIdsToDelete = new SET<Id>();
        for(ContentVersion contentVer : cvList){
            String attachmentBody = EncodingUtil.base64Encode(contentVer.VersionData);
            String formattedDateString = Datetime.now().formatGMT('EEE, dd MMM yyyy HH:mm:ss z');
            String filename = contentVer.Title;
            filename = filename.replaceAll('\\s', ''); 
            filename = EncodingUtil.urlEncode(filename, 'UTF-8');
            HttpRequest req = new HttpRequest();
            req.setMethod('PUT');
            req.setEndpoint('callout:buildertek__AWS_S3/'+folderList[0].Name+'/'+fileName+'.'+contentVer.FileExtension);
            req.setHeader('Content-Length', String.valueOf(attachmentBody.length()));
            req.setHeader('Content-Encoding', 'base64');
            //req.setHeader('Content-type', ContentType(contentVer.FileExtension));
            req.setHeader('Connection', 'keep-alive');
            req.setHeader('Date', formattedDateString);
            req.setHeader('ACL', 'public-read-write');
            req.setBodyAsBlob(contentVer.VersionData);
            
            Http http = new Http();
            HTTPResponse res = http.send(req);
            system.debug('Response ------> '+res.getBody());
            system.debug('Response ------> '+res.getStatusCode());
            system.debug('Response ------> '+res.getStatus());
            if(res.getStatusCode() == 200){
                if(filesIdsMap.get(contentVer.Title+'.'+contentVer.FileExtension) != null){
                    rfqIdsToDelete.add(filesIdsMap.get(contentVer.Title+'.'+contentVer.FileExtension));    
                }else if(filesIdsMap.get(contentVer.Title+'.'+contentVer.FileType) != null){
                    rfqIdsToDelete.add(filesIdsMap.get(contentVer.Title+'.'+contentVer.FileType));      
                }
                File__c newFile = new File__c();
                newFile.Name = EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;  
                newFile.Folder__c = folderList[0].Id;
                newFile.Bucket_Name__c = folderList[0].Name;
                newFile.Extension__c = contentVer.FileType;
                newFile.Size__c = contentVer.ContentSize;
                newFile.Content_Type__c = contentVer.FileType;
                Map<String, String> objNameMap = new Map<String, String>();
                if(filesNameMap.get(contentVer.Title+'.'+contentVer.FileExtension) != null){
                    newFile.buildertek__RFQ__c = filesNameMap.get(contentVer.Title+'.'+contentVer.FileExtension);   
                }else if(filesNameMap.get(contentVer.Title+'.'+contentVer.FileType) != null){
                    newFile.buildertek__RFQ__c = filesNameMap.get(contentVer.Title+'.'+contentVer.FileType);   
                }
                newFile.Public_On_Amazon__c = true;
                newFile.Allow_to_Download_by_Presigned_URL__c = true;
                newFile.Track_Download_History__c = true;
                newFile.Allow_to_Copy_Move__c = true;
                newFile.Access_Type__c = 'Public';
                newFile.buildertek__File_Presigned_URL__c = 'https://s3.amazonaws.com/'+folderList[0].Name+'/'+EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;
                newFile.Parent_Object_API_Name__c = 'RFQ';
                filesList.add(newFile);
            }    
        }
        if(filesList.size() > 0){
            FileTriggerHandler.isSkipTrigger = true;
            insert filesList; 
            DELETE [SELECT Id FROM buildertek__File__c WHERE Id IN: rfqIdsToDelete];
        }
    }
    
    global void finish(Database.BatchableContext BC){
        
    }
}