public with sharing class SearchController {
    @AuraEnabled
    public static List<sObject> search(String objectName, List<String> fields, String searchTerm){
        system.debug('search'+searchTerm);
        String searchKeyword = searchTerm + '*';
        String returningQuery = '';
        returningQuery = objectName+' ( Id, '+String.join(fields,',')+')';
        String query = 'FIND :searchKeyword IN ALL FIELDS RETURNING '+returningQuery+' LIMIT 20';
        System.debug(' query '+query);
        List<List<sObject>> searchRecords = Search.Query(Query);
        system.debug('searchRecords--->'+searchRecords.get(0));
        return searchRecords.get(0); 
    }
    @AuraEnabled
    public static List<Contact> searchContact(String searchTerm){
        System.debug('Search Item'+searchTerm);
        List<Contact> queryresult;    
        if(searchTerm!=null){
            String queryList ='Select Id ,Name, LastName, Email from Contact where Name like \''+searchTerm+'%\' order by Name asc  limit 10';     
            queryresult = Database.query(queryList);
        }
        return queryresult;
    }
}