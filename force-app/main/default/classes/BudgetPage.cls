public without sharing class BudgetPage {

    @AuraEnabled
    public static string deleteBudgetLine(Id budgetItemId) {

        try{
            buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
            budgetItem.Id = budgetItemId;
            delete budgetItem;
        
            return 'Sucess';

        } catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return ex.getMessage();
        }
    }


    @AuraEnabled
    public static allData getallData(Id budgetId) {

        try{

            allData ad = new allData();

            buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Remove_Single_Quote_Line_Option__c, buildertek__Hide_Global_Margin__c, buildertek__Hide_Global_Markup__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Quote Configuration'];

            // Boolean checkSingleQLine = adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c ;
            // Boolean checkButtonMargin = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c;
            // Boolean checkButtonMarkup = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c;

            ad.checkSingleQLine = adminInterfaceNodeConfigurations.buildertek__Remove_Single_Quote_Line_Option__c;
            ad.checkButtonMargin = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Margin__c;
            ad.checkButtonMarkup = adminInterfaceNodeConfigurations.buildertek__Hide_Global_Markup__c;


            List<buildertek__Budget_Line_Group__c> BudgetItemGroupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c ORDER BY Name];
            ad.BudgetItemGroupList = BudgetItemGroupList;

            ad.OrgCurrency = UserInfo.getDefaultCurrency();

            List<BT_Lightning_Utils.dataTableFields> Budgetcolumn = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Budget__c', 'buildertek__BudgetPage');
            ad.Budgetcolumns = Budgetcolumn;

            List<BT_Lightning_Utils.dataTableFields> BudgetLinecolumn = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Budget_Item__c', 'buildertek__BT_Detail_Page_Fields');
            ad.BudgetLineFields = BudgetLinecolumn;

            String budgetFields = '';
            for(BT_Lightning_Utils.dataTableFields dt : Budgetcolumn){
                if(dt.fieldName != 'Id' && dt.fieldName != 'Name' && dt.fieldName != 'buildertek__Project__r.Name'){
                    budgetFields += dt.fieldName + ',';
                }
            }
            budgetFields = budgetFields.removeEnd(',');

            String budgetQuery = 'SELECT Id, Name, buildertek__Project__r.Name, ' + budgetFields;
            budgetQuery += ' FROM buildertek__Budget__c WHERE Id =\'' + budgetId + '\'';
            System.debug('budgetQuery: ' + budgetQuery);

            buildertek__Budget__c  budget = Database.query(budgetQuery);
            ad.Budget = budget;
    
            String apiString = '';
    
            List<BT_Lightning_Utils.dataTableFields> column = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Budget_Item__c', 'buildertek__BT_Related_List_View_Fields');
            System.debug('column: ' + column);
            ad.columns = column;
    
            for(BT_Lightning_Utils.dataTableFields s : column){
                if(s.type == 'Reference'){
                    s.fieldName = s.fieldName.substringBefore('__c')+'__r.Name';
                }
                apiString += s.fieldName + ', ';
            }
    
            String query = 'SELECT Id, ' + apiString;
            query += 'buildertek__Group__c, buildertek__Group__r.Name, buildertek__Group__r.buildertek__Sort_Id__c FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =\'' + budgetId + '\'';
            query += ' ORDER BY buildertek__Group__r.buildertek__Sort_Id__c NULLS Last, buildertek__Group__r.Name, Name ASC';
            System.debug('query: ' + query);
    
            List<buildertek__Budget_Item__c> budgetLineList = Database.query(query);
            System.debug('budgetLineList: ' + budgetLineList);
            ad.budgetLineList = budgetLineList;

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
    public static string saveBL(buildertek__Budget_Item__c BL ){
        try{
            upsert BL;
            return 'Success';
        }catch(Exception ex){
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return ex.getMessage();
        }
    }

    @AuraEnabled
    public static massUpdateQuoteItemWrapper massUpdateQuote(String Quote) {
        massUpdateQuoteItemWrapper QIWrapper = new massUpdateQuoteItemWrapper();
        try {
            List<buildertek__Quote_Item__c> quoteItemList = [SELECT Id, Name, buildertek__Quantity__c, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Tax__c, buildertek__Notes__c, buildertek__Quote__r.Name, buildertek__Grouping__c, buildertek__Grouping__r.Name, buildertek__Grouping__r.buildertek__Sort_Id__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :Quote ORDER BY buildertek__Grouping__r.buildertek__Sort_Id__c NULLS LAST, buildertek__Grouping__r.Name, buildertek__Priority__c ASC NULLS LAST , Name ASC];
            QIWrapper.QuoteItemList = quoteItemList;
            
            List<buildertek__Quote_Line_Group__c> groupingList = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c ORDER BY Name];
            QIWrapper.QuoteItemGroupList = groupingList;
            
            return QIWrapper;
        } catch(Exception e) {
            System.debug(e.getMessage());
            BT_ExceptionHandler.Store_Exception(e);
            QIWrapper.QuoteItemList = new List<buildertek__Quote_Item__c>();
            QIWrapper.QuoteItemGroupList = new List<buildertek__Quote_Line_Group__c>();
            return QIWrapper;
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
                quoteItem.buildertek__Grouping__c = quoteItemWrapper.Grouping;

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

    @AuraEnabled
    public static poDataTableWrapper getPOData(String budgetId) {
        poDataTableWrapper poData = new poDataTableWrapper();

        try {
            buildertek__Budget__c budgetRec = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c WHERE Id = :budgetId LIMIT 1];

            Boolean isMultiCurrency = UserInfo.isMultiCurrencyOrganization();

            if (isMultiCurrency) {
                String status = 'Master';
                poData.poList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__PO_Type__c, buildertek__Description__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c FROM buildertek__Purchase_Order__c WHERE buildertek__Budget__c = null AND buildertek__Budget_Line__c = null AND buildertek__Project__c = :budgetRec.buildertek__Project__c AND buildertek__PO_Type__c != :status AND Id NOT IN (SELECT buildertek__Purchase_Order__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__BT_Budget__c != null ) ORDER BY Name ASC];
            } else {
                poData.poList = [SELECT Id, Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__PO_Type__c, buildertek__Description__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__PO_Total__c FROM buildertek__Purchase_Order__c WHERE buildertek__Budget__c = null AND buildertek__Budget_Line__c = null AND buildertek__Project__c = :budgetRec.buildertek__Project__c AND buildertek__PO_Type__c != 'Master' AND Id NOT IN (SELECT buildertek__Purchase_Order__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__BT_Budget__c != null ) ORDER BY Name ASC];
            }

            poData.poItemList = [SELECT Id, Name, buildertek__Purchase_Order__r.Name, buildertek__Purchase_Order__r.buildertek__Description__c, buildertek__Purchase_Order__r.buildertek__Project__r.Name, buildertek__Purchase_Order__r.buildertek__PO_Type__c, buildertek__Purchase_Order__r.buildertek__Vendor__c, buildertek__Purchase_Order__r.buildertek__Vendor__r.Name, buildertek__Purchase_Order__r.buildertek__Project__c, buildertek__Total_Amount_Tax__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__r.buildertek__Project__c = :budgetRec.buildertek__Project__c AND buildertek__BT_Budget__c = null AND buildertek__Budget_Item__c = null AND buildertek__Purchase_Order__r.buildertek__Budget_Line__c = null AND buildertek__Purchase_Order__r.buildertek__Budget__c = null AND buildertek__Purchase_Order__r.buildertek__PO_Type__c != 'Master' ORDER BY buildertek__Purchase_Order__r.Name, Name NULLS Last];
        } catch (Exception e) {
            System.debug('Exception occurred: ' + e.getMessage());
            BT_ExceptionHandler.Store_Exception(e);
            poData = null;
        }
        return poData;
    }

    public class allData{

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> BudgetLineFields;

        @AuraEnabled
        public boolean checkSingleQLine;

        @AuraEnabled
        public boolean checkButtonMargin;

        @AuraEnabled
        public boolean checkButtonMarkup;

        @AuraEnabled
        public List<buildertek__Quote_Line_Group__c> QuoteItemGroupList;

        @AuraEnabled
        public List<buildertek__Budget_Line_Group__c> BudgetItemGroupList;

        @AuraEnabled
        public string OrgCurrency;

        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> Budgetcolumns;

        @AuraEnabled
        public buildertek__Quote__c Quote;

        @AuraEnabled
        public List<buildertek__Quote_Item__c> quoteLineList;

        @AuraEnabled
        public buildertek__Budget__c Budget;

        @AuraEnabled
        public List<buildertek__Budget_Item__c> budgetLineList;

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
        @AuraEnabled public String Grouping;
    }

    public class massUpdateQuoteItemWrapper {

        @AuraEnabled 
        public List<buildertek__Quote_Item__c> QuoteItemList;
        
        @AuraEnabled
        public List<buildertek__Quote_Line_Group__c> QuoteItemGroupList;
    }

    public class poDataTableWrapper {
        @AuraEnabled
        public List<buildertek__Purchase_Order__c> poList{ get; set; }

        @AuraEnabled
        public List<buildertek__Purchase_Order_Item__c> poItemList{ get; set; }
    }
}