public with sharing class NewGanttChartTaskTriggerHandler{
    public static Boolean blnSkipTaskTrigger = false;
    public static void upsertMilestoneData(List<buildertek__Project_Task__c> newTaskList, Map<ID, buildertek__Project_Task__c> newTaskMap){

        if (!blnSkipTaskTrigger){

            Id scheduleId = newTaskList[0].buildertek__Schedule__c;

            List<buildertek__Project_Task__c> projectTaskList = [SELECT Id, Name, buildertek__Dependency__c, buildertek__Milestone__c, buildertek__Dependency__r.Name, buildertek__Schedule__c, buildertek__Phase__c, buildertek__Start__c, buildertek__finish__c
                                                                 FROM buildertek__Project_Task__c
                                                                 WHERE buildertek__Schedule__c = :scheduleId
                                                                 ORDER BY buildertek__Phase__c];

            Map<String, Date> phaseDateMap = new Map<String, Date>();
            Map<String, buildertek__Project_Task__c> phaseMileStoneMap = new Map<String, buildertek__Project_Task__c>();

            for (buildertek__Project_Task__c projectTask : projectTaskList){
                if (projectTask.buildertek__Milestone__c){
                    phaseMileStoneMap.put(projectTask.buildertek__Phase__c, projectTask);
                } else{
                    if (projectTask.buildertek__finish__c == null) {
                        projectTask.buildertek__finish__c = projectTask.buildertek__Start__c.addDays(1);
                    }
                    if (phaseDateMap.containsKey(projectTask.buildertek__Phase__c)){
                        Date endDate = phaseDateMap.get(projectTask.buildertek__Phase__c);
                        if (endDate < projectTask.buildertek__finish__c){
                            phaseDateMap.put(projectTask.buildertek__Phase__c, projectTask.buildertek__finish__c);
                        }
                    } else{
                        phaseDateMap.put(projectTask.buildertek__Phase__c, projectTask.buildertek__finish__c);
                    }
                }

            }

            List<buildertek__Project_Task__c> mileStoneList = new List<buildertek__Project_Task__c>();
            for (String key : phaseDateMap.keySet()){
                if (phaseMileStoneMap.containsKey(key)){
                    buildertek__Project_Task__c task = phaseMileStoneMap.get(key);
                    task.buildertek__Start__c = phaseDateMap.get(key).addDays(1);
                    task.buildertek__finish__c = phaseDateMap.get(key).addDays(1);
                    if (key != null && key != ''){
                        mileStoneList.add(task) ;
                    }
                } else{
                    buildertek__Project_Task__c task = new buildertek__Project_Task__c();
                    task.Name = 'Milestone Complete';
                    task.buildertek__Phase__c = key;
                    task.buildertek__Start__c = phaseDateMap.get(key).addDays(1);
                    task.buildertek__Finish__c = phaseDateMap.get(key).addDays(1);
                    task.buildertek__Duration__c = 0;
                    task.buildertek__Schedule__c = scheduleId;
                    task.buildertek__Milestone__c = true;
                    task.buildertek__Type__c = 'Milestone';
                    if (key != null && key != ''){
                        mileStoneList.add(task) ;
                    }
                }
            }
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = true;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
            upsert mileStoneList;
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = false;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
        }
    }

}