public class MassUpdateTakeOffLines{
    Public String recordId{ get; set; }

    Private ApexPages.StandardController controller;

    Public MassUpdateTakeOffLines(){
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }

    // @AuraEnabled
    // public static string getName(String recordId){
    //     try{
    //         List<buildertek__Project_Takeoff__c> takeOff = [Select Id, Name
    //                                                         From buildertek__Project_Takeoff__c
    //                                                         WHERE Id = :recordId];
    //         if (takeOff.size() > 0){
    //             return takeOff[0].Name;
    //         }
    //     } catch (Exception e){
    //         List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
    //         if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
    //             BT_ExceptionHandler.Store_Exception(e);
    //         }
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return null;
    // }

    // @AuraEnabled
    // public static string getParentId(String recordId){
    //     try{
    //         List<buildertek__Project_Takeoff__c> takeOff = [Select Id, buildertek__Project__c
    //                                                         From buildertek__Project_Takeoff__c
    //                                                         WHERE Id = :recordId];
    //         if (takeOff.size() > 0){
    //             return takeOff[0].buildertek__Project__c;
    //         }
    //     } catch (Exception e){
    //         List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
    //         if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
    //             BT_ExceptionHandler.Store_Exception(e);
    //         }
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return null;
    // }

    // @AuraEnabled
    // public static Integer getCount(String recordId){
    //     try{
    //         if (String.isNotBlank(recordId)){
    //             return [Select COUNT()
    //                     FROM buildertek__Project_Takeoff_Lines__c
    //                     WHERE buildertek__Project_Takeoff__c = :recordId];

    //         }
    //     } catch (Exception e){
    //         List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
    //         if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
    //             BT_ExceptionHandler.Store_Exception(e);
    //         }
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return null;
    // }

    public class TakeoffInfoWrapper {
        @AuraEnabled
        public String name { get; set; }
        @AuraEnabled
        public String parentId { get; set; }
        @AuraEnabled
        public Integer count { get; set; }
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String message { get; set; }
    }

    @AuraEnabled
    public static TakeoffInfoWrapper getTakeoffInfo(String recordId) {
        TakeoffInfoWrapper result = new TakeoffInfoWrapper();

        try {
            if (String.isNotBlank(recordId)) {
                List<buildertek__Project_Takeoff__c> takeOffList = [SELECT Id, Name, buildertek__Project__c
                                                                   FROM buildertek__Project_Takeoff__c
                                                                   WHERE Id = :recordId
                                                                   LIMIT 1];

                if (!takeOffList.isEmpty()) {
                    buildertek__Project_Takeoff__c takeOff = takeOffList[0];
                    result.name = takeOff.Name;
                    result.parentId = takeOff.buildertek__Project__c;

                    result.count = [SELECT COUNT()
                                    FROM buildertek__Project_Takeoff_Lines__c
                                    WHERE buildertek__Project_Takeoff__c = :recordId];

                    result.status = 'SUCCESS';
                }
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            result.status = 'FAIL';
            result.message = e.getMessage() + e.getLineNumber();
        }
        return result;
    }

    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Project_Takeoff_Lines__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__TakeOff_Lines')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__TakeOff_Lines').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (f.getFieldPath() == 'Name'){
                        jsonPart += ',"readOnly":"' + 'true' + '"';
                    }
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Project_Takeoff_Lines__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;

                }
            }

        } catch (Exception e){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            result += e.getLineNumber()+' : ' + e.getMessage();
        }
        return '[' + result + ']';
    }

    @AuraEnabled
    public static String getRecords(String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize, String productType, String searchLocation, String searchCategory, String searchTradeType){
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            if (String.isNotBlank(recordId)){
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c=: recordId';
                if (String.isNotBlank(productType)){
                    productType = '%' + productType + '%';
                    query += ' AND buildertek__Product_Type__r.NAME LIKE : productType';
                }
                if (String.isNotBlank(searchLocation)){
                    searchLocation = '%' + searchLocation + '%';
                    query += ' AND buildertek__Location__c LIKE : searchLocation';
                }
                if (String.isNotBlank(searchCategory)){
                    searchCategory = '%' + searchCategory + '%';
                    query += ' AND buildertek__Categories__r.Name LIKE : searchCategory';
                }
                if (String.isNotBlank(searchTradeType)){
                    searchTradeType = '%' + searchTradeType + '%';
                    query += ' AND buildertek__Trade_Type__r.Name LIKE : searchTradeType';
                }
                query += ' ORDER BY Name ASC NULLS LAST';
                query += ' LIMIT : pageSize OFFSET : offset';

                for (sObject s : Database.query(query)){
                    lstResult.add(s);
                }
                if (lstResult.size() > 0){
                    result = JSON.serialize(lstResult);
                    return result;
                }
            }
        } catch (Exception e){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            System.debug('Error' + e.getMessage());
        }
        return null;
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
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, String searchName, String searchPlan, String searchCategory, String searchTradeType){
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Project_Takeoff_Lines__c> items = (List<buildertek__Project_Takeoff_Lines__c>)JSON.deserialize(updatedRecords, List<buildertek__Project_Takeoff_Lines__c>.class);
                for (buildertek__Project_Takeoff_Lines__c item : items){
                    if (item.Id == null){
                        item.buildertek__Project_Takeoff__c = recordId;
                    }
                }
                if (items.size() > 0){
                    upsert items;
                }
                return 'Success';
                //return getRecords(recordId, fieldSetName, pageNumber, pageSize, searchName, searchPlan, searchCategory, searchTradeType);
            }
        } catch (Exception e){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }

    @AuraEnabled
    public static String deleteProject(String deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize, String searchName, String searchPlan, String searchCategory, String searchTradeType){
        try{
            if (String.isNotBlank(deleteRecordId)){
                delete [Select Id
                        FROM buildertek__Project_Takeoff_Lines__c
                        WHERE ID = :deleteRecordId];
                return getRecords(recordId, fieldSetName, pageNumber, pageSize, searchName, searchPlan, searchCategory, searchTradeType);
            }
        } catch (Exception e){
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    
    
        @AuraEnabled
    public static String DeleteMassTakeOffLines(List<String> sovLineIds) {
        system.debug('sovLineIds--->'+ sovLineIds);
        List<buildertek__Project_Takeoff_Lines__c> SovLineList = [select Id, Name from buildertek__Project_Takeoff_Lines__c where Id IN:sovLineIds];
        
        if(!SovLineList.isEmpty()){
           
            Delete SovLineList;
            return 'success';
        }else{
            return null;
        }  
    }
}