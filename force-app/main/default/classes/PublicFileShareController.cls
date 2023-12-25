public without sharing class PublicFileShareController {

    @AuraEnabled
    public static List<ContentDocumentLink> getContentDocuments( Id recordId, Id folderId){

        System.debug('recordId:- '+ recordId);
        
        List<ContentDocumentLink> cdlist = new List<ContentDocumentLink>();
        List<ContentDocumentLink> cdlist2 = new List<ContentDocumentLink>();

        cdlist = [SELECT Id, ContentDocument.Title, ContentDocumentId, ContentDocument.LatestPublishedVersionId
                        FROM ContentDocumentLink
                        WHERE LinkedEntityId = :recordId];

        System.debug('cdlist :- '+cdlist);

        List<buildertek__Public_File_Folder_Jn__c> publicfilefolderjnc = new List<buildertek__Public_File_Folder_Jn__c>();

        publicfilefolderjnc = [SELECT buildertek__Public_File__r.buildertek__Content_Version__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c where buildertek__Public_Folder__c = :folderId];

        System.debug('publicfilefolderjnc:- '+publicfilefolderjnc);

        Set<Id> converIds = new Set<Id>();
        for (buildertek__Public_File_Folder_Jn__c obj : publicfilefolderjnc) {
            converIds.add(obj.buildertek__Public_File__r.buildertek__Content_Version__c);
        } 

        System.debug('converids:- '+ converIds);

        for (ContentDocumentLink sd : cdlist){
            if(!(converIds.contains(sd.ContentDocument.LatestPublishedVersionId))){
                cdlist2.add(sd);
            }
        }

        System.debug('cdlist2:- '+cdlist2);

        return cdlist2;
    }

    @AuraEnabled
    public static List<buildertek__Public_Folder__c> getFolderList(Id currentId){

        List<buildertek__Public_Folder__c> publicfolders = new List<buildertek__Public_Folder__c>();
        
        publicfolders = [SELECT Id, buildertek__File_Count__c, Name, buildertek__Description__c FROM buildertek__Public_Folder__c WHERE buildertek__RelatedToId__c = :currentId];

        return publicfolders;
    }

    @AuraEnabled
    public static String createPublicFolder(String Fname, String Fdesc, Id currentId){

        buildertek__Public_Folder__c publicfol = new buildertek__Public_Folder__c();
        publicfol.Name = Fname;
        publicfol.buildertek__Description__c = Fdesc;
        publicfol.buildertek__RelatedToId__c = currentId;

        insert publicfol;

        return 'Success';

    }

    @AuraEnabled
    public static List<buildertek__Public_File_Folder_Jn__c> getFileFolderJuncData(){

        List<buildertek__Public_File_Folder_Jn__c> publicfilefolderjunc = new List<buildertek__Public_File_Folder_Jn__c>();

        publicfilefolderjunc = [SELECT buildertek__Public_File__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c];
        
        return publicfilefolderjunc;
    }

    @AuraEnabled
    public static string createPublicFileFolderJnc( Id folderId, List<ContentDocumentLink> cdllist ){

        List<buildertek__Public_File__c> publicfilelst = new List<buildertek__Public_File__c>();
        List<buildertek__Public_File__c> publicfilelst2 = new List<buildertek__Public_File__c>();
        List<buildertek__Public_File__c> finalpublicfilelst = new List<buildertek__Public_File__c>();

        List<Id> idList = new List<Id>();

        for (ContentDocumentLink obj : cdllist) {
            idList.add(obj.ContentDocument.LatestPublishedVersionId);
        }

        System.debug('idList:- '+idList);

        publicfilelst = [SELECT Id, buildertek__Content_Version__c FROM buildertek__Public_File__c WHERE buildertek__Content_Version__c in :idList];

        System.debug('publicfiles List:- '+publicfilelst);

        Set<Id> idSet = new Set<Id>();
        for (buildertek__Public_File__c obj : publicfilelst) {
            idSet.add(obj.buildertek__Content_Version__c);
        }

        List<ContentDistribution> cdlist = new List<ContentDistribution>();
        List<ContentDistribution> cdlist2 = new List<ContentDistribution>();

        for (ContentDocumentLink obj : cdllist) {
            if(!(idSet.contains(obj.ContentDocument.LatestPublishedVersionId))){
                ContentDistribution cd = new ContentDistribution();
                cd.Name = obj.ContentDocument.Title;
                cd.ContentVersionId = obj.ContentDocument.LatestPublishedVersionId;
                cd.PreferencesAllowViewInBrowser= true;
                cd.PreferencesLinkLatestVersion=true;
                cd.PreferencesNotifyOnVisit=false;
                cd.PreferencesPasswordRequired=false;
                cd.PreferencesAllowOriginalDownload= true;
                cdlist.add(cd);
            }
        }

        insert cdlist;

        System.debug('cdlist:- '+cdlist);

        List<Id> cdidlist = new List<Id>();
        for (ContentDistribution cd : cdlist){
            cdidlist.add(cd.Id);
        }
        cdlist2 = [SELECT Id, Name, ContentVersionId, DistributionPublicUrl FROM ContentDistribution WHERE Id in :cdidlist];

        for (ContentDistribution cd : cdlist2){
            buildertek__Public_File__c publicfile = new buildertek__Public_File__c();
            publicfile.buildertek__File_Name__c = cd.Name;
            publicfile.buildertek__Content_Distrubution__c = cd.Id;
            publicfile.buildertek__Content_Version__c = cd.ContentVersionId;
            // publicfile.buildertek__Expiry_Date__c = cd.ExpiryDate.date();
            publicfile.buildertek__Public_URL__c = cd.DistributionPublicUrl;
            publicfilelst2.add(publicfile);
        }

        insert publicfilelst2;

        System.debug('publicfilelst:- '+publicfilelst);
        System.debug('publicfilelst2:- '+publicfilelst2);

        finalpublicfilelst.addAll(publicfilelst);
        finalpublicfilelst.addAll(publicfilelst2);

        System.debug('finalpublicfilelst after insert :- '+finalpublicfilelst);

        List<buildertek__Public_File_Folder_Jn__c> publicfilefolderjunclst = new List<buildertek__Public_File_Folder_Jn__c>();
        List<buildertek__Public_File_Folder_Jn__c> publicfilefolderjunclst2 = new List<buildertek__Public_File_Folder_Jn__c>();

        // List<Id> idlist2 = new List<Id>();
        // for(buildertek__Public_Folder__c folder : Pfolderlst){
        //     idlist2.add(folder.Id);
        // }
        
        // publicfilefolderjunclst = [SELECT buildertek__Public_File__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c WHERE buildertek__Public_Folder__c in :idlist];

        Map<Id, List<buildertek__Public_File_Folder_Jn__c>> idToPublicFileFolderJncMap = new Map<Id, List<buildertek__Public_File_Folder_Jn__c>>();

        for (buildertek__Public_File_Folder_Jn__c obj : [SELECT buildertek__Public_File__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c WHERE buildertek__Public_Folder__c = :folderId]) {
            
            if (!idToPublicFileFolderJncMap.containsKey(obj.buildertek__Public_Folder__c)) {
                idToPublicFileFolderJncMap.put(obj.buildertek__Public_Folder__c, new List<buildertek__Public_File_Folder_Jn__c>());
            }
            
            idToPublicFileFolderJncMap.get(obj.buildertek__Public_Folder__c).add(obj);
        }

        System.debug('idToPublicFileFolderJncMap:- '+idToPublicFileFolderJncMap);

        // for(buildertek__Public_Folder__c folder : Pfolderlst){

            System.debug('Pfolder:- '+folderId);

            Set<Id> idSet2 = new Set<Id>();

            System.debug('folderid:- '+folderId);
            if(idToPublicFileFolderJncMap.containsKey(folderId)){
                System.debug('folder Files list :- '+idToPublicFileFolderJncMap.get(folderId));
                publicfilefolderjunclst = idToPublicFileFolderJncMap.get(folderId);

                for (buildertek__Public_File_Folder_Jn__c obj : publicfilefolderjunclst) {
                    System.debug('obj:- '+obj);
                    idSet2.add(obj.buildertek__Public_File__c);
                }
            }
                
            for(buildertek__Public_File__c pfile : finalpublicfilelst){
                buildertek__Public_File_Folder_Jn__c publicfilefolderjunc = new buildertek__Public_File_Folder_Jn__c();
                System.debug('pfile:-  '+pfile);
                if(!(idSet2.contains(pfile.Id))){
                    publicfilefolderjunc.buildertek__Public_File__c = pfile.Id;
                    publicfilefolderjunc.buildertek__Public_Folder__c = folderId;
                    publicfilefolderjunclst2.add(publicfilefolderjunc);
                }
            }
        // }
        for(buildertek__Public_File_Folder_Jn__c p : publicfilefolderjunclst2){
            System.debug('publicfilefolderjunclst2:- '+p);
        }

        insert publicfilefolderjunclst2;

        System.debug('Public File Folder Junction List After Insert:- '+publicfilefolderjunclst2);

        return 'Success';
    }

    @AuraEnabled
    public static List<buildertek__Public_File_Folder_Jn__c> getAllFileFolderJunctionObj(String FolderIds){
        try {
            system.debug('FolderIds >> '+ FolderIds);
            List<buildertek__Public_File_Folder_Jn__c> JunObj = [SELECT ID, Name,
                                                                        buildertek__Public_File__r.Id, buildertek__Public_File__r.Name,buildertek__Public_File__r.buildertek__File_Name__c,buildertek__Public_File__r.buildertek__Public_URL__c,
                                                                        buildertek__Public_Folder__r.Id, buildertek__Public_Folder__r.Name
                                                                        FROM buildertek__Public_File_Folder_Jn__c WHERE buildertek__Public_Folder__c = : FolderIds];
            system.debug('JunObj >> ' + JunObj[0]);
            
            return JunObj;
        } catch (Exception e) {
            system.debug('error in apex method getAllFileFolderJunctionObj > ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string UpdateFileName(List<Map<String, String>> UpdatedRecords){
        try {
            system.debug('UpdatedRecords >> ' + UpdatedRecords);
            list<buildertek__Public_File__c> fileRecordsToUpdate = new list<buildertek__Public_File__c>();

            for(Map<String, String> obj : UpdatedRecords){
                String recordID = obj.get('Id');
                String FileId = [SELECT Id, Name , buildertek__Public_File__c FROM buildertek__Public_File_Folder_Jn__c WHERE Id =: recordID].buildertek__Public_File__c;

                buildertek__Public_File__c FileRecord = [SELECT Id, Name, buildertek__File_Name__c FROM buildertek__Public_File__c WHERE Id =: FileId LIMIT 1];
                FileRecord.buildertek__File_Name__c = obj.get('buildertek__File_Name__c');
                fileRecordsToUpdate.add(FileRecord);
            }

            if(fileRecordsToUpdate.size() > 0){
                update fileRecordsToUpdate;
            }
        
            system.debug('fileName >> ' + UpdatedRecords);

            
            return 'success';
        } catch (Exception e) {
            system.debug('error in apex method UpdateFileName > ' + e.getMessage());
            return null;
        }
    }

    @AuraEnabled
    public static string ConfirmationPageSiteUR(){
        List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
        string SiteUrl;
        if (confirmationurl.size() > 0){
            SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
        }
        return SiteUrl;
    }

    //Sakina's Changes
    @AuraEnabled
    public static void deleteFile( List<Id> pubFileFolderJnId){
        System.debug('deleteFile');
        List<buildertek__Public_File_Folder_Jn__c>  publicFileFolderJnList = [SELECT Id, buildertek__Public_File__c, buildertek__Public_Folder__c FROM buildertek__Public_File_Folder_Jn__c WHERE Id IN:pubFileFolderJnId];
        if(!publicFileFolderJnList.isEmpty()){
            delete publicFileFolderJnList;
        }
    }

    @AuraEnabled
    public static String deleteFolder( Id publicFolderId ){
        try {
            System.debug('deleteFolder');
            List<buildertek__Public_Folder__c>  publicFolderList = [SELECT Id, Name FROM buildertek__Public_Folder__c WHERE Id = :publicFolderId];
            if(!publicFolderList.isEmpty()){
                delete publicFolderList;
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String updateFolder( Id publicFolderId, String folderName, String folderDesc ){
        try {
            System.debug('updateFolder');
            List<buildertek__Public_Folder__c>  publicFolderList = [SELECT Id, Name, buildertek__Description__c FROM buildertek__Public_Folder__c WHERE Id = :publicFolderId];
            System.debug('publicFolderList >> ' + publicFolderList);
            if(!publicFolderList.isEmpty()){
                publicFolderList[0].Name = folderName;
                publicFolderList[0].buildertek__Description__c = folderDesc;
                System.debug('publicFolderList2 >> ' + publicFolderList);
                update publicFolderList;
            }
            return 'Success';
        } catch (Exception e) {
            return e.getMessage();
        }
    }

}