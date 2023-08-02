public without sharing class BT_New_RFI_Controller {

     @AuraEnabled
    public static List<buildertek__RFI__c> updateDateOriginalSent(String newRFIId){
        System.debug('newRFIId----------'+newRFIId);
        List<buildertek__RFI__c> rfiList=[SELECT Id, Name, buildertek__RFQ__c, buildertek__Date_Sent__c FROM buildertek__RFI__c where id=:newRFIId];
        for(buildertek__RFI__c rfiRec:rfiList){
            rfiRec.buildertek__Date_Sent__c=System.today();
        }
        update rfiList;
         return rfiList;
    }
    @AuraEnabled
    public static void deleteFile(String RecordId,List<string> fileIds){
        Set<String> DocumentIds = new Set<String>();
        Set<String> filesset = new Set<String>();
        for(String str:fileIds){
           filesset.add(str);
        }
         
        /*List<ContentDocumentLink> doclink = [select id,LinkedEntityId,ContentDocumentId from ContentDocumentLink  where LinkedEntityId=:RecordId];
        for(ContentDocumentLink con:doclink){
            DocumentIds.add(con.ContentDocumentId);
        }*/
        List<ContentVersion> ccids = [select id,ContentdocumentId from ContentVersion where id IN:filesset];
        for(ContentVersion cv:ccids){
            DocumentIds.Add(cv.ContentdocumentId);
        }
        List<ContentDocument> contlist = [SELECT id from ContentDocument Where id IN:DocumentIds];
        if(contlist.size()>0){
        Delete contlist;
        }
        
    }
    
    
    @AuraEnabled
    public static boolean getRFISettings(){
        Boolean notificationtemplate = false;
        buildertek__RFI_Settings__c rfiSettings = null;
        List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name, 
                                                             buildertek__Using_Communities__c,
                                                             buildertek__Using_Email__c,
                                                             buildertek__New_RFI_Notification_Template__c
                                                             from buildertek__RFI_Settings__c
                                                             WHERE Name ='RFI Settings'];
        system.debug('rfiSettingsList-------'+rfiSettingsList);
        if(rfiSettingsList.size() > 0){
            rfiSettings = rfiSettingsList[0]; 
          //  if(rfiSettings.buildertek__New_RFI_Notification_Template__c!=null){
                notificationtemplate = rfiSettings.buildertek__Using_Email__c;
           // } 
        }
        return notificationtemplate;
    }
    
    @AuraEnabled
    public static AllFilesWrapper getContentDocs(Id arecordId) {
        AllFilesWrapper wrap = new AllFilesWrapper();

        list<buildertek__File__c> fileslist =
        [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c , buildertek__ContentDocument_Id__c
        FROM buildertek__File__c Where buildertek__RFI__c=:arecordId ];

        list<Id> filecontentid= new list<Id>();        
         for(buildertek__File__c fileRec : fileslist){
              if(fileRec.buildertek__ContentDocument_Id__c != null ){
                filecontentid.add(fileRec.buildertek__ContentDocument_Id__c);
             }
         }
         List<Attachment> attList = new List<Attachment>();
             for (Attachment att : [select Id, Name
                                    FROM Attachment
                                    where ParentId = :arecordId]){
                 attList.add(att);
             }
        list<ContentDocumentLink> files = [select ContentDocumentId, LinkedEntityId
                                        FROM ContentDocumentLink
                                        where LinkedEntityId = :arecordId and ContentDocumentId NOT IN: filecontentid];
            list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
        List<ContentVersion> fileAttachments = new List<ContentVersion>();
                for (ContentDocumentLink content : files){
                for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                            from ContentVersion
                                            where ContentDocumentId = :content.ContentDocumentId]){
                    fileAttachments.add(docs);
                }
            }
        wrap.btfileslist = fileslist;
        wrap.standardfiles = fileAttachments; 


        return wrap;
    }


    public class AllFilesWrapper{
        @AuraEnabled 
        public  List<buildertek__File__c> btfileslist;
        @AuraEnabled 
        public list<ContentVersion> standardfiles; 
    } 

    /*@AuraEnabled
    public static List<ContentDocument> getContentDocs(Id arecordId) {

        List<ContentDocumentLink> CDLs = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :arecordId];
        if (CDLs.size() < 1) {
            return new List<ContentDocument>();
        }
        List<Id> CDIdList = new List<Id> (); 
        for (ContentDocumentLink nextCDL : CDLs) { 
            CDIdList.add(nextCDL.ContentDocumentId); 
        } 
        List<ContentDocument> entries = [SELECT Id, Title, FileType FROM ContentDocument WHERE Id IN :CDIdList]; 
        return entries;
    }*/


   /*@AuraEnabled
    public static List<buildertek__File__c> getContentDocs1(Id arecordId) {
        list<buildertek__File__c> fileslist =
        [SELECT Id, Name, buildertek__Amazon_File_Key__c,buildertek__Account__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFI_Response__c=:arecordId ];
        return fileslist;
    }*/

      
    @AuraEnabled
    public static AllFilesWrapper getContentDocs1(Id arecordId) {
        AllFilesWrapper wrap = new AllFilesWrapper();

        list<buildertek__File__c> fileslist =
        [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c , buildertek__ContentDocument_Id__c
        FROM buildertek__File__c Where buildertek__RFI_Response__c=:arecordId ];

        list<Id> filecontentid= new list<Id>();        
         for(buildertek__File__c fileRec : fileslist){
              if(fileRec.buildertek__ContentDocument_Id__c != null ){
                filecontentid.add(fileRec.buildertek__ContentDocument_Id__c);
             }
         }
         List<Attachment> attList = new List<Attachment>();
             for (Attachment att : [select Id, Name
                                    FROM Attachment
                                    where ParentId = :arecordId]){
                 attList.add(att);
             }
        list<ContentDocumentLink> files = [select ContentDocumentId, LinkedEntityId
                                        FROM ContentDocumentLink
                                        where LinkedEntityId = :arecordId and ContentDocumentId NOT IN: filecontentid];
            list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
        List<ContentVersion> fileAttachments = new List<ContentVersion>();
                for (ContentDocumentLink content : files){
                for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                            from ContentVersion
                                            where ContentDocumentId = :content.ContentDocumentId]){
                    fileAttachments.add(docs);
                }
            }
        wrap.btfileslist = fileslist;
        wrap.standardfiles = fileAttachments; 


        return wrap;
    }





    @AuraEnabled 
    public static string fetchUser(){
        User u = [select id,Name from User where id =: userInfo.getUserId()];
        system.debug('user -----------------------'+u);
        return u.id;
    }
    @AuraEnabled 
    public static User fetchUser1(){
        User u = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        system.debug('Please check data flow here ==> '+u);
        return u;
    }
    @AuraEnabled 
    public static string getUser(){
        string portalCode = 'false';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
           system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                // portalCode = userRec[0].get('isPortalEnabled');
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        // User userRec = [SELECT id, Name,isPortalEnabled FROM User where id =: userInfo.getUserId()];
       // system.debug('portalCode'+portalCode);
        return portalCode;
        //User userRec = [SELECT id, Name,isPortalEnabled FROM User where id =: userInfo.getUserId()];
        //return userRec.isPortalEnabled;
    }
    @AuraEnabled 
    public static string getcontact(){
        //Contact con= [select id,Name from Contact limit 1];
        string contactid='';
        User u = [select id,Name, AccountId, ContactId from User where id =: userInfo.getUserId()];        
        if(u.ContactId!=null){
            contactid = u.ContactId;
        }else{
            Contact con= [select id,Name from Contact limit 1];
            contactid = con.Id;
        }
        return contactid;
    }

    /*Map<String,List<ContentDocumentLink>>*/

    @AuraEnabled 
    public static Map<String,List<FileWrapper>>   getrfirelatedfilesrecords(string parentRecordId){
        system.debug('parentRecordId'+parentRecordId);
        List<FileWrapper> FileWrapper = new List<FileWrapper>();
        list<buildertek__RFI__c> rfislist = [SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =: parentRecordId];


        system.debug('rfislist size--->'+rfislist.size());
        set<Id> rfiidsset = new set<Id>();
        for(buildertek__RFI__c rec:rfislist){
            rfiidsset.add(rec.Id);
        }
        system.debug('rfiidsset--->'+rfiidsset);
        Map<String,List<FileWrapper>> docRfiMap = new Map<String,List<FileWrapper>>();
        List<buildertek__File__c> conVersion = [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFI__c In:rfiidsset]; 
        for (buildertek__File__c rec : conVersion){             
            FileWrapper wrap = new FileWrapper();
            if(docRfiMap.get(String.valueOf(rec.buildertek__RFI__c) ) != null){
                list<FileWrapper> newDocList = docRfiMap.get(String.valueOf(rec.buildertek__RFI__c));
                wrap.LinkedEntityId = rec.buildertek__RFI__c;
                newDocList.add(wrap);    
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList);     
            }else{
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = rec.buildertek__RFI__c;
                newDocList2.add(wrap);
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList2); 
            }
        }
        system.debug('docRfiMap--->'+docRfiMap);
         

        list<ContentDocumentLink> conlist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
                                            ( SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId) and LinkedEntity.Type='buildertek__RFI__c'];
        //Map<String,List<ContentDocumentLink>> docRfiMap = new Map<String,List<ContentDocumentLink>>();
        for(ContentDocumentLink doc: conlist){
            FileWrapper wrap = new FileWrapper();

            if(docRfiMap.get(String.valueOf(doc.LinkedEntityId) ) != null){
                list<FileWrapper>  newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //list<ContentDocumentLink> newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //newDocList.add(doc);    
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList.add(wrap);    

                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList);  
            }else{
                //List<ContentDocumentLink> newDocList2 = new List<ContentDocumentLink>();
                //newDocList2.add(doc);
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList2.add(wrap);

                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList2);  
            }
        }




        return docRfiMap ;


    }


    @AuraEnabled 
    public static Map<String,List<buildertek__File__c>>   getrfirelatedfilesrecordsOld(string parentRecordId){
        system.debug('parentRecordId'+parentRecordId);
        List<FileWrapper> FileWrapper = new List<FileWrapper>();
        list<buildertek__RFI__c> rfislist = [SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =: parentRecordId];


        system.debug('rfislist size--->'+rfislist.size());
        set<Id> rfiidsset = new set<Id>();
        for(buildertek__RFI__c rec:rfislist){
            rfiidsset.add(rec.Id);
        }
        system.debug('rfiidsset--->'+rfiidsset);
        Map<String,List<buildertek__File__c>> docRfiMap = new Map<String,List<buildertek__File__c>>();
        List<buildertek__File__c> conVersion = [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFI__c In:rfiidsset]; 
        for (buildertek__File__c rec : conVersion){             
            if(docRfiMap.get(String.valueOf(rec.buildertek__RFI__c) ) != null){
                list<buildertek__File__c> newDocList = docRfiMap.get(String.valueOf(rec.buildertek__RFI__c));
                newDocList.add(rec);    
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList);     
            }else{
                List<buildertek__File__c> newDocList2 = new List<buildertek__File__c>();
                newDocList2.add(rec);
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList2); 
            }
        }
        system.debug('docRfiMap--->'+docRfiMap);
         

        /*list<ContentDocumentLink> conlist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
                                            ( SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId) and LinkedEntity.Type='buildertek__RFI__c'];
        Map<String,List<ContentDocumentLink>> docRfiMap = new Map<String,List<ContentDocumentLink>>();
        for(ContentDocumentLink doc: conlist){
            if(docRfiMap.get(String.valueOf(doc.LinkedEntityId) ) != null){
                list<ContentDocumentLink> newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                newDocList.add(doc);    
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList);  
            }else{
                List<ContentDocumentLink> newDocList2 = new List<ContentDocumentLink>();
                newDocList2.add(doc);
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList2);  
            }
        }*/




        return docRfiMap ;


    }





    
    @AuraEnabled 
    public static Map<String,List<FileWrapper>>     getrfqtovenrfirelatedfilesrecords(string parentRecordId){
        system.debug('parentRecordId'+parentRecordId);

        buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c, buildertek__isCommunityUser__c FROM buildertek__RFQ_To_Vendor__c where id=:parentRecordId];
        
        List<FileWrapper> FileWrapper = new List<FileWrapper>();
        list<buildertek__RFI__c> rfislist = [SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =: rfqtovendor.buildertek__RFQ__c];


        system.debug('rfislist size--->'+rfislist.size());
        set<Id> rfiidsset = new set<Id>();
        for(buildertek__RFI__c rec:rfislist){
            rfiidsset.add(rec.Id);
        }
        system.debug('rfiidsset--->'+rfiidsset);
        Map<String,List<FileWrapper>> docRfiMap = new Map<String,List<FileWrapper>>();
        List<buildertek__File__c> conVersion = [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFI__c In:rfiidsset]; 
        for (buildertek__File__c rec : conVersion){ 
            FileWrapper wrap = new FileWrapper();
            
            if(docRfiMap.get(String.valueOf(rec.buildertek__RFI__c) ) != null){
                list<FileWrapper> newDocList = docRfiMap.get(String.valueOf(rec.buildertek__RFI__c));
                wrap.LinkedEntityId = rec.buildertek__RFI__c;
                newDocList.add(wrap);    
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList);     
            }else{
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = rec.buildertek__RFI__c;
                newDocList2.add(wrap);
                docRfiMap.put(String.valueOf(rec.buildertek__RFI__c),newDocList2); 
            }
        }
        system.debug('docRfiMap--->'+docRfiMap);
         

        list<ContentDocumentLink> conlist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
                                            ( SELECT Id FROM buildertek__RFI__c 
                                            where Id In:rfiidsset) and LinkedEntity.Type='buildertek__RFI__c'];
        for(ContentDocumentLink doc: conlist){
            FileWrapper wrap = new FileWrapper();

            if(docRfiMap.get(String.valueOf(doc.LinkedEntityId) ) != null){
                list<FileWrapper>  newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //list<ContentDocumentLink> newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //newDocList.add(doc);    
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList.add(wrap);     
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList);  
            }else{
                //List<ContentDocumentLink> newDocList2 = new List<ContentDocumentLink>();
                //newDocList2.add(doc);
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList2.add(wrap);
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList2);  
            }
        }




        return docRfiMap ;


    }


    public class FileWrapper{
        @AuraEnabled 
        public string imgUrl;
        @AuraEnabled 
        public string imgTitle;
        @AuraEnabled 
        public string LinkedEntityId;
    }


    /*@AuraEnabled 
    public static Map<String,List<ContentDocumentLink>> getrfiresponserelatedfiles(string parentRecordId){
        list<ContentDocumentLink> conlist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
                                            ( SELECT Id FROM buildertek__RFI_Response__c where buildertek__RFI__r.buildertek__RFQ__c =:parentRecordId) and LinkedEntity.Type='buildertek__RFI_Response__c'];
        Map<String,List<ContentDocumentLink>> docRfiMap = new Map<String,List<ContentDocumentLink>>();
        for(ContentDocumentLink doc: conlist){
            if(docRfiMap.get(String.valueOf(doc.LinkedEntityId) ) != null){
                list<ContentDocumentLink> newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                newDocList.add(doc);    
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList);  
            }else{
                List<ContentDocumentLink> newDocList2 = new List<ContentDocumentLink>();
                newDocList2.add(doc);
                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList2);  
            }
        }
        return docRfiMap ;                
        //return conlist;
    }*/

    @AuraEnabled 
    public static  Map<String,List<FileWrapper>> getrfiresponserelatedfiles(string parentRecordId){

        List<FileWrapper> FileWrapper = new List<FileWrapper>();

        
        list<buildertek__RFI_Response__c> rfiresponseslist = [SELECT Id, buildertek__RFI__c,buildertek__RFI__r.Name  
        FROM buildertek__RFI_Response__c Where buildertek__RFI__c=: parentRecordId];

        system.debug('rfiresponseslist size--->'+rfiresponseslist.size());
        set<Id> rfirespidsset = new set<Id>();
        for(buildertek__RFI_Response__c rec:rfiresponseslist){
            rfirespidsset.add(rec.Id);
        }
        system.debug('rfirespidsset--->'+rfirespidsset);

        
        Map<String,List<FileWrapper>> docRfiMap = new Map<String,List<FileWrapper>>();
        List<buildertek__File__c> conVersion = [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFI__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFI_Response__c In:rfirespidsset]; 
        for (buildertek__File__c rec : conVersion){     
            FileWrapper wrap = new FileWrapper();        
            if(docRfiMap.get(String.valueOf(rec.buildertek__RFI_Response__c) ) != null){
                list<FileWrapper> newDocList = docRfiMap.get(String.valueOf(rec.buildertek__RFI_Response__c));
                wrap.LinkedEntityId = rec.buildertek__RFI_Response__c;
                newDocList.add(wrap);    
                docRfiMap.put(String.valueOf(rec.buildertek__RFI_Response__c),newDocList);     
            }else{
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = rec.buildertek__RFI_Response__c;
                newDocList2.add(wrap);
                docRfiMap.put(String.valueOf(rec.buildertek__RFI_Response__c),newDocList2); 
            }
        }
         

            list<ContentDocumentLink> conlist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
            ( SELECT Id FROM buildertek__RFI_Response__c 
            where Id In:rfirespidsset) ];
            //Map<String,List<ContentDocumentLink>> docRfiMap = new Map<String,List<ContentDocumentLink>>();
            for(ContentDocumentLink doc: conlist){
                FileWrapper wrap = new FileWrapper();

                if(docRfiMap.get(String.valueOf(doc.LinkedEntityId) ) != null){
                list<FileWrapper>  newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //list<ContentDocumentLink> newDocList = docRfiMap.get(String.valueOf(doc.LinkedEntityId));
                //newDocList.add(doc);    
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList.add(wrap);    

                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList);  
                }else{
                //List<ContentDocumentLink> newDocList2 = new List<ContentDocumentLink>();
                //newDocList2.add(doc);
                List<FileWrapper> newDocList2 = new List<FileWrapper>();
                wrap.LinkedEntityId = doc.LinkedEntityId;
                newDocList2.add(wrap);

                docRfiMap.put(String.valueOf(doc.LinkedEntityId),newDocList2);  
                }
            }
        return docRfiMap ;                
        //return conlist;
    }

        




    @AuraEnabled 
    public static list<buildertek__RFI_Response__c> getrfiresponselist(string parentRecordId){
        list<buildertek__RFI_Response__c> rfiresponselist= [SELECT Id, buildertek__RFI__c,buildertek__RFI__r.Name  FROM buildertek__RFI_Response__c where buildertek__RFI__c in 
                                                            ( SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =: parentRecordId)];    
        return rfiresponselist;
    }
    @AuraEnabled 
    public static string updateRFQ(string RecordId,List<User> selectedUsers,List<Contact> selectedContacts,
    list<buildertek__File__c> selectedFiles)
    {
        System.debug('selectedUsers-----------------------'+selectedUsers);
        System.debug('selectedContacts-----------------------'+selectedContacts);
         System.debug('RecordId-----------------------'+RecordId);
         System.debug('selectedFiles-----------------------'+selectedFiles);

        List<buildertek__Users_Contacts__c > uandc=new List<buildertek__Users_Contacts__c >();
        // buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : RecordId];
        buildertek__RFI_Response__c rfirespRec = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c,
                                                  buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c 
                                                  where Id =: RecordId ];
        //  User UseRec = [SELECT id, Name/*,isPortalEnabled*/ FROM User WHERE Id =: rfirespRec.CreatedById   /*Profile.UserLicense.Name='PartnerCommunityClone' OR Profile.UserLicense.Name='Customer Community'*/];
        
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : rfirespRec.buildertek__RFI__c];
        rfirec.buildertek__Status__c = 'Responded';
        Boolean isuser = false;
        string portalCode = 'false';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
           system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'false'){
            Update rfirec;
        }
        Set<Id> userIds=new Set<Id>();
        Set<Id> conIds=new Set<Id>();
        if(selectedUsers!=null){
            for(User u:selectedUsers){
                userIds.add(u.Id);
            }            
        }
        
        list<User> userslist = [Select Id, Name, Email From User Where Id In:userIds]; 
        
        if(selectedContacts!=null){
            for(Contact c:selectedContacts){ 
                conIds.add(c.Id);
            }            
        }

        list<Contact> contlist = [Select Id, Name, Email From Contact Where Id In:conIds]; 

        Map<Id,Id> userMap=new Map<Id,Id>();
        Map<Id,Id> conMap=new Map<Id,Id>();
        
        List<buildertek__Users_Contacts__c> deluserconList=[SELECT Id, Name, 
                                                      buildertek__Contact__c, 
                                                      buildertek__User__c, buildertek__RFI__c
                                                      FROM buildertek__Users_Contacts__c 
                                                      where buildertek__RFI__c=:rfirec.Id ];
       if(deluserconList.size()>0){
         if(portalCode == 'false'){
             delete deluserconList;
           }
       }
        
        List<buildertek__Users_Contacts__c> userList=[SELECT Id, Name, 
                                                      buildertek__Contact__c, 
                                                      buildertek__User__c, buildertek__RFI__c
                                                      FROM buildertek__Users_Contacts__c 
                                                      where buildertek__RFI__c=:rfirec.Id and buildertek__User__c in :userIds ];
        List<buildertek__Users_Contacts__c> conList=[SELECT Id, Name, 
                                                     buildertek__Contact__c, 
                                                     buildertek__User__c, buildertek__RFI__c
                                                     FROM buildertek__Users_Contacts__c 
                                                     where buildertek__RFI__c=:rfirec.Id and buildertek__Contact__c in :conIds];
        
        for(buildertek__Users_Contacts__c ucuser:userList){
            userMap.put(ucuser.buildertek__User__c,ucuser.buildertek__RFI__c);
        }
        for(buildertek__Users_Contacts__c uccon:conList){
            conMap.put(uccon.buildertek__Contact__c,uccon.buildertek__RFI__c);
        }
        if(selectedUsers!=null){
            for(User u:selectedUsers){   
                buildertek__Users_Contacts__c uc=new buildertek__Users_Contacts__c();
                if(!userMap.containsKey(u.Id)){
                    uc.buildertek__User__c=u.Id;
                    uc.buildertek__RFI__c=rfirec.Id;
                    uandc.add(uc); 
                }
            }
        }
        if(selectedContacts!=null){
            for(Contact c:selectedContacts){
                buildertek__Users_Contacts__c uc1=new buildertek__Users_Contacts__c();
                if(!conMap.containsKey(c.Id)){
                    uc1.buildertek__RFI__c=rfirec.Id;
                    uc1.buildertek__Contact__c=c.Id;
                    uandc.add(uc1); 
                }
            }
        }
        insert uandc;
        
        buildertek__RFI_Settings__c rfisettings=[SELECT Id, Name, buildertek__New_RFI_Notification_Template__c,
          buildertek__Vendor_Notification_Template__c, buildertek__Recipient_Notification_Template__c FROM buildertek__RFI_Settings__c 
          where buildertek__Vendor_Notification_Template__c!=null and buildertek__Vendor_Notification_Template__c!=null limit 1]; 
        /* Sending Email to Selected Users and Contacts */
        buildertek__RFI__c rfiRec1 = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Email,buildertek__RFI_Assigned_To__r.Name,Owner.Name,Owner.Email,OwnerId ,
                                      buildertek__Submitted_By2__c,buildertek__Submitted_By2__r.Email,buildertek__Submitted_By__c,buildertek__Submitted_By__r.Email
                                      from buildertek__RFI__c where Id =: rfirespRec.buildertek__RFI__c ];
        System.debug('Owner Email------------'+ rfiRec1.Owner.Email!= null);
        Contact con;
        string msg='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
               string usingSalesforceAC= getUser();
        string theTemplate;
        if(usingSalesforceAC=='true'){
         theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :rfisettings.buildertek__Recipient_Notification_Template__c].Id;
        }else{
         theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :rfisettings.buildertek__Vendor_Notification_Template__c].Id;
        }       
        EmailServicesAddress eServices;
        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                        FROM EmailServicesAddress
                        where LocalPart = 'projects'];
        
        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;

        //system.Debug(selectedContacts.size());
        //system.Debug(selectedUsers.size());
        system.debug('theTemplate>'+theTemplate);
        boolean usingemail =  getRFISettings();
        
        //if(selectedContacts.size()==0 &&  (selectedUsers.size()==0)){
             string toemailadd='';
             
            /*if(usingemail==true){
              toemailadd = rfiRec1.buildertek__Submitted_By2__r.Email;
            }else{
              toemailadd = rfiRec1.Owner.Email;
                //System.debug('toemailadd'+toemailadd);
            }*/
        
            if(usingemail==true){
              toemailadd = rfiRec1.buildertek__Submitted_By2__r.Email;
            }else{
                if(usingSalesforceAC=='false'){
                    toemailadd = rfiRec1.buildertek__Submitted_By__r.Email; 
                }else if(usingSalesforceAC=='true'){
                    toemailadd = rfiRec1.buildertek__RFI_Assigned_To__r.Email;
                }
            }   
            system.debug('toemailadd'+toemailadd);
            if( toemailadd!= null){   
                system.debug(toemailadd);
                try{
                     List<string> CCAdresses = new List<string>();
                    if(selectedContacts!=null){
                    if(selectedContacts.size()>0){    
                        for(Contact cc:contlist){
                            
                            if( cc.Email!= null){
                                CCAdresses.add(cc.Email); 
                            }
                        }
                    } 
                    }
                    
                    system.debug('CCAdresses--->'+CCAdresses);
                    if(selectedUsers!=null){
                    if(selectedUsers.size()>0){
                        for(User uu:userslist){                                                
                            if( uu.Email!= null){
                                 CCAdresses.add(uu.Email); 
                            }
                        }
                    }
                    }
                    system.debug('CCAdresses--->'+CCAdresses);
                    
                    List<File__c> flList;
                    string body = '';
                    String fileDetails = '';
                    if(selectedFiles!=null){
                        flList = [Select Id, Name, Bucket_Name__c, Amazon_File_Key__c, File_Presigned_URL__c
                            from File__c
                            where Id IN :selectedFiles];    

                        fileDetails = getFileDetails(flList);
                        
                        if (fileDetails != null){
                        body = body + '<br/><br/><br/>' + fileDetails;
                        }
                    }
                    system.debug('fileDetails --------> ' + fileDetails);


                    string htmlbody = rfirespRec.buildertek__Response__c;
                    htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                    system.debug(htmlbody);
                    system.debug(CCAdresses);
                   // system.debug(htmlbody);
                    //htmlbody = htmlbody+'Please review RFI :'+'https://btservice360-dev-ed.lightning.force.com/lightning/r/buildertek__RFI_Response__c/'+rfirespRec.buildertek__RFI__c+'/view';
                    //htmlbody = 'Hi '+rfiRec1.Owner.Name+'<br/> You have response waiting for your review. <br/><br/> '+htmlbody+'<br/> <br/> Click link to view response '+URL.getSalesforceBaseUrl().toExternalForm()+ '/'+rfirespRec.Id; 
                    

                    List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                    Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();
    
                    message.toAddresses = new String[] { toemailadd};
                    message.setTemplateID(theTemplate);     
                    message.setSaveAsActivity(false);
                    message.setWhatId(rfiRec1.Id);
                    if(usingSalesforceAC=='false'){
                      message.setTargetObjectId(rfiRec1.buildertek__Submitted_By__c);
                    }else if(usingSalesforceAC=='true'){
                      message.setTargetObjectId(rfiRec1.buildertek__RFI_Assigned_To__c);
                    }
                    messageList.add(message);
                    
                    Savepoint sp = Database.setSavepoint();
                    
                    Messaging.sendEmail(messageList);
                    
                    Database.rollback(sp);
                    
                    list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
                    list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
                                                                                                                from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                                WHERE Name = :'Email Configuration'];
                    if (adminInterfaceNodeConfigurations.size() > 0){
                        owea = [select Id from OrgWideEmailAddress where Address =: adminInterfaceNodeConfigurations[0].buildertek__Email_Address__c];
                    }
                    List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                    
                    // loop through the previous message list and set the email fields
                    for (Messaging.SingleEmailMessage email : messageList) {
                        Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                        emailToSend.setToAddresses(email.getToAddresses());

                        //
                        string templatebody = email.getHTMLBody();
                        if(templatebody.contains('{replaceresponse}')){
                            templatebody = templatebody.replace('{replaceresponse}','<br/>'+htmlbody);                            
                        }
                        emailToSend.setHTMLBody('<br/>'+templatebody+'<br/><br/><br/>'+body);    
                        //emailToSend.setHTMLBody('<br/>'+email.getHTMLBody()+'<br/><br/><br/>'+htmlbody+'<br/><br/><br/>'+body);
                        emailToSend.setSaveAsActivity(true);
                        //emailToSend.setSubject(email.getSubject());
                        //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                        emailToSend.setFileAttachments(email.getFileAttachments());
                        emailToSend.setSubject(email.getSubject()+' - [ref:'+rfiRec1.Id+']');
                        emailToSend.setReplyTo(fromAddress);    
                        if(CCAdresses.size()>0){
                            emailToSend.setCcAddresses(CCAdresses);
                        }                       

                        if (owea.size() > 0 ) {
                            emailToSend.setOrgWideEmailAddressId(owea.get(0).Id);
                        }
                        actualMessageList.add(emailToSend);
                    }
                    
                    try{                
                        Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                        msg = 'success';
                    }catch(Exception e){
                        msg = 'fail';
                        //if(error.toLowerCase().contains('invalid')){
                        //}
                        
                    }





                    /*List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                    email.setTargetObjectId(rfiRec1.OwnerId); 
                    email.setSaveAsActivity(false); 
                    email.setTemplateID(theTemplate); 
                    email.setWhatId(rfiRec1.Id); 
                    email.setSaveAsActivity(false);                       
                    email.toAddresses = new String[] { toemailadd};
                    if(CCAdresses.size()>0){
                            email.setCcAddresses(CCAdresses);
                        }                       
                        Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                    if (results[0].success) 
                    {
                        message = 'success';
                        System.debug('The email was sent successfully.');
                    } else {
                        message = 'fail';
                        
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }*/



                    
                }
                catch (exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                   // msg = e.getMessage()+'-'+e.getLineNumber();
                }  
            }
        //}
        
        
        
        
        // return message;
        
        
        return rfirec.id;
    }  
    
    private static string getFileDetails(List<File__c> files){

        if (files.size() == 0){
            return null;
        }
        // Get AWS credentials
        AmazonS3Credential s3Credentials = new AmazonS3Credential();
        String fileDownloadURL = '';
        String emailContent = '';
        emailContent += '<table cellpadding="5"><tr style="background-color:#007fcc;color:white;font-weight:bold;">';
        emailContent += '<th>File Name</th>';
        emailContent += '<th>' + System.Label.Action + '</th><tr>';
        for (File__c file : files){
            emailContent += '<tr>';
            String fileDownloadLinkHTML = '';
            String expiryDateString = '';
            //Check for file access type and encript the link if the file is private
            if (file.File_Presigned_URL__c != null){
                fileDownloadURL = file.File_Presigned_URL__c;
            } else{
                // Get AWS credentials
                //AmazonS3Credential s3Credentials = new AmazonS3Credential();
                Datetime expiryDate = System.now().addMinutes(1);
                fileDownloadURL = FileUtils.getPresignedURL(file.Bucket_Name__c, file.Amazon_File_Key__c, System.now().addDays(100), s3Credentials.key, s3Credentials.secret);
            }
            fileDownloadLinkHTML = '<a href="' + fileDownloadURL + '">' + System.Label.Download + '</a>';
            System.debug('Download Link ----------> ' + fileDownloadLinkHTML);
            emailContent += '<td>' + file.Name + '</td>';
            emailContent += '<td>' + fileDownloadLinkHTML + '</td>';
            emailContent += '</tr>';
        }
        emailContent += '</table>';

        return emailContent;
    }
   
    @AuraEnabled 
    public static string updateRFQ1(string RecordId){
        List<buildertek__Users_Contacts__c > uandc=new List<buildertek__Users_Contacts__c >();
        // buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : RecordId];
        buildertek__RFI_Response__c rfirespRec = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c,
                                                  buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c 
                                                  where Id =: RecordId ];
        //  User UseRec = [SELECT id, Name/*,isPortalEnabled*/ FROM User WHERE Id =: rfirespRec.CreatedById   /*Profile.UserLicense.Name='PartnerCommunityClone' OR Profile.UserLicense.Name='Customer Community'*/];
        
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : rfirespRec.buildertek__RFI__c];
        rfirec.buildertek__Status__c = 'Responded';
        Boolean isuser = false;
        string portalCode = 'false';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'false'){
            Update rfirec;
        }
       buildertek__RFI_Settings__c rfisettings=[SELECT Id, Name, buildertek__New_RFI_Notification_Template__c,
          buildertek__Vendor_Notification_Template__c, buildertek__Recipient_Notification_Template__c FROM buildertek__RFI_Settings__c 
          where buildertek__Vendor_Notification_Template__c!=null and buildertek__Vendor_Notification_Template__c!=null limit 1];
     
        
        /* Sending Email to Selected Users and Contacts */
        buildertek__RFI__c rfiRec1 = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Email,buildertek__RFI_Assigned_To__r.Name,Owner.Name,Owner.Email,OwnerId ,
                                      buildertek__Submitted_By2__c,buildertek__Submitted_By2__r.Email,buildertek__Submitted_By__c,buildertek__Submitted_By__r.Email
                                      from buildertek__RFI__c where Id =: rfirespRec.buildertek__RFI__c ];
        System.debug('Owner Email------------'+ rfiRec1.Owner.Email!= null);
        Contact con;
        string message='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
               string usingSalesforceAC= getUser();
        string theTemplate;
        if(usingSalesforceAC=='true'){
        theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :rfisettings.buildertek__Recipient_Notification_Template__c].Id;
        }else{
        theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :rfisettings.buildertek__Vendor_Notification_Template__c].Id;
        }       
        
        
        system.debug('theTemplate>'+theTemplate);
        boolean usingemail =  getRFISettings();
        
        //if(selectedContacts.size()==0 &&  (selectedUsers.size()==0)){
             string toemailadd='';
             
            if(usingemail==true){
              toemailadd = rfiRec1.buildertek__Submitted_By2__r.Email;
            }else if(usingSalesforceAC=='false'){
            toemailadd =rfiRec1.buildertek__Submitted_By__r.Email;
            }else if(usingSalesforceAC=='true'){
            toemailadd =rfiRec1.buildertek__RFI_Assigned_To__r.Email;
            }else{
              toemailadd = rfiRec1.Owner.Email;
                //System.debug('toemailadd'+toemailadd);
            }
            
            if( toemailadd!= null){   
                system.debug(toemailadd);
                try{
                     
                    
                    string htmlbody = rfirespRec.buildertek__Response__c;
                    htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                    system.debug(htmlbody);
                    //htmlbody = htmlbody+'Please review RFI :'+'https://btservice360-dev-ed.lightning.force.com/lightning/r/buildertek__RFI_Response__c/'+rfirespRec.buildertek__RFI__c+'/view';
                    //htmlbody = 'Hi '+rfiRec1.Owner.Name+'<br/> You have response waiting for your review. <br/><br/> '+htmlbody+'<br/> <br/> Click link to view response '+URL.getSalesforceBaseUrl().toExternalForm()+ '/'+rfirespRec.Id; 
                    
                    List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                    email.setTargetObjectId(rfiRec1.buildertek__RFI_Assigned_To__c); 
                    email.setSaveAsActivity(false); 
                    email.setTemplateID(theTemplate); 
                    email.setWhatId(rfiRec1.Id); 
                    email.setSaveAsActivity(false);                       
                    email.toAddresses = new String[] { toemailadd};
                                        
                        Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                            Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                    if (results[0].success) 
                    {
                        message = 'success';
                        System.debug('The email was sent successfully.');
                    } else {
                        message = 'fail';
                        
                        System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    }
                    
                }
                catch (exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                    message = e.getMessage()+'-'+e.getLineNumber();
                }  
            }
        //}
        
        
        
        
        // return message;
        
        
        return rfirec.id;
    }  
     
    @AuraEnabled 
    public static string updateRFQ2(string RecordId){
        List<buildertek__Users_Contacts__c > uandc=new List<buildertek__Users_Contacts__c >();
        // buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : RecordId];
        buildertek__RFI_Response__c rfirespRec = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c,
                                                  buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c 
                                                  where Id =: RecordId ];
        //  User UseRec = [SELECT id, Name/*,isPortalEnabled*/ FROM User WHERE Id =: rfirespRec.CreatedById   /*Profile.UserLicense.Name='PartnerCommunityClone' OR Profile.UserLicense.Name='Customer Community'*/];
        
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : rfirespRec.buildertek__RFI__c];
        rfirec.buildertek__Status__c = 'Responded';
        Boolean isuser = false;
        string portalCode = 'false';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'false'){
            Update rfirec;
        }
         buildertek__RFI_Settings__c rfisettings=[SELECT Id, Name, buildertek__New_RFI_Notification_Template__c,
          buildertek__Vendor_Notification_Template__c, buildertek__Recipient_Notification_Template__c FROM buildertek__RFI_Settings__c 
          where buildertek__Vendor_Notification_Template__c!=null and buildertek__Vendor_Notification_Template__c!=null limit 1]; 
     
        
        /* Sending Email to Selected Users and Contacts */
        buildertek__RFI__c rfiRec1 = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Email,buildertek__RFI_Assigned_To__r.Name,Owner.Name,Owner.Email,OwnerId ,
                                      buildertek__Submitted_By2__c,buildertek__Submitted_By2__r.Email,buildertek__Submitted_By__c,buildertek__Submitted_By__r.Email
                                      from buildertek__RFI__c where Id =: rfirespRec.buildertek__RFI__c ];
        System.debug('Owner Email------------'+ rfiRec1.Owner.Email!= null);
        Contact con;
        string msg='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
               string usingSalesforceAC= getUser();
        string theTemplate;
   
       theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :rfisettings.buildertek__Vendor_Notification_Template__c].Id;        
        
        system.debug('theTemplate>'+theTemplate);
        boolean usingemail =  getRFISettings();
        
        string toemailadd='';                        
        toemailadd = rfiRec1.buildertek__Submitted_By2__r.Email;
        EmailServicesAddress eServices;
        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                        FROM EmailServicesAddress
                        where LocalPart = 'projects'];
        
        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
        
        if( toemailadd!= null){   
            system.debug(toemailadd);
            try{
 
                    
                string htmlbody = rfirespRec.buildertek__Response__c;
                htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                system.debug(htmlbody);
                //htmlbody = htmlbody+'Please review RFI :'+'https://btservice360-dev-ed.lightning.force.com/lightning/r/buildertek__RFI_Response__c/'+rfirespRec.buildertek__RFI__c+'/view';
                //htmlbody = 'Hi '+rfiRec1.Owner.Name+'<br/> You have response waiting for your review. <br/><br/> '+htmlbody+'<br/> <br/> Click link to view response '+URL.getSalesforceBaseUrl().toExternalForm()+ '/'+rfirespRec.Id; 
                

                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();

                message1.toAddresses = new String[] { toemailadd};
                message1.setTemplateID(theTemplate);     
                message1.setSaveAsActivity(false);
                message1.setWhatId(rfiRec1.Id);
                //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
                message1.setTargetObjectId(rfiRec1.buildertek__Submitted_By2__c);
                messageList.add(message1);
                
                Savepoint sp = Database.setSavepoint();
                
                Messaging.sendEmail(messageList);
                
                Database.rollback(sp);
                try{ 
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSaveAsActivity(false);
                    emailToSend.setSubject(email.getSubject()+' - [ref:'+rfiRec1.Id+']');
                    emailToSend.setReplyTo(fromAddress);

                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    emailToSend.setFileAttachments(email.getFileAttachments());
                    actualMessageList.add(emailToSend);
                    system.debug('emailToSend--->'+emailToSend);
                }
               
                
               

                    Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                    msg = 'success';
                    System.debug('The email was sent successfully.');
                }catch(Exception e){
                    msg = 'fail';
                     System.debug('The email failed to send: ');
                    //}
                    
                }                
                



            }catch (exception e){
                system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                msg = e.getMessage()+'-'+e.getLineNumber();
            } 
        }    
          
        
        // return message;
        
        
        return rfirec.id;
    }  
    
    
    @AuraEnabled 
    public static string updaterfirec(string projectId){
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c , buildertek__RFQ__c
        from buildertek__RFI__c where id = : projectId];
        rfirec.buildertek__Status__c = 'Closed';
        Update rfirec;

        buildertek__RFQ__c rfqrec = [select id,Name,buildertek__Project__c,buildertek__Project__r.Name,
                                     buildertek__Project__r.OwnerId,buildertek__Project__r.Owner.Email
                                      from buildertek__RFQ__c where Id =: rfirec.buildertek__RFQ__c ];

        string toemailadd='';
        if(rfqrec.buildertek__Project__c!=null){
            toemailadd = rfqrec.buildertek__Project__r.Owner.Email;
            System.debug('toemailadd--->'+toemailadd);
    
            string theTemplate;
       
            theTemplate = [SELECT Id
                            FROM EmailTemplate
                            WHERE Name  = 'RFI Closed Project Manager Notification'].Id;        
             
             system.debug('theTemplate>'+theTemplate);
                 
             List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
             Messaging.SingleEmailMessage message1= new        Messaging.SingleEmailMessage();
    
             message1.toAddresses = new String[] { toemailadd};
             message1.setTemplateID(theTemplate);     
             message1.setSaveAsActivity(false);
             message1.setWhatId(rfirec.Id);
             //message1.setSubject('New RFI Notification - [ref:'+newrfi.Id+']');
             message1.setTargetObjectId(rfqrec.buildertek__Project__r.OwnerId);
             messageList.add(message1);
             
             Savepoint sp = Database.setSavepoint();
             
             Messaging.sendEmail(messageList);
             
             Database.rollback(sp);
             try{ 
    
                //List<string> CCAdresses = new List<string>();                    
                //CCAdresses.add('sowndarya.nittala@diligentforcelabs.com'); 
    
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSaveAsActivity(false);
                    emailToSend.setSubject(email.getSubject());
                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    emailToSend.setFileAttachments(email.getFileAttachments());
                    //emailToSend.setCcAddresses(CCAdresses);
                    actualMessageList.add(emailToSend);
                    system.debug('emailToSend--->'+emailToSend);
                }
            
    
                Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                System.debug('The email was sent successfully.');
             }catch(Exception e){
                  System.debug('The email failed to send: ');             
             }                
             
    
    
        }

        return rfirec.id;
    }
    
    @AuraEnabled 
    public static buildertek__RFI__c getrfiRecord(string parentRecordId){
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c,buildertek__Question__c,
        buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,
        buildertek__Submitted_By__c,buildertek__Submitted_By__r.Name,
        buildertek__Submitted_By2__c, buildertek__Submitted_By2__r.Name,
        buildertek__RFQ__c 
        from buildertek__RFI__c where id = : parentRecordId];
        return rfirec;
    }
     @AuraEnabled 
    public static string getrfiquestion(string parentRecordId){
        string question='';
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c,buildertek__Question__c,buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,buildertek__Submitted_By__c,buildertek__Submitted_By__r.Name from buildertek__RFI__c where id = : parentRecordId];
        if(rfirec.buildertek__Question__c!=null){
            question = rfirec.buildertek__Question__c;
            question  = question.stripHtmlTags();    
        }

        return question;        
    }


    @AuraEnabled 
    public static string getrfiresponse(string parentRecordId){
        string question='';
        buildertek__RFI_Response__c rfirec= [select id,Name, buildertek__Response__c from buildertek__RFI_Response__c where id = : parentRecordId];
        question = rfirec.buildertek__Response__c;
        question  = question.stripHtmlTags();
        return question;
    }
    
    @AuraEnabled
                                                            public static String rfiresgetrfiFieldSet(String sObjectName, String fieldSetName,String parentRecordId) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            system.debug('>>>>>>> FsMap >>> ' + FsMap);
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
                }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }
    @AuraEnabled
    public static String getFieldSet(){
        
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__RFI__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__New_RFI_Community_Field_Set')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__New_RFI_Community_Field_Set').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__RFI__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
        }
        return '[' + result + ']';
    }
    
    @AuraEnabled
    public static buildertek__RFQ__c getproject(String projectId){
        system.debug(projectId);
        buildertek__RFQ__c projRecords = [SELECT Id, Name,buildertek__Project__c,buildertek__Project__r.Name , OwnerId, Owner.Name , buildertek__RFI_Owner__c , buildertek__RFI_Owner__r.Name FROM buildertek__RFQ__c where Id =: projectId];
        return projRecords ;
    }
    
     @AuraEnabled
    public static buildertek__RFQ__c getRFQRecDetails(String rfqId){
        system.debug(rfqId);
        buildertek__RFQ__c RFQRecords = [SELECT Id, Name,buildertek__Project__c,buildertek__Status__c,buildertek__Project__r.Name , OwnerId, Owner.Name , buildertek__RFI_Owner__c , buildertek__RFI_Owner__r.Name FROM buildertek__RFQ__c where Id =: rfqId];
        return RFQRecords ;
    }
    
    
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    @AuraEnabled
    public static String uploadFile(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks  
        System.debug(' parentId  ++++++++++++++++++++++++++++++++++'+parentId);
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            system.debug('****'+fileId);
        } else {
            appendToFile(fileId, base64Data);
        }
        return string.valueOf(fileId);
    }
    
    
    private static void appendToFile(Id fileId, String base64Data) {
        system.debug('appendToFile method');
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }
    
     @AuraEnabled
    public static String uploadFile1(String parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert, 
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with reamins chunks  
        System.debug(' parentId  ++++++++++++++++++++++++++++++++++'+parentId);
        System.debug(' fileId  ++++++++++++++++++++++++++++++++++'+fileId);
        
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
            system.debug('****'+fileId);
        } else {
            system.debug('appendToFile');
            appendToFile(fileId, base64Data);
        }
        return string.valueOf(fileId);
    }
    public static Id saveTheFile(String parentId, String fileName, String base64Data, String contentType) { 
        system.debug('parentId--->'+parentId);
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion conVer = new ContentVersion();
        Set<SObjectField> ContentVersionFields = new set<SObjectField>{ContentVersion.ContentLocation,
            ContentVersion.PathOnClient,
            ContentVersion.Title,
            ContentVersion.VersionData};
                conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion
        // First get the Content Document Id from ContentVersion Object
        Id conDoc = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
        //create ContentDocumentLink  record 
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        Set<SObjectField> ContentDocumentLinkFields = new set<SObjectField>{ContentDocumentLink.LinkedEntityId,
            ContentDocumentLink.ContentDocumentId,
            ContentDocumentLink.shareType};
                conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'I';
        insert conDocLink;
        system.debug('inserted--------------'+conDocLink.Id);
        return conDocLink.Id;
    }
    @AuraEnabled
    public static List<buildertek__RFI__c> getrfirecords(string parentRecordId){
        list<buildertek__RFI__c> rfilist = new list<buildertek__RFI__c>();
        string usrtype = getUser(); 
         boolean usingemail =  getRFISettings();
       
        if(usrtype=='true'){                    
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,
                                             buildertek__Submitted_By__c,buildertek__Submitted_By__r.Name,
                                            buildertek__Submitted_By2__c,
                                            buildertek__Submitted_By2__r.Name, buildertek__Status__c
                                            from buildertek__RFI__c 
                                            where buildertek__RFQ__c =:parentRecordId and buildertek__RFI_From_Site__c=false 
                                            And OwnerId =: userInfo.getUserId()
                                            order by Name ASC];
        }else{
            
            if(usingemail==true){
                rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                           buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                           buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Submitted_By2__c,
                           buildertek__Submitted_By2__r.Name, buildertek__Status__c
                           from buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId and buildertek__RFI_From_Site__c=true order by Name ASC];
            }else if(usingemail==false){  
                rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                           buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                           buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,
                           buildertek__Submitted_By__c,buildertek__Submitted_By__r.Name,
                           buildertek__Submitted_By2__c,
                           buildertek__Submitted_By2__r.Name, buildertek__Status__c
                           from buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId and buildertek__RFI_From_Site__c=false  order by Name ASC];    
                
            }            
            
        }
        
        
        /*list<ContentDocumentLink> conDoclist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
( SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId) and LinkedEntity.Type='buildertek__RFI__c'];*/
        //return conlist;
        
        // Map<String,List<ContentDocumentLink>>  = new Map<String,List<ContentDocumentLink>>();
        
        
        
        //if(rfilist.size()>0){
        return rfilist;
        //}
    }
    @AuraEnabled
    public static Map<String,List<buildertek__RFI_Response__c>> getrfiresponeserecords(string parentRecordId){
      string usrtype = getUser(); 
        boolean usingemail =  getRFISettings();
        list<buildertek__RFI__c> rfilist = new list<buildertek__RFI__c>();
        
         if(usrtype=='true'){   
             
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,buildertek__Status__c
                                            from buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId /*and buildertek__RFI_From_Site__c=false*/ ];
        }else{
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name, buildertek__Status__c
                                            from buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId ];        
        }
                                                                                        
                                            
        //if(rfilist.size()>0){
        list<buildertek__RFI_Response__c> rfiresplist = new list<buildertek__RFI_Response__c>();

        if(usrtype=='true'){
            
            rfiresplist = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Other_Responder__c,buildertek__Other_Responder__r.Name,
                                                             buildertek__Response__c,buildertek__Response_Date__c,
                                                             buildertek__Answered__c,buildertek__RFI__c , buildertek__Responderformula__c
                                                             from buildertek__RFI_Response__c where buildertek__RFI__c IN: rfilist
                           and buildertek__Show_In_Community__c  = true and buildertek__private__c=false order by Name ASC];            
        }else{
            rfiresplist = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Other_Responder__c,buildertek__Other_Responder__r.Name,
                                                             buildertek__Response__c,buildertek__Response_Date__c,
                                                             buildertek__Answered__c,buildertek__RFI__c , buildertek__Responderformula__c,buildertek__private__c
                                                             from buildertek__RFI_Response__c where buildertek__RFI__c IN: rfilist order by Name ASC]; 
        } 
        
        Map<String,List<buildertek__RFI_Response__c>> TaskWithPhaseMap = new Map<String,List<buildertek__RFI_Response__c>>();
        
        for(buildertek__RFI_Response__c task:rfiresplist){ //projectTasks1
            // system.debug(task.Name);
            if(TaskWithPhaseMap.get(String.valueOf(task.buildertek__RFI__c) ) != null){
                list<buildertek__RFI_Response__c> newProjectTaskList = TaskWithPhaseMap.get(String.valueOf(task.buildertek__RFI__c));
                newProjectTaskList.add(task);    
                TaskWithPhaseMap.put(String.valueOf(task.buildertek__RFI__c),newProjectTaskList);  
            }else{
                List<buildertek__RFI_Response__c> newTaskList = new List<buildertek__RFI_Response__c>();
                newTaskList.add(task);
                TaskWithPhaseMap.put(String.valueOf(task.buildertek__RFI__c),newTaskList);  
            }
        }
        
        for(buildertek__RFI__c rfi : rfilist){
            if(TaskWithPhaseMap.get(String.valueOf(rfi.Id)) == null){
                List<buildertek__RFI_Response__c> newRfiList = new List<buildertek__RFI_Response__c>();
                TaskWithPhaseMap.put(String.valueOf(rfi.Id),newRfiList);
            }
        }
        
        //if(rfilist.size()>0){
        return TaskWithPhaseMap;
        //}
    }
    @AuraEnabled 
    /* public static list<buildertek__RFI_Response__c> getrfiresponselists(string parentRecordId){
list<buildertek__RFI_Response__c> rfiresponselist= [SELECT Id, buildertek__RFI__c,buildertek__RFI__r.Name  FROM buildertek__RFI_Response__c where buildertek__RFI__c in 
( SELECT buildertek__Assigned_To__c FROM buildertek__RFI__c where buildertek__RFQ__c =: parentRecordId)];     
return rfiresponselist;
}*/
    public static list<buildertek__RFI_Response__c> getrfiresponselists(string parentRecordId){
        list<buildertek__RFI_Response__c> rfiresponselist= [SELECT Id,Name,CreatedDate,buildertek__RFI__c,buildertek__Responder__r.Name,
                                                            buildertek__Response_Date__c,buildertek__Response__c,CreatedBy.Name,
                                                            buildertek__RFI__r.Name , buildertek__Responderformula__c
                                                            FROM buildertek__RFI_Response__c 
                                                            where buildertek__RFI__c =: parentRecordId Order by CreatedDate desc];    
        return rfiresponselist;
    }
    
    /*@AuraEnabled 
    public static List<String> getRecContacts(string rfiId1){
        Set<Id> rfiIds=new Set<Id>();
        buildertek__RFI__c rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Users_Contacts__c 
                                      from buildertek__RFI__c where Id =:rfiId1 ];
        
        list<buildertek__Users_Contacts__c> userandcontact = [SELECT Id,
                                                              Name,
                                                              buildertek__User__c, 
                                                              buildertek__Contact__c, 
                                                              buildertek__Contact__r.Name,
                                                              buildertek__User__r.Name,
                                                              buildertek__RFI__c 
                                                              FROM buildertek__Users_Contacts__c 
                                                              where buildertek__RFI__c =:rfiId1];
        List<String> userNamesList=new List<String>();
        List<String> contactsNamesList=new List<String>();
        for(buildertek__Users_Contacts__c uc:userandcontact){
            userNamesList.add(uc.buildertek__User__r.Name);
            contactsNamesList.add(uc.buildertek__Contact__r.Name);
        }
        set<string> aStringSet = new set<string>(userNamesList);
        set<string> bStringSet = new set<string>(contactsNamesList);
        aStringSet.remove('');
        bStringSet.remove(null);
        System.debug('contactsNamesList-------------------'+contactsNamesList);
        return contactsNamesList;
    }*/
   
    /*@AuraEnabled 
    public static List<String> getRecUsers(string rfiId){
        Set<Id> rfiIds=new Set<Id>();
        buildertek__RFI__c rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Users_Contacts__c 
                                      from buildertek__RFI__c where Id =:rfiId ];
        
        list<buildertek__Users_Contacts__c> userandcontact = [SELECT Id,
                                                              Name,
                                                              buildertek__User__c, 
                                                              buildertek__Contact__c, 
                                                              buildertek__Contact__r.Name,
                                                              buildertek__User__r.Name,
                                                              buildertek__RFI__c 
                                                              FROM buildertek__Users_Contacts__c 
                                                              where buildertek__RFI__c =:rfiId];
        List<String> userNamesList=new List<String>();
        List<String> contactsNamesList=new List<String>();
        for(buildertek__Users_Contacts__c uc:userandcontact){
            userNamesList.add(uc.buildertek__User__r.Name);
            contactsNamesList.add(uc.buildertek__Contact__r.Name);
        }
        set<string> aStringSet = new set<string>(userNamesList);
        set<string> bStringSet = new set<string>(contactsNamesList);
        aStringSet.remove('');
        bStringSet.remove(null);
        System.debug('contactsNamesList-------------------'+contactsNamesList);
        return userNamesList;
    }   */ 
    
    @AuraEnabled 
    public static List < sObject > getRecUsers(string rfiId){
        Set<Id> rfiIds=new Set<Id>();
        List < sObject > returnList = new List < sObject > ();
        buildertek__RFI__c rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Users_Contacts__c 
                                      from buildertek__RFI__c where Id =:rfiId ];
        
        list<buildertek__Users_Contacts__c> userandcontact = [SELECT Id,
                                                              Name,
                                                              buildertek__User__c, 
                                                              buildertek__Contact__c, 
                                                              buildertek__Contact__r.Name,
                                                              buildertek__User__r.Name,
                                                              buildertek__RFI__c 
                                                              FROM buildertek__Users_Contacts__c 
                                                              where buildertek__RFI__c =:rfiId];
        set<Id> userIds = new set<Id>();
        system.debug('userandcontact'+userandcontact);
        for(buildertek__Users_Contacts__c uc:userandcontact){
            system.debug('user'+uc.buildertek__User__c+uc.buildertek__User__r.Name);
             system.debug('cont'+uc.buildertek__Contact__c+uc.buildertek__Contact__r.Name);
            if(uc.buildertek__User__c!=null)
            userIds.add(uc.buildertek__User__c);
        }
        
            
       
        String sQuery = 'select id, Name from User where Id IN : userIds order by createdDate DESC ';
        List < sObject > lstOfRecords; 
        lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));       
        for (sObject obj: lstOfRecords) { 
            returnList.add(obj);
        }
        
        System.debug('returnList-------------------'+returnList);
        return returnList;
    }   
    
    @AuraEnabled 
    public static List < sObject > getRecContacts(string rfiId1){
        Set<Id> rfiIds=new Set<Id>();
        List < sObject > returnList = new List < sObject > ();

        buildertek__RFI__c rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Users_Contacts__c 
                                      from buildertek__RFI__c where Id =:rfiId1 ];
         
        list<buildertek__Users_Contacts__c> userandcontact = [SELECT Id,
                                                              Name,
                                                              buildertek__User__c, 
                                                              buildertek__Contact__c, 
                                                              buildertek__Contact__r.Name,
                                                              buildertek__User__r.Name,
                                                              buildertek__RFI__c 
                                                              FROM buildertek__Users_Contacts__c 
                                                              where buildertek__RFI__c =:rfiId1];
        set<Id> condIds = new set<Id>();
        system.debug('userandcontact'+userandcontact);
        for(buildertek__Users_Contacts__c uc:userandcontact){
            system.debug('user'+uc.buildertek__User__c+uc.buildertek__User__r.Name);
             system.debug('cont'+uc.buildertek__Contact__c+uc.buildertek__Contact__r.Name);
            if(uc.buildertek__Contact__r!=null)
            condIds.add(uc.buildertek__Contact__c);
        }
        
            
       
        String sQuery = 'select id, Name from Contact where Id IN : condIds order by createdDate DESC ';
        List < sObject > lstOfRecords; 
        lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));       
        for (sObject obj: lstOfRecords) { 
            returnList.add(obj);
        }
        System.debug('returnList-------------------'+returnList);
        return returnList;
    }


    @AuraEnabled 
    public static RFIWrap getrfidetailsecord(string parentRecordId){
        system.debug('getrfidetailsecord');
        RFIWrap wrapper = new RFIWrap();
        buildertek__RFI_Response__c rfirrrec=[SELECT Id, Name, 
                                              buildertek__Responder__c, 
                                              buildertek__Responder__r.Name,
                                              buildertek__Response__c, 
                                              buildertek__Response_Date__c,
                                              buildertek__RFI__c,
                                              buildertek__RFI__r.buildertek__Status__c,
                                              buildertek__Parent__c, 
                                              buildertek__Other_Responder__c, 
                                              buildertek__Responderformula__c,
                                              buildertek__Show_In_Community__c,
                                              buildertek__Date_Sent__c, 
                                              buildertek__Answered__c FROM buildertek__RFI_Response__c where id=:parentRecordId];

        
        wrapper.responserec = rfirrrec;
        wrapper.contacts = getRecContacts(rfirrrec.buildertek__RFI__c);
        wrapper.users = getRecUsers(rfirrrec.buildertek__RFI__c);
        wrapper.rfirec  = getrfiRecord(rfirrrec.buildertek__RFI__c);
        return wrapper;
    }
    

    public class RFIWrap{
        @AuraEnabled
        public List < sObject > contacts{ get; set; }

        @AuraEnabled
        public List < sObject > users{ get; set; }

        @AuraEnabled
        public buildertek__RFI_Response__c responserec;  

        @AuraEnabled
        public buildertek__RFI__c rfirec;  

     }


@AuraEnabled 
    public static RFQWrap getrfqdetailsecord(string recId){
        system.debug('getrfidetailsecord------------------'+recId);
        RFQWrap wrapper = new RFQWrap();
        buildertek__RFQ_To_Vendor__c rfqrec=[ SELECT Id, Name, buildertek__RFQ__c, buildertek__Vendor__c FROM buildertek__RFQ_To_Vendor__c where id=:recId];

        
       
        wrapper.rfqrec  = getproject(rfqrec.buildertek__RFQ__c);
        return wrapper;
    }




public class RFQWrap{
      
        @AuraEnabled
        public buildertek__RFQ__c rfqrec;  

     }
    
    @AuraEnabled
    public static String sendProposalforVendor(String recordId,list<buildertek__File__c> selectedFiles){
     buildertek__RFI_Settings__c rfiSettings = new buildertek__RFI_Settings__c();
     string notificationtemplate='New RFI notification';
        List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name, 
                                                             buildertek__Using_Communities__c,
                                                             buildertek__Using_Email__c,
                                                             buildertek__New_RFI_Notification_Template__c
                                                             from buildertek__RFI_Settings__c
                                                             WHERE Name ='RFI Settings'];
    system.debug('rfiSettingsList-------'+rfiSettingsList);
    if(rfiSettingsList.size() > 0){
        rfiSettings = rfiSettingsList[0]; 
        if(rfiSettings.buildertek__New_RFI_Notification_Template__c!=null){
             notificationtemplate = rfiSettings.buildertek__New_RFI_Notification_Template__c;
        }  
    }
    
    
        buildertek__RFI__c rfiRec = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                     buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                     buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Email,buildertek__RFI_Assigned_To__r.Name,buildertek__Vendor_Account__c
                                     from buildertek__RFI__c where Id =:recordId ];
        User u = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string portalCode = 'false';
        string userName = userInfo.getUserId();        
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'true'){      
            if(u.AccountId!=null){
                rfiRec.buildertek__Vendor_Account__c = u.AccountId;
                update rfiRec; 
                system.debug(rfiRec);
            }
        } 
        
        system.debug('selectedFiles-->'+selectedFiles);
        if(selectedFiles.size()>0){
          list<buildertek__File__c> fileslist = 
          [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c ,
          buildertek__ContentDocument_Id__c
          FROM buildertek__File__c Where Id In:selectedFiles];
  
        
            try{
              for(buildertek__File__c rec: fileslist){
                rec.buildertek__RFQ__c = null; 
                  rec.buildertek__RFI__c = recordId; 
                  rec.buildertek__RFI_Response__c = null;
                }
                update fileslist;
            }catch(exception e){               
            }        
  
        }

        Contact con;
        string msg='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
        string theTemplate;
        theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :notificationtemplate].Id;
        if( rfiRec.buildertek__RFI_Assigned_To__c != null){
            
            try{
                
                
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();

                message.toAddresses = new String[] { rfiRec.buildertek__RFI_Assigned_To__r.Email };
                    message.setTemplateID(theTemplate);     
                message.setSaveAsActivity(false);
                message.setWhatId(recordId);
                message.setTargetObjectId(Con.id /* UserInfo.getUserId() */);
                messageList.add(message);
                
                Savepoint sp = Database.setSavepoint();
                
                Messaging.sendEmail(messageList);
                
                Database.rollback(sp);
                
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSaveAsActivity(true);
                    emailToSend.setSubject(email.getSubject());
                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    emailToSend.setFileAttachments(email.getFileAttachments());
                    actualMessageList.add(emailToSend);
                }
                
                try{                
                    Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                    msg = 'success';
                }catch(Exception e){
                    msg = 'fail';
                    //if(error.toLowerCase().contains('invalid')){
                    //}
                    
                }
            
                
                
                /*List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                email.setTargetObjectId(con.id); 
                email.setSaveAsActivity(false); 
                email.setTemplateID(theTemplate); 
                email.setWhatId(recordId); 
                email.setSaveAsActivity(true);                       
                email.toAddresses = new String[] { rfiRec.buildertek__RFI_Assigned_To__r.Email};
                    Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                if (results[0].success) 
                {
                    message = 'success';
                    System.debug('The email was sent successfully.');
                } else {
                    message = 'fail';
                    
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }*/
            }
            catch (exception e){
                system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                msg = e.getMessage()+'-'+e.getLineNumber();
            }  
        }
        
        return msg;
    } 
    
 
    @AuraEnabled
    public static String sendProposalforVendor1(String recordId,String rfqtovendorId,list<buildertek__File__c> selectedFiles){
     buildertek__RFI_Settings__c rfiSettings = new buildertek__RFI_Settings__c();
     string notificationtemplate='New RFI notification';
        List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name, 
                                                             buildertek__Using_Communities__c,
                                                             buildertek__Using_Email__c,
                                                             buildertek__New_RFI_Notification_Template__c
                                                             from buildertek__RFI_Settings__c
                                                             WHERE Name ='RFI Settings'];
    system.debug('rfiSettingsList-------'+rfiSettingsList);
    if(rfiSettingsList.size() > 0){
        rfiSettings = rfiSettingsList[0]; 
        if(rfiSettings.buildertek__New_RFI_Notification_Template__c!=null){
             notificationtemplate = rfiSettings.buildertek__New_RFI_Notification_Template__c;
        }  
    }
    
    
        buildertek__RFI__c rfiRec = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                     buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                     buildertek__RFI_Assigned_To__c,
                                     buildertek__RFI_Assigned_To__r.Email,
                                     buildertek__RFI_Assigned_To__r.Name,
                                     buildertek__Vendor_Account__c, buildertek__RFQ_To_Vendor__c
                                     from buildertek__RFI__c where Id =:recordId ];
        User u = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string portalCode = 'false';
        string userName = userInfo.getUserId();       
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'true'){      
            if(u.AccountId!=null){
                rfiRec.buildertek__Vendor_Account__c = u.AccountId;
                rfiRec.buildertek__RFQ_To_Vendor__c  = rfqtovendorId;
                update rfiRec; 
                system.debug(rfiRec);
            }
        } 
        
        system.debug('selectedFiles-->'+selectedFiles);
        if(selectedFiles.size()>0){
          list<buildertek__File__c> fileslist = 
          [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c ,
          buildertek__RFQ_To_Vendor__c,
          buildertek__ContentDocument_Id__c
          FROM buildertek__File__c Where Id In:selectedFiles];
  
        
            try{
              for(buildertek__File__c rec: fileslist){
                rec.buildertek__RFQ__c = null; 
                rec.buildertek__RFQ_To_Vendor__c  = null; 
                  rec.buildertek__RFI__c = recordId; 
                  rec.buildertek__RFI_Response__c = null;
                }
                update fileslist;
            }catch(exception e){               
            }        
  
        }

        Contact con;
        string msg='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
        string theTemplate;
        theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :notificationtemplate].Id;
        if( rfiRec.buildertek__RFI_Assigned_To__c != null){
            
            try{
                
                
                List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();

                message.toAddresses = new String[] { rfiRec.buildertek__RFI_Assigned_To__r.Email };
                    message.setTemplateID(theTemplate);     
                message.setSaveAsActivity(false);
                message.setWhatId(recordId);
                message.setTargetObjectId(Con.id /* UserInfo.getUserId() */);
                messageList.add(message);
                
                Savepoint sp = Database.setSavepoint();
                
                Messaging.sendEmail(messageList);
                
                Database.rollback(sp);
                
                List<Messaging.SingleEmailMessage> actualMessageList = new List<Messaging.SingleEmailMessage>();
                
                // loop through the previous message list and set the email fields
                for (Messaging.SingleEmailMessage email : messageList) {
                    Messaging.SingleEmailMessage emailToSend = new Messaging.SingleEmailMessage();
                    emailToSend.setToAddresses(email.getToAddresses());
                    emailToSend.setHTMLBody(email.getHTMLBody());
                    emailToSend.setSaveAsActivity(true);
                    emailToSend.setSubject(email.getSubject());
                    //emailToSend.setOrgWideEmailAddressId(email.getOrgWideEmailAddressId());
                    emailToSend.setFileAttachments(email.getFileAttachments());
                    actualMessageList.add(emailToSend);
                }
                
                try{                
                    Messaging.SendEmailResult [] serList = Messaging.sendEmail(actualMessageList);           
                    msg = 'success';
                }catch(Exception e){
                    msg = 'fail';
                    //if(error.toLowerCase().contains('invalid')){
                    //}
                    
                }
            
                
                
                /*List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                email.setTargetObjectId(con.id); 
                email.setSaveAsActivity(false); 
                email.setTemplateID(theTemplate); 
                email.setWhatId(recordId); 
                email.setSaveAsActivity(true);                       
                email.toAddresses = new String[] { rfiRec.buildertek__RFI_Assigned_To__r.Email};
                    Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                if (results[0].success) 
                {
                    message = 'success';
                    System.debug('The email was sent successfully.');
                } else {
                    message = 'fail';
                    
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                }*/
            }
            catch (exception e){
                system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                msg = e.getMessage()+'-'+e.getLineNumber();
            }  
        }
        
        return msg;
    } 
    

    

    
     @AuraEnabled 
    public static string saveNewRFI(string recId,string assignedTo,string submittedby,string projectid,string subject,string duedate,string contactname,string rfiassignedto){
         string msg = '';
         system.debug('recId-'+ recId);
         system.debug('assignedTo-'+ assignedTo);
         system.debug('submittedby-'+ submittedby);
         system.debug('projectid-'+ projectid);
         system.debug('subject-'+ subject);
         system.debug('duedate-'+ duedate);
         system.debug('contactname-'+ contactname);
         string year = duedate.split('-')[0];
         string month = duedate.split('-')[1];
         string day = duedate.split('-')[2];         
         
         

         //contact con = [Select Id From contact where Name=:submittedby];
         if(contactname!=null){
            buildertek__RFI__c rec = new buildertek__RFI__c();
            rec.buildertek__RFI_Assigned_To__c  =  rfiassignedto;
            rec.buildertek__Assigned_To__c  = assignedTo;
            rec.buildertek__Submitted_By2__c = contactname;
            rec.buildertek__Project__c = projectid;   
            rec.buildertek__Subject__c = subject;
             if(!test.isRunningTest()){
                 rec.buildertek__Due_Date__c =   date.valueOf(duedate);
             }
            rec.buildertek__RFQ__c  =  recId;
            try{
               insert rec; 
               system.debug(rec.Id);  
               msg = 'Saved~'+rec.Id; 
                       
            }catch(Exception e){
               msg = e.getMessage()+'-'+e.getLineNumber();
            }
            system.debug('msg'+msg);
         }
         
        
        return msg;
    }   
    
    
    @AuraEnabled 
    public static string updateRFIForward(string RecordId,List<User> selectedUsers,List<Contact> selectedContacts
    ,list<buildertek__File__c> selectedFiles){
        System.debug('selectedUsers-----------------------'+selectedUsers);
        System.debug('selectedContacts-----------------------'+selectedContacts);
        List<buildertek__Users_Contacts__c > uandc=new List<buildertek__Users_Contacts__c >();
        // buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : RecordId];
        buildertek__RFI_Response__c rfirespRec = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Response__c,buildertek__Response_Date__c,
                                                  buildertek__Answered__c,buildertek__RFI__c,CreatedById from buildertek__RFI_Response__c 
                                                  where Id =: RecordId ];
        //  User UseRec = [SELECT id, Name/*,isPortalEnabled*/ FROM User WHERE Id =: rfirespRec.CreatedById   /*Profile.UserLicense.Name='PartnerCommunityClone' OR Profile.UserLicense.Name='Customer Community'*/];
        
        buildertek__RFI__c rfirec= [select id,Name,buildertek__Status__c from buildertek__RFI__c where id = : rfirespRec.buildertek__RFI__c];
        rfirec.buildertek__Status__c = 'Responded';
        Boolean isuser = false;
        string portalCode = 'false';
        string userName = userInfo.getUserId();
        list<Network> netRec = [SELECT Id FROM Network where Status = 'Live'];
        system.debug('%%%'+netRec.size());
        if(netRec.size() > 0){
            string strQry = 'Select isPortalEnabled From User Where id=: userName';    
            list<User> userRec = Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
        }
        if(portalCode == 'false'){
            Update rfirec;
        }
        Set<Id> userIds=new Set<Id>();
        Set<Id> conIds=new Set<Id>();
        for(User u:selectedUsers){
            userIds.add(u.Id);
        }
        
        list<User> userslist = [Select Id, Name, Email From User Where Id In:userIds]; 
        
        
        for(Contact c:selectedContacts){ 
            conIds.add(c.Id);
        }
        
         list<Contact> contlist = [Select Id, Name, Email From Contact Where Id In:conIds]; 
         
        Map<Id,Id> userMap=new Map<Id,Id>();
        Map<Id,Id> conMap=new Map<Id,Id>();
        
        List<buildertek__Users_Contacts__c> deluserconList=[SELECT Id, Name, 
                                                      buildertek__Contact__c, 
                                                      buildertek__User__c, buildertek__RFI__c
                                                      FROM buildertek__Users_Contacts__c 
                                                      where buildertek__RFI__c=:rfirec.Id ];
       if(deluserconList.size()>0){
          delete deluserconList;
       }
        
        List<buildertek__Users_Contacts__c> userList=[SELECT Id, Name, 
                                                      buildertek__Contact__c, 
                                                      buildertek__User__c, buildertek__RFI__c
                                                      FROM buildertek__Users_Contacts__c 
                                                      where buildertek__RFI__c=:rfirec.Id and buildertek__User__c in :userIds ];
        List<buildertek__Users_Contacts__c> conList=[SELECT Id, Name, 
                                                     buildertek__Contact__c, 
                                                     buildertek__User__c, buildertek__RFI__c
                                                     FROM buildertek__Users_Contacts__c 
                                                     where buildertek__RFI__c=:rfirec.Id and buildertek__Contact__c in :conIds];
        
        for(buildertek__Users_Contacts__c ucuser:userList){
            userMap.put(ucuser.buildertek__User__c,ucuser.buildertek__RFI__c);
        }
        for(buildertek__Users_Contacts__c uccon:conList){
            conMap.put(uccon.buildertek__Contact__c,uccon.buildertek__RFI__c);
        }
        for(User u:selectedUsers){   
            buildertek__Users_Contacts__c uc=new buildertek__Users_Contacts__c();
            if(!userMap.containsKey(u.Id)){
                uc.buildertek__User__c=u.Id;
                uc.buildertek__RFI__c=rfirec.Id;
                uandc.add(uc); 
            }
        }
        for(Contact c:selectedContacts){
            buildertek__Users_Contacts__c uc1=new buildertek__Users_Contacts__c();
            if(!conMap.containsKey(c.Id)){
                uc1.buildertek__RFI__c=rfirec.Id;
                uc1.buildertek__Contact__c=c.Id;
                uandc.add(uc1); 
            }
        }
        insert uandc;
        
        
        /* Sending Email to Selected Users and Contacts */
        buildertek__RFI__c rfiRec1 = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                      buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                      buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Email,buildertek__RFI_Assigned_To__r.Name,Owner.Name,Owner.Email,OwnerId ,
                                      buildertek__Submitted_By2__c,buildertek__Submitted_By2__r.Email
                                      from buildertek__RFI__c where Id =: rfirespRec.buildertek__RFI__c ];
        System.debug('Owner Email------------'+ rfiRec1.Owner.Email!= null);
        Contact con;
        string message='';
        con = [select id, Email
               from Contact
               where email != null
               order by createddate desc
               limit 1];
        string theTemplate;
        /*theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = :'New RFI Response Notification'].Id;*/
        system.Debug(selectedContacts.size());
        system.Debug(selectedUsers.size());
        
        boolean usingemail =  getRFISettings();
       
        
        if(selectedContacts.size()>0){
            for(Contact cc : contlist){
                if( cc.Email!= null){
                    
                    try{
                        List<File__c> flList;


                        flList = [Select Id, Name, Bucket_Name__c, Amazon_File_Key__c, File_Presigned_URL__c
                            from File__c
                            where Id IN :selectedFiles];
    
    
                        String fileDetails = getFileDetails(flList);
                        system.debug('fileDetails --------> ' + fileDetails);
                        string body = '';
                        if (fileDetails != null){
                        body = body + '<br/><br/><br/>' + fileDetails;
                        }
    
                        string htmlbody = rfirespRec.buildertek__Response__c;
                        htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                        system.debug(htmlbody);
                        //htmlbody = htmlbody+'Please review RFI :'+'https://btservice360-dev-ed.lightning.force.com/lightning/r/buildertek__RFI_Response__c/'+rfirespRec.buildertek__RFI__c+'/view';
                        htmlbody = 'Hi '+cc.Name+'<br/><br/> Please review below response and respond to this email. <br/><br/>'+htmlbody+'<br/>';
                        EmailServicesAddress eServices;
                        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                                     FROM EmailServicesAddress
                                     where LocalPart = 'projects'];
                        
                        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(cc.id); 
                        email.setSubject('Review Response Notification - [ref:'+recordId+']');
                        email.setSaveAsActivity(true); 
                        //email.setTemplateID(theTemplate); 
                        email.setWhatId(recordId); 
                        email.setSaveAsActivity(true);
                        email.setHTMLBody(htmlbody+'<br/><br/><br/>'+body);
                        email.setReplyTo(fromAddress);                        

                        email.toAddresses = new String[] { cc.Email};
                            Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                        if (results[0].success) 
                        {
                            message = 'success';
                            System.debug('The email was sent successfully.');
                        } else {
                            message = 'fail';
                            
                            System.debug('The email failed to send: ' +  results[0].errors[0].message);
                        }
                    }
                    catch (exception e){
                        system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                        message = e.getMessage()+'-'+e.getLineNumber();
                    }  
                }
            }
        }
        if(selectedUsers.size()>0){
            for(User uu:userslist){
                
                
                if( uu.Email!= null){
                    
                    try{
                        
                        string htmlbody = rfirespRec.buildertek__Response__c;
                        htmlbody =  htmlbody.replaceAll('\n', '<br/>');
                        system.debug(htmlbody);                        
                        //htmlbody = htmlbody+'Please review RFI :'+'https://btservice360-dev-ed.lightning.force.com/lightning/r/buildertek__RFI_Response__c/'+rfirespRec.buildertek__RFI__c+'/view';
                        htmlbody = 'Hi '+uu.Name+'<br/><br/>Here is the response : '+htmlbody+'<br/>'+'<br/>'+' Please review the response '+URL.getSalesforceBaseUrl().toExternalForm()+ '/'+RecordId;   
                        EmailServicesAddress eServices;
                        eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
                                     FROM EmailServicesAddress
                                     where LocalPart = 'projects'];
                        
                        String fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;                        
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(uu.id); 
                        email.setSubject('Review Response Notification - [ref:'+recordId+']');
                        email.setSaveAsActivity(true); 
                        //email.setTemplateID(theTemplate); 
                        email.setWhatId(recordId); 
                        email.setSaveAsActivity(false);
                        email.setHTMLBody(htmlbody);   
                        email.setReplyTo(fromAddress);                        
                        email.toAddresses = new String[] { uu.Email};
                            Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                                Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                        if (results[0].success) 
                        {
                            message = 'success';
                            System.debug('The email was sent successfully.');
                        } else {
                            message = 'fail';
                            
                            System.debug('The email failed to send: ' +  results[0].errors[0].message);
                        }
                    }
                    catch (exception e){
                        system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                        message = e.getMessage()+'-'+e.getLineNumber();
                    }  
                }
            }
        }
        
        // return message;
        
        
        return rfirec.id;
    }  
    @AuraEnabled 
    public static buildertek__RFI_Response__c getrfiRRRecord(string parentRecordId){
        buildertek__RFI_Response__c rfirrrec=[SELECT Id, Name, 
                                              buildertek__Responder__c, 
                                              buildertek__Responder__r.Name,
                                              buildertek__Response__c, 
                                              buildertek__Response_Date__c,
                                              buildertek__RFI__c,
                                              buildertek__RFI__r.buildertek__RFI_Assigned_To__c,
                                              buildertek__RFI__r.buildertek__RFI_Assigned_To__r.Name,
                                              buildertek__RFI__r.buildertek__Submitted_By__c,
                                              buildertek__RFI__r.buildertek__Submitted_By__r.Name,
                                              buildertek__RFI__r.buildertek__Submitted_By2__c,
                                              buildertek__RFI__r.buildertek__Submitted_By2__r.Name,
                                              buildertek__RFI__r.buildertek__Status__c,
                                              buildertek__Parent__c, 
                                              buildertek__Other_Responder__c, 
                                              buildertek__Responderformula__c,
                                              buildertek__Show_In_Community__c,
                                              buildertek__Date_Sent__c, 
                                              buildertek__Answered__c FROM buildertek__RFI_Response__c where id=:parentRecordId];
        return rfirrrec;
    }
    
     @AuraEnabled
    public static string getRFQRec(String rfiId){
      buildertek__RFI__c rfirec=[SELECT Id, Name, buildertek__RFQ__c FROM buildertek__RFI__c where id=:rfiId and buildertek__RFQ__c!=null];
        return rfirec.buildertek__RFQ__c ;
    }
    @AuraEnabled
    public static string getRFQRec1(String rfiIdr){
      buildertek__RFI__c rfirec=[SELECT Id, Name, buildertek__RFQ__c FROM buildertek__RFI__c where id=:rfiIdr and buildertek__RFQ__c!=null];
        return rfirec.buildertek__RFQ__c ;
    }
    
    @AuraEnabled
    public static string getBTSettings(String rfiId){
      buildertek__RFI__c rfirec=[SELECT Id, Name, buildertek__RFQ__c FROM buildertek__RFI__c where id=:rfiId];
        return rfirec.buildertek__RFQ__c ;
    }
    @AuraEnabled
    public static buildertek__RFI_Response__c createRFIResponse(String rfiRecId,String userId,String response,String parentId,
                                                                List<User> selectedUsers,List<Contact> selectedContacts,
                                                               list<buildertek__File__c> selectedFiles){
      system.debug('createRFIResponse');
      system.debug('parentId---->'+parentId);
      String returvalue='';
      String varresponse ='';
      varresponse = response.stripHtmlTags();
      buildertek__RFI_Response__c rfirr= new buildertek__RFI_Response__c();
       try{
      rfirr.buildertek__RFI__c=rfiRecId;
      rfirr.buildertek__Responder__c=userId;
      rfirr.buildertek__Response__c=varresponse ;
      rfirr.buildertek__Response_Date__c=system.today();
      rfirr.buildertek__Parent__c=parentId;
      rfirr.buildertek__Response_From_CMP__c = true;   
      insert rfirr;
      returvalue='sucess';
      system.debug('selectedFiles-->'+selectedFiles);
      if(selectedFiles.size()>0){
        list<buildertek__File__c> fileslist = 
        [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c ,
        buildertek__ContentDocument_Id__c
        FROM buildertek__File__c Where Id In:selectedFiles];

      
          try{
            for(buildertek__File__c rec: fileslist){
                //rec.buildertek__RFI__c = null; 
                rec.buildertek__RFI_Response__c = rfirr.Id;
              }
              update fileslist;
          }catch(exception e){
            
          }
         
                       
         

      

        }

        updateRFQ(rfirr.Id,selectedUsers,selectedContacts,selectedFiles);
      }catch (exception e){
                        system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                        returvalue= e.getMessage()+'-'+e.getLineNumber();
                    }
                    return rfirr;
    }


     @AuraEnabled
    public static string createRFIResponseTest(String rfiRecId, String userId,String response,String parentId,list<buildertek__File__c> selectedFiles){
        system.debug('createRFIResponse');
      String returvalue='';
      String varresponse ='';
        varresponse = response.stripHtmlTags();
        buildertek__RFI_Response__c rfirr= new buildertek__RFI_Response__c();

       try{
           rfirr.buildertek__RFI__c=rfiRecId;
           rfirr.buildertek__Responder__c=userId;
           rfirr.buildertek__Response__c=varresponse ;
           rfirr.buildertek__Response_Date__c=system.today();
           rfirr.buildertek__Response_From_CMP__c = true;   
           if(parentId!=''){
            rfirr.buildertek__Parent__c=parentId;    
           }           
           //rfirr.buildertek__private__c=privatevalue;
           insert rfirr;
           system.debug('selectedFiles--->'+selectedFiles);
           
           if(selectedFiles.size()>0){
               list<buildertek__File__c> fileslist = 
                   [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c 
                    FROM buildertek__File__c Where Id In:selectedFiles];
               
               for(buildertek__File__c rec: fileslist){
                   rec.buildertek__RFI_Response__c = rfirr.Id;
               }
               update fileslist;
               
           }

      updateRFQ(rfirr.Id,null,null,selectedFiles);
      }catch (exception e){
                        system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                        returvalue= e.getMessage()+'-'+e.getLineNumber();
                    }
                    return '';
    }
    
    
    @AuraEnabled
    public static buildertek__RFI_Response__c createRFIResponse1(String rfiRecId,String userId,String response,
    List<User> selectedUsers,List<Contact> selectedContacts,list<buildertek__File__c> selectedFiles,String parentId){
    System.debug('RFI Id--------------'+rfiRecId);
    System.debug('userId--------------'+userId);
    System.debug('response--------------'+response);        
    System.debug('parentId--------------'+parentId);
      String returvalue='';
      String varresponse ='';
      varresponse = response.stripHtmlTags();
      buildertek__RFI_Response__c rfirr= new buildertek__RFI_Response__c();
       
      rfirr.buildertek__RFI__c=rfiRecId;
      rfirr.buildertek__Responder__c=userId;
      rfirr.buildertek__Response__c=varresponse ;
      rfirr.buildertek__Response_Date__c=system.today();
      rfirr.buildertek__Parent__c=parentId;
      rfirr.buildertek__Response_From_CMP__c = true;   
     //rfirr.buildertek__private__c=privatevalue;
      insert rfirr;
      returvalue='sucess';
      system.debug('rfirr--->'+rfirr);
      //system.debug('selectedFiles--->'+selectedFiles);

      if(selectedFiles.size()>0){
          list<buildertek__File__c> fileslist = 
          [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c ,
          buildertek__ContentDocument_Id__c
          FROM buildertek__File__c Where Id In:selectedFiles];
          
          for(buildertek__File__c rec: fileslist){
            //rec.buildertek__RFI__c = null; 
            rec.buildertek__RFI_Response__c = rfirr.Id;
            rec.buildertek__ContentDocument_Id__c = '';
          }
          update fileslist;

      }


      updateRFQ(rfirr.Id,selectedUsers,selectedContacts,selectedFiles);
      
                    return rfirr;
    }
    
    
     @AuraEnabled
    public static buildertek__RFI_Response__c createRFIResponseForward(String rfiRecId,String userId,String response,
    List<User> selectedUsers,List<Contact> selectedContacts,
    boolean privatevalue,list<buildertek__File__c> selectedFiles){
      String returvalue='';
      String varresponse ='';
      varresponse = response.stripHtmlTags();
      buildertek__RFI_Response__c rfirr= new buildertek__RFI_Response__c();
       try{
      rfirr.buildertek__RFI__c=rfiRecId;
      rfirr.buildertek__Responder__c=userId;
      rfirr.buildertek__Response__c=varresponse ;
      rfirr.buildertek__Response_Date__c=system.today();
    // rfirr.buildertek__Parent__c=parentId;
      rfirr.buildertek__private__c=privatevalue;
      rfirr.buildertek__Response_From_CMP__c = true;   
      insert rfirr;
      returvalue='sucess';
      if(selectedFiles.size()>0){
            list<buildertek__File__c> fileslist = 
            [SELECT Id, Name, buildertek__RFI__c, buildertek__RFI_Response__c ,
            buildertek__ContentDocument_Id__c
            FROM buildertek__File__c Where Id In:selectedFiles];

            for(buildertek__File__c rec: fileslist){
                //rec.buildertek__RFI__c = null; 
                rec.buildertek__RFI_Response__c = rfirr.Id;
            }
            update fileslist;

        }
      updateRFIForward(rfirr.Id,selectedUsers,selectedContacts,selectedFiles);
      }catch (exception e){
                        system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                        returvalue= e.getMessage()+'-'+e.getLineNumber();
                    }
                    return rfirr;
    }


  





    @AuraEnabled
    public Static String getFileAttachments(String recordId){
        Map<Id, list<ContentDocumentLink>> FilesListMap = new Map<Id, list<ContentDocumentLink>>();
        String fieldName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('fieldName ----------> ' + fieldName);
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get('buildertek__File__c').getDescribe().fields.getMap();
        String fields = '';
        for (Schema.SObjectField sfield : fieldMap.Values()){
            schema.describefieldresult dfield = sfield.getDescribe();
            fields += dfield.getname()+',';
        }
        fields = fields.removeEnd(',');
        String query;
        if (fields.contains(fieldName)){
            query = 'select Id, Name, ' + fieldName + ' from buildertek__File__c where ' + fieldName + '=: recordId';
        } else{
            query = 'select Id, Name from buildertek__File__c where ' + fieldName + '=: recordId';
        }
        List<buildertek__File__c> customFilesList;
        /* if(Schema.sObjectType.buildertek__File__c.fields.Id.isAccessible()&&
         Schema.sObjectType.buildertek__File__c.fields.Name.isAccessible() ){*/
        customFilesList = Database.query(query);
        /*}*/
        system.debug('customFilesList --------> ' + customFilesList);
        system.debug('customFilesList --------> ' + customFilesList.size());
        List<FinalFileAttachmentsClass> FinalFileAttachmentsList = new List<FinalFileAttachmentsClass>();
        List<Attachment> attList = new List<Attachment>();
        if (Id.valueOf(recordId).getSObjectType().getDescribe().getName() != 'buildertek__Quote__c'){
            for (Attachment att : [select Id, Name
                                   FROM Attachment
                                   where ParentId = :recordId]){
                attList.add(att);
            }
            if (attList.size() > 0){
                FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(attList, null, null));
            }
        }
        for (ContentDocumentLink files : [select ContentDocumentId, LinkedEntityId
                                          FROM ContentDocumentLink
                                          where LinkedEntityId = :recordId]){
            list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
            if (FilesListMap.get(files.LinkedEntityId) == null){
                fileList.add(files);
                FilesListMap.put(files.LinkedEntityId, fileList);
            } else{
                fileList = FilesListMap.get(files.LinkedEntityId);
                fileList.add(files);
                FilesListMap.put(files.LinkedEntityId, fileList);
            }
        }
        system.debug('files List --> ' + FilesListMap);
        List<ContentVersion> fileAttachments = new List<ContentVersion>();
        if (FilesListMap.get(recordId) != null){
            for (ContentDocumentLink content : FilesListMap.get(recordId)){
                for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                            from ContentVersion
                                            where ContentDocumentId = :content.ContentDocumentId]){
                    fileAttachments.add(docs);
                }
            }
        }
        if (fileAttachments.size() > 0){
            FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(null, fileAttachments, null));
        }
        system.debug('fileAttachments ---------> ' + fileAttachments.size());
        List<buildertek__File__c> filesList = new List<buildertek__File__c>();
        if (customFilesList.size() > 0){
            FinalFileAttachmentsList.add(new FinalFileAttachmentsClass(null, null, customFilesList));
        }
        system.debug('FinalFileAttachmentsList ---------> ' + FinalFileAttachmentsList);
        String finalString = JSON.serialize(FinalFileAttachmentsList);
        system.debug('finalString ---------> ' + finalString);
        return finalString;
    }



    public class FinalFileAttachmentsClass{
        @AuraEnabled
        public List<Attachment> attachmentList{ get; set; }

        @AuraEnabled
        public List<ContentVersion> ContentVersionList{ get; set; }

        @AuraEnabled
        public List<buildertek__File__c> customFilesList{ get; set; }

        public FinalFileAttachmentsClass(List<Attachment> attachmentList, List<ContentVersion> ContentVersionList, List<buildertek__File__c> customFilesList){
            this.attachmentList = attachmentList;
            this.ContentVersionList = ContentVersionList;
            this.customFilesList = customFilesList;
        }
    }


@AuraEnabled
public Static String getRFQFromRFQToVendor(String recordId){
buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c, buildertek__isCommunityUser__c FROM buildertek__RFQ_To_Vendor__c where id=:recordId];
buildertek__RFQ__c rfqRec=[SELECT Id, Name, buildertek__Status__c, buildertek__Due_Date__c, buildertek__Vendor__c FROM buildertek__RFQ__c where id=:rfqtovendor.buildertek__RFQ__c];
return rfqRec.Id;
}

@AuraEnabled
public Static buildertek__RFQ__c getRFQfromvendorrec(String recordId){
buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c, buildertek__isCommunityUser__c FROM buildertek__RFQ_To_Vendor__c where id=:recordId];
buildertek__RFQ__c rfqRec=[SELECT Id, Name, buildertek__Status__c, buildertek__Due_Date__c, buildertek__Vendor__c FROM buildertek__RFQ__c where id=:rfqtovendor.buildertek__RFQ__c];
return rfqRec;
}

@AuraEnabled
public Static buildertek__RFQ_To_Vendor__c getRFQtovendorrec(String recordId){
    system.debug('recordId'+recordId);
    buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c, buildertek__RFQ__r.buildertek__Status__c,
    buildertek__Status__c FROM buildertek__RFQ_To_Vendor__c where id=:recordId];
    system.debug('rfqtovendor'+rfqtovendor);
    return rfqtovendor;
}

 @AuraEnabled
    public static List<buildertek__RFI__c> getRFQtoVendorRelatedRFIs(string rfqToVenrdorId){
        list<buildertek__RFI__c> rfilist = new list<buildertek__RFI__c>();
        buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c,
                                                  buildertek__Vendor__c, buildertek__Open_RFI__c 
                                                  FROM buildertek__RFQ_To_Vendor__c where id=:rfqToVenrdorId];
        string usrtype = getUser(); 
         boolean usingemail =  getRFISettings();
       User getUser=[SELECT Id, Name, AccountId  FROM User where id=:userInfo.getUserId()];
        if(usrtype=='true'){                    
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,buildertek__Vendor_Account__c,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,
                                            buildertek__Submitted_By__c,buildertek__Submitted_By__r.Name,
                                            buildertek__Submitted_By2__c,
                                            buildertek__Submitted_By2__r.Name, buildertek__Status__c
                                            from buildertek__RFI__c 
                                            where buildertek__RFQ__c =:rfqtovendor.buildertek__RFQ__c and buildertek__Vendor_Account__c=:getUser.AccountId and buildertek__RFI_From_Site__c=false 
                                            order by Name ASC];
        }else{
            
            if(usingemail==true){
                rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                           buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                           buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Submitted_By2__c,
                           buildertek__Submitted_By2__r.Name, buildertek__Status__c
                           from buildertek__RFI__c where buildertek__RFQ__c =:rfqtovendor.buildertek__RFQ__c and buildertek__Vendor_Account__c=:rfqtovendor.buildertek__Vendor__c and buildertek__RFI_From_Site__c=true order by Name ASC];
            }else if(usingemail==false){  
                rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                           buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                           buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,OwnerId,Owner.Name,buildertek__Submitted_By2__c,
                           buildertek__Submitted_By2__r.Name, buildertek__Status__c
                           from buildertek__RFI__c where buildertek__RFQ__c =:rfqtovendor.buildertek__RFQ__c and buildertek__Vendor_Account__c=:rfqtovendor.buildertek__Vendor__c and buildertek__RFI_From_Site__c=false  order by Name ASC];    
                
            }            
            
        }
        
        
        /*list<ContentDocumentLink> conDoclist= [SELECT ContentDocumentId, LinkedEntityId  FROM ContentDocumentLink where LinkedEntityId in 
( SELECT Id FROM buildertek__RFI__c where buildertek__RFQ__c =:parentRecordId) and LinkedEntity.Type='buildertek__RFI__c'];*/
        //return conlist;
        
        // Map<String,List<ContentDocumentLink>>  = new Map<String,List<ContentDocumentLink>>();
        
        
        
        //if(rfilist.size()>0){
        return rfilist;
        //}
    }
    
    
    @AuraEnabled
    public static Map<String,List<buildertek__RFI_Response__c>> getrfiresponeserecords1(string rfqToVenrdorId){
      string usrtype = getUser(); 
        boolean usingemail =  getRFISettings();
        list<buildertek__RFI__c> rfilist = new list<buildertek__RFI__c>();
        buildertek__RFQ_To_Vendor__c rfqtovendor=[SELECT Id, Name, buildertek__RFQ__c,
                                                  buildertek__Vendor__c, buildertek__Open_RFI__c 
                                                  FROM buildertek__RFQ_To_Vendor__c where id=:rfqToVenrdorId];
         if(usrtype=='true'){   
             
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name,buildertek__Status__c
                                            from buildertek__RFI__c where buildertek__RFQ__c =:rfqtovendor.buildertek__RFQ__c and buildertek__Vendor_Account__c=:rfqtovendor.buildertek__Vendor__c /*and buildertek__RFI_From_Site__c=false*/ ];
        }else{
            rfilist = [select id,Name,buildertek__RFQ__c,buildertek__Subject__c,buildertek__Project__c,buildertek__Project__r.Name,
                                            buildertek__Due_Date__c, buildertek__Assigned_To__c, buildertek__Assigned_To__r.Name,buildertek__Question__c,
                                            buildertek__RFI_Assigned_To__c,buildertek__RFI_Assigned_To__r.Name, buildertek__Status__c
                                            from buildertek__RFI__c where buildertek__RFQ__c =:rfqtovendor.buildertek__RFQ__c and buildertek__Vendor_Account__c=:rfqtovendor.buildertek__Vendor__c  ];        
        }
                                                                                        
                                            
        //if(rfilist.size()>0){
        list<buildertek__RFI_Response__c> rfiresplist = new list<buildertek__RFI_Response__c>();

        if(usrtype=='true'){
            
            rfiresplist = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Other_Responder__c,buildertek__Other_Responder__r.Name,
                                                             buildertek__Response__c,buildertek__Response_Date__c,
                                                             buildertek__Answered__c,buildertek__RFI__c , buildertek__Responderformula__c
                                                             from buildertek__RFI_Response__c where buildertek__RFI__c IN: rfilist
                           and buildertek__Show_In_Community__c  = true and buildertek__private__c=false order by Name ASC];            
        }else{
            rfiresplist = [select id,Name,buildertek__Responder__c,buildertek__Responder__r.Name,buildertek__Other_Responder__c,buildertek__Other_Responder__r.Name,
                                                             buildertek__Response__c,buildertek__Response_Date__c,
                                                             buildertek__Answered__c,buildertek__RFI__c , buildertek__Responderformula__c,buildertek__private__c
                                                             from buildertek__RFI_Response__c where buildertek__RFI__c IN: rfilist order by Name ASC]; 
        } 
        
        Map<String,List<buildertek__RFI_Response__c>> TaskWithPhaseMap = new Map<String,List<buildertek__RFI_Response__c>>();
        
        for(buildertek__RFI_Response__c task:rfiresplist){ //projectTasks1
            // system.debug(task.Name);
            if(TaskWithPhaseMap.get(String.valueOf(task.buildertek__RFI__c) ) != null){
                list<buildertek__RFI_Response__c> newProjectTaskList = TaskWithPhaseMap.get(String.valueOf(task.buildertek__RFI__c));
                newProjectTaskList.add(task);    
                TaskWithPhaseMap.put(String.valueOf(task.buildertek__RFI__c),newProjectTaskList);  
            }else{
                List<buildertek__RFI_Response__c> newTaskList = new List<buildertek__RFI_Response__c>();
                newTaskList.add(task);
                TaskWithPhaseMap.put(String.valueOf(task.buildertek__RFI__c),newTaskList);  
            }
        }
        
        for(buildertek__RFI__c rfi : rfilist){
            if(TaskWithPhaseMap.get(String.valueOf(rfi.Id)) == null){
                List<buildertek__RFI_Response__c> newRfiList = new List<buildertek__RFI_Response__c>();
                TaskWithPhaseMap.put(String.valueOf(rfi.Id),newRfiList);
            }
        }
        
        //if(rfilist.size()>0){
        return TaskWithPhaseMap;
        //}
    }
    
    
    
    @AuraEnabled
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) { 
              system.debug('saveTheFile');
                            system.debug('parentId'+parentId);
        //String base64Content = ( String ) JSON.deserialize( base64Data, String.class );
        //Blob body = EncodingUtil.base64Decode(base64Content);
       // base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        /*Attachment a = new Attachment();
        a.parentId = parentId;
 
        a.Body = EncodingUtil.base64Decode(base64Data);
        a.Name = fileName;
        a.ContentType = contentType;*/
        
        //insert a;
        
        //return a.Id;
        
        ContentVersion contentToInsert =new ContentVersion(); 
        contentToInsert.Title =fileName; 
        contentToInsert.VersionData=EncodingUtil.base64Decode(base64Data);
        contentToInsert.PathOnClient='/' + fileName ;
        contentToInsert.IsMajorVersion = false;
        insert contentToInsert; 
        
        contentToInsert = [select id, ContentDocumentId from ContentVersion WHERE Id =: contentToInsert.Id];
        ContentDocumentLink cl = new ContentDocumentLink();
        cl.ContentDocumentId = contentToInsert.ContentDocumentId;
        cl.LinkedEntityId = parentId; 
        cl.ShareType = 'V';
        cl.Visibility = 'AllUsers';
        insert cl;
        
        return contentToInsert.id;

        
        
        
    }
    
    
    @AuraEnabled
    public static Id saveTheChunk(Id parentId, String fileName, String base64Data, String contentType, String fileId) { 
      system.debug('saveTheChunk');
        system.debug('parentI'+parentId);
        system.debug('fileId'+fileId); 
         base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFileNew(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    private static void appendToFileNew(Id fileId, String base64Data) {
        system.debug('fileId'+fileId);
          system.debug('appendToFileNew');
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        /*Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = :fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data); 
        
        update a;*/
        
        
        //base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion versionData = [
            SELECT Id, VersionData,ContentDocumentId
            FROM ContentVersion
            WHERE Id = :fileId
        ];

        String existingBody     = EncodingUtil.base64Encode(versionData.VersionData);
        versionData.VersionData = EncodingUtil.base64Decode(existingBody + base64Data); 

        update versionData;
        
        
        
    }
    
    
    
    
    @AuraEnabled
    public static string copyFiles(Id parentId, list<string> fileIds,Id recordId) { 
        system.debug('copyFiles');        
        system.debug('fileIds'+fileIds);
        system.debug('parentId'+parentId);
        system.debug('recordId'+recordId);
        set<Id> fileidsset  = new set<Id>();
        set<Id> contentdocidsset  = new set<Id>();
        if(fileIds.size()>0){
            for(string str : fileIds ){
                fileidsset.add(str);
            }
            
        }        
        list<ContentVersion> contenvlist = [ SELECT Checksum,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,
                                            FileType,FirstPublishLocationId,Id,IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,
                                            RatingCount,ReasonForChange,SharingOption,Title,VersionData,VersionNumber 
                                            FROM ContentVersion WHERE Id In : fileidsset];
        list<ContentVersion> newcontenvlist = new list<ContentVersion>();
        system.debug('contenvlist'+contenvlist);
        if(contenvlist.size()>0){
            for(ContentVersion cont :  contenvlist){
                ContentVersion newcont = new ContentVersion();
                newcont.Title  = cont.Title;
                newcont.PathOnClient  = cont.PathOnClient;
                newcont.VersionData = cont.VersionData;
                newcontenvlist.add(newcont);
                contentdocidsset.add(cont.ContentDocumentId);
            }
            system.debug('newcontenvlist'+newcontenvlist);
            if(newcontenvlist.size()>0){
                insert newcontenvlist;
            }
            system.debug('newcontenvlist'+newcontenvlist);
            list<ContentVersion> actualcontenvlist = [ SELECT Checksum,ContentDocumentId,ContentLocation,ContentSize,ContentUrl,Description,FileExtension,
                                                      FileType,FirstPublishLocationId,Id,IsAssetEnabled,IsDeleted,Origin,OwnerId,PathOnClient,PublishStatus,
                                                      RatingCount,ReasonForChange,SharingOption,Title,VersionData,VersionNumber 
                                                      FROM ContentVersion WHERE Id In:newcontenvlist];
            system.debug('actualcontenvlist'+actualcontenvlist);
            
            list<ContentDocumentLink> contentdoclist = new list<ContentDocumentLink>();
            if(actualcontenvlist.size()>0){
                for(ContentVersion conte :  actualcontenvlist){
                    ContentDocumentLink cl = new ContentDocumentLink();
                    cl.ContentDocumentId = conte.ContentDocumentId;
                    cl.LinkedEntityId = parentId; 
                    cl.ShareType = 'V';
                    cl.Visibility = 'AllUsers';
                    contentdoclist.add(cl);
                }
                system.debug('contentdoclist'+contentdoclist);
                if(contentdoclist.size()>0){
                    insert contentdoclist;
                }
                system.debug('contentdoclist'+contentdoclist);
            }
            
            
            list<ContentDocument> lstCntDocsToDelete = new list<ContentDocument>();
            
            for(ContentDocumentLink iterator : [SELECT ContentDocumentId FROM ContentDocumentLink 
                                                WHERE LinkedEntityId =:recordId 
                                                and ContentDocumentId In:contentdocidsset]) {
                                                    lstCntDocsToDelete.add(new ContentDocument(Id = iterator.ContentDocumentId));
                                                }
            system.debug('lstCntDocsToDelete'+lstCntDocsToDelete);
            if(!lstCntDocsToDelete.isEmpty() && lstCntDocsToDelete != null) {
                Database.delete(lstCntDocsToDelete, false);
                Database.emptyRecycleBin(lstCntDocsToDelete);
            }
            
            
            
        }
        
        

        
        
        
        return '';
    }
    
    @AuraEnabled
    public static void sentEmailtousers(string recordId) {
     try{
        buildertek__RFI_Settings__c bsettings = [Select Id,Name,buildertek__Queue_Name__c from buildertek__RFI_Settings__c WHERE Name = 'RFI Settings'];
        list<QueueSObject>  Queuereclist= new list<QueueSObject>();
        Queuereclist = [Select Id, Queue.Id, Queue.Name, Queue.Type from QueueSObject WHERE Queue.Type ='Queue' AND Queue.Name =: bsettings.buildertek__Queue_Name__c Limit 1];
        system.debug('Queuereclist-->'+Queuereclist);
        buildertek__RFI__c rfi = [Select id,OwnerId from buildertek__RFI__c Where id=:recordId];
        if (Queuereclist!=null){
             if(Queuereclist.size()>0){
                 rfi.OwnerId =Queuereclist[0].Queue.Id;
              }
        }
        update rfi;
    
       List<GroupMember> grpmember = [SELECT UserorGroupId FROM GroupMember WHERE Group.Name =:bsettings.buildertek__Queue_Name__c];
        List<string> userIdsList = new List<string>();
        List<string> EmalList = new List<string>();
        for(GroupMember grp:grpmember){
            if(String.valueOf(grp.UserOrGroupId).startsWith('005')){
                userIdsList.add(grp.UserOrGroupId);
            }
        }
        system.debug(userIdsList);
        List<User> userList = [SELECT ID,Email From USER where ID IN:userIdsList];
        for(User us:userList){
            EmalList.add(us.Email);
        }
        
            //EmalList.add('sriram.bodda@diligentforcelabs.com');
         system.debug(EmalList);
        string theTemplate;
        theTemplate = [SELECT Id
                       FROM EmailTemplate
                       WHERE Name  = 'Email Sent to Queue'].Id;
                       
                       
                       
               List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();    
                Messaging.SingleEmailMessage message = new        Messaging.SingleEmailMessage();

                message.toAddresses = EmalList;
                message.setTemplateID(theTemplate);     
                message.setSaveAsActivity(false);
                message.setWhatId(recordId);
                message.setTargetObjectId(userList[0].id /* UserInfo.getUserId() */);
                messageList.add(message);
                //Savepoint sp = Database.setSavepoint();
                Messaging.sendEmail(messageList);
                //Database.rollback(sp);
                
         }catch(Exception e){
               system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
         }       
    }
    
   

}