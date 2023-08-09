public with sharing class CreateSalesInvoiceController {
    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult d = objToken.getDescribe();
        Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
        if (FsMap.containsKey(fieldSetName)){
            for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                if (result != ''){
                    result += ',';
                }
                String jsonPart = '{';
                jsonPart += '"label":"' + f.getLabel()+'",';
                jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                jsonPart += '"type":"' + (f.getType())+'",';
                jsonPart += '"name":"' + f.getFieldPath()+'"';
                if (String.valueOf(f.getType()) == 'PICKLIST'){
                    pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                    jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                }
                jsonPart += '}';
                result += jsonPart;
            }
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
    public static String saveRecord(String salesInvoiceData){
        buildertek__Billings__c salesInvoice = (buildertek__Billings__c)JSON.deserialize(salesInvoiceData, buildertek__Billings__c.class);
        insert salesInvoice;
        return salesInvoice.Id;
    }
    @AuraEnabled
    public static String getobjectNames(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }

}