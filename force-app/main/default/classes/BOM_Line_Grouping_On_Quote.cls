public with sharing class BOM_Line_Grouping_On_Quote {

    @AuraEnabled(cacheable=true)
    public static quoteLineWrapperClass getQuoteData(String quoteId, Integer pageNumber, Integer recordToDisply, List<String> groupingList){
        quoteLineWrapperClass mainWrapper = new quoteLineWrapperClass();
        Integer pageSize = recordToDisply;
        Integer offset = (pageNumber - 1) * pageSize;
        List<String> gorupingFieldList = new List<String>{'id','buildertek__Build_Phase__c', 'buildertek__Build_Reference_1__c','buildertek__Base_Location__c','buildertek__Location_Picklist__c','buildertek__Location_Detailed_Area__c','buildertek__Location_Detail_Reference_1__c','buildertek__BL_SERVICE_CATEGORY__c'};
        String apiString = '';

        List<BT_Lightning_Utils.dataTableFields> column = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Quote_Item__c', 'buildertek__BT_Related_List_View_Fields');
        for(BT_Lightning_Utils.dataTableFields s : column){
            if (!gorupingFieldList.contains(s.fieldName)) {
                apiString += s.fieldName + ', ';
            }
        }
        String query = 'SELECT Id, '+apiString+' buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Build_Reference_1__c, buildertek__Base_Location__c, buildertek__Location_Picklist__c, buildertek__Location_Detailed_Area__c, ';
        query += 'buildertek__Location_Detail_Reference_1__c, buildertek__BL_SERVICE_CATEGORY__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =\''+quoteId+'\''+' ORDER BY '+groupingList[0];
        if (groupingList.size() > 1) {
            query += ', '+groupingList[1];
        }
        if (groupingList.size() > 2) {
            query += ', '+groupingList[2];
        }
        if (groupingList.size() > 3) {
            query += ', '+groupingList[3];
        }
        query += ' NULLS LAST';

        List<buildertek__Quote_Item__c> quoteLineList = Database.query(query);

        Integer totalQuoteLine = [SELECT count() FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :quoteId];

        mainWrapper.quoteLineList = quoteLineList;
        mainWrapper.columns = column;
        mainWrapper.pageSize = recordToDisply;
        mainWrapper.pageNumber = pageNumber;
        mainWrapper.total = totalQuoteLine;

        return mainWrapper;

    }


    public class quoteLineWrapperClass{

        @AuraEnabled
        public List<buildertek__Quote_Item__c> quoteLineList;
    
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;
    
        @AuraEnabled
        public Integer pageSize{ get; set; }
    
        @AuraEnabled
        public Integer pageNumber{ get; set; }
    
        @AuraEnabled
        public Integer total{ get; set; }
    }
    
}