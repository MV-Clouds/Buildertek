public without sharing class RFQVendorItemController {
    @AuraEnabled
    public static void DeleteVendorItems(string recordId){
      buildertek__RFQ_Vendor_Item__c vendorline =  [SELECT Id, Name, buildertek__Cost_Code__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, buildertek__Vendor__c, buildertek__Item_Name__c, 
           buildertek__RFQ_Item__c, buildertek__Vendor_Name__c, buildertek__Description__c, buildertek__Auto_Number__c, buildertek__Budget_Line_Amount__c,buildertek__Estimated_Work_Days__c,buildertek__Vendor_Estimated_Work_Days__c,
           buildertek__Vendor_Note__c, buildertek__isVendorRFQSubmited__c, buildertek__Vendor_Quantity__c, buildertek__Vendor_Unit_Price__c, buildertek__Note__c,buildertek__CreateVendor__c
           FROM buildertek__RFQ_Vendor_Item__c Where id =: recordId];
        delete vendorline;
     //  return null;
    }
    @AuraEnabled
    public static string getRfqTo(){
       return UserInfo.getDefaultCurrency();
    }
    @AuraEnabled
    public static Boolean getmulticurrency(){
       return UserInfo.isMultiCurrencyOrganization();
    }
   /* @AuraEnabled
    public static void getvendorlines(String recordId){
        list<buildertek__RFQ_Vendor_Item__c> vendorlineslist = [select Id, Name,buildertek__Vendor__r.buildertek__Status__c from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c =: recordId];
        if(vendorlineslist.size() > 0){
            for(buildertek__RFQ_Vendor_Item__c vendorlineRec : vendorlineslist){
                if(vendorlineRec.buildertek__Vendor__r.buildertek__Status__c  != ''){
                    
                }
            }  
        }
      //  return rfqToAccount.buildertek__Status__c;
    }*/
    @AuraEnabled
    public static String getRQToAccount(String recordId){
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where Id =: recordId];
        return rfqToAccount.buildertek__Status__c;
    }
    @AuraEnabled
    public static vendorItemsWrap getRelatedList(string recId){
    //  buildertek__RFQ__c rfqrec = [SELECT Id, Name, buildertek__RFQ_s_Replied_To__c,buildertek__Status__c,buildertek__RFQ_s_Sent__c FROM buildertek__RFQ__c WHERE Id = :recId ];
        
        vendorItemsWrap wrap = new vendorItemsWrap();
        User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
        list<buildertek__RFQ_To_Vendor__c> rfqToVendorlist = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Vendor_Quote_Amount__c,
                                                    buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Status__c,buildertek__Send_Invitation__c,
                                                    buildertek__Submitted_Date__c
                                                    from buildertek__RFQ_To_Vendor__c
                                                    where buildertek__RFQ__c =: recId 
                                                    and buildertek__Vendor__c =:accountId];
        system.debug('accountId-------'+accountId);
        list<id> vendorids = new list<id>();
        for(buildertek__RFQ_To_Vendor__c rfqtovendorRec : rfqToVendorlist){
            vendorids.add(rfqtovendorRec.id);
        }
        List<buildertek__RFQ_Vendor_Item__c> RFQVendorLineList = new List<buildertek__RFQ_Vendor_Item__c>();
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'Select id,Name,CurrencyIsoCode,buildertek__Description__c,buildertek__CreateVendor__c,buildertek__Total_Price__c,buildertek__Vendor_Total_Price__c,buildertek__Quantity__c,buildertek__Vendor_Quantity__c,buildertek__Unit_Price__c,buildertek__Vendor_Unit_Price__c,'+
                                 'buildertek__Vendor__r.buildertek__Quote_Amount__c,buildertek__Vendor_Note__c,buildertek__Note__c,buildertek__RFQ_Item__c,buildertek__Vendor__c,buildertek__Vendor__r.buildertek__Vendor__c,buildertek__Vendor_Estimated_Work_Days__c,buildertek__Estimated_Work_Days__c from buildertek__RFQ_Vendor_Item__c'+ 
                                 ' Where buildertek__Vendor__c IN : vendorids';
               RFQVendorLineList = Database.query(rfqrecords);
            }else{
              RFQVendorLineList = [Select id,Name,buildertek__Description__c,buildertek__Quantity__c, buildertek__CreateVendor__c, buildertek__Vendor_Quantity__c,buildertek__Unit_Price__c,buildertek__Vendor_Unit_Price__c,
                                                                        buildertek__Vendor_Note__c,buildertek__Vendor__r.buildertek__Quote_Amount__c,
                                                                        buildertek__Note__c,buildertek__Total_Price__c,buildertek__Vendor_Total_Price__c,
                                                                        buildertek__RFQ_Item__c,buildertek__Estimated_Work_Days__c,buildertek__Vendor_Estimated_Work_Days__c,
                                                                        buildertek__Vendor__c,buildertek__Vendor__r.buildertek__Vendor__c
                                                                        from buildertek__RFQ_Vendor_Item__c 
                                                                        Where buildertek__Vendor__c IN : vendorids];
            }
        System.debug('RFQVendorLineList-------'+RFQVendorLineList.size());
        wrap.RFQVendorLineList = RFQVendorLineList;
        wrap.rfqtovendorrec = rfqToVendorlist[0];
        wrap.fileslist = getContentDocs(rfqToVendorlist[0].Id);
        System.debug(wrap);
        return wrap;
    }

    public class vendorItemsWrap{
        @AuraEnabled
        public List < buildertek__RFQ_Vendor_Item__c > RFQVendorLineList{ get; set; } 
        @AuraEnabled
        public buildertek__RFQ_To_Vendor__c rfqtovendorrec;  
        @AuraEnabled
        public list <buildertek__File__c> fileslist{ get; set; }
     }


    @AuraEnabled    
    public static boolean updateVendorItems( List < buildertek__RFQ_Vendor_Item__c > updatedItemsList ) {    
            
        try {  
          
            update updatedItemsList;  
            System.debug('updatedItemsList-------'+updatedItemsList);
            return true;  
              
        } catch(Exception e) {  
          
            return false;  
              
        }  
            
    }    

    @AuraEnabled
    public static List<buildertek__File__c> getContentDocs(Id arecordId) {
        list<buildertek__File__c> fileslist =
        [SELECT Id, Name, buildertek__Amazon_File_Key__c, buildertek__Download_Link1__c, 
        buildertek__RFQ_To_Vendor__c, buildertek__RFI_Response__c, buildertek__File_Presigned_URL__c, 
        buildertek__Download_Link__c, buildertek__Content_Type__c 
        FROM buildertek__File__c Where buildertek__RFQ_To_Vendor__c=:arecordId ];
        return fileslist;
    }
    @AuraEnabled
    public static List<ContentVersion> getContentfiles(Id arecordId) {
        list<Id> filecontentid= new list<Id>();
        buildertek__RFQ_To_Vendor__c rfqToVendor = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,
                                                              buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,
                                                              buildertek__Submitted_Date__c from buildertek__RFQ_To_Vendor__c where ID =: arecordId]; 
        list<buildertek__File__c> fileslist = [SELECT Id,Name,buildertek__Amazon_File_Key__c,buildertek__Download_Link1__c,buildertek__RFQ_To_Vendor__c,buildertek__ContentDocument_Id__c,
                                               buildertek__RFI_Response__c,buildertek__File_Presigned_URL__c,buildertek__RFQ__c,buildertek__Download_Link__c,
                                               buildertek__Content_Type__c FROM buildertek__File__c where buildertek__RFQ__c =:rfqToVendor.buildertek__RFQ__c];
        for(buildertek__File__c fileRec : fileslist){
            if(fileRec.buildertek__ContentDocument_Id__c != null ){
                filecontentid.add(fileRec.buildertek__ContentDocument_Id__c);
            }
        }
        List<Attachment> attList = new List<Attachment>();
            for (Attachment att : [select Id, Name
                                   FROM Attachment
                                   where ParentId = :rfqToVendor.buildertek__RFQ__c]){
                attList.add(att);
            }
       list<ContentDocumentLink> files = [select ContentDocumentId, LinkedEntityId
                                          FROM ContentDocumentLink
                                          where LinkedEntityId = :rfqToVendor.buildertek__RFQ__c];
            list<ContentDocumentLink> fileList = New list<ContentDocumentLink>();
           List<ContentVersion> fileAttachments = new List<ContentVersion>();
       // if (FilesListMap.get(recordId) != null){
            for (ContentDocumentLink content : files){
                for (ContentVersion docs : [Select Id, ContentDocumentId, Title, VersionData
                                            from ContentVersion
                                            where ContentDocumentId = :content.ContentDocumentId]){
                    fileAttachments.add(docs);
                }
            }
       // }
        return fileAttachments;
    }
    @AuraEnabled
    public static List<ContentVersion> getvendorContentfiles(Id arecordId) {
        list<Id> filecontentid= new list<Id>();
       list<buildertek__File__c> fileslist = [SELECT Id,Name,buildertek__Amazon_File_Key__c,buildertek__ContentDocument_Id__c,buildertek__Download_Link1__c,buildertek__RFQ_To_Vendor__c,
                                               buildertek__RFI_Response__c,buildertek__File_Presigned_URL__c,buildertek__RFQ__c,buildertek__Download_Link__c,
                                               buildertek__Content_Type__c FROM buildertek__File__c where buildertek__RFQ_To_Vendor__c =:arecordId];
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
       
        return fileAttachments;
    }
    @AuraEnabled
    public static List<buildertek__File__c> getrfqfiles(string recordId) {
       buildertek__RFQ_To_Vendor__c rfqToVendor = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,
                                                              buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,
                                                              buildertek__Submitted_Date__c from buildertek__RFQ_To_Vendor__c where ID =: recordId];  
                                                              system.debug('rfqToVendor'+rfqToVendor.buildertek__RFQ__c);
                                                              string rfqid = rfqToVendor.buildertek__RFQ__c;
        list<buildertek__File__c> fileslist = [SELECT Id,Name,buildertek__Amazon_File_Key__c,buildertek__Download_Link1__c,buildertek__RFQ_To_Vendor__c,
                                               buildertek__RFI_Response__c,buildertek__File_Presigned_URL__c,buildertek__RFQ__c,buildertek__Download_Link__c,
                                               buildertek__Content_Type__c FROM buildertek__File__c where buildertek__RFQ__c =:rfqToVendor.buildertek__RFQ__c];
        system.debug('fileslist'+fileslist);
        system.debug('fileslist'+fileslist.size());
        return fileslist;
    }

   @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    @AuraEnabled
    public static String getrfq(string RecordId){
       buildertek__RFQ_To_Vendor__c rfqToVendor = [select id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,
                                                              buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,
                                                              buildertek__Submitted_Date__c from buildertek__RFQ_To_Vendor__c where ID =: RecordId]; 
        return rfqToVendor.buildertek__RFQ__c;
    }
    @AuraEnabled
    public static list<buildertek__RFQ_To_Vendor__c> getvendorRelatedList(string recId){
        User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];//changed from userinfo.getuserid()
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
        list<buildertek__RFQ_To_Vendor__c> rfqToVendorlist = new list<buildertek__RFQ_To_Vendor__c>();
        string status = 'New';
        if(UserInfo.isMultiCurrencyOrganization()){
            string rfqrecords = 'select Id,Name,CurrencyIsoCode,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Vendor_Quote_Amount__c,buildertek__Open_RFI__c,'+
                                 'buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,'+
                                  'buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c from buildertek__RFQ_To_Vendor__c where buildertek__Vendor__c =:accountId and buildertek__Status__c !=: status Order By buildertek__RFQ__r.buildertek__Auto_Number__c';
            rfqToVendorlist = Database.query(rfqrecords);
        }else{
        rfqToVendorlist = [select Id,Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__Vendor_Quote_Amount__c,
                                                    buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,
                                                    buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c
                                                    from buildertek__RFQ_To_Vendor__c
                                                    where buildertek__Vendor__c =:accountId and buildertek__Status__c != 'New' Order By buildertek__RFQ__r.buildertek__Auto_Number__c];
        }
        return rfqToVendorlist;
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
            //   appendToFile(fileId, base64Data);
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
    
    
   /*  @AuraEnabled(cacheable=true)
    public static List<buildertek__RFQ_To_Vendor__c> fetchAcc (String searchKey){
        String query= 'SELECT Id,Name,buildertek__Description__c FROM buildertek__RFQ_To_Vendor__c';
         if ( searchKey != Null ) {
            String key = '%' + searchKey + '%';
            query += ' WHERE buildertek__Description__c LIKE :key';
        }system.debug(Database.query( query ));
         return Database.query( query );
        
    }  */
    
    /* @AuraEnabled
    public static List<buildertek__RFQ_To_Vendor__c> findByName(String searchKey , string recId) {
     User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
       String  name = '%'+ searchKey +'%' ;
       //  decimal  names =  + searchKey + 1 ;
        // decimal names =  + searchKeys + ' % ';
        return [select Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__QuoteAmountText__c,
                buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,
                buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c FROM buildertek__RFQ_To_Vendor__c WHERE buildertek__Vendor__c =:accountId
                and( buildertek__RFQ__r.Name LIKE :name or buildertek__Status__c LIKE :name  or buildertek__RFQ__r.buildertek__Auto_Number__c LIKE :name or buildertek__QuoteAmountText__c LIKE :name  )   and buildertek__Status__c != 'New'];
        
    }*/
    
      @AuraEnabled
    public static List<buildertek__RFQ_To_Vendor__c> findByName(String searchKey , string recId ,string listname ) {
        if(listname == 'All'){
             User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
       String  name = '%'+ searchKey +'%' ;
       //  decimal  names =  + searchKey + 1 ;
        // decimal names =  + searchKeys + ' % ';
        return [select Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__QuoteAmountText__c,
                buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,
                buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c FROM buildertek__RFQ_To_Vendor__c WHERE buildertek__Vendor__c =:accountId
                and( buildertek__RFQ__r.Name LIKE :name or buildertek__Status__c LIKE :name  or buildertek__RFQ__r.buildertek__Auto_Number__c LIKE :name or buildertek__QuoteAmountText__c LIKE :name  )   and buildertek__Status__c != 'New' ];
        
        }else{
     User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
       String  name = '%'+ searchKey +'%' ;
       //  decimal  names =  + searchKey + 1 ;
        // decimal names =  + searchKeys + ' % ';
        return [select Name,buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__QuoteAmountText__c,
                buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,
                buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c FROM buildertek__RFQ_To_Vendor__c WHERE buildertek__Vendor__c =:accountId
                and( buildertek__RFQ__r.Name LIKE :name or buildertek__Status__c LIKE :name  or buildertek__RFQ__r.buildertek__Auto_Number__c LIKE :name or buildertek__QuoteAmountText__c LIKE :name  )   and buildertek__Status__c != 'New' and buildertek__Status__c =: listname ];
        }
        
    }
    
    
   
    
    
    @AuraEnabled
    public static Map<String, String> fetchListViews(String strObjName) {
        Map<string,string> listmap = new Map<string,string>();
        list<ListView> lstViews = new list<ListView>(); 
        system.debug('strObjNamestrObjNam-->'+strObjName);
        if(strObjName != null && strObjName !=  ' ' && strObjName.length() != 0) {            
             lstViews = [Select Name,sobjectType,Id From ListView where SobjectType =: strObjName];
        }  
        for(ListView li:lstViews){
            listmap.put(li.Id,li.Name);
        }
        return listmap;

    }
    public class fromJSON{
        public String query;
    }
    @AuraEnabled
     public static WrapperListView getListViewQuery( String listViewId, String objName) {
     
     try{
     buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Community_URL__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name= 'RFQ Configuration'];
      User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        string accountId = '';
        if(userrec.AccountId!=null){
            accountId = userrec.AccountId;
        }
      system.debug(accountId);
        Http http = new Http();
        HTTPRequest httpReq = new HTTPRequest();
        String orgDomain = Url.getSalesforceBaseUrl().toExternalForm();
        
        String endpoint = adminInterfaceNodeConfigurations.buildertek__Community_URL__c+'/services/data/v46.0/sobjects/' + objName + '/listviews/' + listViewId + '/describe';
        
        httpReq.setEndpoint( endpoint );
        httpReq.setMethod( 'GET' );
        httpReq.setHeader( 'Content-Type', 'application/json; charset=UTF-8' );
        httpReq.setHeader( 'Accept', 'application/json' );
        
        String sessionId = 'Bearer ' + UserInfo.getSessionId();
        
        httpReq.setHeader( 'Authorization', sessionId );
        
        HTTPResponse httpRes = http.send( httpReq );
        system.debug('@@@@@@@'+httpRes.getBody());
        system.debug('@status code'+httpRes.getStatusCode());
        
         if(httpRes.getStatusCode() == 200){
             fromJSON fr = new fromJSON();
             fr = (fromJSON) System.JSON.deserialize(httpRes.getBody(),fromJSON.class);
             
             
             string str = fr.query;
             system.debug(str);
             string str2 = ',buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c';
             string[] splitted = str.split('FROM');
             system.debug(splitted[0]);
             system.debug(splitted[1]);
             
             string fieldstring = '';
             if(UserInfo.isMultiCurrencyOrganization()){
                   fieldstring = 'SELECT Name, Id, CurrencyIsoCode, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
             }else{
                 fieldstring = 'SELECT Name, Id, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
             }
             //string fieldstring = 'SELECT Name, Id, CurrencyIsoCode, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
             string prefinalstring = fieldstring+' FROM '+splitted[1];
             string[] getstring = prefinalstring.split('USING'); 
             system.debug(getstring[0]+splitted[1]);
             string queryStr = getstring[0]+splitted[1];
             
             string finalstring = '';
             if(queryStr.contains('WHERE') == false){
                 finalstring = getstring[0]+' WHERE buildertek__Vendor__c =:accountId '+splitted[1];
             }else{
                 finalstring = getstring[0]+' WHERE buildertek__Vendor__c =:accountId AND '+splitted[1].split('WHERE')[1];
             }
             //system.debug(getstring[0]+splitted[1].split('WHERE')[0]);
             
             
             system.debug('*&&&***&*&*'+finalstring);
             
             
             
             List<buildertek__RFQ_To_Vendor__c> vendorList = Database.query(finalstring);
             system.debug('***********'+Database.query(finalstring));
             system.debug('***********'+Database.query(finalstring).size());
             //return vendorList;
             WrapperListView wrap = new WrapperListView();
             wrap.RFQVendorList = vendorList;
             wrap.message = httpRes.getBody();
             wrap.Issuccess = true;
             return wrap;
         }else{
            WrapperListView wrap = new WrapperListView();
            httpReq.setEndpoint(httpRes.getHeader('Location'));
            httpRes = new Http().send(httpReq);
            fromJSON fr = new fromJSON();
            fr = (fromJSON) System.JSON.deserialize(httpRes.getBody(),fromJSON.class);
            
            
            string str = fr.query;
            system.debug(str);
            string str2 = ',buildertek__Status__c,buildertek__Accepted_Date__c,buildertek__Vendor__c,buildertek__Quote_Amount__c,buildertek__Open_RFI__c,buildertek__Days_Outstanding__c,buildertek__RFQ__c,buildertek__Send_Invitation__c,buildertek__RFQ__r.Name,buildertek__RFQ__r.buildertek__Auto_Number__c,buildertek__Submitted_Date__c,buildertek__RFQ__r.buildertek__Description__c';
            string[] splitted = str.split('FROM');
            system.debug(splitted[0]);
            system.debug(splitted[1]);
            
            string fieldstring = '';
            if(UserInfo.isMultiCurrencyOrganization()){
                  fieldstring = 'SELECT Name, Id, CurrencyIsoCode, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
            }else{
                fieldstring = 'SELECT Name, Id, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
            }
            //string fieldstring = 'SELECT Name, Id, CurrencyIsoCode, CreatedDate, LastModifiedDate, SystemModstamp'+string.valueof(str2);
            string prefinalstring = fieldstring+' FROM '+splitted[1];
            string[] getstring = prefinalstring.split('USING'); 
            system.debug(getstring[0]+splitted[1]);
            string queryStr = getstring[0]+splitted[1];
            
            string finalstring = '';
            if(queryStr.contains('WHERE') == false){
                finalstring = getstring[0]+' WHERE buildertek__Vendor__c =:accountId '+splitted[1];
            }else{
                finalstring = getstring[0]+' WHERE buildertek__Vendor__c =:accountId AND '+splitted[1].split('WHERE')[1];
            }
            //system.debug(getstring[0]+splitted[1].split('WHERE')[0]);
            
            
            system.debug('*&&&***&*&*'+finalstring);
            wrap.RFQVendorList = Database.query(finalstring); 
            wrap.message = httpRes.getBody();
            wrap.Issuccess = true;
            return wrap;            
        }
        }catch (Exception e) {
             WrapperListView wrap = new WrapperListView();
             wrap.RFQVendorList = new list<buildertek__RFQ_To_Vendor__c>();
             wrap.Issuccess = false;
             wrap.message = e.getCause()+' ; '+e.getLineNumber() + ' ; '+e.getMessage()+' ; '+e.getStackTraceString()
                           +' ; '+e.getTypeName() ;
             return wrap;
             
        }
        
        //ListViewsDescribeResponse listViewDescResp = ( ListViewsDescribeResponse ) JSON.deserialize( httpRes.getBody(), ListViewsDescribeResponse.class );
        
        //return listViewDescResp.query;
    }
   public class WrapperListView{
        @AuraEnabled
        public List <buildertek__RFQ_To_Vendor__c> RFQVendorList{ get; set; } 
        @AuraEnabled
        public string message;
        @AuraEnabled
        public Boolean Issuccess;
         
         
        
     }
    
      @AuraEnabled
    public static List<buildertek__VendorRfqList__c>  customsettings()
    {   
               //List<buildertek__VendorRfqList__c> getRFQSettings = buildertek__VendorRfqList__c.getAll().values(); 
                 User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        system.debug('userrec.................'+userrec);

      List<buildertek__VendorRfqList__c> getRFQSettings = [SELECT Id, Name, buildertek__RFQListId__c, buildertek__RFQListName__c, buildertek__RFQUser__c FROM buildertek__VendorRfqList__c where Name = 'Test' ];
       
       return getRFQSettings;
    }
    
       @AuraEnabled
    public static void updatecustomsettings(String listviewid, String listviewname){
         User userrec = [select id,Name, AccountId from User where id =: userInfo.getUserId()];
        buildertek__VendorRfqList__c obj = [SELECT Id, Name, buildertek__RFQListId__c, buildertek__RFQListName__c, buildertek__RFQUser__c FROM buildertek__VendorRfqList__c where Name = 'Test' ];
        obj.buildertek__RFQListName__c = listviewname;
        obj.buildertek__RFQListId__c = listviewid;
        obj.buildertek__RFQUser__c = userrec.id;
        update obj;
       // return obj;
    }
    
   /* @AuraEnabled 
    public static string currentUserDetailMethod(){    
      string currentUserObj = 'select id,Name,FirstName,LastName,Username,Country,Email, IsActive, Alias,TimeZoneSidKey, IsPortalEnabled, Profile.Name,UserRole.Name From User Where Id=:userInfo.getUserId()';
       
        return currentUserObj;
    }*/
    
     @AuraEnabled 
    public static string currentUserDetailMethod(){    
      User currentUserObj = [select id,Name,FirstName,LastName,Username,Country,Email, IsActive, Alias,TimeZoneSidKey, Profile.Name,UserRole.Name From User Where Id=:userInfo.getUserId()];
        return currentUserObj.id;
    }
    
   
    
    
    
    
    
    
}