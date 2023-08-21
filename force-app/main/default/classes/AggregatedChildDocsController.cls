public without sharing class AggregatedChildDocsController {

    @AuraEnabled
    public static   Map<String , String>  getChildObectName(String projectId){
        List<String> childObjeNameList = new  List<String>();
        List<String> chilRelationName = new  List<String>();
        List<sObject> sobj= new List<sObject>();
        Map<String , String> sObjectNameMap =new  Map<String , String>();
        List<AggregateResult> aggregateAttachmentParent = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment  GROUP BY Parent.Type];   
        Map<String, String> parentTypeToRelationMap = new Map<String, String>();

        for (ChildRelationship relationship : SObjectType.buildertek__Project__c.getChildRelationships()) {

            // childObjeNameList.add(relationship.getChildSObject().getDescribe().getName());
            // parentTypeToRelationMap.put(relationship.getChildSObject().getDescribe().getName(), relationship.getRelationshipName());
            sObjectNameMap.put(relationship.getChildSObject().getDescribe().getName() , relationship.getChildSObject().getDescribe().getLabel());

        }
    
        // List<String> sQuery = new List<String>();
        // for(String s:childObjeNameList){
        //     String query='Select Id , ContentDocumentId , LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId IN (SELECT Id FROM '+s+' WHERE buildertek__Project__c=:projectId)';
        //     sQuery.add(query);
        // }
        // System.debug(sQuery);

        // List<sObject> lstOfRecords = Database.queryAll(sQuery);
        // System.debug(lstOfRecords);

      
        // List<ContentDocumentLink> ContentDocumentLinkList= [SELECT Id , ContentDocumentId , LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId IN:parentIdList];
        // List<AggregateResult> aggregatedResults= [SELECT COUNT(Id) recordsCount  , LinkedEntity.Type parentType  FROM ContentDocumentLink  WHERE LinkedEntityId IN:parentIdList GROUP BY  LinkedEntity.Type];

        // System.debug(aggregatedResults);
        

    
        // List<AggregateResult> aggregatedResults = [SELECT COUNT(Id) recordsCount, Parent.Type parentType FROM Attachment  WHERE Parent.Type IN :childObjeNameList GROUP BY Parent.Type];   
        // for (AggregateResult result : aggregatedResults) {
        //     sObjectNameList.add((String) result.get('parentType'));
        // }
        // System.debug(sObjectNameList);
        return sObjectNameMap; 
    }

    
    
    public class contntDocumentLinkWrapp {
        @AuraEnabled
        public String ContentDocumentId;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ParentId;
        @AuraEnabled
        public String ParentName;
    } 
    
    @AuraEnabled
    public static  List<contntDocumentLinkWrapp> getAttachement(String objectName , String projectId){

        String query='Select Id , ContentDocumentId , LinkedEntityId  FROM ContentDocumentLink  WHERE LinkedEntityId IN (SELECT Id FROM '+objectName+' WHERE buildertek__Project__c=:projectId)';
        List<sObject> lstOfRecords = Database.query(query);

        List<contntDocumentLinkWrapp> documentWrapList = new List<contntDocumentLinkWrapp>();

        Map<Id, Id> mapDemo= new Map<Id,  Id>();
        List<Id> cntDocLinkIdList= new List<Id>();

        for(sObject cdLink: lstOfRecords){
            cntDocLinkIdList.add((Id)cdLink.get('LinkedEntityId'));
            mapDemo.put((Id)cdLink.get('ContentDocumentId') , (Id)cdLink.get('LinkedEntityId'));
        }

        System.debug(cntDocLinkIdList);
        System.debug(cntDocLinkIdList.size());

        if(cntDocLinkIdList.size() > 0){
            
            List<ContentDocumentLink> cntDocumentList=[Select Id , ContentDocumentId , ContentDocument.Title, LinkedEntityId , LinkedEntity.Name   FROM ContentDocumentLink  WHERE LinkedEntityId IN: cntDocLinkIdList AND ContentDocumentId IN:mapDemo.keySet() LIMIT 800];
            for(ContentDocumentLink cntDoc:cntDocumentList){
                contntDocumentLinkWrapp wrap= new contntDocumentLinkWrapp();
                wrap.ContentDocumentId=cntDoc.ContentDocumentId;
                wrap.Name= cntDoc.ContentDocument.Title;
                wrap.ParentId= cntDoc.LinkedEntityId; 
                wrap.ParentName= cntDoc.LinkedEntity.Name ;
                documentWrapList.add(wrap);
            }
            return documentWrapList;
        }else{
            return null;
        }

    
    }
   
}