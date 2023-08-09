public class PricingRequestLinesController {
    
    
    @AuraEnabled
    public static string getcurrency(){
        return UserInfo.getDefaultCurrency();
    }
    
    
    
    @AuraEnabled
    public static List<String> getSOVName(string recordId){
        List<string> sovData = new List<String>();
        buildertek__Pricing_Request__c consSovLines = [select Id, Name, buildertek__Project__c, buildertek__Project__r.Name from buildertek__Pricing_Request__c    WHERE Id =:recordId];
        if(consSovLines.buildertek__Project__c != null){
             sovData.add(consSovLines.Name);
            sovData.add(consSovLines.buildertek__Project__r.Name);
             sovData.add(consSovLines.buildertek__Project__c);
            return sovData; 
        }else{
             sovData.add(consSovLines.Name);
            sovData.add(consSovLines.buildertek__Project__r.Name);
              sovData.add(consSovLines.buildertek__Project__c);
            return sovData; 
        }
        
    }
    
    
    @AuraEnabled
    public static List<buildertek__Pricing_Request_Line__c> getSovLines(string recordId) {
        string insertedSOVLinesString = '';
        
        
        insertedSOVLinesString = 'SELECT Id,Name,buildertek__Description__c,buildertek__Notes__c ,buildertek__Pricing_Request__c FROM buildertek__Pricing_Request_Line__c WHERE buildertek__Pricing_Request__c =: recordId ';
        
        List<buildertek__Pricing_Request_Line__c> insertedSOVLines = Database.query(insertedSOVLinesString);
        return insertedSOVLines;
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
            if(coItem.buildertek__Pricing_Request__c == null){
                continuationSheetLines.buildertek__Pricing_Request__c = recordId;
            }
                
                
            continuationSheetLinesList.add(continuationSheetLines);
            
            
            system.debug(continuationSheetLinesList);
        }
        
        system.debug('continuationSheetLinesList.size----'+continuationSheetLinesList);
        if(continuationSheetLinesList.size() > 0){
            system.debug(continuationSheetLinesList.size());
            upsert continuationSheetLinesList;
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
    public static string deletesheetline(List<String> sheetlineIds, String recordId){
        List<buildertek__Pricing_Request_Line__c> sheetlineslist = new List<buildertek__Pricing_Request_Line__c>();
        for (string lineId : sheetlineIds){
            buildertek__Pricing_Request_Line__c sheetlinerec = new buildertek__Pricing_Request_Line__c();
            sheetlinerec.Id = lineId;
            sheetlineslist.add(sheetlinerec);
        }
        try{
            delete sheetlineslist;
            
            
            
            
            return 'success';
        } catch (Exception ex){
            return ex.getMessage();
        }
    }
    
    
    
}