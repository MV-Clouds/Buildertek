public without sharing class AggregatedChildDocsController {

    @AuraEnabled
    public static  Map<String , String> getChildObectName(){
        Map<String , String> sObjectNameMap =new Map<String , String>();
        for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()) {
            sObjectNameMap.put(relationship.getChildSObject().getDescribe().getName() , relationship.getChildSObject().getDescribe().getLabel());
        }
        return sObjectNameMap; 
    }

    
    
    public class contntDocumentLinkWrapp {
        // @AuraEnabled
        // public String ContentDocumentId;
        // @AuraEnabled
        // public String Name;
        // @AuraEnabled
        // public String ParentId;
        // @AuraEnabled
        // public String ParentName;
        @AuraEnabled public List<ContentDocumentLink> records;
        @AuraEnabled public Integer totalPages;
        // @AuraEnabled public  String orgBaseURL;


        
    } 
    
    @AuraEnabled
    public static  contntDocumentLinkWrapp getAttachement(String objectName , String projectId ,Integer page, Integer pageSize){
        if(objectName !=null){
            // Replace 'Your_Object_API_Name' with the actual API name of the object you're working with
            String objectApiName = objectName;
            // Get the describe result for the object
            Schema.DescribeSObjectResult objectDescribe = Schema.getGlobalDescribe().get(objectApiName).getDescribe();
            // Find the correct API name for the Project reference field dynamically
            String projectReferenceFieldApiName = null;
            for (Schema.SObjectField field : objectDescribe.fields.getMap().values()) {
                Schema.DescribeFieldResult fieldDescribe = field.getDescribe();
                // Check if the field is of reference type and points to the Project object
                if (fieldDescribe.getType() == Schema.DisplayType.REFERENCE &&
                fieldDescribe.getReferenceTo().size() == 1 &&
                fieldDescribe.getReferenceTo()[0].getDescribe().getName() == 'buildertek__Project__c') {
                    projectReferenceFieldApiName = fieldDescribe.getName();
                    break; // Found the correct reference field, no need to continue the loop
                }
            }
            if (projectReferenceFieldApiName != null) {
                
                String query = 'SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT Id FROM ' + objectApiName + ' WHERE ' + projectReferenceFieldApiName + ' = :projectId)';
                List<sObject> lstOfRecords = Database.query(query);
                List<contntDocumentLinkWrapp> documentWrapList = new List<contntDocumentLinkWrapp>();
                List<Id> cntDocLinkIdList= new List<Id>();
                Map<String, List<ContentDocumentLink>> parentIdToDocuments = new Map<String, List<ContentDocumentLink>>();

        
                for(sObject cdLink: lstOfRecords){
                    cntDocLinkIdList.add((Id)cdLink.get('LinkedEntityId'));
                }
                if(cntDocLinkIdList.size() > 0){
                    List<ContentDocumentLink> cntDocumentList=[Select Id , ContentDocumentId ,LinkedEntity.Type,  ContentDocument.Title, LinkedEntityId , LinkedEntity.Name   FROM ContentDocumentLink  WHERE LinkedEntityId IN:cntDocLinkIdList  AND ContentDocumentId NOT IN(SELECT Id FROM ContentDocument WHERE Title LIKE 'Signature%') LIMIT :pageSize OFFSET :((page - 1) * pageSize)];
                    contntDocumentLinkWrapp wrap= new contntDocumentLinkWrapp();
                    wrap.records = cntDocumentList;
                    wrap.totalPages = (Integer)Math.ceil([SELECT count() FROM ContentDocumentLink WHERE LinkedEntityId IN: cntDocLinkIdList AND ContentDocumentId NOT IN(SELECT Id FROM ContentDocument WHERE Title LIKE 'Signature%')] / (Decimal)pageSize);
                    // wrap.orgBaseURL= URL.getSalesforceBaseUrl().toExternalForm();
    
                    return wrap;
            
                }else{
                    return null;
                }
            } else {
                System.debug('No Project reference field found on the object.');
                return null;
            }
        }else{
            return null;
        }
    }

}