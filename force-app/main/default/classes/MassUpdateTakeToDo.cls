public class MassUpdateTakeToDo{
    Public String recordId{ get; set; }
    
    Private ApexPages.StandardController controller;
    
    Public MassUpdateTakeToDo(){
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    @AuraEnabled
    public static string getName(String recordId){
        try{
            List<buildertek__To_Do__c> toDo = [Select Id, Name
                                               From buildertek__To_Do__c
                                               WHERE Id = :recordId];
            if (toDo.size() > 0){
                return toDo[0].Name;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String getRecords(String parentRecordId, String fieldNameJson){
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
            Set<String> setFieldNames = new Set<String>();
            String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__To_Do_Items__c';
            query += ' WHERE buildertek__To_Do__c= : parentRecordId ORDER BY Name ASC NULLS LAST';
            for (sObject s : Database.query(query)){
                lstResult.add(s);
            }
            if (lstResult.size() > 0){
                result = JSON.serialize(lstResult);
            }
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Result::' + result);
        }
        return result;
    }
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__To_Do_Items__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__To_Do_Items'))
                for (Schema.FieldSetMember f : FsMap.get('buildertek__To_Do_Items').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__To_Do_Items__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
        }
        return '[' + result + ']';
    }
    
    
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String updateToDoItems(String recordId, String updatedToDoItems, String fieldSetName){
        try{

            System.debug('updatedToDoItems ==>');
            System.debug(updatedToDoItems);

            System.debug('fieldSetName ==>');
            System.debug(fieldSetName);

            if (String.isNotBlank(updatedToDoItems)){
                List<buildertek__To_Do_Items__c> items = (List<buildertek__To_Do_Items__c>)JSON.deserialize(updatedToDoItems, List<buildertek__To_Do_Items__c>.class);                
                System.debug('items ==>');
                System.debug(items);

                upsert items;
                return getRecords(recordId, fieldSetName);
            }
        } catch (Exception e){
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
}