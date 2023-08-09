public class RelatedScheduleOfValuesLinesController {
    @AuraEnabled
    public static ScheduleOfValueLineWrap getRelatedList(string recId){
        
        ScheduleOfValueLineWrap wrap = new ScheduleOfValueLineWrap();
        buildertek__Schedule_of_Values__c ScheduleofValuesRec = [select Id,buildertek__Type__c,RecordTypeId, recordtype.name
                                                                        from buildertek__Schedule_of_Values__c
                                                                        where Id =: recId];
        
        /*set<id> ScheduleofValuesids = new set<id>();
        set<id> SOValuesids = new set<id>();
        for(buildertek__Schedule_of_Values__c ScheduleofValuesRec : ScheduleofValueslist){
            ScheduleofValuesids.add(ScheduleofValuesRec.id);            
        }*/
        List<buildertek__Schedule_of_Value_Lines__c> ScheduleOfValueLineList = new List<buildertek__Schedule_of_Value_Lines__c>();
        if(ScheduleofValuesRec.recordtype.name == 'Standard'){
            ScheduleOfValueLineList = [Select id,
                                       Name,
                                       buildertek__Description_of_Work__c,
                                       buildertek__Scheduled_Value__c,
                                       buildertek__Status__c,
                                       buildertek__Rejection_Reason__c,
                                       buildertek__Schedule_of_Values__c
                                       from buildertek__Schedule_of_Value_Lines__c 
                                       where buildertek__Schedule_of_Values__c =: ScheduleofValuesRec.Id 
                                       and (buildertek__Status__c = 'Pending' or buildertek__Status__c = 'Customer Approved') and buildertek__isConsolidated__c = false];
        }
        else{
            ScheduleOfValueLineList = [Select id,
                                       Name,
                                       buildertek__Description_of_Work__c,
                                       buildertek__Scheduled_Value__c,
                                       buildertek__Status__c,
                                       buildertek__Rejection_Reason__c,
                                       buildertek__Schedule_of_Values__c
                                       from buildertek__Schedule_of_Value_Lines__c 
                                       where buildertek__Schedule_of_Values__c =: ScheduleofValuesRec.Id];
        }
        
        System.debug('ScheduleOfValueLineList-------'+ScheduleOfValueLineList.size());
        wrap.ScheduleOfValueLineList = ScheduleOfValueLineList;
        wrap.ScheduleofValuesRec = ScheduleofValuesRec;
        System.debug(wrap);
        return wrap;
    }

    public class ScheduleOfValueLineWrap{
        @AuraEnabled
        public List <buildertek__Schedule_of_Value_Lines__c > ScheduleOfValueLineList{ get; set; } 
        @AuraEnabled
        public buildertek__Schedule_of_Values__c ScheduleofValuesRec;  
     }
    
    @AuraEnabled
    public static void delAccount(buildertek__Schedule_of_Value_Lines__c ScheduleOfValuesLineRec){
        delete ScheduleOfValuesLineRec;
    } 
}