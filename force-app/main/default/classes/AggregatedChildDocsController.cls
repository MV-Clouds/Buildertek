public without sharing class AggregatedChildDocsController {

    @AuraEnabled
    public static void getChildName(){
        List<String> relationName= new List<String>();
        for (ChildRelationship relation : SObjectType.buildertek__Project__c.getChildRelationships())
        {
            String relationshipName = relation.getRelationshipName();
            System.debug(relationshipName);
            relationName.add(relationshipName);
            // the above value is what you would use in a SOQL sub-query
            // e.g. SELECT Id, (SELECT Id FROM Children) FROM MyObject
        
            // SObjectType childType = relation.getChildSObject();
            // the above value is the token for the child object
        
            // SObjectField lookupField = relation.getField();
            // the above value is the token for the lookup field on the child object

            // System.debug(relationshipName);
            // System.debug(lookupField);

        }
        System.debug(relationName.size());

        
    }
   
}