public class newOptionClass {
    @AuraEnabled
    public static String createoption(buildertek__Question__c option , Decimal salesPrice , String BudgetId , String budgetLineId){
        option.buildertek__Cost__c=salesPrice;
        option.buildertek__Budget_Line__c=budgetLineId;
        option.buildertek__Budget__c=BudgetId;
        insert option;
        return option.Id;
    }

    @AuraEnabled
    public static Product2 getProduct(String productId){
        Product2 prod = [SELECT Id, Name, buildertek__Manufacturer__c, (select Id, Name, UnitPrice, buildertek__Unit_Cost__c,Product2Id from PricebookEntries) FROM Product2 WHERE Id =: productId LIMIT 1];
        return prod;
    }
    @AuraEnabled
    public static List<buildertek__Budget__c> getBudget(String seleTypeId){
        Set<Id> selectionCategoryIds= new Set<Id>();
        List<buildertek__Question_Group__c> selectionTypeList = [SELECT Id, Name, buildertek__Section__c, buildertek__Section__r.Name   FROM buildertek__Question_Group__c where id=:seleTypeId];
        for(buildertek__Question_Group__c selectionType:selectionTypeList){
            selectionCategoryIds.add(selectionType.buildertek__Section__c);
        }
        buildertek__Section__c sectionList=[Select Id , Name , buildertek__Selection__c , buildertek__Selection__r.buildertek__Project__c from buildertek__Section__c	where Id=:selectionCategoryIds];
        List<buildertek__Budget__c> budgetList = [SELECT Id, Name  ,buildertek__Project__c FROM buildertek__Budget__c WHERE buildertek__Project__c =:sectionList.buildertek__Selection__r.buildertek__Project__c];
        return budgetList;
    }
    @AuraEnabled
    public static List<buildertek__Budget_Item__c> getBudgetLine(String BudgetId){
        List<buildertek__Budget_Item__c> budegtLineList = [SELECT Id, Name  ,buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE buildertek__Budget__c =:BudgetId];
        return budegtLineList;
    }
    @AuraEnabled
    public static buildertek__Budget_Item__c getBudgetLineUnitSalesPrice(String budgetLineId){
        buildertek__Budget_Item__c budgetLine = [SELECT Id, Name , buildertek__Gross_Profit_Percemtage__c	, buildertek__Sales_Price__c, buildertek__Budget__c FROM buildertek__Budget_Item__c WHERE Id =: budgetLineId LIMIT 1];
        // System.debug(budgetLine.buildertek__Sales_Price__c);
        // System.debug(budgetLine);

        return budgetLine;
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
    //* method for saving data into object
    @AuraEnabled
    public static String saveData(String allData){
        String optionNewId;
        buildertek__Question__c option = (buildertek__Question__c) JSON.deserialize(allData, buildertek__Question__c.class);


        // Id recordId = Id.valueOf(productId);
        if (option.Name.length() > 80) {
            string subStr = option.Name.subString(0,76);
            option.Name = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
        }
        // option.buildertek__Product__c = recordId;


        insert option;
        optionNewId = String.valueOf(option.Id);
        return optionNewId;
    }

    @AuraEnabled
    public static List<buildertek__Budget__c> searchRecords(String searchKey , String projectId){
        String key = '%' + searchKey + '%';
        List<buildertek__Budget__c> budgetList = [Select Id , Name  , buildertek__Project__c From buildertek__Budget__c where buildertek__Project__c=:projectId  AND  Name LIKE :key];
        System.debug(budgetList);
        return budgetList;
    }
    @AuraEnabled
    public static List<buildertek__Budget_Item__c> searchBudgetLineRecords(String searchKey , String budgetId){
        String key = '%' + searchKey + '%';
        List<buildertek__Budget_Item__c> budgetLineList = [Select Id , Name  , buildertek__Budget__c From buildertek__Budget_Item__c where buildertek__Budget__c=:budgetId  AND  Name LIKE :key];
        return budgetLineList;
    }
    @AuraEnabled
    public static List<buildertek__Budget__c> getAllBudget1(){
        list<buildertek__Budget__c> budgetList =[Select Id , Name From buildertek__Budget__c];
        return budgetList;



    }
    // @AuraEnabled
    // public static string getOptionName(String recordId){
    //         Product2 prod =[Select Id , Name From Product2 where Id=:recordId];
    //         return prod.Name;    
        
    // }

    
    
}