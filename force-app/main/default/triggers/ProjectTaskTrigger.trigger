/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date: 24/05/2018
 */
trigger ProjectTaskTrigger on buildertek__Project_Task__c(after insert, after update, before delete, after delete, before insert, before update, After Undelete ){

    List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Old_Gantt_Chart__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];
    if (adminInterfaceNodeConfigurations.size() > 0) {

        if (adminInterfaceNodeConfigurations[0].buildertek__Old_Gantt_Chart__c && !BT_Utils.isTriggerDeactivate('Project_Task__c') && !ProjectTaskTriggerHandler.blnSkipTaskTrigger){
            ProjectTaskTriggerHandler handler = new ProjectTaskTriggerHandler(Trigger.isExecuting, Trigger.size, Trigger.oldMap);
            if (Trigger.isInsert){
                if (ProjectTaskTriggerHandler.blnSkipTaskTrigger){
                    return;
                }
                if (Trigger.isBefore){
                    handler.OnBeforeInsert(Trigger.new );

                } else if (Trigger.isAfter){
                    if (ProjectTaskTriggerHandler.blnSkipTaskTrigger){
                        system.debug('insertStop------------->' + ProjectTaskTriggerHandler.blnSkipTaskTrigger);

                    } else{
                        handler.updateChildDatesWithPredecessor(Trigger.new, Trigger.newMap);
                        handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);
                        handler.OnAfterInsert(Trigger.new, Trigger.newMap);
                        handler.UpdateOriginalstartandEndDates(Trigger.new, Trigger.newMap);
                        if (ProjectTaskTriggerHandler.isTask == true){
                            handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);
                            handler.OnBeforeInsert1(Trigger.new );
                            ProjectTaskTriggerHandler.isTask = false;
                        }

                        // this method setting the start date for phase but since the Predeseccor is not inserted with DML transaction that is why this method is commented
                        handler.insertUpdateMilestones(Trigger.new, Trigger.newMap);
                    }
                }
            } else if (Trigger.isUpdate){
                if (Trigger.isAfter){
                    handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
                    handler.OnAfterUpdateOriginalstartandEndDates(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
                    handler.insertUpdateMilestones(Trigger.new, Trigger.newMap);
                }
                if (Trigger.isBefore){
                    handler.checkCircular(Trigger.new, Trigger.oldMap);
                    handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
                }
                //insert update milestones
            } else if (Trigger.isDelete && Trigger.isAfter){
                handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);
                handler.OnAfterDelete(Trigger.old);
            } else if (Trigger.isUnDelete && Trigger.isAfter){
                handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);
            }
        }else if(!adminInterfaceNodeConfigurations[0].buildertek__Old_Gantt_Chart__c){
            if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && !NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger){
                NewGanttChartTaskTriggerHandler.upsertMilestoneData(Trigger.new, Trigger.newMap);
            } else if(Trigger.isDelete && Trigger.isAfter){
                NewGanttChartTaskTriggerHandler.upsertMilestoneData(Trigger.old, Trigger.oldMap);
            }
        }
    }
}