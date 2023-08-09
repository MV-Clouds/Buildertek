public class ClonedOrderPOFromProjectController {
    
    /*  @AuraEnabled
public static String getobjectName(Id recordId){
String sObjName = recordId.getSObjectType().getDescribe().getName();  
return sObjName;
}  */
    
    @AuraEnabled
    public static POInnerClass getFieldSet(String objectName, String fieldSetName, String recordId){
        system.debug('objectName---------->'+objectName);
        system.debug('fieldSetName------>'+fieldSetName);
        String result = '';
        List<String> pickListValuesList = new List<String>();
        SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult d = objToken.getDescribe();
        Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
        
        
        List<String> FieldsList = new List<String>();
        
        if (FsMap.containsKey(fieldSetName)){
            for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                if (result != ''){
                    result += ',';
                }
                String jsonPart = '{';
                jsonPart += '"label":"' + f.getLabel()+'",';
                jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                jsonPart += '"type":"' + (f.getType())+'",';
                system.debug('f.getFieldPath()--------->'+f.getFieldPath());
                FieldsList.add(f.getFieldPath());
                jsonPart += '"name":"' + f.getFieldPath()+'"';
                if (String.valueOf(f.getType()) == 'PICKLIST'){
                    pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                    jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                }
                jsonPart += '}';
                result += jsonPart;
          
            }
        }
        
        
        POInnerClass POInner = new POInnerClass ();
        
        List<buildertek__Purchase_Order__c> MainpoRecList = new List<buildertek__Purchase_Order__c>();
        
        // Dynamic Query String.
         MainpoRecList = Database.query('SELECT Id,' + String.join(FieldsList, ',') + ' FROM '+ objectName + ' WHERE buildertek__Project__c =: recordId');
        
        POInner.headers = '[' + result + ']';
        POInner.poRecordList = MainpoRecList;
        
        return POInner;
    }
    
    
    
    public class POInnerClass{
        @AuraEnabled
        public String headers {get;set;}
        
        @AuraEnabled
        public List<buildertek__Purchase_Order__c> poRecordList {get;set;}
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
    
    
}