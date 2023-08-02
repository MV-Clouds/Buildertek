public class ImportMasterContinuationSheet {
    
    
    @AuraEnabled
    public static Object getmasterContinuaionSheets(){
        List<MasterContinuationSheetClass> continuationClassList = new List<MasterContinuationSheetClass>();
        List<buildertek__SOV_Continuation__c> continuationItemList;
        //buildertek__Application_Date__c
        if (Schema.sObjectType.buildertek__SOV_Continuation__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__Application__c.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__Application__c.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__Application_Date__c.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__Architect_Project_No__c.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__SOV_Payment_Application__c.isAccessible() && Schema.sObjectType.buildertek__Trade_Type__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__SOV_Continuation__c.fields.buildertek__Period_To__c.isAccessible()){
            continuationItemList = [SELECT Id, Name, buildertek__Application__c, buildertek__Application_Date__c, buildertek__Architect_Project_No__c, buildertek__SOV_Payment_Application__c, buildertek__SOV_Payment_Application__r.Name,buildertek__Period_To__c,buildertek__Type__c
                                    FROM buildertek__SOV_Continuation__c
                                    WHERE buildertek__Type__c = 'Master'];
        }
        
        if (continuationItemList.size() > 0){
            for (buildertek__SOV_Continuation__c continuationItem : continuationItemList){
                MasterContinuationSheetClass continuationClass = new MasterContinuationSheetClass();
                continuationClass.MasterRFQItem = continuationItem;
                continuationClass.SubmittalCheck = false;
                continuationClassList.add(continuationClass);
            }
        }
        
        String JSONString = JSON.serialize(continuationClassList);
        system.debug('Json String ' + JSONString);
        
        return JSONString;
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
                   // rfqItem.buildertek__Total__c = masterRFQItem.buildertek__Total__c;
                  //  rfqItem.buildertek__G_C__c = masterRFQItem.buildertek__G_C__c;
                  //  rfqItem.buildertek__Balance_To_Finish__c = masterRFQItem.buildertek__Balance_To_Finish__c;
                  //  rfqItem.buildertek__SOV_Continuation_Sheet__r.Name = masterRFQItem.buildertek__SOV_Continuation_Sheet__r.Name;
                    rfqItem.buildertek__SOV_Continuation_Sheet__c = recordId;
                    rfqItem.buildertek__Material_Presently_Stored__c = masterRFQItem.buildertek__Material_Presently_Stored__c;
                    //  rfqItem.buildertek__Application__c = RFQId;
                    masterRFQItemToInsert.add(rfqItem);
                    
                    system.debug(rfqItem);
                    
                }
            
        }
        system.debug(masterRFQItemToInsert.size());
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
    }
    
    
    
    public class MasterContinuationSheetClass{
        @AuraEnabled
        public buildertek__SOV_Continuation__c MasterRFQItem{ get; set; }
        
        @AuraEnabled
        public boolean SubmittalCheck{ get; set; }
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    } 
}