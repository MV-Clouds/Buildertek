public class ImportMasterSOVs {
    
        @AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select isPortalEnabled From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    @AuraEnabled
    public static RfqDataTableWrapper getmasterContinuaionSheets(Integer pageNumber, Integer pageSize){
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        
        
        objDT.recordList = [SELECT Id, Name, buildertek__Application__c, buildertek__Application_Date__c, buildertek__Architect_Project_No__c, buildertek__SOV_Payment_Application__c, buildertek__SOV_Payment_Application__r.Name,buildertek__Period_To__c,buildertek__Type__c
                            FROM buildertek__SOV_Continuation__c
                            WHERE buildertek__Type__c = 'Master' ORDER BY Name 
                            LIMIT :pageSize
                            OFFSET :offset];  
        
        
        
        return objDT;
        
    }
    
    
    @AuraEnabled
    public static void importContinuationSheetItems(List<String> Id,  String recordId){
        list<buildertek__SOV_Continuation_Sheet_Lines__c> masterRFQItemToInsert = new list<buildertek__SOV_Continuation_Sheet_Lines__c>();
        list<buildertek__SOV_Continuation_Sheet_Lines__c> masterRFQList;
        if (Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Description_of_Work__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Scheduled_Value__c.isAccessible() && 
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Work_Completed_from_Previous_Application__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Work_Completed__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.Name.isAccessible() && 
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Total__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__G_C__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Balance_To_Finish__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__SOV_Continuation_Sheet__c.isAccessible() &&
            Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Material_Presently_Stored__c.isAccessible()){
                masterRFQList = [SELECT Id,
                                 Name,
                                 buildertek__Description_of_Work__c,
                                 buildertek__Scheduled_Value__c,
                                 buildertek__Work_Completed_from_Previous_Application__c,
                                 buildertek__Work_Completed__c,
                                 buildertek__Total__c,
                                 buildertek__G_C__c,
                                 buildertek__Balance_To_Finish__c,
                                 buildertek__Material_Presently_Stored__c,
                                 buildertek__SOV_Continuation_Sheet__c,
                                 buildertek__SOV_Continuation_Sheet__r.Name
                                 FROM buildertek__SOV_Continuation_Sheet_Lines__c
                                 WHERE buildertek__SOV_Continuation_Sheet__c IN :Id];
            }
        for (buildertek__SOV_Continuation_Sheet_Lines__c masterRFQItem : masterRFQList){
            if (Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Description_of_Work__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Scheduled_Value__c.isAccessible() && 
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Work_Completed_from_Previous_Application__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Work_Completed__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.Name.isAccessible() && 
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Total__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__G_C__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Balance_To_Finish__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__SOV_Continuation_Sheet__c.isAccessible() &&
                Schema.sObjectType.buildertek__SOV_Continuation_Sheet_Lines__c.fields.buildertek__Material_Presently_Stored__c.isAccessible()){
                    
                    buildertek__SOV_Continuation_Sheet_Lines__c rfqItem = new buildertek__SOV_Continuation_Sheet_Lines__c();
                    
                    rfqItem.Name = masterRFQItem.Name;
                    rfqItem.buildertek__Description_of_Work__c = masterRFQItem.buildertek__Description_of_Work__c;
                    rfqItem.buildertek__Scheduled_Value__c = masterRFQItem.buildertek__Scheduled_Value__c;
                    rfqItem.buildertek__Work_Completed_from_Previous_Application__c = masterRFQItem.buildertek__Work_Completed_from_Previous_Application__c;
                    rfqItem.buildertek__Work_Completed__c = masterRFQItem.buildertek__Work_Completed__c;
                    //Id sheetId = Id.valueOf(recordId);
                    system.debug(recordId);
                    rfqItem.buildertek__SOV_Continuation_Sheet__c = recordId;
                    rfqItem.buildertek__Material_Presently_Stored__c = masterRFQItem.buildertek__Material_Presently_Stored__c;
                    masterRFQItemToInsert.add(rfqItem);
                    
                    system.debug(rfqItem);
                    
                }
            
        }
        system.debug(masterRFQItemToInsert.size());
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
    }
    
    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<buildertek__SOV_Continuation__c> recordList{ get; set; }
        
    }
}