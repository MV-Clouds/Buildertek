public with sharing class SchedulePOController {
    
    @AuraEnabled
    public static buildertek__Purchase_Order__c getPurchaseOrderData(String recordId){
        buildertek__Purchase_Order__c pur;
         if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() &&
			
			Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
			Schema.sObjectType.Account.fields.Name.isAccessible() ){
            pur= [select Id, buildertek__Description__c, buildertek__Project__c, buildertek__Project__r.Name,buildertek__Vendor__c,buildertek__Vendor__r.Name from buildertek__Purchase_Order__c where Id =: recordId];
			}
        return pur;     
    }
    
    @AuraEnabled
    public static List<ScheduleWrap> getSchedulelist(String recordId){
        buildertek__Purchase_Order__c pur;
        if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible()){
            pur= [select Id, buildertek__Description__c, buildertek__Project__c from buildertek__Purchase_Order__c where Id =: recordId]; 
			}
        system.debug('projectId -----> '+pur.buildertek__Project__c);
        list<Schedule__c> getSchedulesList;
         if(Schema.sObjectType.Schedule__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Schedule__c.fields.buildertek__Description__c.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.buildertek__Project__c.isAccessible()){
             getSchedulesList = [select id, Name, buildertek__Description__c from Schedule__c where buildertek__Project__c =: pur.buildertek__Project__c];
            }
        system.debug('getSchedulesList ---------> '+getSchedulesList);
        list<ScheduleWrap> ScheduleWrapList = new list<ScheduleWrap>(); 
        for(Schedule__c sch : getSchedulesList){
            ScheduleWrap ScheduleWrapRec = new ScheduleWrap();
            ScheduleWrapRec.getSchedulesList = sch;
            ScheduleWrapRec.scheduleCheckbox = false;
            ScheduleWrapList.add(ScheduleWrapRec);
        }
        return ScheduleWrapList;    
    }
    
    @AuraEnabled
    public static List<ScheduleWrap> getProjectSchedules(String projectId){
         list<Schedule__c> getSchedulesList;
        if(Schema.sObjectType.Schedule__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Schedule__c.fields.buildertek__Description__c.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.buildertek__Project__c.isAccessible()){
            getSchedulesList = [select id, Name, buildertek__Description__c from Schedule__c where buildertek__Project__c =: projectId];
         }
        system.debug('getSchedulesList -----------> '+getSchedulesList);
        list<ScheduleWrap> ScheduleWrapList = new list<ScheduleWrap>(); 
        for(Schedule__c sch : getSchedulesList){
            ScheduleWrap ScheduleWrapRec = new ScheduleWrap();
            ScheduleWrapRec.getSchedulesList = sch;
            ScheduleWrapRec.scheduleCheckbox = false;
            ScheduleWrapList.add(ScheduleWrapRec);
        }
        return ScheduleWrapList;
    }
    
    @AuraEnabled
    public static List <String> getselectOptions(sObject objectName, string fieldName) {
        system.debug('objObject --->' + objectName);
        system.debug('fld --->' + fieldName);
        List< String > allOpts = new List< String > ();
        Schema.sObjectType objType = objectName.getSObjectType();
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        Map< String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        List< Schema.PicklistEntry > values = fieldMap.get(fieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        system.debug('allOpts ---->' + allOpts);
        allOpts.sort();
        return allOpts;
    }
    
    @AuraEnabled
    public static ErrorMessageClass insertScheduleTask(buildertek__Project_Task__c task, String poId, String scheduleId, String dependency, String contactorResource, String recordId){
        buildertek__Purchase_Order__c pur ;
        if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Schedule_Item__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible()){
             pur = [select Id,buildertek__Schedule_Item__c, buildertek__Description__c, buildertek__Project__c from buildertek__Purchase_Order__c where Id =: poId]; 
			}
        ErrorMessageClass errMessage = new ErrorMessageClass();
        try{
            buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
            if (Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isCreateable() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Contractor__c.isCreateable() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Start__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isCreateable() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Phase__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isCreateable() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Project__c.isCreateable()) {
                projectTask.Name = task.Name; 
                projectTask.buildertek__Project__c = pur.buildertek__Project__c;
                projectTask.buildertek__Schedule__c = scheduleId;
                projectTask.buildertek__Start__c = task.buildertek__Start__c;
                projectTask.buildertek__Duration__c = task.buildertek__Duration__c;
                projectTask.buildertek__Contractor__c=contactorResource;
                projectTask.buildertek__Dependency__c = dependency;
                projectTask.buildertek__Purchase_Order__c = recordId;
                projectTask.buildertek__Phase__c = task.buildertek__Phase__c;
                if(task.buildertek__Finish__c != null){
                    projectTask.buildertek__Finish__c = task.buildertek__Finish__c;    
                }else{
                    projectTask.buildertek__Finish__c = task.buildertek__Start__c.addDays(Integer.valueOf(task.buildertek__Duration__c));
                }
            }
            System.debug('projectTask :: '+projectTask);
            insert projectTask;  
            
            //Set Schedule Item 
            pur.buildertek__Schedule_Item__c=projectTask.Id;
            pur.buildertek__Schedule__c=scheduleId;
            update pur;
            
            errMessage.MessageType = 'Success';
            errMessage.Message = 'Purchase Order Scheduled Successfully';
            return errMessage;
        }catch(Exception exp){
            errMessage.Message = exp.getMessage(); 
            errMessage.MessageType = 'Error';
            System.debug('error line :: '+exp.getLineNumber());
            System.debug('error line :: '+exp.getMessage());

            return errMessage;
        }
        
    }
    

    @AuraEnabled
    public static  Map<String,String> getPredecessorList(String scheduleId) {
        List<buildertek__Project_Task__c> schduleItemList= [Select Id , Name , buildertek__Schedule__c From buildertek__Project_Task__c  WHERE buildertek__Schedule__c=:scheduleId];
        Map<String,String> predecessorMap= new Map<String, String>();
        for(buildertek__Project_Task__c scheduleItem: schduleItemList){
            predecessorMap.put(scheduleItem.Id , scheduleItem.Name);
        }
        return predecessorMap;

    }

    public Class ScheduleWrap{
       @AuraEnabled public boolean scheduleCheckbox;
       @AuraEnabled public Schedule__c getSchedulesList;
   }
   
   public class ErrorMessageClass{
       @AuraEnabled public String Message { get; set; }
       @AuraEnabled public String MessageType { get; set; }
   }
}