public class getRelatedListsController {
    @auraEnabled
    public static list<itemList> getTreeList(string projectId) {
       
        list<itemList> l=new list<itemList>();
        list<String> relatedObjectList = new List<String>();
        for (ChildRelationship relation : SObjectType.buildertek__Project__c.getChildRelationships()){
            if(relation.getRelationshipName()!=null && relation.getRelationshipName().contains('__r') && relation.getRelationshipName() != 'buildertek__Work_Orders__r'){
                string s = relation.getRelationshipName();
                System.debug( 'reationship name---->'+s);
                relatedObjectList.add(s);
                //String query='select id,name,(select id ,Name from '+s+') from buildertek__Project__c where id='+'\''+projectId+'\'' ;
                //system.debug('query without fire()-->'+query);
                //sObject sobj=Database.query(query);
                //system.debug('query with fire() result---->'+sobj);
                /*l.add(new itemList(string.valueof(sobj.getsobjects(s).get('id')), string.valueof(sobj.getsobjects(s).get('Name'))));
                system.debug(l);*/
                
             }
        }
        System.debug( 'related List name---->'+relatedObjectList);
        System.debug( 'related List size ---->'+relatedObjectList.size());
        return l;
    }
    
    public class itemList{
        @auraEnabled public String relatedListId { get; set; }
        @auraEnabled public String relatedListName { get; set; }
        
        public itemList(String relatedListId, String relatedListName){
            this.relatedListId = relatedListId;
            this.relatedListName = relatedListName;
        }
    }
}