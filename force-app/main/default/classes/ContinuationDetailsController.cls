public class ContinuationDetailsController {
    @AuraEnabled 
    public static string getContsheet(string recId){
        List<buildertek__SOV_Continuation__c> sovlist = [select id,Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where buildertek__SOV_Payment_Application__c =:recId];
        return sovlist[0].id;
    }
    
        @AuraEnabled 
    public static innerclass getState(string recId){
        buildertek__SOV_Payment_Application__c paymentold = [select id,buildertek__IsNextPayment__c,buildertek__Period_To__c,buildertek__Status__c from buildertek__SOV_Payment_Application__c where id=:recId];
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        innerclass inn = new innerclass();
       // inn.userrec = userRec[0].isPortalEnabled; 
        if(portalCode != '' && portalCode != null){
            inn.userrec = boolean.valueof(portalCode); 
        }
        inn.PeriodDate = paymentold.buildertek__Period_To__c;
        inn.status = paymentold.buildertek__Status__c;
        return inn;
        
    }
     public class innerclass{
        @AuraEnabled
        public boolean userrec;
        @AuraEnabled
        public string status;
         @AuraEnabled
        public Date PeriodDate;
     }
        
    
    @AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        system.debug(userRec);
        if(userRec.size() > 0){
         system.debug(userRec.size());
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        system.debug(userRec[0]);
        return  userRec[0] ;
    }
    
    
         @AuraEnabled 
    public static innerclass2 getConSheetState(string recId){
        buildertek__SOV_Continuation__c paymentold = [select id,buildertek__IsNextPayment__c,buildertek__SOV_Payment_Application__r.buildertek__Status__c from buildertek__SOV_Continuation__c where id=:recId];
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        innerclass2 inn = new innerclass2();
       // inn.userrec = userRec[0].isPortalEnabled; 
        if(portalCode != '' && portalCode != null){
          inn.userrec = boolean.valueof(portalCode);  
        }
        inn.status = paymentold.buildertek__SOV_Payment_Application__r.buildertek__Status__c;
        return inn;
        
    }
     public class innerclass2{
        @AuraEnabled
        public boolean userrec;
        @AuraEnabled
        public string status;
     }
}