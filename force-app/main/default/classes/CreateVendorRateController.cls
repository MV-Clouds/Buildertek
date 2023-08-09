public with sharing class CreateVendorRateController {
    public CreateVendorRateController() {

    }

    @AuraEnabled 
    public static string getVendorAccountId(){
        string accountId = '';
        string portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, AccountId, isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            // portalCode = userRec[0].get('isPortalEnabled');
            portalCode = userRec[0].get('isPortalEnabled').toString();            
        }
        if(portalCode=='true'){
            accountId = userRec[0].get('AccountId').toString(); 
        }
        
        return accountId;
    }

    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }


    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        system.debug('objectName--->'+objectName);
        system.debug('fieldSetName--->'+fieldSetName);
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
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
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
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
    public Static LookupWrapper getParentObjRec(string parentrecordid){
        Id recordid = parentrecordid;
        string sObjName = recordid.getSObjectType().getDescribe().getName();
        string  Query;
        Query = 'select Id, Name from ' +sObjName +' where Id=:recordid';  
        SObject ObjectRec = Database.query(Query);
        LookupWrapper NewWrapperRec = new LookupWrapper();
        NewWrapperRec.LookupRec = ObjectRec;
        NewWrapperRec.ObjectName = sObjName;
        return NewWrapperRec;
    }
    Public class LookupWrapper{
        @AuraEnabled
        Public SObject LookupRec {get;set;}
        @AuraEnabled
        Public String ObjectName {get;set;}
        
    }


}