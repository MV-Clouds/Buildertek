
public with sharing class MultiSelectLookupController {

    @AuraEnabled
    public static List<RecordsData> fetchRecords(String objectName, String filterField, String searchString, String values, String containerForExtraId1, String containerForExtraId2) {
        try {
            System.debug('containerForExtraId1 '+containerForExtraId1);
            System.debug('containerForExtraId2 '+containerForExtraId2);
            List<RecordsData> recordsDataList = new List<RecordsData>();
            Set<String> idDuplicatePreventionMap = new Set<String>();
            List<String> selectedvalues = (List<String>) JSON.deserialize(values, List<String>.class);
            String query = 'SELECT Id, ' + filterField + ' FROM '+objectName;
            if(selectedvalues != null && selectedvalues.size() > 0) {
                query += ' WHERE Id IN: selectedvalues LIMIT 49999';
            } else {
                if (objectName == 'buildertek__Checklist_Questions__c') {
                    query += ' WHERE buildertek__Checklist_Configuration__c =:containerForExtraId1 AND buildertek__Questions__r.buildertek__Section__c =:containerForExtraId2 AND buildertek__Questions__r.buildertek__Sub_Section__c != null AND '+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                } else {
                    query += ' WHERE '+filterField+
                            ' LIKE ' + '\'' + String.escapeSingleQuotes(searchString.trim()) + '%\' LIMIT 49999';
                }
            }

            System.debug('query '+query);
            if (objectName == 'buildertek__Checklist_Questions__c') {
                System.debug('before querying ');
                List<buildertek__Checklist_Questions__c> listName = Database.query(query);
                for(buildertek__Checklist_Questions__c s : Database.query(query)) {
                    if (!idDuplicatePreventionMap.contains(s.buildertek__Questions__r.buildertek__Sub_Section__r.Id)) {
                        idDuplicatePreventionMap.add(s.buildertek__Questions__r.buildertek__Sub_Section__r.Id);
                        recordsDataList.add( new RecordsData(s.buildertek__Questions__r.buildertek__Sub_Section__r.Name, s.buildertek__Questions__r.buildertek__Sub_Section__r.Id) );
                    }
                }
            } else {
                for(SObject s : Database.query(query)) {
                    recordsDataList.add( new RecordsData((String)s.get(filterField), (String)s.get('id')) );
                }
            }
            return recordsDataList;
	    } catch (Exception err) {
	    	if ( String.isNotBlank( err.getMessage() ) && err.getMessage().contains( 'error:' ) ) {
                throw new AuraHandledException(err.getMessage().split('error:')[1].split(':')[0] + '.');
            } else {
                throw new AuraHandledException(err.getMessage());
            }
	    }
    }

    public class RecordsData {
        @AuraEnabled public String label;
        @AuraEnabled public String value;
        public RecordsData(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
}
