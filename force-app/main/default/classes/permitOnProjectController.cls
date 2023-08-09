public class permitOnProjectController {
    @AuraEnabled
    public static InnertList getPermit(String recordId){
        List<buildertek__Permit__c> permitRecor = new  List<buildertek__Permit__c>();
        InnertList resp = new InnertList();
        permitRecor = [select buildertek__Permit__c,Name,buildertek__Permit_Type__c,buildertek__Status__c,buildertek__Date_Ordered__c,buildertek__Date_Scheduled__c,buildertek__Date_Completed__c,buildertek__Inspector__c from buildertek__Permit__c where buildertek__Project__c =: recordId];
        if(permitRecor.size() > 0){
            resp.permits = permitRecor;
            resp.message = 'Success';
            return resp;
        }
        else{
            resp.message = 'Error';
            return resp;
        }
    }
    
    public class InnertList{
        @AuraEnabled public List<buildertek__Permit__c> permits;
        @AuraEnabled  public String message;
    }
    
}