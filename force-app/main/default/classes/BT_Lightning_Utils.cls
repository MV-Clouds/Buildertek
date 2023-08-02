public with sharing class BT_Lightning_Utils{
    @AuraEnabled
    public static String sessionId(){
        return UserInfo.getSessionId();
    }

    /**************************************************************************
     Purpose: ColumnsHeader method used to Columns Header for Jqgrid
     Parameters: objectName: "objectName"
     Returns: Columns Header JSON String
     Throws [Exceptions]: NA
     ****************************************************************************/
    @AuraEnabled
    public Static String columnsHeader(String objectName, String fieldSetAPI, List<string> groupingFields, List<string> rowActions){
        // GET FIELD SET FIELDS
        List<Schema.FieldSetMember> listFieldsFromFieldSet = new List<Schema.FieldSetMember>();
        listFieldsFromFieldSet = getFieldSetMember(objectName, fieldSetAPI);

        List<String> listColumnHeaders = new List<String>();

        if (objectName != 'Group' && objectName != 'Titles'){
            listColumnHeaders.add('id');


            for (Schema.FieldSetMember objFieldSetMember : listFieldsFromFieldSet){

                if (objFieldSetMember.getLabel() == 'Account Id'){
                    listColumnHeaders.Add('Account Name');
                } else{
                    listColumnHeaders.Add(objFieldSetMember.getLabel());
                }

                if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'REFERENCE'){
                    listColumnHeaders.Add(objFieldSetMember.getFieldPath());
                }
            }

            for (Schema.FieldSetMember fieldSetMember : getSummaryFields(objectName)){
                listColumnHeaders.Add(fieldSetMember.getLabel());
                if (String.ValueOf(fieldSetMember.getType()).toUpperCase() == 'REFERENCE'){
                    listColumnHeaders.Add(fieldSetMember.getFieldPath());
                }
            }

            if (rowActions != null && rowActions.size() > 0){
                listColumnHeaders.Add('');
            }
        }
        return JSON.serialize(listColumnHeaders);
    }

    /**************************************************************************
     Purpose: ColumnsHeader method used to Columns Models for Jqgrid
     Parameters: objectName: "objectName"
     Returns: ColumnsModels JSON String
     Throws [Exceptions]: NA
     ****************************************************************************/
    @AuraEnabled
    public Static String columnsModels(String objectName, String fieldSetAPI, List<String> groupingFields, List<String> editableColumnList, List<string> rowActions){

        //String srchTrainingsText = 'ABC';

        // Grid option to indicate that policyand training campaign search box will use Contains (cn) and Between (bw) operators
        List<String> searchOptionsList = new List<String>{'cn', 'bw'};

        GridOptions.SearchOptions objSearchOptions = new GridOptions.SearchOptions('', true, searchOptionsList);
        //GridOptions.SearchOptions searchOptions = new GridOptions.SearchOptions('', true, searchOptionsList, srchTrainingsText);
        //GridOptions.SearchOptions searchOptions = new GridOptions.SearchOptions('', true, searchOptionsList, srchTrainingsText);

        if (objectName != 'Group' && objectName != 'Titles'){

            // Get fields from the field set
            List<Schema.FieldSetMember> listFieldsFromFieldSet = getFieldSetMember(objectName, fieldSetAPI);
            List<GridOptions.ColumnModel> listColumnModels = new List<GridOptions.ColumnModel>();

            // Get namespace
            string namespace = BT_Utils.getNamespacePrefix();


            // We need ID as a hidden
            // Create hidden ColumnModel object
            string hdnColumnName;
            hdnColumnName = 'Id';
            GridOptions.ColumnModel objHdnColumnModel = new GridOptions.ColumnModel(hdnColumnName, hdnColumnName, 'text', 'left', false, true, true, 'commonFormatter', false);
            objHdnColumnModel.key = true;
            listColumnModels.Add(objHdnColumnModel);


            // Here we are preparing columnModel based on field set
            GridOptions.ColumnModel objColumnModel = new GridOptions.ColumnModel();


            for (Schema.FieldSetMember objFieldSetMember : listFieldsFromFieldSet){

                objColumnModel = new GridOptions.ColumnModel();
                String strNameIndex = +objFieldSetMember.getFieldPath();

                if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'REFERENCE'){
                    if (!objFieldSetMember.getFieldPath().Contains('__c')){
                        strNameIndex = objFieldSetMember.getFieldPath().replace('Id', '.Name');
                    } else{
                        strNameIndex = objFieldSetMember.getFieldPath().replace('__c', '__r.Name');
                    }
                }


                objColumnModel.name = strNameIndex;
                objColumnModel.index = strNameIndex;
                objColumnModel.sorttype = 'text';
                objColumnModel.align = 'left';
                objColumnModel.editable = false;
                objColumnModel.hidden = false;
                objColumnModel.formatter = 'commonFormatter';
                objColumnModel.Searchoptions = objSearchOptions;

                listColumnModels.Add(objColumnModel);

                if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'REFERENCE'){

                    // Apply Formatter for the Reference type field
                    objColumnModel.formatter = 'linkFormatter';
                    String strFieldName = objFieldSetMember.getFieldPath();
                    GridOptions.FormatOptions objFormatOptions = new GridOptions.FormatOptions(strFieldName, 'true', '_blank', null, null, null);
                    objColumnModel.formatoptions = objFormatOptions;

                    objHdnColumnModel = new GridOptions.ColumnModel();
                    objHdnColumnModel.name = objFieldSetMember.getFieldPath();
                    objHdnColumnModel.index = objFieldSetMember.getFieldPath();
                    objHdnColumnModel.align = 'left';
                    objHdnColumnModel.editable = false;
                    objHdnColumnModel.hidden = true;
                    objHdnColumnModel.hidedlg = true;

                    for (string groupBy : groupingFields){
                        if (objHdnColumnModel.name == groupBy){
                            objHdnColumnModel.formatter = 'groupingSummeryFormatter';
                        } else{
                            objHdnColumnModel.formatter = 'commonFormatter';
                        }
                    }

                    objHdnColumnModel.search = false;

                    listColumnModels.Add(objHdnColumnModel);

                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'BOOLEAN'){

                    // Apply Formatter for the Boolean type field

                    objColumnModel.formatter = 'checkBoxFormatter';
                    objColumnModel.align = 'center';
                    objColumnModel.sortable = false;

                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'DATE'){

                    // Apply Formatter for the Date type field

                    objColumnModel.formatter = 'dueDate';
                    String strFieldName = objFieldSetMember.getFieldPath();

                    String TodayDate = String.valueOf(system.today());

                    GridOptions.FormatOptions objFormatOptions = new GridOptions.FormatOptions(null, null, null, 'Y-m-d', 'm/d/Y', TodayDate);
                    objColumnModel.formatoptions = objFormatOptions;
                    objColumnModel.width = '100';

                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'PERCENT'){

                    // Apply Formatter for the Percent type field

                    objColumnModel.formatter = 'numberToPercent';
                    objColumnModel.width = '80';
                    objColumnModel.sortable = false;
                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'INTEGER'){
                    objColumnModel.formatter = 'integer';
                    objColumnModel.align = 'left';
                    objColumnModel.width = '100';
                    objColumnModel.sortable = false;
                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'DOUBLE'){
                    objColumnModel.formatter = 'number';
                    objColumnModel.align = 'left';
                    objColumnModel.width = '100';
                    objColumnModel.sortable = false;
                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'NUMBER'){
                    //objColumnModel.formatter = 'integer';
                    objColumnModel.align = 'left';
                    objColumnModel.width = '100';
                    objColumnModel.sortable = false;
                } else if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'CURRENCY'){
                    objColumnModel.formatter = 'currency';
                    objColumnModel.align = 'left';
                    objColumnModel.width = '110';
                    objColumnModel.summaryType = 'sum';
                    GridOptions.FormatOptions objFormatOptions = new GridOptions.FormatOptions('$');
                    objColumnModel.formatoptions = objFormatOptions;
                    objColumnModel.sortable = false;
                }

                if (objFieldSetMember.getLabel().toUpperCase() == 'UOM'){
                    objColumnModel.width = '80';
                    objColumnModel.sortable = false;
                }


                for (string groupBy : groupingFields){
                    if (objColumnModel.name == groupBy){
                        objColumnModel.formatter = 'groupingSummeryFormatter';
                    }
                }

                system.debug('editableColumnList---' + editableColumnList);
                system.debug('objFieldSetMember.getFieldPath()---' + objFieldSetMember.getFieldPath());
                for (string editableField : editableColumnList){
                    if (objFieldSetMember.getFieldPath() == editableField){
                        objColumnModel.editable = true;
                    }
                }

            }

            for (Schema.FieldSetMember objFieldSetMember : getSummaryFields(objectName)){

                String strNameIndex = +objFieldSetMember.getFieldPath();

                if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'REFERENCE'){
                    if (!objFieldSetMember.getFieldPath().Contains('__c')){
                        strNameIndex = objFieldSetMember.getFieldPath().replace('Id', '.Name');
                    } else{
                        strNameIndex = objFieldSetMember.getFieldPath().replace('__c', '__r.Name');
                    }
                }
                objColumnModel = new GridOptions.ColumnModel();
                objColumnModel.name = strNameIndex;
                objColumnModel.index = strNameIndex;
                objColumnModel.sortable = false;
                objColumnModel.align = 'right';
                objColumnModel.editable = false;
                objColumnModel.hidden = true;
                objColumnModel.formatter = 'commonFormatter';
                objColumnModel.search = false;
                objColumnModel.width = '50';
                listColumnModels.add(objColumnModel);

                if (String.ValueOf(objFieldSetMember.getType()).toUpperCase() == 'REFERENCE'){

                    // Apply Formatter for the Reference type field
                    objColumnModel.formatter = 'linkFormatter';
                    String strFieldName = objFieldSetMember.getFieldPath();
                    GridOptions.FormatOptions objFormatOptions = new GridOptions.FormatOptions(strFieldName, 'true', '_blank', null, null, null);
                    objColumnModel.formatoptions = objFormatOptions;

                    objHdnColumnModel = new GridOptions.ColumnModel();
                    objHdnColumnModel.name = objFieldSetMember.getFieldPath();
                    objHdnColumnModel.index = objFieldSetMember.getFieldPath();
                    objHdnColumnModel.align = 'left';
                    objHdnColumnModel.editable = false;
                    objHdnColumnModel.hidden = true;
                    objHdnColumnModel.hidedlg = true;
                    objHdnColumnModel.formatter = 'commonFormatter';
                    objHdnColumnModel.search = false;

                    listColumnModels.Add(objHdnColumnModel);

                }
            }


            if (rowActions != null && rowActions.size() > 0){
                objColumnModel = new GridOptions.ColumnModel();
                objColumnModel.name = '';
                objColumnModel.index = '';
                objColumnModel.sortable = false;
                objColumnModel.align = 'right';
                objColumnModel.editable = false;
                objColumnModel.hidden = false;
                objColumnModel.formatter = 'actionFormatter';
                objColumnModel.search = false;
                objColumnModel.width = '30';
                objColumnModel.classes = 'gridactions';
                listColumnModels.add(objColumnModel);
            }

            return JSON.serialize(listColumnModels);
        }
        return null;
    }

    /**************************************************************************
     Purpose: AuraEnabled method usded to get record data
     Parameters: objectName: "Accounnt/Contact/User" , filterConditions:"AND XYZ = ABC ",selectedUsers:'UserID1,UserID2'
     Returns: recordData JSON String
     Throws [Exceptions]: NA
     ****************************************************************************/
    @AuraEnabled
    public Static string recordData(String objectName, String filterConditions, String fieldSetAPI, String parentId, String gridType){


        String soql = 'SELECT Id, Name ';

        if (gridType == 'groupByBudgetGroup'){
            soql = soql + ', Group__c ';
        }

        // Add selected field in soql from field set
        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList = getFieldSetMember(objectName, fieldSetAPI);
        for (Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList){
            if (!soql.contains(fieldSetMemberObj.getFieldPath().replace(namespacePrefix, ''))){
                soql = soql + ',' + fieldSetMemberObj.getFieldPath();
            }

            if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE'){
                if (!fieldSetMemberObj.getFieldPath().Contains('__c')){
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
                } else{
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
                }
            }
        }

        for (Schema.FieldSetMember fieldSetMemberObj : getSummaryFields(objectName)){
            if (!soql.contains(fieldSetMemberObj.getFieldPath().replace(namespacePrefix, ''))){
                soql = soql + ',' + fieldSetMemberObj.getFieldPath();
            }

            if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE'){
                if (!fieldSetMemberObj.getFieldPath().Contains('__c')){
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('Id', '.Name');
                } else{
                    soql = soql + ',' + fieldSetMemberObj.getFieldPath().replace('__c', '__r.Name');
                }
            }
        }


        soql = soql + ' FROM ' + objectName;

        soql = soql + ' WHERE Id != null ';

        if (filterConditions != null && filterConditions != ''){
            soql = soql + filterConditions;
        }

        /*
         if('RFQ_BUDGET_ITEM_PICKER_LHS' == gridType && !String.isBlank(parentId)){
         Set<Id> Ids = new set<Id>();
         for (RFQ_Item__c rfqItem: [Select Id, Budget_Item__c from RFQ_Item__c where RFQ_Package__c=: parentId AND Budget_Item__c != null]) {
         Ids.add(rfqItem.Budget_Item__c);
         }

         soql = soql +' AND ID NOT IN:Ids';

         return JSON.serialize(Database.query(soql));

         } else if('RFQ_BUDGET_ITEM_PICKER_RHS' == gridType && !String.isBlank(parentId)) {
         Set<Id> Ids = new set<Id>();
         for (RFQ_Item__c rfqItem: [Select Id, Budget_Item__c from RFQ_Item__c where RFQ_Package__c=: parentId AND Budget_Item__c != null]) {
         Ids.add(rfqItem.Budget_Item__c);
         }

         soql = soql +' AND ID IN:Ids';

         return JSON.serialize(Database.query(soql));

         } else if('RFQ_QUOTE_ITEM_PICKER_LHS' == gridType && !String.isBlank(parentId)){
         Set<Id> Ids = new set<Id>();
         for (RFQ_Item__c rfqItem: [Select Id, Quote_Item__c from RFQ_Item__c where RFQ_Package__c=: parentId AND Quote_Item__c != null]) {
         Ids.add(rfqItem.Quote_Item__c);
         }

         soql = soql +' AND ID NOT IN:Ids';

         return JSON.serialize(Database.query(soql));

         } else if('RFQ_QUOTE_ITEM_PICKER_RHS' == gridType && !String.isBlank(parentId)) {
         Set<Id> Ids = new set<Id>();
         for (RFQ_Item__c rfqItem: [Select Id, Quote_Item__c from RFQ_Item__c where RFQ_Package__c=: parentId AND Quote_Item__c != null]) {
         Ids.add(rfqItem.Quote_Item__c);
         }

         soql = soql +' AND ID IN:Ids';

         return JSON.serialize(Database.query(soql));

         } else if('RFQ_VENDOR_PICKER_LHS' == gridType && !String.isBlank(parentId)) {
         Set<Id> Ids = new set<Id>();
         for (RFQ_To_Vendor__c rfqVendorLink: [Select Id, Vendor__c from RFQ_To_Vendor__c where RFQ__c=: parentId AND Vendor__c != null]) {
         Ids.add(rfqVendorLink.Vendor__c);
         }

         soql = soql +' AND ID NOT IN:Ids';

         return JSON.serialize(Database.query(soql));

         } else if('RFQ_VENDOR_PICKER_RHS' == gridType && !String.isBlank(parentId)) {
         Set<Id> Ids = new set<Id>();
         for (RFQ_To_Vendor__c rfqVendorLink: [Select Id from RFQ_To_Vendor__c where RFQ__c =: parentId]) {
         Ids.add(rfqVendorLink.Id);
         }

         soql = soql +' AND ID IN:Ids';

         return JSON.serialize(Database.query(soql));
         }
         */

        return JSON.serialize(Database.query(String.escapeSingleQuotes(soql)));
    }

    @AuraEnabled
    public static void deleteRecords(String objectName, List<String> selectedRecords){
        try{
            if (objectName != null && objectName.trim() != '' && Schema.getGlobalDescribe().get(objectName) != null){
                String soql = 'SELECT Id, Name from  ' + objectName + ' where Id IN:selectedRecords';
                delete database.query(String.escapeSingleQuotes(soql));
            }
        } catch (Exception e){
            throw new AuraHandledException('Unable to delete auth: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void addRecordToRHS(List<String> ids, String GridType, String parentId){
        /*
         try {
         if('RFQ_BUDGET_ITEM_PICKER_LHS' == gridType && !String.isBlank(parentId)){
         List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
         for(string budgetId:ids) {
         RFQ_Item__c rfqItem = new RFQ_Item__c();
         rfqItem.RFQ_Package__c = parentId;
         rfqItem.Budget_Item__c = budgetId;
         rfqItems.add(rfqItem)    ;
         }

         insert rfqItems;

         } else if('RFQ_QUOTE_ITEM_PICKER_LHS' == gridType && !String.isBlank(parentId)){
         List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>();
         for(string quoteId:ids) {
         RFQ_Item__c rfqItem = new RFQ_Item__c();
         rfqItem.RFQ_Package__c = parentId;
         rfqItem.Quote_Item__c = quoteId;
         rfqItems.add(rfqItem)    ;
         }

         insert rfqItems;
         }

         } catch (Exception e) {
         throw new AuraHandledException('Unable to Add auth: ' + e.getMessage());
         }
         */
    }

    @AuraEnabled
    public static void deleteRecordRHS(List<String> ids, String GridType, String parentId){
        /*
         try {
         if('RFQ_BUDGET_ITEM_PICKER_RHS' == gridType && !String.isBlank(parentId)){

         List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>([Select Id from RFQ_Item__c where RFQ_Package__c=:parentId AND Budget_Item__c IN:ids]);
         delete rfqItems;

         } else if('RFQ_QUOTE_ITEM_PICKER_RHS' == gridType && !String.isBlank(parentId)){

         List<RFQ_Item__c> rfqItems = new List<RFQ_Item__c>([Select Id from RFQ_Item__c where RFQ_Package__c=:parentId AND Quote_Item__c IN:ids]);
         delete rfqItems;
         }
         } catch (Exception e) {
         throw new AuraHandledException('Unable to Add auth: ' + e.getMessage());
         }
         */
    }

    /**************************************************************************
     Purpose:Get fieldset for filter using get describe
     Parameters: objectName: "Accounnt/Contact/User"
     Returns:
     Throws [Exceptions]: NA
     ****************************************************************************/
    public static List<Schema.DescribeFieldResult> perpareFieldsOfObject(String objectName, String fieldSetAPI){
        List<Schema.DescribeFieldResult> fieldDescribeResults = new List<Schema.DescribeFieldResult>();
        Map<String, Schema.SObjectField> sobjectFieldsByName = new Map<String, Schema.SObjectField>();
        String namespacePrefix = BT_Utils.getNamespacePrefix();
        if (objectName != null && objectName.trim() != '' && Schema.getGlobalDescribe().get(objectName) != null){
            sobjectFieldsByName = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
            List<Schema.FieldSetMember> fieldSetMembers = BT_Utils.getFieldSetMembers(fieldSetAPI, objectName);
            if (fieldSetMembers != null && !fieldSetMembers.isEmpty()){
                for (Schema.FieldSetMember fieldSetMember : fieldSetMembers){
                    fieldDescribeResults.add(sobjectFieldsByName.get(fieldSetMember.getFieldPath()).getDescribe());
                }
            } else{
                if (objectName == BT_Constants.OBJECT_TYPE_ACCOUNT){
                    fieldDescribeResults.add(sobjectFieldsByName.get('Name').getDescribe());
                    fieldDescribeResults.add(sobjectFieldsByName.get('AccountNumber').getDescribe());
                }
            }
        }
        return fieldDescribeResults;
    }

    private static List<Schema.FieldSetMember> getFieldSetMember(String objectType, String FieldSetName){
        return BT_Utils.getFieldSetMembers(FieldSetName, objectType);
    }

    // Fetches the field set for the given sObject and the field set name
    @AuraEnabled
    public static List<FieldSetWrapper> getFieldSet(String objectName, String FieldSetName){

        List<Schema.FieldSetMember> fieldSet = BT_UTILS.getFieldSetMembers(FieldSetName, objectName);
        List<FieldSetWrapper> fMaplist = new List<FieldSetWrapper>();
        for (Schema.FieldSetMember fmem : fieldSet){
            fMaplist.add(new FieldSetWrapper(fmem.getLabel(), fmem.getFieldPath(), fmem, Schema.getGlobalDescribe().get(objectName).newSObject()));
        }
        return fMaplist;
    }

    @AuraEnabled
    public static List<dataTableFields> getFieldSetForDataTable(String objectName, String FieldSetName){

        List<Schema.FieldSetMember> fieldSet = BT_UTILS.getFieldSetMembers(FieldSetName, objectName);
        Map<String, Schema.SObjectField> sobjectFieldsByName = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
        List<dataTableFields> fMaplist = new List<dataTableFields>();
        for (Schema.FieldSetMember fmem : fieldSet){
            fMaplist.add(new dataTableFields(fmem.getLabel(), fmem.getFieldPath(), fmem, Schema.getGlobalDescribe().get(objectName).newSObject(), sobjectFieldsByName.get(fmem.getFieldPath()).getDescribe().isUpdateable()));
        }
        return fMaplist;
    }

    public static List<Schema.FieldSetMember> getSummaryFields(String objectAPi){
        return BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+'Summary_Fields', objectAPi);
    }

    @AuraEnabled
    public static List<ListView> getListViews(String SobjectType){
        List<ListView> listviews;
        if (Schema.sObjectType.ListView.fields.Id.isAccessible() && Schema.sObjectType.ListView.fields.Name.isAccessible()){

            listviews = [SELECT Id, Name
                         FROM ListView
                         WHERE SobjectType = :SobjectType];
        }


        // Perform isAccessible() check here
        return listviews;
    }

    @AuraEnabled
    public static List<Account> getAllVendors(String vendorName,String ratingValue,String tradeType,String rfqId){ //String filterInfoStr

        // get all existing vendor ids
        Set<Id> Ids = new set<Id>();
        RFQ__c rfq;
      //  if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Trade_Type__c.isAccessible()){

            rfq = [Select Id, buildertek__Trade_Type__c
                   from buildertek__RFQ__c
                   where id = :rfqId];
        string rfqtradetype = rfq.buildertek__Trade_Type__c;
       // }
           list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Is_Pre_Qualified__c 
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'RFQ Configuration' and buildertek__Is_Pre_Qualified__c !=false limit 1];
        
           

        for (RFQ_To_Vendor__c rfqVendorLink : [Select Id, Vendor__c
                                               from RFQ_To_Vendor__c
                                               where RFQ__c = :rfqId]){
            Ids.add(rfqVendorLink.Vendor__c);
        } 

        List<Account> accounts = new List<Account>();
        
        if(vendorName != '' || tradeType != '' || ratingValue != ''){
            String queryList = 'Select Id, Name,buildertek__Trade_Type_Lookup__c,buildertek__Trade_Type_Lookup__r.Name,buildertek__Bid_Rating__c, buildertek__Cost_Code__c,buildertek__Insurance__c, (select Id, Name, Email,buildertek__Primary_Contact__c from contacts where buildertek__Primary_Contact__c =true and Email != null) from Account';
            /*if (rfq.buildertek__Trade_Type__c != null){
                if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible()){
                    queryList = queryList +  ' where (Id NOT IN :Ids AND buildertek__BT_Account_Type__c = \'Vendor\' and buildertek__Trade_Type_Lookup__c =: rfqtradetype) ';
                }
            }else{*/
              //  if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible()){
                    queryList = queryList +  ' where (Id NOT IN :Ids AND buildertek__BT_Account_Type__c = \'Vendor\') ';
              //  }
           // }
           system.debug('queryList'+queryList);
            if(adminInterfaceNodeConfigurations.size()>0){
                if(adminInterfaceNodeConfigurations[0].buildertek__Is_Pre_Qualified__c == true){ 
                    queryList = queryList + 'AND (buildertek__Pre_Qualified__c = true)';
                }
            }
            if(ratingValue != '' && ratingValue != null){
                queryList = queryList+ 'AND (buildertek__Bid_Rating__c = \''+String.escapeSingleQuotes(ratingValue)+'\')';
            }
            if(tradeType != '' && tradeType != null){
                queryList = queryList+ ' AND (buildertek__Trade_Type_Lookup__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeType)+'%\')';
            }
            if(vendorName != '' && vendorName != null){
                queryList = queryList+ 'AND (Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            
            queryList = queryList+ ' Order By buildertek__Trade_Type_Lookup__r.Name NULLS LAST '; //Order By Name
            
            accounts = Database.query(queryList);
            
        }else{
            list<Account> acclst = new List<Account>();
            if (Schema.sObjectType.Account.fields.id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible() && Schema.sObjectType.Account.fields.BT_Account_Type__c.isAccessible()){
                if(adminInterfaceNodeConfigurations.size()>0){
                    if(adminInterfaceNodeConfigurations[0].buildertek__Is_Pre_Qualified__c == true){ 
                        acclst = [Select Id,Name,buildertek__Trade_Type_Lookup__c,buildertek__Trade_Type_Lookup__r.Name,buildertek__Insurance__c,buildertek__Pre_Qualified__c,
                                  (select Id, Name, Email,buildertek__Primary_Contact__c from contacts where buildertek__Primary_Contact__c =true and Email != null) 
                                  FROM Account WHERE Id NOT IN:Ids AND BT_Account_Type__c = 'Vendor' AND buildertek__Pre_Qualified__c = true Order By buildertek__Trade_Type_Lookup__r.Name NULLS LAST]; // Order By Name,
                    }
                }else{
                   acclst = [Select Id,Name,buildertek__Trade_Type_Lookup__c,buildertek__Trade_Type_Lookup__r.Name,buildertek__Insurance__c,buildertek__Pre_Qualified__c,
                                  (select Id, Name, Email,buildertek__Primary_Contact__c from contacts where buildertek__Primary_Contact__c =true and Email != null) 
                                  FROM Account WHERE Id NOT IN:Ids AND BT_Account_Type__c = 'Vendor' Order By buildertek__Trade_Type_Lookup__r.Name NULLS LAST]; // Order By Name,
                }
                
            }
            return acclst;
        }
        
        
        
        /*if (string.isblank(filterInfoStr)){
            system.debug('Null Values');
            if (rfq.Trade_Type__c != null){
                if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible()){

                    accounts = [Select Id, Name, buildertek__Cost_Code__c
                                from Account
                                where Id NOT IN :Ids AND BT_Account_Type__c = 'Vendor' and Trade_Type_Lookup__c = :rfq.Trade_Type__c
                                order by Name];
                }
            } else{
                if (Schema.sObjectType.Account.fields.Id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible()){

                    accounts = [Select Id, Name, buildertek__Cost_Code__c
                                from Account
                                where Id NOT IN :Ids AND BT_Account_Type__c = 'Vendor'
                                order by Name];
                }

            }

        } else{
            system.debug('Not Null Values');
            BT_FilterCondition filterCondition = BT_FilterCondition.create(filterInfoStr);
            filterCondition.crossObj = 'NA';
            String condition = filterCondition.generateConditions();
            String orderBy = filterCondition.orderBy;
            if (orderBy != null && orderBy != ''){
                orderBy = ' Order By Name.' + orderBy.trim();
            }
            if (orderBy == null){
                orderBy = '';
            }

            if (filterCondition.isForSearch){
                string keyword = filterCondition.keyword;
                if (condition != null && condition != ''){
                    condition = 'where ' + condition + 'AND Id NOT IN:Ids AND BT_Account_Type__c = Vendor';
                } else{
                    condition = 'where Id NOT IN:Ids AND BT_Account_Type__c = Vendor';
                }
                String queryString = 'Find : keyword IN ALL FIELDS RETURNING Account (Id,Name,buildertek__Cost_Code__c ' + condition + ')';
                System.debug('################The Search String is #########: ' + queryString);
                System.debug('################The keyword is #########: ' + keyword);

                accounts = search.query(queryString).get(0);
            } else{

                system.debug('---condition--->' + condition);
                //accounts = [Select Id, Name,buildertek__Cost_Code__c from Account order by Name];

                String queryString = 'Select Id, Name, buildertek__Cost_Code__c from Account ';

                if (condition != null && condition != ''){
                    condition = condition + 'AND Id NOT IN:Ids AND BT_Account_Type__c = Vendor';
                } else{
                    condition = 'Id NOT IN:Ids AND BT_Account_Type__c = Vendor';
                }


                queryString = queryString + ' where ' + condition + orderBy + ' limit 2000';
                list<Account> acclst;
                if (Schema.sObjectType.Account.fields.id.isAccessible() && Schema.sObjectType.Account.fields.Name.isAccessible() && Schema.sObjectType.Account.fields.buildertek__Cost_Code__c.isAccessible() && Schema.sObjectType.Account.fields.BT_Account_Type__c.isAccessible()){
                    acclst = database.query(String.escapeSingleQuotes(queryString));
                }
                return acclst;
            }
        }*/
        system.debug('accounts ----------> ' + accounts);
        return accounts;
    }
    
    @AuraEnabled
    public static List<Account> getSelectedVendor(String selectedvendorId){
        List<Account> selectedVendorList = new List<Account>();
        selectedVendorList = [Select Id, Name From Account Where Id =: selectedvendorId];
        return selectedVendorList;
    }

    /*
     * Wrapper Class to hold
     * Field Labels, their APIName, FieldSetMember and
     * sObject Record
     */
    public class FieldSetWrapper{
        @AuraEnabled
        public String fLabel;
        @AuraEnabled
        public String fAPIName;
        @AuraEnabled
        public String fType;
        @AuraEnabled
        public String fSetMember;
        @AuraEnabled
        public sObject sObjRecord;
        @AuraEnabled
        public sObject sObjNewRecord;
        public FieldSetWrapper(String fieldlabel, String fieldAPIName, FieldSetMember fSetMem, sObject sObjRecord){
            fLabel = fieldlabel;
            fAPIName = fieldAPIName;
            fType = string.valueOf(fSetMem.getType());
            fSetMember = JSON.serialize(fSetMem);
            sObjNewRecord = sObjRecord;
        }

        public FieldSetWrapper(sObject sObjRec){
            sObjRecord = sObjRec;
        }
    }

    public class dataTableFields{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String fieldName;
        @AuraEnabled
        public String type;
        @AuraEnabled
        public Boolean editable;
        public dataTableFields(String fieldlabel, String fieldAPIName, FieldSetMember fSetMem, sObject sObjRecord, Boolean isUpdateable){
            label = fieldlabel;
            fieldName = fieldAPIName;
            type = string.valueOf(fSetMem.getType()).toLowercase();
            editable = isUpdateable;
            if (type == 'double' || type == 'integer'){
                type = 'number';
            }
            if (type == 'percent'){
                type = 'string';
            }
        }
    }
}