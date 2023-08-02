public class BoxAuthController {
    public String Authcode;
    public String AccessToken;
    public String RefreshToken;
    public String clientid;
    public String client_secret;
    public String API_Key;
    public String EnterpriceId;
    public String ViewAPI_Key;
    public String securitycode;
    public String Response;//response from Box.com
    public String endPointURL;
    public String FileViewUrl;
    public String selectedFolder;
    
    
    
    //map to store file id and file name present in box
    public Map<String,String>folderIdToNameMap=new Map<String,String>();
    //Variable to store all folder information in this wrapper
    public FoldersInfo folderDetails;
    //list to dispaly file list in UI
    public List<entry> fileList;
    
    //variables for file upload
    public blob uploadContent{get;set;}
    public String uploadFilename{get;set;}
    
    
    
    public BoxAuthController(){
        Authcode=ApexPages.currentPage().getparameters().get('code');
        securitycode=ApexPages.currentPage().getparameters().get('state');
        clientid=Box_Settings__c.getValues('BOX API').Client_Id__c;  
        client_secret=Box_Settings__c.getValues('BOX API').Client_Secret__c;
        ViewAPI_Key=Box_Settings__c.getValues('BOX API').API_Key__c;
        AccessToken=Box_Settings__c.getValues('BOX API').Access_Token__c;
        RefreshToken=Box_Settings__c.getValues('BOX API').Refresh_Token__c;
        EnterpriceId= Box_Settings__c.getValues('BOX API').Enterprise_ID__c;
        endPointURL='https://app.box.com/api/oauth2/token?';
       
    }
    public class FoldersInfo{
        public String type{get;set;}
        public String id{get;set;}
        public String sequence_id{get;set;}
        public String etag{get;set;}
        public String name{get;set;}
        public String created_at{get;set;}
        public String modified_at{get;set;}
        public String item_status{get;set;}
        public String description{get;set;}
        public itemCollections item_collection{get;set;}
        public FoldersInfo(){}
        public FoldersInfo(String type,String id,String sequence_id,String etag,String name,String created_at,String modified_at,String description,String item_status ){
            this.type=type;
            this.id=id;
            this.sequence_id=sequence_id;
            this.etag=etag;
            this.created_at=created_at;
            this.modified_at=modified_at;
            this.description=description;
            this.item_status=item_status;
            this.item_collection=new itemCollections();
            
        }
    }
    
    //code to upload files to BOX.COM
    public PageReference uploadFileToBox(){
        Response='';
        system.debug('****selectedFolder;'+selectedFolder);
        if(selectedFolder!=null && selectedFolder!=''){
            if(uploadContent!=null){
                blob base64EncodeFile=base64EncodeFileContent(uploadContent,uploadFilename);
                //blob fileContent=blob.valueof('test String');
                //blob base64EncodeFile=BoxUtility.base64EncodeFileContent(fileContent,'First file Upload');
                String uploadEndPointURL='https://upload.box.com/api/2.0/files/content?parent_id='+selectedFolder;
                String boundary = '----------------------------741e90d31eff';
                HttpRequest req = new HttpRequest();
                req.setBodyAsBlob(base64EncodeFile);
                req.setHeader('Content-Type','multipart/form-data; boundary='+boundary);
                req.setHeader('Content-Length',String.valueof(req.getBodyAsBlob().size()));
                req.setHeader('Authorization', 'Bearer ' + accessToken);
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
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'File uploaded successfully.'));
                }else{
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Error encountered. Status Code;'+uploadStatusCode));
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please select file.'));
            }
        }else{
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please select folder.');
            ApexPages.addMessage(myMsg);
        }
        return null;
    }
    
    //reference :http://blog.enree.co/2013/01/salesforce-apex-post-mutipartform-data.html
    public blob base64EncodeFileContent(Blob file_body, String file_name){
        String boundary = '----------------------------741e90d31eff';
        String header = '--'+boundary+'\nContent-Disposition: form-data; name="file"; filename="'+file_name+'";\nContent-Type: application/octet-stream';
        String footer = '--'+boundary+'--';             
        String headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        while(headerEncoded.endsWith('='))
        {
            header+=' ';
            headerEncoded = EncodingUtil.base64Encode(Blob.valueOf(header+'\r\n\r\n'));
        }
        String bodyEncoded = EncodingUtil.base64Encode(file_body);
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
            bodyBlob = EncodingUtil.base64Decode(headerEncoded+bodyEncoded+footerEncoded);  
        }
        
        return bodyBlob;
    }
    
    
    
    public HTTPResponse sendHttpRequest(HTTPRequest req){
        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('****response body:'+res.getBody());
        return res;
    }
    
    public class itemCollections{
        public String total_count{get;set;}
        public List<entry> entries{get;set;}
        public itemCollections(){}
        public itemCollections(String count){
            this.total_count=count;
            this.entries=new list<entry>();  
        }
    }
    
    public class entry{
        public String type{get;set;}
        public String id{get;set;}
        public String name{get;set;}
        public entry(String type,String id,String name){
            this.type=type;
            this.id=id;
            this.name=name;
        }   
    }
    
    
    
    
}