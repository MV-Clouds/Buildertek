public class ReviewPricingRequestController {
    
    @AuraEnabled
    public static string getcurrency(){
        return UserInfo.getDefaultCurrency();
    }
    
    
    @AuraEnabled
    public static String getSOVName(string recordId){
        buildertek__Pricing_Request__c consSovLines = [select Id, Name, buildertek__Project__c, buildertek__Project__r.Name from buildertek__Pricing_Request__c    WHERE Id =:recordId];
        if(consSovLines.buildertek__Project__c != null){
            return consSovLines.Name; 
        }else{
            return consSovLines.Name;
        }
        
    }
    
    @AuraEnabled
    public static SOVLinesWrapperClass getVendorSOVLines(String SOVId) {
        system.debug('@@@@@@@@@@@@@'+SOVId);
        SOVLinesWrapperClass  wc = new SOVLinesWrapperClass();
        
        List<buildertek__Pricing_Request_Line__c> sovLineListreturn = new List<buildertek__Pricing_Request_Line__c>();
        List<buildertek__Pricing_Request_Line__c> sovLineList = [SELECT Id,
                                                                 Name,
                                                                 buildertek__Description__c,
                                                                 buildertek__Notes__c,
                                                                 buildertek__Price__c,
                                                                 buildertek__Status__c,
                                                                 buildertek__Reject_Reason__c,
                                                                 buildertek__Pricing_Request__c
                                                                 FROM buildertek__Pricing_Request_Line__c
                                                                 WHERE buildertek__Pricing_Request__c =: SOVId];
        if(!sovLineList.isEmpty()){
            wc.VendorSOVLinesList=sovLineList;
        }else{
            wc.VendorSOVLinesList=sovLineListreturn;
        }
        
        
        
        return wc;
    }
    
    
    
    
    public class SOVLinesWrapperClass{
        @AuraEnabled
        public List<buildertek__Pricing_Request_Line__c> VendorSOVLinesList {get;set;}
        @AuraEnabled
        public String sovName {get; set;}
        @AuraEnabled 
        public boolean isChecked=false; 
        @AuraEnabled 
        public Integer ApprovedSOVLinesCount {get; set;}
    }
    
    
    
    @AuraEnabled
    public static String ApproveSovLines(String sovLineIds) {
        system.debug('sovLineIds--->'+ sovLineIds);
        List<buildertek__Pricing_Request_Line__c> SovLineList = [select Id, Name, buildertek__Status__c from buildertek__Pricing_Request_Line__c where Id =:sovLineIds];
        
        system.debug('SovLineList------>'+SovLineList);
        
        
        if(!SovLineList.isEmpty()){
            for(buildertek__Pricing_Request_Line__c sov :SovLineList){
                sov.buildertek__Status__c = 'Accepted';
                sov.buildertek__Reject_Reason__c = '';
            }
            update SovLineList;
            
            return 'success';
        }else{
            return null;
        }  
    }
    
    
    
    @AuraEnabled
    public static String rejectSovLines(String sovLineIds, String rejectReason) {
        system.debug('sovLineIds--->'+ sovLineIds);
        List<buildertek__Pricing_Request_Line__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Reject_Reason__c from buildertek__Pricing_Request_Line__c where Id =:sovLineIds];
        
        if(!SovLineList.isEmpty()){
            for(buildertek__Pricing_Request_Line__c sov :SovLineList){
                sov.buildertek__Status__c = 'Rejected';
                sov.buildertek__Reject_Reason__c = rejectReason;
            }
            update SovLineList;
            return 'success';
        }else{
            return null;
        }  
    }
    
    
    
    @AuraEnabled
    public static ResponseWrapper createSheetLines(list<buildertek__Pricing_Request_Line__c> SovLineValues, String recordId){
        
        
        
        ResponseWrapper RC = new ResponseWrapper();
        Boolean isNew = false;
        
        List<buildertek__Pricing_Request_Line__c> sovLinesList = new  List<buildertek__Pricing_Request_Line__c>();
        
        sovLinesList=[SELECT Id, Name,buildertek__Description__c, buildertek__Notes__c, buildertek__Pricing_Request__c
                      FROM buildertek__Pricing_Request_Line__c where buildertek__Pricing_Request__c =: recordId ];
        
        system.debug('sovLinesList-->'+sovLinesList);
        //try{
        List<buildertek__Pricing_Request_Line__c> continuationSheetLinesList = new List<buildertek__Pricing_Request_Line__c>();
        
        
        system.debug('SovLineValues------------->'+SovLineValues);
        for(buildertek__Pricing_Request_Line__c coItem : SovLineValues){
            
            buildertek__Pricing_Request_Line__c continuationSheetLines = new buildertek__Pricing_Request_Line__c();
            
            continuationSheetLines.Id = coItem.Id;
            continuationSheetLines.buildertek__Description__c = coItem.buildertek__Description__c;
            continuationSheetLines.buildertek__Notes__c = coItem.buildertek__Notes__c;
           // continuationSheetLines.buildertek__Price__c = coItem.buildertek__Price__c;
           // continuationSheetLines.buildertek__Pricing_Request__c = recordId;
            continuationSheetLines.buildertek__Status__c = coItem.buildertek__Status__c;
            
            
            continuationSheetLinesList.add(continuationSheetLines);
            
            
            system.debug(continuationSheetLinesList);
        }
        
        system.debug('continuationSheetLinesList.size----'+continuationSheetLinesList);
        if(continuationSheetLinesList.size() > 0){
            system.debug(continuationSheetLinesList.size());
            update continuationSheetLinesList;
            system.debug('&&'+continuationSheetLinesList);
        }
        RC.Status = 'Success';
        RC.Message = 'Pricing Request Lines saved successfully';
        
        
        //}
        /*catch(exception exp){
RC.Status = 'Error';
RC.Message = exp.getMessage();
} */
        return RC;
    }
    
    
      public class ResponseWrapper{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
    
    
    
      @AuraEnabled
    public static string getAllApproved(List<String> sovLineIds) {
        try {
            system.debug('@@@@@@@@@@@@@sovLineIds'+sovLineIds);
            List<buildertek__Pricing_Request_Line__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Reject_Reason__c from buildertek__Pricing_Request_Line__c where Id IN:sovLineIds];
           
            
            if(!SovLineList.isEmpty()){
                for(buildertek__Pricing_Request_Line__c sov:SovLineList){
                    sov.buildertek__Status__c = 'Accepted';
                    sov.buildertek__Reject_Reason__c = '';
                }
                update SovLineList;
               
                return 'success';
            }else{
                return null;
            }  
        }
        catch(Exception e){ 
            system.debug('error--->'+e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    
    
    
    @AuraEnabled
    public static string getAllRejected(List<String> sovLineIds, String rejectReason) {
        try {
            system.debug('@@@@@@@@@@@@@sovLineIds'+sovLineIds);
            List<buildertek__Pricing_Request_Line__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Reject_Reason__c from buildertek__Pricing_Request_Line__c where Id IN:sovLineIds];
            
            
            if(!SovLineList.isEmpty()){
                for(buildertek__Pricing_Request_Line__c sov:SovLineList){
                    sov.buildertek__Status__c = 'Rejected';
                     sov.buildertek__Reject_Reason__c = rejectReason;
                }
                update SovLineList;
                
                return 'success';
            }else{
                return null;
            }  
        }
        catch(Exception e){ 
            system.debug('error--->'+e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    
    
    @AuraEnabled
    public static string clearAllLines(List<String> sovLineIds) {
        try {
            system.debug('@@@@@@@@@@@@@sovLineIds'+sovLineIds);
            List<buildertek__Pricing_Request_Line__c> SovLineList = [select Id, Name, buildertek__Status__c,buildertek__Reject_Reason__c,buildertek__Price__c from buildertek__Pricing_Request_Line__c where Id IN:sovLineIds];
            
            
            if(!SovLineList.isEmpty()){
                for(buildertek__Pricing_Request_Line__c sov:SovLineList){
                  //  sov.buildertek__Description__c = '';
                    sov.buildertek__Notes__c = '';
                }
                update SovLineList;
                
                return 'success';
            }else{
                return null;
            }  
        }
        catch(Exception e){ 
            system.debug('error--->'+e.getMessage());
            return  e.getMessage();
        }
        
    }
    
    
    
}