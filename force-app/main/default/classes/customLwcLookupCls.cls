public without sharing class customLwcLookupCls {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter,String selectedFrompar,String scheduleId) {
        String myQuery = null;
        system.debug(selectedFrompar+' '+searchTerm);
        if(myObject == 'buildertek__Project_Task__c'){ //buildertek__Project_Task__c
            if(selectedFrompar != null && selectedFrompar != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Id =:selectedFrompar AND buildertek__Schedule__c =: scheduleId ';
            }else if(filter != null && filter != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+'  AND buildertek__Schedule__c =: scheduleId LIMIT  5';
            }else {
                if(searchTerm == null || searchTerm == ''){
                    // myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL  AND buildertek__Schedule__c =: scheduleId ORDER BY LastViewedDate DESC LIMIT  5';
                    myQuery = 'Select Id, Name from '+myObject+' Where buildertek__Schedule__c =: scheduleId ORDER BY LastViewedDate DESC LIMIT  5';
                }
                else {
                    myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\'  AND buildertek__Schedule__c =: scheduleId LIMIT  5';
                }
            }
        }else{
            if(selectedFrompar != null && selectedFrompar != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Id =:selectedFrompar ';
            }else if(filter != null && filter != ''){
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT  5';
            }else {
                if(searchTerm == null || searchTerm == ''){
                    // myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC LIMIT  5';
                    myQuery = 'Select Id, Name from '+myObject+' ORDER BY LastViewedDate DESC LIMIT  5';
                }
                else {
                    myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' LIMIT  5';
                }
            }
        }
        
        system.debug('check dynamic query here& '+myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}