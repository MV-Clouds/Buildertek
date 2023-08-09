public class ManageSOVClone {
  @AuraEnabled
    public static String getProjectId(String sovId){
        
        buildertek__Schedule_of_Values__c project = [select Id, Name,buildertek__Project__c from buildertek__Schedule_of_Values__c WHERE Id =: sovId];
        
        return project.buildertek__Project__c;
    }
    
    
    @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSovType(String sovId){
        
        buildertek__Schedule_of_Values__c SOVType = [select Id, Name,buildertek__Type__c, buildertek__Status__c, RecordTypeId, recordtype.name from buildertek__Schedule_of_Values__c WHERE Id =: sovId];
        
        return SOVType;
    }
}