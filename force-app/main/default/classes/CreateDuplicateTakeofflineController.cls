public with sharing class CreateDuplicateTakeofflineController {
    @AuraEnabled
    public static buildertek__Project_Takeoff_Lines__c cloneTakeOffLine(String recordId) 
    {
        buildertek__Project_Takeoff_Lines__c clonedTakeOffLine = new buildertek__Project_Takeoff_Lines__c();

        if(String.isNotBlank(recordId))
        {
            Map < String, Schema.SObjectType > schemaMap = Schema.getGlobalDescribe();
            String objectAPIName = '';
            String keyPrefix = recordId.substring(0, 3);
            /*for (Schema.SObjectType obj: schemaMap.Values()) {
                String prefix = obj.getDescribe().getKeyPrefix();
                if (String.isNotBlank(prefix) && String.isNotBlank(keyPrefix) && prefix.equals(keyPrefix) ) {
                    objectAPIName = obj.getDescribe().getName();
                    break;
                }
            }*/
            objectAPIName = 'buildertek__Project_Takeoff_Lines__c';
		    System.debug('objectAPIName---'+objectAPIName);
            Set < String > fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
            String soqlQuery = 'SELECT ';
            for (String s: fieldMap) {
                if (schema.getGlobalDescribe().get(objectAPIName).getDescribe().fields.getMap().get(s).getDescribe().isAccessible()) {
                    soqlQuery += +s + ',';
                }
            }
            soqlQuery = soqlQuery.removeEnd(',');
            soqlQuery += ' FROM ' + objectAPIName + ' WHERE ID = \'' + recordId + '\'';
            System.debug('soqlQuery--' + soqlQuery);
		    SObject record = Database.query(soqlQuery); 
		    SObject clondedParentRecord = record.clone(false, true, false, false);
		    System.debug('Clone---'+clondedParentRecord);
            clonedTakeOffLine = (buildertek__Project_Takeoff_Lines__c)clondedParentRecord;
        }
		return clonedTakeOffLine;
    }

    @AuraEnabled
    public static String saveTakeOffLineRecord(buildertek__Project_Takeoff_Lines__c record)
    {
        String recordId;
        try 
        {
            insert record;
            recordId = record.Id;
        } catch (Exception e) 
        {
            System.debug('ERROR!!!'+e.getMessage());
        }

        return recordId;
    }

    @AuraEnabled
    public static List<buildertek__Project_Takeoff_Lines__c> getTakeOffLines(String parentId){
        System.debug('#@#@parentId--'+parentId);
        List<buildertek__Project_Takeoff_Lines__c> takeOffLineList = new List<buildertek__Project_Takeoff_Lines__c>();
        if(String.isNotBlank(parentId))
        {
            takeOffLineList = [Select Id, Name from buildertek__Project_Takeoff_Lines__c  where buildertek__Project_Takeoff__c =: parentId ];
            
        }
        System.debug('#@#@takeOffLineList--'+takeOffLineList);
        return takeOffLineList;
    }
}