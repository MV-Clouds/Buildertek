public with sharing class NewGanttChartTaskTriggerHandler{
    public static Boolean blnSkipTaskTrigger = false;
    public static void upsertMilestoneData(List<buildertek__Project_Task__c> newTaskList, Map<ID, buildertek__Project_Task__c> newTaskMap){

		Boolean checkIncludeWeekendSettings = false;

		List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [SELECT Id, buildertek__Include_Weekend__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Schedule Configuration'];

        if (adminInterfaceNodeConfigurations.size() > 0) {
            checkIncludeWeekendSettings = adminInterfaceNodeConfigurations[0].buildertek__Include_Weekend__c;
        }

        if (!blnSkipTaskTrigger){

            Id scheduleId = newTaskList[0].buildertek__Schedule__c;

            List<buildertek__Project_Task__c> projectTaskList = [SELECT Id, Name, buildertek__Dependency__c, buildertek__Milestone__c, buildertek__Dependency__r.Name, buildertek__Schedule__c, buildertek__Phase__c, buildertek__Start__c, buildertek__finish__c
                                                                 FROM buildertek__Project_Task__c
                                                                 WHERE buildertek__Schedule__c = :scheduleId
                                                                 ORDER BY buildertek__Phase__c];

            Map<String, Date> phaseDateMap = new Map<String, Date>();
            Map<String, buildertek__Project_Task__c> phaseMileStoneMap = new Map<String, buildertek__Project_Task__c>();

            for (buildertek__Project_Task__c projectTask : projectTaskList){
                System.debug('projectTask ==> '+projectTask);
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
                System.debug('phaseDateMap ==> '+phaseDateMap.get(key));
                if (phaseMileStoneMap.containsKey(key)){
                    buildertek__Project_Task__c task = phaseMileStoneMap.get(key);
                    if (checkIncludeWeekendSettings) {
						task.buildertek__Start__c = phaseDateMap.get(key);
						task.buildertek__Finish__c = phaseDateMap.get(key);
					} else {
						task.buildertek__Start__c = skipWeekend(phaseDateMap.get(key));
						task.buildertek__Finish__c = skipWeekend(phaseDateMap.get(key));
					}
                    if (key != null && key != ''){
                        System.debug('task ===> '+task);
                        mileStoneList.add(task) ;
                    }
                } else{
                    buildertek__Project_Task__c task = new buildertek__Project_Task__c();
                    task.Name = 'Milestone Complete';
                    task.buildertek__Phase__c = key;
					if (checkIncludeWeekendSettings) {
						task.buildertek__Start__c = phaseDateMap.get(key);
						task.buildertek__Finish__c = phaseDateMap.get(key);
					} else {
						task.buildertek__Start__c = skipWeekend(phaseDateMap.get(key));
						task.buildertek__Finish__c = skipWeekend(phaseDateMap.get(key));
					}
                    task.buildertek__Duration__c = 0;
                    task.buildertek__Schedule__c = scheduleId;
                    task.buildertek__Milestone__c = true;
                    task.buildertek__Type__c = 'Milestone';
                    if (key != null && key != ''){
                        System.debug('task ===> '+task);
                        mileStoneList.add(task) ;
                    }
                }
            }
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = true;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;

            upsert mileStoneList;
            updateProjectAnticipatedDate(newTaskList);
            NewGanttChartTaskTriggerHandler.blnSkipTaskTrigger = false;
            ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;
            System.debug('mileStoneList: ' + mileStoneList);

        }
    }

    public static Date skipWeekend(Date startDate){
		DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
		String todayDay = currDate.format('EEEE');
		if (todayDay == 'Saturday'){
			startDate = startDate.addDays(2);
		} else if (todayDay == 'Sunday'){
			startDate = startDate.addDays(1);
		}
		return startDate;
	}

    public static void updateProjectAnticipatedDate(List<buildertek__Project_Task__c> taskList) {
        if (taskList.size()>0) {
            String projectId = taskList[0].buildertek__Project__c;

            if (!String.isBlank(projectId)) {
                buildertek__Schedule__c scheduleRec = [SELECT Id, Name, buildertek__End_Date__c, buildertek__Start_Date__c, buildertek__Project__c
                                                       FROM buildertek__Schedule__c
                                                       WHERE buildertek__Project__c = :projectId ORDER BY buildertek__End_Date__c DESC LIMIT 1];

                buildertek__Project__c projectOnSchedule = new buildertek__Project__c();
                projectOnSchedule.Id = projectId;
                projectOnSchedule.buildertek__Estimated_Completion_Date__c = scheduleRec.buildertek__End_Date__c;
                update projectOnSchedule;
            }
        }
    }

    public static void OnBeforeInsert(Project_Task__c[] newProjectTasks){
		Set<id> accountIds = new Set<id>();
		for (Project_Task__c newProjectTask : newProjectTasks){
			accountIds.add(newProjectTask.buildertek__Contractor__c);
		}
		Map<id, account> newMapAccounts = new Map<id, account>([select id, buildertek__Trade_Type_Lookup__c
		                                                        from Account
		                                                        where id IN:accountIds]);
		for (Project_Task__c newProjectTask : newProjectTasks){

			/**
			 * BUIL-2551
			 * Update completed checkbox true when completion is 100, if completion is less than 100 then completed checkbox false
			 */
			if (newProjectTask.buildertek__Completion__c == 100){
				newProjectTask.buildertek__Actual_Completion_date__c = system.today();
				newProjectTask.buildertek__Completed__c = true;
			}else if (newProjectTask.buildertek__Completion__c < 100 &&  newProjectTask.buildertek__Completion__c > 0 && newProjectTask.buildertek__Actual_Start_Date__c == null){
				newProjectTask.buildertek__Actual_Start_Date__c=system.today();
			}else if (newProjectTask.buildertek__Completion__c < 100){
				newProjectTask.buildertek__Actual_Completion_date__c = null;
				newProjectTask.buildertek__Completed__c = false;
			}
			/**
			 * BUIL-3308
			 * When the user check the Completed checkbox it should set the Completion % field - 100 and set the Actual Completion Date = TODAY()
			 */
			if (newProjectTask.buildertek__Completed__c == true){
				newProjectTask.buildertek__Actual_Completion_date__c = system.today();
				newProjectTask.buildertek__Completion__c = 100;
			}

			if (newProjectTask.buildertek__Completion__c > 0 && newProjectTask.buildertek__Completion_updated__c == false){
				newProjectTask.buildertek__Actual_Start_Date__c = system.today();
				newProjectTask.buildertek__Completion_updated__c = true;
			}

			//Get 'Trade Type' from selected Contractor[Account] and update 'Trade Type' field in Schedule Item
			if (newProjectTask.buildertek__Contractor__c != null && newMapAccounts.containsKey(newProjectTask.buildertek__Contractor__c)){
				if (newMapAccounts.get(newProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c != null){
					newProjectTask.buildertek__Trade_Type__c = newMapAccounts.get(newProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
				}
			}
		}
	}

	public static void OnBeforeUpdate(Project_Task__c[] oldProjectTasks, Project_Task__c[] updatedProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap, Map<Id, Project_Task__c> oldProjectTaskMap){
		Set<Id> accountIds = new Set<Id>();
		system.debug('updatedprojecttasks:- '+updatedProjectTasks);
		system.debug('oldprojecttasks:- '+oldProjectTasks);
		for (Project_Task__c updatedProjectTask : updatedProjectTasks){
			accountIds.add(updatedProjectTask.buildertek__Contractor__c);
		}
		Map<id, Account> updatedMapAccounts = new Map<id, Account>([Select id, buildertek__Trade_Type_Lookup__c
		                                                            from Account
		                                                            where id IN:accountIds]);
		for (Project_Task__c updatedProjectTask : updatedProjectTasks){

			//Actual Completion date
			if (updatedProjectTask.buildertek__Completion__c == 100){
				updatedProjectTask.buildertek__Actual_Completion_date__c = system.today();
				updatedProjectTask.buildertek__Completed__c = true;
			}else if (updatedProjectTask.buildertek__Completion__c < 100 && updatedProjectTask.buildertek__Completion__c > 0 && updatedProjectTask.buildertek__Actual_Start_Date__c == null){
				updatedProjectTask.buildertek__Actual_Start_Date__c = system.today();
			}else if (updatedProjectTask.buildertek__Completion__c < 100){
				updatedProjectTask.buildertek__Actual_Completion_date__c = null;
				updatedProjectTask.buildertek__Completed__c = false;
			}

			/**
			 * BUIL-3308
			 * When the user check the Completed checkbox it should set the Completion % field - 100 and set the Actual Completion Date = TODAY()
			 */
			if (updatedProjectTask.buildertek__Completed__c == true){
				updatedProjectTask.buildertek__Actual_Completion_date__c = system.today();
				updatedProjectTask.buildertek__Completion__c = 100;
			}


			if (updatedProjectTask.buildertek__Completion__c > 0 && updatedProjectTask.buildertek__Completion_updated__c == false){
				updatedProjectTask.buildertek__Actual_Start_Date__c = system.today();
				updatedProjectTask.buildertek__Completion_updated__c = true;
			}

			//Get 'Trade Type' from selected Contractor[Account] and update 'Trade Type' field in Schedule Item
			if (updatedProjectTask.buildertek__Contractor__c != null && updatedMapAccounts.containsKey(updatedProjectTask.buildertek__Contractor__c)){
				if (updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c != null){
					if (updatedProjectTask.buildertek__Contractor__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Contractor__c || updatedProjectTask.buildertek__Trade_Type__c == null || updatedProjectTask.buildertek__Trade_Type__c != updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c){
						updatedProjectTask.buildertek__Trade_Type__c = updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
					}
				}
			} else if (updatedProjectTask.buildertek__Contractor__c == null && oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Contractor__c != null){
				updatedProjectTask.buildertek__Trade_Type__c = null;
			}

			if (String.isBlank(updatedProjectTask.buildertek__Dependency__c)){
				updatedProjectTask.buildertek__Schedule_Item_Dependency_Path__c = '';
			}
		}
	}

}