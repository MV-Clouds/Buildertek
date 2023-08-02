public with sharing class SearchCompany {
    
    @AuraEnabled
    public static List<Account> searchAccount(String searchTerm){
        System.debug('Search Item'+searchTerm);
        List<Account> queryresult;    
        
            String queryList ='Select Id ,Name,Phone from Account where Name like \''+searchTerm+'%\' order by Name asc  limit 10';     
            queryresult = Database.query(queryList);
                    return queryresult;
    }
}