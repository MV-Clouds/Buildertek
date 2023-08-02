public with sharing class CreateCDFromPR {

    @AuraEnabled 
     public static String getFieldSet(String objectName, String fieldSetName){

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
     public static buildertek__Payment_Request__c getParentRecord( String parentRecordId){
        System.debug('currentRecordId => ' + parentRecordId);
        buildertek__Payment_Request__c ParRecord;
        try {
            ParRecord = [SELECT Id, Name, buildertek__Amount__c, buildertek__Payment_Method__c, buildertek__BT_Contractor_Invoice_PO__c, buildertek__Effective_Date__c, buildertek__BT_Purchase_Order__c FROM buildertek__Payment_Request__c WHERE Id =: parentRecordId LIMIT 1];
        } catch (Exception e) {
            system.debug('Error => ' + e);
            throw new AuraHandledException(e.getMessage());
        }
         return ParRecord;
     }

     @AuraEnabled
     public static String saveRecord(String CashDisbursementData){
        try{
            // Map<String, Object> jsonResponseMap = (Map<String, Object>) JSON.deserializeUntyped(CashDisbursementData);
            buildertek__Payment__c CashDisbursement = (buildertek__Payment__c)JSON.deserialize(CashDisbursementData, buildertek__Payment__c.class);

            // buildertek__Payment__c CashDisbursement = new buildertek__Payment__c();
            // CashDisbursement.buildertek__Payment_Amount__c = (Decimal) jsonResponseMap.get('buildertek__Payment_Amount__c');
            // CashDisbursement.buildertek__Payment_Date__c = Date.valueOf(((String) jsonResponseMap.get('buildertek__Payment_Date__c')).replace('T18:00:00.000Z',''));
            // CashDisbursement.buildertek__Reference__c = (String) jsonResponseMap.get('buildertek__Reference__c');
            // CashDisbursement.buildertek__Payable__c = (String) jsonResponseMap.get('buildertek__Payable__c');
            // CashDisbursement.buildertek__Type__c = (String) jsonResponseMap.get('buildertek__Type__c');
            
            insert CashDisbursement;

            return CashDisbursement.Id;
        }
        catch(Exception e){
            System.debug('error in saveRecord => ' + e);
            return null;
        }
     }
    
}