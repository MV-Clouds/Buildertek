public class ContentVersionTriggerHandler{

    public static Boolean isSkip = false;
    public static void onAfterInsert(List<ContentVersion> contentVersionList){
        SET<Id> contentVersionIds = new SET<Id>();
        for(ContentVersion contentVer : contentVersionList){
             contentVersionIds.add(contentVer.Id);  
        } 
        createFile(contentVersionIds);            
                    
    }
    
    @future(callout = true)
    public static void createFile(SET<Id> contentVersionIds){
        List<buildertek__Folder__c> folderList = [Select Id, Name From buildertek__Folder__c Where buildertek__Default__c = true AND buildertek__Active__c = true];
        List<buildertek__File__c> filesList = new List<Buildertek__File__c>();
        List<ContentVersion> contentVersionList = [Select Id, 
                                                        ContentDocumentId, 
                                                        Title, 
                                                        VersionData,
                                                        ContentSize,
                                                        PathOnClient,
                                                        FileType,
                                                        FileExtension,
                                                        FirstPublishLocationId
                                                        from ContentVersion 
                                                        where Id IN :contentVersionIds];
        for(ContentVersion contentVer : contentVersionList){
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
                    File__c newFile = new File__c();
                    newFile.Name = EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;  
                    newFile.Folder__c = folderList[0].Id;
                    newFile.Bucket_Name__c = folderList[0].Name;
                    newFile.Extension__c = contentVer.FileType;
                    newFile.Size__c = contentVer.ContentSize;
                    newFile.Content_Type__c = contentVer.FileType;
                    newFile.Allow_to_Copy_Move__c = true;
                    newFile.Presigned_URL_Frequency__c = 'Every Month';
                    newFile.Public_On_Amazon__c = true;
                    newFile.Allow_to_Download_by_Presigned_URL__c = true;
                    newFile.Track_Download_History__c = true;
                    newFile.Allow_to_Copy_Move__c = true;
                    newFile.Access_Type__c = 'Public';
                    newFile.buildertek__File_Presigned_URL__c = 'https://s3.amazonaws.com/'+folderList[0].Name+'/'+EncodingUtil.urlDecode(fileName, 'UTF-8')+'.'+contentVer.FileExtension;
                    newFile.Parent_Object_API_Name__c = 'Account';
                    newFile.buildertek__Account__c = contentVer.FirstPublishLocationId;
                    filesList.add(newFile);
                
                }
        }                                                
        
        if(filesList.size() > 0){
            
                insert filesList;
            system.debug('filesList------>'+JSON.serialize(filesList));
           //if(ContentDocument.sObjectType.getDescribe().isDeletable()){
                //DELETE contentdoc;      
           //}
            
        }
      }  
}