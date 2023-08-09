public class ScheduleItemBatchClass implements Database.Batchable<sObject>{
    Map<id, Project_Task__c> ProjectTaskBatch = new Map<id, Project_Task__c>();
    List<Project_Task__c> ProjecttaskListFromtrigger = new List<Project_Task__c>();
    public ScheduleItemBatchClass(Map<id, Project_Task__c> ProjectTaskIds){
        // system.debug('^^^^^^^^^^^^' + ProjectTaskIds);
        // system.debug(ProjectTaskIds.values()[0].buildertek__Start__c);
        ProjectTaskBatch = ProjectTaskIds;
    }

    public Database.QueryLocator start(Database.BatchableContext BC){
        system.debug('************' + BC);
        List<Project_Task__c> listTemp = new List<Project_Task__c>();
        listTemp = [SELECT id, buildertek__Schedule__c, buildertek__Start__c
                    from Project_Task__c
                    where id in:ProjectTaskBatch.keySet()];
        for (Project_Task__c tt : listTemp){
            System.debug('batch class start date before execute => ' + tt.buildertek__Start__c);
        }

        return Database.getQueryLocator([SELECT id, buildertek__Schedule__c, buildertek__Start__c
                                         from Project_Task__c
                                         where id in:ProjectTaskBatch.keySet()]);
    }

    public void execute(Database.BatchableContext BC, List<Project_Task__c> scope){
        // system.debug('%%%%%%%%%%%%' + scope[0].buildertek__Start__c);
        Set<Id> scheduleIds = new Set<Id>();
        for (Project_Task__c schItem : scope){
            scheduleIds.add(schItem.buildertek__Schedule__c);
        }
        List<id> projectids = new List<id>();
        list<buildertek__Schedule__c> scheduleListAscItems = [Select Id, Name, buildertek__Project__c, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, (select id, Name, buildertek__Schedule__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, buildertek__Finish__c
                                                                                                                                                                                                                                         from buildertek__Schedule_Tasks__r
                                                                                                                                                                                                                                         where buildertek__Original_Start_Date__c != null
                                                                                                                                                                                                                                         Order by buildertek__Original_Start_Date__c ASC
                                                                                                                                                                                                                                         LIMIT 1)
                                                              FROM buildertek__Schedule__c
                                                              WHERE Id In:scheduleIds];
        list<buildertek__Schedule__c> scheduleListDescItems = [Select Id, Name, buildertek__Project__c, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, (select id, Name, buildertek__Schedule__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, buildertek__Finish__c
                                                                                                                                                                                                                                          from buildertek__Schedule_Tasks__r
                                                                                                                                                                                                                                          where buildertek__Original_End_Date__c != null
                                                                                                                                                                                                                                          Order by buildertek__Finish__c ASC)
                                                               FROM buildertek__Schedule__c
                                                               WHERE Id In:scheduleIds];
        for (buildertek__Schedule__c schRec : scheduleListAscItems){
            projectids.add(schRec.buildertek__Project__c);
        }
        List<buildertek__Project__c> projectList = [select id, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                    from buildertek__Project__c
                                                    where id IN:projectids];

        for (buildertek__Project__c projectRec : projectList){
            for (buildertek__Schedule__c schAsc : scheduleListAscItems){
                for (buildertek__Project_Task__c item : schAsc.buildertek__Schedule_Tasks__r){
                    system.debug(item);
                    if (projectRec.id == schAsc.buildertek__Project__c){
                        projectRec.buildertek__Original_Start_Date__c = item.buildertek__Original_Start_Date__c;
                    }
                }
            }
            for (buildertek__Schedule__c schAsc : scheduleListDescItems){
                for (buildertek__Project_Task__c item : schAsc.buildertek__Schedule_Tasks__r){
                    if (projectRec.id == schAsc.buildertek__Project__c){
                        projectRec.buildertek__Original_End_Date__c = item.buildertek__Finish__c;
                    }
                }
            }
        }
        ScheduleTriggerHandler handler = new ScheduleTriggerHandler(true, scheduleListAscItems.size());
        ProjectTriggerHandler.blnSkipProjectTrigger = true;
        handler.blnSkipTaskTrigger = true;
        update projectList;
        ProjectTriggerHandler.blnSkipProjectTrigger = false;
        handler.blnSkipTaskTrigger = false;
    }

    public void finish(Database.BatchableContext BC){
        try{
            List<buildertek__Project_Task__c> schItemList = [SELECT id, buildertek__Schedule__c, buildertek__Start__c
                                                             from Project_Task__c
                                                             where id in:ProjectTaskBatch.keySet()
                                                             FOR  UPDATE ];
            if (schItemList.size() > 0){
                String schId = schItemList[0].buildertek__Schedule__c;
                list<buildertek__Schedule__c> scheduleList = [SELECT Id, buildertek__Start_Date__c, buildertek__Original_Dates_Filled__c, buildertek__End_Date__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
                                                              FROM buildertek__Schedule__c
                                                              where Id = :schId
                                                              FOR  UPDATE ];
                // System.debug('scheduleList-----------'+scheduleList[0].buildertek__Start_Date__c);
                // System.debug('scheduleList-----------'+scheduleList[0].buildertek__End_Date__c);
                // System.debug('scheduleList-----------'+scheduleList[0].buildertek__Original_Start_Date__c);
                // System.debug('scheduleList-----------'+scheduleList[0].buildertek__Original_End_Date__c);
                // System.debug('scheduleList-----------'+scheduleList[0].buildertek__Original_Dates_Filled__c);


                // for (buildertek__Schedule__c schedule : scheduleList) {
                //     System.debug('schedule.Id-----------'+schedule.Id);
                //     System.debug('schedule.buildertek__Start_Date__c-----------'+schedule.buildertek__Start_Date__c);
                //     System.debug('schedule.buildertek__End_Date__c-----------'+schedule.buildertek__End_Date__c);
                //     System.debug('schedule.buildertek__Original_Start_Date__c-----------'+schedule.buildertek__Original_Start_Date__c);
                //     System.debug('schedule.buildertek__Original_End_Date__c-----------'+schedule.buildertek__Original_End_Date__c);
                //     System.debug('schedule.buildertek__Original_Dates_Filled__c-----------'+schedule.buildertek__Original_Dates_Filled__c);

                // }


                List<buildertek__Schedule__c> scheduleListNew = new List<buildertek__Schedule__c>();
                for (buildertek__Schedule__c scheduleRec : scheduleList){
                    if (scheduleRec.buildertek__Start_Date__c != null && scheduleRec.buildertek__End_Date__c != null){
                        if (scheduleRec.buildertek__Original_Dates_Filled__c == false){
                            scheduleRec.buildertek__Original_Dates_Filled__c = true;
                            scheduleRec.buildertek__Original_Start_Date__c = scheduleRec.buildertek__Start_Date__c;
                            scheduleRec.buildertek__Original_End_Date__c = scheduleRec.buildertek__End_Date__c;
                            scheduleListNew.add(scheduleRec);
                            system.debug(scheduleRec);
                        }
                    }

                }
                if (scheduleListNew.size() > 0){
                    ScheduleTriggerHandler handler = new ScheduleTriggerHandler(true, scheduleListNew.size());
                    handler.blnSkipTaskTrigger = true;
                    update scheduleListNew;
                    handler.blnSkipTaskTrigger = false;

                }
                system.debug(scheduleListNew);
            }
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            //throw new AuraHandledException(e.getMessage());
        }
    }

}