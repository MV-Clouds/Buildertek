public with sharing class GetProjectAndScheduleForGanttCmp {

    @AuraEnabled
    public static scheduleWrapperClass getScheduleData() {
        List<buildertek__schedule__c> scheduleList = new List<buildertek__schedule__c>([SELECT Id, Name, buildertek__Description__c, buildertek__project__c, buildertek__project__r.Name FROM buildertek__schedule__c ORDER BY buildertek__project__r.Name ASC limit 500]);
        List<buildertek__schedule__c> scheduleWithoutProjectList = new List<buildertek__schedule__c>();
        
        Map<Id, List<buildertek__schedule__c>> mapOfSchedulesByProject = new Map<Id, List<buildertek__schedule__c>>();
        
        for (buildertek__schedule__c schedule : scheduleList) {
            if (schedule.buildertek__project__c == null) {
                scheduleWithoutProjectList.add(schedule);
            } else {
                if (mapOfSchedulesByProject.containsKey(schedule.buildertek__project__c)) {
                    mapOfSchedulesByProject.get(schedule.buildertek__project__c).add(schedule);
                } else {
                    mapOfSchedulesByProject.put(schedule.buildertek__project__c, new List<buildertek__schedule__c>{schedule});
                }
            }
        }
        
        scheduleWrapperClass scheduleWrapper = new scheduleWrapperClass();
        scheduleWrapper.scheduleWithoutProjectList = scheduleWithoutProjectList;
        scheduleWrapper.mapOfSchedulesByProject = mapOfSchedulesByProject;
        
        return scheduleWrapper;
    }
    
    @AuraEnabled
    public static String setScheduleDataIntoCustomSetting(String ScheduleId, String ProjectId) {
        List<buildertek__Project_Schedule_Selection__c> projectScheduleSelection = [SELECT Id, Name, buildertek__project_selected__c, buildertek__schedule_selected__c FROM buildertek__Project_Schedule_Selection__c LIMIT 1];
        
        if (projectScheduleSelection.isEmpty()) {
            buildertek__Project_Schedule_Selection__c customSettingRec = new buildertek__Project_Schedule_Selection__c();
            customSettingRec.Name = 'Selected Project and Schedule';
            customSettingRec.buildertek__project_selected__c = projectId;
            customSettingRec.buildertek__schedule_selected__c = ScheduleId;
            insert customSettingRec;
            return customSettingRec.Id;
        } else {
            projectScheduleSelection[0].buildertek__project_selected__c = projectId;
            projectScheduleSelection[0].buildertek__schedule_selected__c = ScheduleId;
            update projectScheduleSelection;
            return projectScheduleSelection[0].Id;
        }
    }

    @AuraEnabled
    public static List<buildertek__Project_Schedule_Selection__c> getScheduleDateFromCustomSetting() {
        List<buildertek__Project_Schedule_Selection__c> schedulelist = [SELECT Id, Name, buildertek__project_selected__c, buildertek__schedule_selected__c FROM buildertek__Project_Schedule_Selection__c LIMIT 1];
        if (!schedulelist.isEmpty()) {
            return schedulelist;
        } 
        return null;
    }
    
    public class scheduleWrapperClass {
        @AuraEnabled
        public List<buildertek__schedule__c> scheduleWithoutProjectList;
        
        @AuraEnabled
        public Map<Id, List<buildertek__schedule__c>> mapOfSchedulesByProject;
    }

}