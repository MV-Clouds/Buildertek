public without sharing class NewScheduleItemController {
        
    @AuraEnabled
    public static WorkOrder getPurchaseOrderData(String recordId){
        WorkOrder pur= [select Id, buildertek__Project__c, buildertek__Project__r.Name, ContactId from WorkOrder where Id =: recordId];
        return pur;     
    }
    
    @AuraEnabled
    public static List<ScheduleWrap> getSchedulelist(String recordId){
        list<Schedule__c> getSchedulesList = [select id, Name, buildertek__Description__c from Schedule__c where buildertek__Project__c =: recordId];
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
                Date adjustedDate = NewScheduleItemController.modifyDate(startdate);
                System.debug('adjustedDate==>'+adjustedDate);
                projectTask.buildertek__Start__c = adjustedDate;
                projectTask.buildertek__Original_Start_Date__c = adjustedDate;
                projectTask.buildertek__Original_End_Date__c = adjustedDate;
                projectTask.buildertek__Finish__c = adjustedDate;
                projectTask.buildertek__Duration__c = 1;
            }
            if (!String.isBlank(contactorResource)) {
                projectTask.buildertek__Contractor_Resource__c = contactorResource;
            }
            if (!String.isBlank(dependency)) {
                projectTask.buildertek__Dependency__c = dependency;
                List<buildertek__Project_Task__c> schduleItemList= [Select Id ,buildertek__Finish__c ,buildertek__Lag__c  From buildertek__Project_Task__c  WHERE Id =: dependency];
                System.debug('schduleItemList===>'+schduleItemList);
                Decimal lagValue = schduleItemList[0].buildertek__Lag__c;
                if (lagValue != 0) {
                    Integer lagDays = lagValue.intValue() + 1;
                    if (schduleItemList[0].buildertek__Finish__c > startdate) {
                        Date adjustedDate = NewScheduleItemController.modifyDate(schduleItemList[0].buildertek__Finish__c.addDays(lagDays));
                        System.debug('adjustedDate==>'+adjustedDate);
                        projectTask.buildertek__Start__c = adjustedDate;
                        projectTask.buildertek__Finish__c = adjustedDate;
                    }else {
                        Date adjustedDate = NewScheduleItemController.modifyDate(startdate);
                        System.debug('adjustedDate==>'+adjustedDate);
                        projectTask.buildertek__Start__c = adjustedDate;
                        projectTask.buildertek__Finish__c = adjustedDate;
                    }
                    
                }else {
                    if (schduleItemList[0].buildertek__Finish__c > startdate) {
                        Date adjustedDate = NewScheduleItemController.modifyDate(schduleItemList[0].buildertek__Finish__c.addDays(1));
                        System.debug('adjustedDate==>'+adjustedDate);
                        projectTask.buildertek__Start__c = adjustedDate;
                        projectTask.buildertek__Finish__c = adjustedDate;
                    }else {
                        Date adjustedDate = NewScheduleItemController.modifyDate(startdate);
                        System.debug('adjustedDate==>'+adjustedDate);
                        projectTask.buildertek__Start__c = adjustedDate;
                        projectTask.buildertek__Finish__c = adjustedDate;
                    }
                }
            }
            
    
            System.debug('projectTask :: '+projectTask);
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
            insert projectTask; 
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
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
   

 public static Date modifyDate(Date inputDate) {
    // Convert the Date to a DateTime to use the format method
    DateTime dt = DateTime.newInstance(inputDate.year(), inputDate.month(), inputDate.day());
    
    // Check if the inputDate is Saturday
    if (dt.format('E') == 'Sat') {
        return inputDate.addDays(2);
    }
    // Check if the inputDate is Sunday
    else if (dt.format('E') == 'Sun') {
        return inputDate.addDays(1);
    }
    // If not Saturday or Sunday, return the original date
    else {
        return inputDate;
    }
}
}