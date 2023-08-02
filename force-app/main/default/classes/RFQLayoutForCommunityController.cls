public class RFQLayoutForCommunityController {
    @AuraEnabled 
    public static String getRFQStatus(string recordId){
       
        buildertek__RFQ__c awardedRfq = [Select id, Name, buildertek__Status__c from buildertek__RFQ__c where Id =:recordId ];
        
        system.debug(awardedRfq.buildertek__Status__c);
            return awardedRfq.buildertek__Status__c;
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
    
    
    @AuraEnabled
    public static String submitSOVForView(String recordId, String vendorId){
        
        buildertek__RFQ__c awardedRfq = [Select id, Name, buildertek__Status__c from buildertek__RFQ__c where Id =:recordId ];
        system.debug(awardedRfq );
        awardedRfq.buildertek__Status__c = 'Accepted';
        
        update awardedRfq ;
        
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =:recordId AND buildertek__Vendor__c =:vendorId];
        rfqToAccount.buildertek__Status__c = 'Accepted';
        
        system.debug(rfqToAccount);
        update rfqToAccount;
        
        return 'success';
    }
    
    
    
    @AuraEnabled
    public static String rqSubmitted(String recordId, String vendorId){
        
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =:recordId AND buildertek__Vendor__c =:vendorId];
        
        
        system.debug(rfqToAccount);
        
        return rfqToAccount.buildertek__Status__c;
    }
    
    
    
    @AuraEnabled
    public static String getRQToAccount(String recordId, String vendorId){

        
        buildertek__RFQ_To_Vendor__c rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =:recordId AND buildertek__Vendor__c =:vendorId AND (buildertek__RFQ__r.buildertek__Status__c = 'Awarded' OR buildertek__RFQ__r.buildertek__Status__c = 'Accepted')];
       // rfqToAccount.buildertek__Status__c = 'Accepted';
        
        system.debug(rfqToAccount);
       // update rfqToAccount;
        
        return rfqToAccount.buildertek__Status__c;
    }
    
    
    @AuraEnabled
    public static Boolean getrejectMessage(String recordId, String vendorId){
        
        
        list<buildertek__RFQ_To_Vendor__c> rfqToAccount = [select Id, Name,buildertek__Status__c, buildertek__RFQ__c,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c =:recordId];
        boolean isAccepted = false;
        
        for(buildertek__RFQ_To_Vendor__c rfqToVendor : rfqToAccount){
            if(rfqToVendor.buildertek__Status__c == 'Accepted'){
                isAccepted = true;
            }
        }
       
        return isAccepted;
    }
    
    
    
    @AuraEnabled
    public static String rejectRfq(String recordId){
        
        buildertek__RFQ__c awardedRfq = [Select id, Name, buildertek__Status__c from buildertek__RFQ__c where Id =:recordId ];
        system.debug(awardedRfq );
        awardedRfq.buildertek__Status__c = 'Canceled';
        
        update awardedRfq ;
        return 'success';
    }
    
}