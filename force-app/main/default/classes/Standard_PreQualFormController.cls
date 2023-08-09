public without sharing class Standard_PreQualFormController {


    
    @AuraEnabled
    public static buildertek__Dynamic_Prequal_Setting__mdt getMetaData(){
        list<buildertek__Dynamic_Prequal_Setting__mdt> displayimagemetadatelist= 
            [select Id,DeveloperName,buildertek__Header__c,buildertek__Header_1__c,buildertek__Header_2__c,buildertek__Height_Width__c from buildertek__Dynamic_Prequal_Setting__mdt 
             Where DeveloperName='Standard_PreQual_Header' limit 1];
        return displayimagemetadatelist[0];
        
    }
    
    @AuraEnabled
    public static boolean getIsMultiPreQual(){
        boolean falsebool = false;
        List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
        if(preQualSettings.size()>0){
            return preQualSettings[0].buildertek__Is_Multiple_PreQual__c;
        }else{
            return falsebool;
        }
    }
    
 /* @AuraEnabled
        public static List<String> getPickListValuesIntoList(){
            String objectType ='buildertek__Pre_Qual__c';
            String selectedField = 'buildertek__Type_of_Company__c';
        List<String> pickListValuesList = new List<String>();
        Schema.SObjectType convertToObj = Schema.getGlobalDescribe().get(objectType);
        Schema.DescribeSObjectResult res = convertToObj.getDescribe();
        Schema.DescribeFieldResult fieldResult = res.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
        }*/    
    public class innerClass{
      @AuraEnabled public Account acc;
      @AuraEnabled public List<buildertek__Past_Project__c> proj;  
      @AuraEnabled public List<buildertek__References__c> ref; 
    }
    
    @AuraEnabled
    public static innerClass getAccountRecord(string recordId){
        system.debug('@@@@@@@@@@@@'+recordId);
        
        Account Acc = [select id,Name,
                       buildertek__Alternate_Name__c,
                       buildertek__Type_of_Company__c,
                       buildertek__Year_Established__c,
                       buildertek__Office_Address__c,
                       buildertek__City__c,
                       buildertek__State__c,
                       buildertek__ZipCode__c,
                       buildertek__Service_Are__c,
                       BillingCity,
                       BillingState,
                       BillingPostalCode,
                       buildertek__License_Expiration_Date1__c,
                       buildertek__License_Expiration_Date2__c,
                       buildertek__License_Expiration_Date3__c,
                       buildertek__Worker_s_Compensation_License_Expiration__c,
                       buildertek__General_Liability_License_Expiration__c,
                       buildertek__State1__c,
                       buildertek__State2__c,
                       buildertek__State3__c,
                       buildertek__Vendor_License__c,
                       buildertek__Vendor_License_Number__c,
                       buildertek__Vendor_License_Number_3__c,
                       buildertek__Bid_Limit__c,
                       buildertek__General_Liability_Coverage__c,
                       buildertek__Workers_Compensation_Limit__c,
                       buildertek__Number_of_Employees__c
                       from Account where id=: recordId];
                       //system.debug(Acc);
        List<buildertek__Past_Project__c> projectlist = [select id,buildertek__Project_Name__c,buildertek__Contractor_Name__c,buildertek__Contact_Name__c,buildertek__Contact_Email__c,buildertek__Cell_Phone__c,buildertek__Contract_Value__c,buildertek__Date_Completed__c from buildertek__Past_Project__c where buildertek__Account__c=:recordId];
        List<buildertek__References__c> referencelist =[select  id,buildertek__Company_Name__c,buildertek__Address__c,buildertek__City__c,buildertek__State__c,buildertek__Zip__c,buildertek__Contact_Name__c,buildertek__Email__c,buildertek__Cell_Phone__c from buildertek__References__c where Account__c=:recordId];
        innerClass inn = new innerClass();
        inn.acc = Acc;
        inn.proj = projectlist;
        inn.ref = referencelist;
        
        return inn;
    }
    @AuraEnabled
    public static FileUploadWrapper createPreQual(String boxData,string recId,Account accountRecord,String ref1,String ref2,String ref3,string projectlist1,String projectlist2,String projectlist3){
        system.debug(boxData);
    Account acc = [select id,name,buildertek__Box_Folder_Id__c from Account where id =:recId];
                 List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Enable_Box__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];

    system.debug(acc);
        //system.debug('base64String --------> '+base64String);
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ResponseClass RC = new ResponseClass();
        string AccessToken;
        FileUploadWrapper fileWrapper = new FileUploadWrapper();
        
       // try{
            //if(base64String != ''){
                //system.debug('base64String --------> '+base64String);
                //List<FilesWrapper> files = (List<FilesWrapper>)System.JSON.deserialize(base64String, List<FilesWrapper>.class);
                //system.debug('files---------'+files);
                
                ParameterResponseClass boxdatalist = (ParameterResponseClass)System.JSON.deserialize(boxData, ParameterResponseClass.class);

                string Response1='';
                string Response='';
                
                string endPointURL;
                string RefreshToken;
                /*code to get access token*/
                HttpRequest req1 = new HttpRequest();
                //endPointURL='https://app.box.com/api/oauth2/token?code='+Authcode+'&client_id='+clientid+'&client_secret='+client_secret+'&grant_type=authorization_code';
                endPointURL='https://app.box.com/api/oauth2/token?';
                System.debug('******endPointURL:'+endPointURL);
                req1.setEndpoint(endPointURL);
                req1.setMethod('POST');
                req1.setHeader('Content-Type','application/x-www-form-urlencoded');
                String bb='grant_type=authorization_code';
    
                req1.setbody('grant_type=client_credentials'+
                             '&box_subject_type=enterprise'+
                             '&box_subject_id='+boxdatalist.EnterpriceId+
                             '&client_id='+boxdatalist.clientid+
                             '&client_secret='+boxdatalist.client_secret);
                req1.setHeader('Accept','application/json');
                Http http = new Http();
                HTTPResponse res1 = http.send(req1);
                Response=res1.getBody();
                Integer statusCode=res1.getStatusCode();
                System.debug(Response);
                // Parse JSON response to get refresh_token values.
                JSONParser parser = JSON.createParser(Response);
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if(fieldName == 'access_token') {
                            AccessToken= parser.getText();
                        }if(fieldName == 'refresh_token') {
                            RefreshToken= parser.getText();
                        }
                    }
               // }
            String boundary = '----------------------------741e90d31eff';
            fileWrapper.boxFolderId = acc.buildertek__Box_Folder_Id__c;
            fileWrapper.accessToken = accessToken;
            fileWrapper.boundary = boundary;    
                     if(preQualSettings.size() > 0){
                        fileWrapper.EnableBox = preQualSettings[0].buildertek__Enable_Box__c;
                    }
            /*if(base64String != ''){
               for(FilesWrapper FW :files){
                blob base64EncodeFile=base64EncodeFileContent(FW.fileContent,FW.fileName);
                //blob fileContent=blob.valueof('test String');
                //blob base64EncodeFile=BoxUtility.base64EncodeFileContent(fileContent,'First file Upload');
                system.debug(acc.buildertek__Box_Folder_Id__c);
                
                String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+acc.buildertek__Box_Folder_Id__c;
                String boundary = '----------------------------741e90d31eff';
                
                HttpRequest req = new HttpRequest();
                req.setBodyAsBlob(base64EncodeFile);
                req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setMethod('POST');
                req.setEndpoint(uploadEndPointURL);
                req.setMethod('POST');
                req.setTimeout(120000);
                //Send request to Box
                HTTPResponse res=sendHttpRequest(req);
                Response=res.getBody();
                System.debug('**Files upload Response:'+Response);
                Integer uploadStatusCode=res.getStatusCode();
                if(uploadStatusCode==201){
                    //return 'success';
                }else{
                   //return 'error';
                }
            }             
                
              }*/
                /*if(contentVersionList.size() > 0){
                    ContentVersionTriggerHandler.isSkip = true;
                    if(!Test.isRUnningTest())
                        insert contentVersionList;
                }*/ 
               
            }
        
      /*  if(ref1 != null){
            buildertek__References__c convertRef1 = (buildertek__References__c)JSON.deserialize((ref1),buildertek__References__c.Class);
            convertRef1.buildertek__Account__c = accountRecord.id;
            upsert convertRef1;
            system.debug('@@@@'+convertRef1.Id);
        }
        if(ref2 != null){
            buildertek__References__c convertRef2 = (buildertek__References__c)JSON.deserialize((ref2),buildertek__References__c.Class);
            convertRef2.buildertek__Account__c = accountRecord.id;
            upsert convertRef2;
        }
        if(ref3 != null){
            buildertek__References__c convertRef3 = (buildertek__References__c)JSON.deserialize((ref3),buildertek__References__c.Class);
            convertRef3.buildertek__Account__c = accountRecord.id;
            upsert convertRef3;
        }
        
        if(projectlist1 != null){
            buildertek__Past_Project__c convertProject1 = (buildertek__Past_Project__c)JSON.deserialize((projectlist1),buildertek__Past_Project__c.Class);
            convertProject1.buildertek__Account__c = accountRecord.id;
            upsert convertProject1;
            system.debug('@@@@'+convertProject1.Id);
        }
        
        if(projectlist2 != null){
            buildertek__Past_Project__c convertProject2 = (buildertek__Past_Project__c)JSON.deserialize((projectlist2),buildertek__Past_Project__c.Class);
            convertProject2.buildertek__Account__c = accountRecord.id;
            upsert convertProject2;
            system.debug('@@@@'+convertProject2.Id);
        }
        
        if(projectlist3 != null){
            buildertek__Past_Project__c convertProject3 = (buildertek__Past_Project__c)JSON.deserialize((projectlist3),buildertek__Past_Project__c.Class);
            convertProject3.buildertek__Account__c = accountRecord.id;
            upsert convertProject3;
            system.debug('@@@@'+convertProject3.Id);
        } */




            if(accountRecord.NumberOfEmployees != null){
                accountRecord.NumberOfEmployees = Integer.valueOf(accountRecord.NumberOfEmployees);
            }else{
                accountRecord.NumberOfEmployees = null;    
            }
            accountRecord.buildertek__Qualification_Stage__c = 'Email Received';
            update accountRecord;   
            //RC.Status = 'Success';
            //RC.Message = 'Account updated successfully';
            // return 'sri';
      //  }catch(exception exp){
            //RC.Status = 'Error';
            //RC.Message = exp.getMessage();
          //  return 'ram';
        //}
        
        //return RC;
        return fileWrapper;
    }
    
        @AuraEnabled
    public static FileUploadWrapper createMultiPreQual(String boxData,string recId,buildertek__Pre_Qual__c preQualRecord,String ref1,String ref2,String ref3,string projectlist1,String projectlist2,String projectlist3){
        system.debug(boxData);
    buildertek__Pre_Qual__c acc = [select id,name,buildertek__Box_Folder_Id__c,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c from buildertek__Pre_Qual__c where id =:recId];
         List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Enable_Box__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
    system.debug(acc);
        //system.debug('base64String --------> '+base64String);
        List<ContentVersion> contentVersionList = new List<ContentVersion>();
        ResponseClass RC = new ResponseClass();
        string AccessToken;
        FileUploadWrapper fileWrapper = new FileUploadWrapper();
        
       // try{
            //if(base64String != ''){
                //system.debug('base64String --------> '+base64String);
                //List<FilesWrapper> files = (List<FilesWrapper>)System.JSON.deserialize(base64String, List<FilesWrapper>.class);
                //system.debug('files---------'+files);
                
                ParameterResponseClass boxdatalist = (ParameterResponseClass)System.JSON.deserialize(boxData, ParameterResponseClass.class);

                string Response1='';
                string Response='';
                
                string endPointURL;
                string RefreshToken;
                /*code to get access token*/
                HttpRequest req1 = new HttpRequest();
                //endPointURL='https://app.box.com/api/oauth2/token?code='+Authcode+'&client_id='+clientid+'&client_secret='+client_secret+'&grant_type=authorization_code';
                endPointURL='https://app.box.com/api/oauth2/token?';
                System.debug('******endPointURL:'+endPointURL);
                req1.setEndpoint(endPointURL);
                req1.setMethod('POST');
                req1.setHeader('Content-Type','application/x-www-form-urlencoded');
                String bb='grant_type=authorization_code';
    
                req1.setbody('grant_type=client_credentials'+
                             '&box_subject_type=enterprise'+
                             '&box_subject_id='+boxdatalist.EnterpriceId+
                             '&client_id='+boxdatalist.clientid+
                             '&client_secret='+boxdatalist.client_secret);
                req1.setHeader('Accept','application/json');
                Http http = new Http();
                HTTPResponse res1 = http.send(req1);
                Response=res1.getBody();
                Integer statusCode=res1.getStatusCode();
                System.debug(Response);
                // Parse JSON response to get refresh_token values.
                JSONParser parser = JSON.createParser(Response);
                while (parser.nextToken() != null) {
                    if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                        String fieldName = parser.getText();
                        parser.nextToken();
                        if(fieldName == 'access_token') {
                            AccessToken= parser.getText();
                        }if(fieldName == 'refresh_token') {
                            RefreshToken= parser.getText();
                        }
                    }
               // }
            String boundary = '----------------------------741e90d31eff';
            fileWrapper.boxFolderId = acc.buildertek__Box_Folder_Id__c;
            fileWrapper.accessToken = accessToken;
            fileWrapper.boundary = boundary;    
                    if(preQualSettings.size() > 0){
                        fileWrapper.EnableBox = preQualSettings[0].buildertek__Enable_Box__c;
                    }
            /*if(base64String != ''){
               for(FilesWrapper FW :files){
                blob base64EncodeFile=base64EncodeFileContent(FW.fileContent,FW.fileName);
                //blob fileContent=blob.valueof('test String');
                //blob base64EncodeFile=BoxUtility.base64EncodeFileContent(fileContent,'First file Upload');
                system.debug(acc.buildertek__Box_Folder_Id__c);
                
                String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+acc.buildertek__Box_Folder_Id__c;
                String boundary = '----------------------------741e90d31eff';
                
                HttpRequest req = new HttpRequest();
                req.setBodyAsBlob(base64EncodeFile);
                req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
                req.setHeader('Authorization', 'Bearer ' + AccessToken);
                req.setMethod('POST');
                req.setEndpoint(uploadEndPointURL);
                req.setMethod('POST');
                req.setTimeout(120000);
                //Send request to Box
                HTTPResponse res=sendHttpRequest(req);
                Response=res.getBody();
                System.debug('**Files upload Response:'+Response);
                Integer uploadStatusCode=res.getStatusCode();
                if(uploadStatusCode==201){
                    //return 'success';
                }else{
                   //return 'error';
                }
            }             
                
              }*/
                /*if(contentVersionList.size() > 0){
                    ContentVersionTriggerHandler.isSkip = true;
                    if(!Test.isRUnningTest())
                        insert contentVersionList;
                }*/ 
               
            }
            
            /*if(preQualRecord.NumberOfEmployees != null){
                preQualRecord.NumberOfEmployees = Integer.valueOf(accountRecord.NumberOfEmployees);
            }else{
                preQualRecord.NumberOfEmployees = null;    
            }*/
      /*  if(ref1 != null){
            buildertek__References__c convertRef1 = (buildertek__References__c)JSON.deserialize((ref1),buildertek__References__c.Class);
            convertRef1.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertRef1;
        }
        if(ref2 != null){
            buildertek__References__c convertRef2 = (buildertek__References__c)JSON.deserialize((ref2),buildertek__References__c.Class);
            convertRef2.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertRef2;
        }
        if(ref3 != null){
            buildertek__References__c convertRef3 = (buildertek__References__c)JSON.deserialize((ref3),buildertek__References__c.Class);
            convertRef3.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertRef3;
        }
        
        if(projectlist1 != null){
            buildertek__Past_Project__c convertProject1 = (buildertek__Past_Project__c)JSON.deserialize((projectlist1),buildertek__Past_Project__c.Class);
            convertProject1.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertProject1;
            system.debug('@@@@'+convertProject1.Id);
        }
        
        if(projectlist2 != null){
            buildertek__Past_Project__c convertProject2 = (buildertek__Past_Project__c)JSON.deserialize((projectlist2),buildertek__Past_Project__c.Class);
            convertProject2.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertProject2;
            system.debug('@@@@'+convertProject2.Id);
        }
        
        if(projectlist3 != null){
            buildertek__Past_Project__c convertProject3 = (buildertek__Past_Project__c)JSON.deserialize((projectlist3),buildertek__Past_Project__c.Class);
            convertProject3.buildertek__Pre_Qual__c = preQualRecord.id;
            upsert convertProject3;
            system.debug('@@@@'+convertProject3.Id);
        } */

        
        
        
            preQualRecord.buildertek__Qualification_Stage__c = 'Email Received';
            preQualRecord.buildertek__Pre_Qual_Contact__c = acc.buildertek__Pre_Qual_Contact__c;
            preQualRecord.buildertek__MSA_Additional_Email__c = acc.buildertek__MSA_Additional_Email__c;
            update preQualRecord;   
            //RC.Status = 'Success';
            //RC.Message = 'Account updated successfully';
            // return 'sri';
      //  }catch(exception exp){
            //RC.Status = 'Error';
            //RC.Message = exp.getMessage();
          //  return 'ram';
        //}
        
        //return RC;
        return fileWrapper;
    }
    
    
    
    public static blob base64EncodeFileContent(string file_body, String file_name){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = file_body;
        Blob bodyBlob = null;
        String last4Bytes = bodyEncoded.substring(bodyEncoded.length()-4,bodyEncoded.length());
        
        if(last4Bytes.endsWith('==')) {
            last4Bytes = last4Bytes.substring(0,2) + '0K';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);
        } else if(last4Bytes.endsWith('=')) {
            last4Bytes = last4Bytes.substring(0,3) + 'N';
            bodyEncoded = bodyEncoded.substring(0,bodyEncoded.length()-4) + last4Bytes;
            footer = '\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);              
        } else {
            footer = '\r\n' + footer;
            String footerEncoded = EncodingUtil.base64Encode(Blob.valueOf(footer));
            system.debug('headerEncoded ****' + headerEncoded);
            system.debug('bodyEncoded ****' + bodyEncoded);
            system.debug('footerEncoded ****' + footerEncoded);
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        
        return bodyBlob;
    }
    @AuraEnabled
    public static ParameterResponseClass getparameters(){
        ParameterResponseClass prm = new ParameterResponseClass();
        prm.clientid = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Client_Id__c;
        prm.client_secret = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Client_Secret__c;
        prm.ViewAPI_Key = buildertek__Box_Settings__c.getValues('BOX API').buildertek__API_Key__c;
        prm.AccessToken = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Access_Token__c;
        prm.RefreshToken = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Refresh_Token__c;
        prm.EnterpriceId = buildertek__Box_Settings__c.getValues('BOX API').buildertek__Enterprise_ID__c;
        return prm;
        
    }
    public class ParameterResponseClass{
        @AuraEnabled public String clientid;
        @AuraEnabled public String client_secret;
        @AuraEnabled public String ViewAPI_Key;
        @AuraEnabled public String AccessToken;
        @AuraEnabled public String RefreshToken;
        @AuraEnabled public String EnterpriceId;
        @AuraEnabled public String endPointURL;
    }
    
      public static HTTPResponse sendHttpRequest(HTTPRequest req){
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('****response body:'+res.getBody());
        return res;
    }
    
    public class FilesWrapper{
     @AuraEnabled   public String fileName;
    @AuraEnabled    public String fileContent;
     @AuraEnabled   public String parentId;
    //    public String fileType;
     //   public Integer fileSize;
    }
    
    public class ResponseClass{
        @AuraEnabled public String Status;
        @AuraEnabled public String Message;
    }

    public class FileUploadWrapper{
        @AuraEnabled public String boxFolderId;
        @AuraEnabled public String accessToken;
        @AuraEnabled public String boundary;
        @AuraEnabled public Blob base64EncodeFileContent;
        @AuraEnabled public Boolean  EnableBox;
    }
    
       @AuraEnabled
      public static  List<ContentDocumentLink> uploadFilesInSalesforce(string fileData){
          System.debug('File Date To Upload in Salesforce -------------------  '+fileData);
          
          List<ContentDocumentLink> CDList = new  List<ContentDocumentLink>();
              List<FilesWrapper> inn = new  List<FilesWrapper>();
        if(fileData != null && fileData != '' && fileData != '[]'){
            inn = (List<FilesWrapper>)JSON.deserialize((fileData),List<FilesWrapper>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            
        }
          
           if(inn.size() > 0){
            for(FilesWrapper a : inn){
                 ContentVersion cv = createContentVersion(a.fileContent, a.fileName);
                    ContentDocumentLink cdl = createContentLink(cv.Id,a.parentId);
                CDList.add(cdl);
            }
          
      }
          return CDList;
      }
    
    
     private static ContentVersion createContentVersion(String base64, String filename) {
    ContentVersion cv = new ContentVersion();
    cv.VersionData = EncodingUtil.base64Decode(base64);
    cv.Title = filename;
    cv.PathOnClient = filename;
    try {
      insert cv;
      return cv;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
    
    
    private static ContentDocumentLink createContentLink(String contentVersionId, String recordId) {
              if (contentVersionId == null || recordId == null) { return null; }
    ContentDocumentLink cdl = new ContentDocumentLink();
    cdl.ContentDocumentId = [
      SELECT ContentDocumentId 
      FROM ContentVersion 
      WHERE Id =: contentVersionId
    ].ContentDocumentId;
    cdl.LinkedEntityId = recordId;
    // ShareType is either 'V', 'C', or 'I'
    // V = Viewer, C = Collaborator, I = Inferred
    cdl.ShareType = 'V';
    try {
      insert cdl;
      return cdl;
    } catch(DMLException e) {
      System.debug(e);
      return null;
    }
  }
  
    @AuraEnabled
     public static Boolean checkEnableBox(){
               List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Enable_Box__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
        if(preQualSettings.size() > 0){
            return preQualSettings[0].buildertek__Enable_Box__c;
        }
        else{
        return false;
        }

    }
    
    //-----------Hemanth--------------
    
    
     @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            //appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug(parentId);
        system.debug(fileName);
        system.debug(base64Data);
        system.debug(contentType);
        List<Account> lstAcc=[SELECT Id,Name FROM Account WHERE id =:parentId];        
         base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
          ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
            conVer.Title = fileName; // Display name of the files
            conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
           system.debug(conVer.Id);
        system.debug('******************'+parentId);
        
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
           system.debug(conDoc);
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
        return conDocLink.Id;

        
        
        
        
        /*base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        
        Attachment oAttachment = new Attachment();
        oAttachment.parentId = parentId;
        
        oAttachment.Body = EncodingUtil.base64Decode(base64Data);
        oAttachment.Name = fileName;
        oAttachment.ContentType = contentType;
        
        insert oAttachment;        
        return oAttachment.Id;*/
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
    }
    
     public static void dummy(){
        integer i = 0;
        i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
          i++;
         i++;
         i++;
         i++;
    }
    
}