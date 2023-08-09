public class FieldSetController {
     /*
     * @Created Date:- 2nd OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : editBudget
     * @ReturnType : list
     * @param : objectName, fieldSetName
     * @Description : Get the fields from FieldSet
    */
    @AuraEnabled
    public static List<FieldSetMember> getFields(String objectName, String fieldSetName) {
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(objectName);
        Schema.DescribeSObjectResult describe = objectType.getDescribe();
        Map<String, Schema.FieldSet> fieldSetMap = describe.fieldSets.getMap();
        Schema.FieldSet fieldSet = fieldSetMap.get(fieldSetName);
        List<Schema.FieldSetMember> fieldSetList = fieldSet.getFields();
        List<FieldSetMember> fieldSetFieldsList = new List<FieldSetMember>();
        for (Schema.FieldSetMember f: fieldSetList) {
            fieldSetFieldsList.add(new FieldSetMember(f));
        }
        return fieldSetFieldsList;
    }
    
    /*
     * @Description : Wrapper class contains the information about all the fields of a FieldSet
    */ 
    
    public class FieldSetMember {
    
        public FieldSetMember(Schema.FieldSetMember fsMember) {
            this.DBRequired = fsMember.DBRequired;
            this.fieldPath = fsMember.fieldPath;
            this.label = fsMember.label;
            this.required = fsMember.required;
            this.type = '' + fsMember.getType();
        }
        
        public FieldSetMember(Boolean DBRequired) {
            this.DBRequired = DBRequired;
        }
        
        @AuraEnabled
        public Boolean DBRequired { get;set; }
        
        @AuraEnabled
        public String fieldPath { get;set; }
        
        @AuraEnabled
        public String label { get;set; }
        
        @AuraEnabled
        public Boolean required { get;set; }
        
        @AuraEnabled
        public String type { get; set; }
    }
}