public with sharing class FieldSetFormController {
    @AuraEnabled
    public static FieldSetForm getForm(Id recordId, String objectName, String fieldSetName) {
        FieldSetForm form = new FieldSetForm();        
        form.Fields = getFields(recordId, objectName, fieldSetName);
        
        return form;
    }
    @AuraEnabled
    public static buildertek__RFQ__c saveRFQ(){
        system.debug('acc');
        // insert rfqRec;
        // return rfqRec;
        return null;
    }
    
     @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews;
        if(Schema.sObjectType.ListView.fields.id.isAccessible()
            && Schema.sObjectType.ListView.fields.Name.isAccessible()
            && Schema.sObjectType.ListView.fields.SobjectType.isAccessible()){
            
            listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__RFQ__c'];    
        }
        return listviews;
    }
    
    @AuraEnabled
    public static void saveDetails (/*buildertek__RFQ__c rfqRec, String recordId*/){
        
        /*if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isCreateable()) {
            rfqRec.buildertek__Project__c = recordId;
            INSERT rfqRec;    
        }*/
        
        // return rfqRec;
    }


    private static List<Field> getFields(Id recordId, String objectName, String fieldSetName) {
        Schema.SObjectType objectType = null;
        
        if (recordId != null) {
            objectType = recordId.getSobjectType();
        }
        else if (String.isNotBlank(objectName)) {
            objectType = Schema.getGlobalDescribe().get(objectName);
        }
        
        Schema.DescribeSObjectResult objectDescribe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = objectDescribe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetMembers = fieldSet.getFields();

        List<Field> fields = new List<Field>();
        for (Schema.FieldSetMember fsm : fieldSetMembers) {
            Field f = new Field(fsm);

            fields.add(f);
        }

        return fields;
    }
    
    public class FieldSetForm {
        @AuraEnabled
        public List<Field> Fields { get; set; }

        public FieldSetForm() {
            Fields = new List<Field>();
        }
    }
}