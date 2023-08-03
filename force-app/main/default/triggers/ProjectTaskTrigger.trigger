/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date: 24/05/2018
 */
trigger ProjectTaskTrigger on buildertek__Project_Task__c(after insert, after update, before delete, after delete, before insert, before update, After Undelete ){
	System.debug('*** ** ProjectTaskTrigger ** ***');
	System.debug(ProjectTaskTriggerHandler.blnSkipTaskTrigger);
	System.debug('outside condition project task ==> ');
    system.debug(BT_Utils.isTriggerDeactivate('Project_Task__c')+'--'+ProjectTaskTriggerHandler.blnSkipTaskTrigger);
	if (!BT_Utils.isTriggerDeactivate('Project_Task__c') && !ProjectTaskTriggerHandler.blnSkipTaskTrigger){
		System.debug('in trigger ==> ');
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

					//insert update milestones
					// this method setting the start date for phase but since the Predeseccor is not inserted with DML transaction that is why this method is commented
					handler.insertUpdateMilestones(Trigger.new, Trigger.newMap);
				}


				/*  handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);

				 handler.OnAfterInsert(Trigger.new, Trigger.newMap);
				 handler.UpdateOriginalstartandEndDates(Trigger.new, Trigger.newMap);
				 if (ProjectTaskTriggerHandler.isTask == true){
				 handler.OnAfterInsertItemCount(Trigger.new, Trigger.old);
				 handler.OnBeforeInsert1(Trigger.new);
				 ProjectTaskTriggerHandler.isTask = false;
				 }*/


			}
		} else if (Trigger.isUpdate){
			// if (ProjectTaskTriggerHandler.blnSkipTaskTrigger){
			//       return;
			// }
			System.debug('In the update trigger');
			if (Trigger.isAfter){
				handler.updateChildDatesWithPredecessor(Trigger.new, Trigger.newMap);
				handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap);
				handler.OnAfterUpdateOriginalstartandEndDates(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
				handler.insertUpdateMilestones(Trigger.new, Trigger.newMap);
				System.debug('at the end of IS update trigger');
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
	}
}