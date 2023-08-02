public class ImageUploadService {
    @AuraEnabled
    public static String postImage(Blob Image, String fileType){
        List<buildertek__Image_Upload_Settings__c> imageSettings = [SELECT Id, 
                                                                    		buildertek__API_Key__c, 
                                                                    		buildertek__Domain__c 
                                                                    		FROM buildertek__Image_Upload_Settings__c
                                                                   			WHERE Name = 'Image Upload Settings' LIMIT 1];
        String resultId;
    	HttpRequest req = new HttpRequest();                            
        req.setMethod('POST');
        req.setEndpoint(imageSettings[0].buildertek__Domain__c+'/formrecognizer/v2.1-preview.2/prebuilt/invoice/analyze');
        if(fileType == 'pdf'){
        	req.setHeader('Content-Type', 'application/pdf');    
        }else if(fileType == 'jpeg' || fileType == 'jpg'){
            req.setHeader('Content-Type', 'image/jpeg');
        }else if(fileType == 'png'){
            req.setHeader('Content-Type', 'image/png');
        }
        req.setHeader('Ocp-Apim-Subscription-Key', imageSettings[0].buildertek__API_Key__c);
        //String body = Image;
        req.setBodyAsBlob(Image);
        Http http = new Http();  
        HTTPResponse res = http.send(req); 
        resultId = res.getHeader('apim-request-id');
        system.debug('Status Code -------> '+res.getStatusCode());
        system.debug('Response ------> '+res.getBody());
        system.debug('Response Header ------> '+res.getHeader('apim-request-id'));
        return resultId;
    }
    
    @AuraEnabled
    public static ResponseWrapper getImageResponse(String resultId){
        ResponseWrapper RW = new ResponseWrapper();
        List<buildertek__Image_Upload_Settings__c> imageSettings = [SELECT Id, 
                                                                    		buildertek__API_Key__c, 
                                                                    		buildertek__Domain__c 
                                                                    		FROM buildertek__Image_Upload_Settings__c
                                                                   			WHERE Name = 'Image Upload Settings' LIMIT 1];
    	HttpRequest req = new HttpRequest();                            
        req.setMethod('GET');
        req.setEndpoint(imageSettings[0].buildertek__Domain__c+'/formrecognizer/v2.1-preview.2/prebuilt/invoice/analyzeResults/'+resultId);
        req.setHeader('Ocp-Apim-Subscription-Key', imageSettings[0].buildertek__API_Key__c);
        Http http = new Http();  
        HTTPResponse res = http.send(req); 
        if(res.getStatusCode() == 200){
            system.debug('Response ------> '+res.getBody());
            RW.responseString = res.getBody();
        	Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug('m -------> '+m);
            if(m.get('analyzeResult') != null){
            	Map<String, Object> a = (Map<String, Object>)m.get('analyzeResult');   
                system.debug('a -------> '+a);
                if(a.get('pageResults') != null){
                    List<Object> pageResults = (List<Object>)a.get('pageResults');  
                    RW.pageResults = pageResults;
                }
                if(a.get('documentResults') != null){
                    List<Object> readResults = (List<Object>)a.get('documentResults');  
                    RW.readResults = readResults;
                }
            }
        }
        return RW;
            
    }
    
    public class ResponseWrapper{
        @AuraEnabled public List<Object> pageResults;
        @AuraEnabled public List<Object> readResults;
        @AuraEnabled public String responseString;
    }
        
    public class pageResults{
        public List<Tables> tablesList;
        public Integer pageNumber;
    }
    
    public class Tables{
        public Integer Rows;
        public Integer Columns;
        public List<Cells> cellList;
    }
    
    public class Cells{
        public Integer rowIndex;
        public Integer columnIndex;
        public String text;
    }
}