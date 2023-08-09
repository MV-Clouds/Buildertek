public with sharing class NewScheduleItemController {
        
    @AuraEnabled
    public static WorkOrder getPurchaseOrderData(String recordId){
        WorkOrder pur= [select Id, buildertek__Project__c, buildertek__Project__r.Name, ContactId from WorkOrder where Id =: recordId];
        return pur;     
    }
    
    @AuraEnabled
    public static List<ScheduleWrap> getSchedulelist(String recordId){
        // WorkOrder pur = [select Id, buildertek__Project__c from WorkOrder where Id =: recordId]; 
        // system.debug('projectId -----> '+pur.buildertek__Project__c);
        list<Schedule__c> getSchedulesList;
         if(Schema.sObjectType.Schedule__c.fields.Id.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.Name.isAccessible()&&
            Schema.sObjectType.Schedule__c.fields.buildertek__Description__c.isAccessible() &&
            Schema.sObjectType.Schedule__c.fields.buildertek__Project__c.isAccessible()){
             getSchedulesList = [select id, Name, buildertek__Description__c from Schedule__c where buildertek__Project__c =: recordId];
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
    public static String insertScheduleTask(String task, String scheduleId, String dependency, Date startdate, String project, String contactorResource){
            buildertek__Project_Task__c projectTask = new buildertek__Project_Task__c();
    
            if (!String.isBlank(task)) {
                projectTask.Name = task; 
            }
            if (!String.isBlank(project)) {
                projectTask.buildertek__Project__c = project;
            }
            if (!String.isBlank(scheduleId)) {
                projectTask.buildertek__Schedule__c = scheduleId;
            }
            if (startdate != null) {
                projectTask.buildertek__Start__c = startdate;
            }
            if (!String.isBlank(contactorResource)) {
                projectTask.buildertek__Contractor_Resource__c = contactorResource;
            }
            if (!String.isBlank(dependency)) {
                projectTask.buildertek__Dependency__c = dependency;
            }
    
            System.debug('projectTask :: '+projectTask);
            insert projectTask; 
            System.debug('projectTask id :: '+projectTask.Id);
            
            return projectTask.Id;
        
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