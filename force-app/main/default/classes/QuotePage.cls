public without sharing class QuotePage {
    public QuotePage() {

    }

    @AuraEnabled
    public static allData getallData(Id quoteId) {

        try{

            allData ad = new allData();

            ad.OrgCurrency = UserInfo.getDefaultCurrency();

            List<BT_Lightning_Utils.dataTableFields> Quotecolumn = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Quote__c', 'buildertek__QuotePage');
            ad.Quotecolumns = Quotecolumn;

            String quoteFields = '';
            for(BT_Lightning_Utils.dataTableFields dt : Quotecolumn){
                if(dt.fieldName != 'Id' && dt.fieldName != 'Name' && dt.fieldName != 'buildertek__Project__r.Name'){
                    quoteFields += dt.fieldName + ',';
                }
            }
            quoteFields = quoteFields.removeEnd(',');

            String quoteQuery = 'SELECT Id, Name, buildertek__Project__r.Name, ' + quoteFields;
            quoteQuery += ' FROM buildertek__Quote__c WHERE Id =\'' + quoteId + '\'';
            System.debug('quoteQuery: ' + quoteQuery);

            buildertek__Quote__c  quote = Database.query(quoteQuery);
            ad.quote = quote;
    
            String apiString = '';
    
            List<BT_Lightning_Utils.dataTableFields> column = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Quote_Item__c', 'buildertek__BT_Related_List_View_Fields');
            System.debug('column: ' + column);
            ad.columns = column;
    
            for(BT_Lightning_Utils.dataTableFields s : column){
                if(s.type == 'Reference'){
                    s.fieldName = s.fieldName.substringBefore('__c')+'__r.Name';
                }
                apiString += s.fieldName + ', ';
            }
    
            String query = 'SELECT Id, ' + apiString;
            query += 'buildertek__Grouping__c, buildertek__Grouping__r.Name, buildertek__Grouping__r.buildertek__Sort_Id__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =\'' + quoteId + '\'';
            query += ' ORDER BY buildertek__Grouping__r.buildertek__Sort_Id__c NULLS Last, buildertek__Grouping__r.Name, buildertek__Priority__c ASC NULLS Last , Name ASC';
    
            System.debug('query: ' + query);
    
            List<buildertek__Quote_Item__c> quoteLineList = Database.query(query);
            System.debug('quoteLineList: ' + quoteLineList);
            ad.quoteLineList = quoteLineList;

            ad.Status = 'Success';
            
            return ad;
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            allData ad = new allData();
            ad.Status = 'Error' + ex.getMessage() + ex.getStackTraceString();
            return ad;
        }

    }

    @AuraEnabled
    public static List<buildertek__Quote_Item__c> massUpdateQuote(String Quote) {
        try {
            System.debug('Quote: ' + Quote);
            List<buildertek__Quote_Item__c> quoteItemList = [SELECT Id, Name, buildertek__Quantity__c, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Tax__c, buildertek__Notes__c, buildertek__Quote__r.Name, buildertek__Grouping__c, buildertek__Grouping__r.Name, buildertek__Grouping__r.buildertek__Sort_Id__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :Quote ORDER BY buildertek__Grouping__r.buildertek__Sort_Id__c NULLS LAST, buildertek__Grouping__r.Name, buildertek__Priority__c ASC NULLS LAST , Name ASC];
            
            return quoteItemList;
        } catch(Exception e) {
            System.debug(e.getMessage());
            BT_ExceptionHandler.Store_Exception(e);
            return new List<buildertek__Quote_Item__c>();
        }
    }

    @AuraEnabled
    public static String massUpdateQuoteItem(String QuoteItems) {
        try {
            List<QuoteItemWrapper> quoteItemsList = (List<QuoteItemWrapper>) JSON.deserialize(QuoteItems, List<QuoteItemWrapper>.class);
            List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();

            for (QuoteItemWrapper quoteItemWrapper : quoteItemsList) {
                buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
                quoteItem.Id = quoteItemWrapper.QuoteItemId;
                quoteItem.Name = quoteItemWrapper.Name;
                quoteItem.buildertek__Quantity__c = quoteItemWrapper.Quantity;
                quoteItem.buildertek__Unit_Cost__c = quoteItemWrapper.UnitCost;
                quoteItem.buildertek__Markup__c = quoteItemWrapper.Markup;
                quoteItem.buildertek__Tax__c = quoteItemWrapper.Tax;
                quoteItem.buildertek__Notes__c = quoteItemWrapper.notes;

                quoteItemList.add(quoteItem);
            }
            
            update quoteItemList;
            return 'Success';

        } catch(Exception e) {
            System.debug('Error: ' + e.getMessage());
            BT_ExceptionHandler.Store_Exception(e);
            return 'Error: ' + e.getMessage();
        }
    }

    public class allData{

        @AuraEnabled
        public string OrgCurrency;

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> Quotecolumns;

        @AuraEnabled
        public buildertek__Quote__c Quote;

        @AuraEnabled
        public List<buildertek__Quote_Item__c> quoteLineList;

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns;

        @AuraEnabled
        public string status;
    }

    public class QuoteItemWrapper {
        @AuraEnabled public String QuoteItemId;
        @AuraEnabled public String Name;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public Decimal UnitCost;
        @AuraEnabled public Decimal Markup;
        @AuraEnabled public Decimal Tax;
        @AuraEnabled public String Notes;
    }
}