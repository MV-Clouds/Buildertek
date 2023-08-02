public with sharing class customLookUpController {
    @AuraEnabled
    public static List < sObject > fetchLookUpValues(String searchKeyWord, String ObjectName, String parentRecordId) {
        system.debug('ObjectName-->' + ObjectName);
        String searchKey = '%'+ searchKeyWord + '%';
        
        List < sObject > returnList = new List < sObject > ();
        String sQuery;
        system.debug('Schema.getGlobalDescribe().get(ObjectName)---->'+Schema.getGlobalDescribe().get(ObjectName));
        if(ObjectName != null && ObjectName.trim() != '' && Schema.getGlobalDescribe().get(ObjectName) != null){
            // Create a Dynamic SOQL Query For Fetch Record List with LIMIT 5  
            if(ObjectName == 'buildertek__Cost_Codes__c'){
                sQuery =  'select id,Name, buildertek__Cost_Code_Name__c from ' +ObjectName + ' where Name LIKE: searchKey order by Name ASC limit 5';    
            }else if(ObjectName == 'buildertek__Budget_Item__c'){
                sQuery =  'select id,Name,buildertek__Budget__c  from ' +ObjectName + ' where buildertek__Budget__c =:parentRecordId AND Name LIKE: searchKey order by Name ASC limit 5';  
            }else{
                sQuery =  'select id, Name from ' +ObjectName + ' where Name LIKE: searchKey order by Name ASC ';    
            }
            List < sObject > lstOfRecords = Database.query(String.escapeSingleQuotes(sQuery));
            
            for (sObject obj: lstOfRecords) {
                returnList.add(obj);
            }
        }
        return returnList;
    }
}