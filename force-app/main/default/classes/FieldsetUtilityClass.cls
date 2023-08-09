public class FieldsetUtilityClass {

    /**
     * This method is responsible to return list of fields (label, api and type) avaliable
     * under field set of an object passed as parameters.
     * */
    public static List<FieldSetProperties> getFieldFromFieldSet(String objApi, String fieldSetName){
        List<FieldSetProperties> lstOfWrapper = new List<FieldSetProperties>();
        
        Schema.SObjectType sObjType = Schema.getGlobalDescribe().get(objApi);
        Schema.DescribeSObjectResult desSObjRslt = sObjType.getDescribe();            
        Schema.FieldSet fieldSetIns = desSObjRslt.FieldSets.getMap().get(fieldSetName);
        
        for( Schema.FieldSetMember fieldSetMember : fieldSetIns.getFields() ){
            FieldSetProperties wrapperIns = new FieldSetProperties();
            
            wrapperIns.label = String.valueOf(fieldSetMember.getLabel()); 
            wrapperIns.fieldName = String.valueOf(fieldSetMember.getFieldPath()); 
            wrapperIns.type = String.valueOf(fieldSetMember.getType()).toLowerCase();
            
            lstOfWrapper.add(wrapperIns);
        }        
        
        return lstOfWrapper;
    }
    
    /**
     * Wrapper class to hold fieds properties like label, field api and field type.
     * */
    public class FieldSetProperties{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
    }
}