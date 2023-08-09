public class DisplayBoxFiles_Controller {
//List<entry> fileList;
@auraEnabled
public static List<entry> getFileData(string recordId){
    List<entry> fileListReturn=new List<entry>();
    String sObjName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
    Account acc;
    buildertek__Pre_Qual__c pre;
    if(sObjName == 'buildertek__Pre_Qual__c'){ 
        if(recordId != null && recordId != ''){
            pre = [select id,buildertek__Box_Folder_Id__c from buildertek__Pre_Qual__c where id=:recordId];
        }
    }else{
        if(recordId != null && recordId != ''){
            acc = [select id,buildertek__Box_Folder_Id__c from Account where id=:recordId];
        }
    }
    string AccessToken = getAccesstoken();
    if(sObjName == 'buildertek__Pre_Qual__c'){
        fileListReturn = FindFilesFromFolder(AccessToken,pre.buildertek__Box_Folder_Id__c);
    }else{
        fileListReturn = FindFilesFromFolder(AccessToken,acc.buildertek__Box_Folder_Id__c);
    }
    
    system.debug('@@@'+fileListReturn);
    return fileListReturn;
    
}
public static List<entry> FindFilesFromFolder(string accessToken,string selectedFolder){
    
    string Response='';
    string FileViewUrl='';
    FoldersInfo folderDetails = new FoldersInfo();
    List<entry> fileListData=new List<entry>();
    if(selectedFolder!=null && selectedFolder!=''){
        String endpointURLForFiles = 'https://api.box.com/2.0/folders/'+selectedFolder;
        system.debug('*******endpointURLForFiles '+endpointURLForFiles );
        Map<String,String>headers=new Map<String,String>();
        headers.put('Content-Type','application/x-www-form-urlencoded');
        headers.put('Accept','application/json');
        headers.put('Authorization','Bearer ' + accessToken);
        HTTPRequest req=createHTTPReq('', endpointURLForFiles ,'GET',headers);
        
        //Now send request to fetch files details
        HTTPResponse res=sendHttpRequest(req);
        Response=res.getBody();
        System.debug('**Files Response:'+Response);
        
        //parse file response json
        folderDetails = (FoldersInfo )JSON.deserialize(Response,FoldersInfo.class);
        system.debug('********folderDetails :'+folderDetails );
        //find file list from respone to display in ui
        fileListData = FindFileList(folderDetails);
        system.debug('$$$$$$$$$$$$$$$$'+fileListData);
    }else{
        
    }
    system.debug(fileListData);
    return fileListData;
}

public static HTTPRequest createHTTPReq(String reqBody, string reqEndPoint, string reqMethod, Map<String,String> headersMap){
    HttpRequest req = new HttpRequest();
    req.setEndpoint(reqEndPoint);
    req.setMethod(reqMethod);
    if(reqBody!=null && reqBody!=''){
        req.setbody(reqBody);
    }
    if(headersMap.size()>0){
        for(String ss : headersMap.keyset()){
            req.setHeader(ss,headersMap.get(ss));   
        }
    }
    req.setTimeout(120000);
    return req;
}
public class FoldersInfo{
    public String type;
    public String id;
    public String sequence_id;
    public String etag;
    public String name;
    public String created_at;
    public String modified_at;
    public String item_status;
    public String description;
    public itemCollections item_collection;
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
public class entry{
    @AuraEnabled public String type;
    @AuraEnabled public String id;
    @AuraEnabled public String name;
    public entry(String type,String id,String name){
        this.type=type;
        this.id=id;
        this.name=name;
    }   
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
public static HTTPResponse sendHttpRequest(HTTPRequest req){
    Http http = new Http();
    HTTPResponse res = http.send(req);
    System.debug('****response body:'+res.getBody());
    return res;
}
public static List<entry> FindFileList(FoldersInfo folderDetails){
    List<entry> fileList=new List<entry>();
    string selectedFolder;
    // if(selectedFolder!=null && selectedFolder!=''){
    if(folderDetails.item_collection!=null){
        if(folderDetails.item_collection.entries.size()>0){
            for(entry en: folderDetails.item_collection.entries){
                if(en.type.equalsignorecase('file')){
                    fileList.add(en);
                }
            }
            system.debug(fileList);
        }
    }
    // }
    return fileList;
}
public static string getAccesstoken(){
    string clientid=Box_Settings__c.getValues('BOX API').Client_Id__c;  
    string client_secret=Box_Settings__c.getValues('BOX API').Client_Secret__c;
    string ViewAPI_Key=Box_Settings__c.getValues('BOX API').API_Key__c;
    string AccessToken=Box_Settings__c.getValues('BOX API').Access_Token__c;
    string RefreshToken=Box_Settings__c.getValues('BOX API').Refresh_Token__c;
    string EnterpriceId= Box_Settings__c.getValues('BOX API').Enterprise_ID__c;
    string Response='';
    
    
    
    HttpRequest req1 = new HttpRequest();
    string endPointURL='https://app.box.com/api/oauth2/token?';
    System.debug('******endPointURL:'+endPointURL);
    req1.setEndpoint(endPointURL);
    req1.setMethod('POST');
    req1.setHeader('Content-Type','application/x-www-form-urlencoded');
    String bb='grant_type=authorization_code';
    req1.setbody('grant_type=client_credentials'+
                 '&box_subject_type=enterprise'+
                 '&box_subject_id='+EnterpriceId+
                 '&client_id='+clientid+
                 '&client_secret='+client_secret);
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
    }
    system.debug(AccessToken);
    
    return AccessToken;
}

@AuraEnabled
public static string downloadFile(string fileId){
    system.debug(fileId);
    string AccessToken = getAccesstoken();
    String endPointValue = 'https://api.box.com/2.0/files';
    endPointValue=endPointValue+'/'+fileId+'/content';
     Http h = new Http();
    HttpRequest req = new HttpRequest();
    //endPointValue=endPointValue+fileId+'/content';
    req.setEndpoint(endPointValue);
    req.setMethod('GET');
    req.setHeader('Authorization', 'Bearer '+AccessToken);
    HTTPResponse res = sendHttpRequest(req);
    //httpresponse res = http.send(req);

    string[] headerkeys = res.getHeaderKeys();

    Map<string, string> headers = new map<string, string>();

//iterate through they keys, and populate your map
   for(string s : headerkeys){
     headers.put(s,res.getHeader(s));
      system.debug('header: ' + s + ' value: ' + res.getHeader(s));
      system.debug(s);
      if(s == 'location'){
         return res.getHeader(s);
      }
   }
    
    system.debug('pANY'+res.getBodyAsblob());
    system.debug(res.getHeader('Location'));
    //return res.getHeader('Location');
    return null;
    
    
}




}