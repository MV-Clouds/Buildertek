public class NewSovOverride {
    @AuraEnabled
    public static buildertek__SOV_Continuation__c GetSheetid(String recordId){
        buildertek__SOV_Continuation__c sheetId = [select Id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__r.Id =: recordId ];
        return sheetId;
    }
    
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
  
    
}