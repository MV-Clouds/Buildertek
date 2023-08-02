public class SOVSheetController {
@AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    @AuraEnabled
    public static List<buildertek__Schedule_of_Value_Lines__c> getContinuationSheetLines(String recordId){
       
        List<buildertek__Schedule_of_Value_Lines__c> insertedSheetLinesList = [SELECT Id,
                                                                                    Name,
                                                                                    buildertek__Description_of_Work__c,
                                                                                    buildertek__Item__c,
                                                                                    buildertek__Scheduled_Value__c,
                                                                                    buildertek__Vendor__c,
                                                                                    buildertek__Schedule_of_Values__c
                                                                                   
                                                                                 
                                                                                    FROM buildertek__Schedule_of_Value_Lines__c
                                                                                    WHERE buildertek__Schedule_of_Values__c =: recordId];
        
       // system.debug(insertedSheetLinesList[0]);
        
        
  
        return insertedSheetLinesList;
    }
    
    @AuraEnabled
    public static ResponseWrapper createSheetLines(list<buildertek__Schedule_of_Value_Lines__c> SovLineValues, String recordId){
        ResponseWrapper RC = new ResponseWrapper();
        try{
            List<buildertek__Schedule_of_Value_Lines__c> continuationSheetLinesList = new List<buildertek__Schedule_of_Value_Lines__c>();
              
            list<buildertek__Schedule_of_Values__c> sovStatus = new list<buildertek__Schedule_of_Values__c>();
                
                for(buildertek__Schedule_of_Value_Lines__c coItem : SovLineValues){
                    buildertek__Schedule_of_Value_Lines__c continuationSheetLines = new buildertek__Schedule_of_Value_Lines__c();
                    continuationSheetLines.buildertek__Description_of_Work__c = coItem.buildertek__Description_of_Work__c;
                    continuationSheetLines.buildertek__Schedule_of_Values__c = recordId;
                    continuationSheetLines.buildertek__Scheduled_Value__c = coItem.buildertek__Scheduled_Value__c;
                    continuationSheetLines.buildertek__Item__c = coItem.buildertek__Item__c;
                    
                    
                   
                    continuationSheetLinesList.add(continuationSheetLines);
                    system.debug(continuationSheetLinesList);
                }
                if(continuationSheetLinesList.size() > 0){
                    system.debug(continuationSheetLinesList.size());
                    insert continuationSheetLinesList;
                    
                    buildertek__Schedule_of_Values__c sov = new buildertek__Schedule_of_Values__c();
                    sov.Id = recordId;
                    sov.buildertek__Status__c = 'Vendor Submitted';
                    
                    sovStatus.add(sov);
                    update sovStatus;
                    system.debug('&&'+continuationSheetLinesList);
                }
                RC.Status = 'Success';
                RC.Message = 'Schedule Of Value Lines added successfully';

        }catch(exception exp){
            RC.Status = 'Error';
            RC.Message = exp.getMessage();
        }
        return RC;
    }
    
    
    public class ResponseWrapper{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        }
 
    
    
}