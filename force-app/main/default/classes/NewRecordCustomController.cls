public with sharing class NewRecordCustomController{
      @AuraEnabled
    public static String getproject(string recordId){
      buildertek__Billings__c recRec = [SELECT Id, Name,buildertek__Project__c FROM buildertek__Billings__c where id =:recordId];
        return recRec.buildertek__Project__c;
    }
    @AuraEnabled
    public static List<buildertek__Budget__c> getBudgetNameFromProject(String recordId){
        try{
        if (String.isNotBlank(recordId)){
            List<buildertek__Budget__c> budgetList = [SELECT Id, Name, buildertek__Project__c FROM buildertek__Budget__c  WHERE buildertek__Project__c = :recordId  ORDER BY CreatedDate DESC];
            return budgetList;
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    // Ticket: BUIL-3330 Modified By: Poojan Gabani Date:12-06-2023(2:10 PM)
    @AuraEnabled
    public static List<buildertek__Budget_Item__c> getBudgetline(String recordId) {

        System.debug(recordId);
        List<buildertek__Budget_Item__c> budgetLineList = [SELECT Id , buildertek__Budget__c, Name FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =: recordId ORDER BY Name ASC];
        System.debug(budgetLineList);

        // for(buildertek__Budget_Item__c getLine :  budgetLine){
        //     budgetLineList.add(getLine.Name);

        // }
        return budgetLineList;
    }
    // Ticket: BUIL-3330 Modified By: Poojan Gabani Date:12-06-2023(12:56 PM)
    @AuraEnabled
    public static List<buildertek__Budget__c> getBudget(string recordId) {

        System.debug(recordId);
        List<buildertek__Budget__c> budgetList = [SELECT Id , buildertek__Project__c, Name FROM buildertek__Budget__c WHERE buildertek__Project__c =: recordId ORDER BY Name ASC];
        System.debug(budgetList);
        return budgetList;
    }


    @AuraEnabled
    public static List<buildertek__Budget__c> getBudgetNew(String recordId, String budgetNameStr) {
        List<buildertek__Budget__c> budgetList;
        if (recordId != '' && budgetNameStr == '' && budgetNameStr == null) {
            budgetList = [SELECT Id , buildertek__Project__c, Name FROM buildertek__Budget__c WHERE buildertek__Project__c =: recordId];
        } else {
            String bName = '\''+budgetNameStr+'%\'';
            string Query = 'SELECT Id , buildertek__Project__c, Name FROM buildertek__Budget__c WHERE buildertek__Project__c =: recordId AND Name LIKE '+bName;
            System.debug('Query ==> '+Query);
            budgetList = Database.query(Query);
        }
        return budgetList;
    }
    @AuraEnabled
    public static List<buildertek__Budget_Item__c> getBudgetlineNew(String recordId,  String budgetLineNameStr) {
        List<buildertek__Budget_Item__c> budgetLineList;
        if (recordId != '' && budgetLineNameStr == '' && budgetLineNameStr == null){
            budgetLineList = [SELECT Id , buildertek__Budget__c, Name FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =: recordId];
        } else {
            String bName = '\''+budgetLineNameStr+'%\'';
            string Query = 'SELECT Id , buildertek__Budget__c, Name FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =: recordId AND Name LIKE '+bName;
            System.debug('Query ==>'+Query);
            budgetLineList = Database.query(Query);
        }
        return budgetLineList;
    }


      @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        return sObjName;
    }

    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    System.debug(String.valueOf(f.getType()));

                    if (String.valueOf(f.getType()) == 'PICKLIST'){

                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);

                        System.debug(pickListValuesList);
                        System.debug(jsonPart);


                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }

        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
        }
        return '[' + result + ']';
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public Static LookupWrapper getParentObjRec(string parentrecordid){
        Id recordid = parentrecordid;
        string sObjName = recordid.getSObjectType().getDescribe().getName();
        string  Query;
        Query = 'select Id, Name from ' +sObjName +' where Id=:recordid';
        SObject ObjectRec = Database.query(Query);
        LookupWrapper NewWrapperRec = new LookupWrapper();
        NewWrapperRec.LookupRec = ObjectRec;
        NewWrapperRec.ObjectName = sObjName;
        return NewWrapperRec;
    }
    Public class LookupWrapper{
        @AuraEnabled
        Public SObject LookupRec {get;set;}
        @AuraEnabled
        Public String ObjectName {get;set;}

    }
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Expense__c'];

        // Perform isAccessible() check here
        return listviews;
    }
    @AuraEnabled
    public static String getbudgetrecord(String Expenserecid){
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Automatically_add_Expense_to_Budget__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'Budget Configuration' and buildertek__Automatically_add_Expense_to_Budget__c !=false limit 1];
         if(adminInterfaceNodeConfigurations.size()>0 ){
             if(adminInterfaceNodeConfigurations[0].buildertek__Automatically_add_Expense_to_Budget__c == true){
                 return 'Message';
             }
             else{
                return null;
             }
         }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static String getbudgettimecardrecord(String timecardrecid){
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Automatically_add_Expense_to_Budget__c,buildertek__Automatically_add_Time_Card_to_Budget__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'Budget Configuration' and buildertek__Automatically_add_Time_Card_to_Budget__c !=false limit 1];
         if(adminInterfaceNodeConfigurations.size()>0 ){
             if(adminInterfaceNodeConfigurations[0].buildertek__Automatically_add_Time_Card_to_Budget__c == true){
                 return 'Message';
             }
             else{
                return null;
             }
         }
        else{
            return null;
        }
    }
    @AuraEnabled
    public static Boolean duplicateExpense(String expenseAmount, String expenseType, String expensePaymentMethod, String expenseDescription){
        Decimal Amount = null;
        if(expenseAmount != null){
           Amount = Decimal.valueOf(expenseAmount);
        }

        System.debug('expenseDescription ==> '+expenseDescription);
        System.debug('expenseType ==>'+expenseType);
        System.debug('expensePaymentMethod ==> '+expensePaymentMethod);
        System.debug('Amount ==>'+Amount);
        list<buildertek__Expense__c> expenselist = [select id, Name, buildertek__Description__c,buildertek__Type__c,buildertek__Payment_Method__c,buildertek__Amount__c
                                             from buildertek__Expense__c where buildertek__Description__c =: expenseDescription and buildertek__Type__c =: expenseType and
                                                                               buildertek__Payment_Method__c =: expensePaymentMethod and buildertek__Amount__c =: Amount];

        System.debug('expenselist ==>'+expenselist);
        if(expenselist.size()>0){
            return true;
        }else{
            return false;
        }
    }

    @AuraEnabled
    public static void bypassTrigger(){
        System.debug('bypassTrigger');
        ExpenseToBudgetItemTriggerHandler.blnSkipExpenseUpdateTrigger = true;

        System.debug('ExpenseToBudgetItemTriggerHandler.blnSkipExpenseUpdateTrigger  ==> '+ExpenseToBudgetItemTriggerHandler.blnSkipExpenseUpdateTrigger );
    }

     @AuraEnabled
    public static string getBudgets(String RecordId){
        buildertek__Budget__c budgetRec = [select id,Name,buildertek__Project__c from buildertek__Budget__c  where id =: RecordId];
        return budgetRec.buildertek__Project__c;
    }
     @AuraEnabled
    public static string getproschedule(String RecordId){
        buildertek__Project_Task__c scheduleRec = [select id,Name,buildertek__Project__c from buildertek__Project_Task__c  where id =: RecordId];
        return scheduleRec.buildertek__Project__c;
    }
    @AuraEnabled
    public static string getprobudgetline(String RecordId){
        buildertek__Budget_Item__c budgetitemRec = [select id,Name,buildertek__Budget__r.buildertek__Project__c from buildertek__Budget_Item__c  where id =: RecordId];
        return budgetitemRec.buildertek__Budget__r.buildertek__Project__c;
    }
    @AuraEnabled
    public static List<ListView> getListView() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__RFQ__c' and Name='All'];

        // Perform isAccessible() check here
        return listviews;
    }

       @AuraEnabled
    public static String getRecordField(Id recordId) {

        buildertek__Project__c admin = [select id,buildertek__Administrator__c from buildertek__Project__c where id =:recordId];
        if(admin.buildertek__Administrator__c != null){
            return admin.buildertek__Administrator__c;
        }
        else{
            return 'Empty';
        }
    }

    @AuraEnabled
    public static String creteExpense(buildertek__Expense__c expenseData) {

        System.debug('expenseData ==> '+expenseData);
        System.debug('expenseData.buildertek__Budget_Line__c =>'+expenseData.buildertek__Budget_Line__c);

        BudgetDAO.isCreateExpense = false;

        String budgetLine = expenseData.buildertek__Budget_Line__c;
        if (expenseData.buildertek__Budget_Line__c != null && budgetLine != '') {
            insert expenseData;

        } else {
            insert expenseData;

            String BudgetId = expenseData.buildertek__Budget__c;
            System.debug('BudgetId ==> '+BudgetId);
            if (BudgetId != null && BudgetId != '') {

                // buildertek__Budget_Line_Group__c  budgetlinegroup =[select id,Name from buildertek__Budget_Line_Group__c  where Name = 'Expense' limit 1];

                // buildertek__Budget_Item__c budgetitem = new buildertek__Budget_Item__c();
                // budgetitem.buildertek__Budget__c = BudgetId;
                // budgetitem.Name = expenseData.buildertek__Description__c;
                // budgetitem.buildertek__Quantity__c = 0;
                // budgetitem.buildertek__UOM__c = 'Each';
                // budgetitem.buildertek__Group__c  = budgetlinegroup.id;
                // budgetitem.buildertek__Cost_Code__c = expenseData.buildertek__Cost_Code__c;
                // budgetitem.buildertek__Contractor__c = expenseData.buildertek__Vendor__c;
                // budgetitem.buildertek__Unit_Price__c = expenseData.buildertek__Amount__c;
                // insert budgetitem;

                // expenseData.buildertek__Budget_Line__c = budgetitem.id;
                // update expenseData;

                // buildertek__Expense_To_Budget_Item_Link__c ExpnseToBudgetItemLink = new buildertek__Expense_To_Budget_Item_Link__c();
                // ExpnseToBudgetItemLink.buildertek__Expense__c = expenseData.Id;
                // ExpnseToBudgetItemLink.buildertek__Budget_Line__c = budgetitem.Id;
                // ExpnseToBudgetItemLink.Auto_Roll_Up__c = true;
                // insert ExpnseToBudgetItemLink;

            }
        }

        BudgetDAO.isCreateExpense = true;

        return expenseData.Id;
    }

    @AuraEnabled(cacheable=true)
    public static List<BT_Lightning_Utils.FieldSetWrapper> getfield(string objectName, string fieldSetName){
        List<Schema.FieldSetMember> fieldSet = BT_UTILS.getFieldSetMembers(fieldSetName, objectName);
        //System.debug('fieldSet-->'+fieldSet);
        List<BT_Lightning_Utils.FieldSetWrapper> fMaplist = new List<BT_Lightning_Utils.FieldSetWrapper>();
        for (Schema.FieldSetMember fmem : fieldSet){
            fMaplist.add(new BT_Lightning_Utils.FieldSetWrapper(fmem.getLabel(), fmem.getFieldPath(), fmem, Schema.getGlobalDescribe().get(objectName).newSObject()));
        }
        System.debug('fMaplist-->'+fMaplist);
        return fMaplist;
    }

}