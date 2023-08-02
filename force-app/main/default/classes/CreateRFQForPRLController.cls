public with sharing class CreateRFQForPRLController {
     @AuraEnabled
    public static String getRecordField(String recordId){
      buildertek__Pricing_Request_Line__c prlineRec =  [SELECT Id, Name, buildertek__Description__c, buildertek__Status__c, buildertek__Vendor__c, buildertek__Pricing_Request__c,
                                                        buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Notes__c, buildertek__Reject_Reason__c, 
            buildertek__Type__c, buildertek__RFQ__c, buildertek__Cost__c, buildertek__Markup__c, buildertek__Price__c, buildertek__Change_Order__c 
                                                        FROM buildertek__Pricing_Request_Line__c where Id =: recordId];
        return prlineRec.buildertek__Pricing_Request__r.buildertek__Project__c;
    }
    
    @AuraEnabled
    public static String getBudgetNameFromProject(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                
                buildertek__Budget__c budgetName = [SELECT Id, Name, buildertek__Project__c
                                                    FROM buildertek__Budget__c
                                                    WHERE buildertek__Project__c = :recordId
                                                    ORDER BY CreatedDate DESC Limit 1];
                return budgetName.Id;
                
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
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
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
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
    public static string duplicateExpense(String expenseAmount, String expenseType, String expensePaymentMethod, String expenseDescription){
        Decimal Amount = null;
        if(expenseAmount != null){
           Amount = Decimal.valueOf(expenseAmount); 
        }
        list<buildertek__Expense__c> expenselist = [select id, Name, buildertek__Description__c,buildertek__Type__c,buildertek__Payment_Method__c,buildertek__Amount__c
                                             from buildertek__Expense__c where buildertek__Description__c =: expenseDescription and buildertek__Type__c =: expenseType and 
                                                                               buildertek__Payment_Method__c =: expensePaymentMethod and buildertek__Amount__c =: Amount];
        System.debug('expenselist===========>>>>>>'+expenselist);
        if(expenselist.size()>0){
            return 'DuplicateExpense';
        }else{
            return null;
        }
        
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
     public static String updateRfqq(string recordId, string rfId){
        buildertek__Pricing_Request_Line__c PRL = [select Id, Name, buildertek__RFQ__c from buildertek__Pricing_Request_Line__c where Id =: recordId];
         
         PRL.buildertek__RFQ__c = rfId;
         update PRL;
         
         
         buildertek__RFQ__c uprfq = [select Id, Name , buildertek__Pricing_Request_Line__c from buildertek__RFQ__c where Id =:rfId];
         
         uprfq.buildertek__Pricing_Request_Line__c = recordId;
         
         update uprfq;
         
         return 'success';
    }
    
    
    @AuraEnabled
    public static String checkIsRFQ(String recordId){
        buildertek__Pricing_Request_Line__c PRL = [select Id, Name, buildertek__RFQ__c from buildertek__Pricing_Request_Line__c where Id =: recordId];
        return PRL.buildertek__RFQ__c ;
    }
    
}