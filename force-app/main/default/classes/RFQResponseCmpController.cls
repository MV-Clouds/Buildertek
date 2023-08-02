public with sharing class RFQResponseCmpController {

    @AuraEnabled
    public static string getRFQdata(){
        return null;
    }

    public class RFQDetailsWrapper{
        @AuraEnabled
        public buildertek__RFQ__c rfq {get;set;}
        
    }
}