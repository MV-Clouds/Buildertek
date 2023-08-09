public with sharing class cloneTakeOffController {
    
    @AuraEnabled
    public static buildertek__Project_Takeoff__c gettakeoffdata(String recordId){
        try {
            System.debug('recordId-->'+recordId);
            buildertek__Project_Takeoff__c parenttakeoff = [SELECT Id, Name FROM buildertek__Project_Takeoff__c WHERE Id =:recordId];
            return parenttakeoff;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}