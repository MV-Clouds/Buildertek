public class COTrackingController {
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
    public static String getPaymentAppStatus(string recordId){
        
        buildertek__BT_Change_Order_Payment_Tracking__c CoPayAppTrac = [select Id, Name, buildertek__Payment_Application_G702__c, buildertek__Payment_Application_G702__r.buildertek__Status__c from buildertek__BT_Change_Order_Payment_Tracking__c where Id =: recordId];
        
        if(CoPayAppTrac.buildertek__Payment_Application_G702__c != null){
             return CoPayAppTrac.buildertek__Payment_Application_G702__r.buildertek__Status__c;
        }else{
            return null;
        }
        
       
    }
}