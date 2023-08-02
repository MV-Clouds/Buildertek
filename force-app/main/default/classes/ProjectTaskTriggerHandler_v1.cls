/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  24-May-2018
 */
public with sharing class ProjectTaskTriggerHandler_v1{
	public static Boolean isFirstTime = true;
	public static Boolean isTask = true;
	//Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipTaskTrigger = false;
	public static Boolean isFromImport = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public ProjectTaskTriggerHandler_v1(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnBeforeInsert(Project_Task__c[] newProjectTasks){
		Set<id> accountIds = new Set<id>();
		System.debug('OnBeforeInsert-->');
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
			} else if (newProjectTask.buildertek__Completion__c < 100){
				newProjectTask.buildertek__Actual_Completion_date__c = null;
				newProjectTask.buildertek__Completed__c = false;
			}
			//Calculate Start Date And End Date with Weekends.
			if (newProjectTask.buildertek__Start__c != null){
				Date sDate = newProjectTask.buildertek__Start__c;
				sDate = getStartDate(sDate);
				//endDate = parentTask.buildertek__finish__c.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
				if (newProjectTask.buildertek__Duration__c != null && newProjectTask.buildertek__Duration__c > 0){
					Date eDate = sDate.addDays(Integer.valueOf(newProjectTask.buildertek__Duration__c) - 1);
					newProjectTask.buildertek__Finish__c = getEndDate(sDate, eDate);
				} else if (newProjectTask.buildertek__Finish__c != null){
					if (sDate.daysBetween(newProjectTask.buildertek__Finish__c) > 0){
						newProjectTask.buildertek__Duration__c = sDate.daysBetween(newProjectTask.buildertek__Finish__c) + 1;
					} else{
						if (sDate.daysBetween(newProjectTask.buildertek__Finish__c) == 0){
							newProjectTask.buildertek__Duration__c = 1;
						}

					}
					// newProjectTask.buildertek__Duration__c = sDate.daysBetween(newProjectTask.buildertek__Finish__c);
				} else{
					newProjectTask.buildertek__Duration__c = 1;
					newProjectTask.buildertek__Finish__c = getEndDate(sDate, sDate);
				}

				if (newProjectTask.buildertek__Completion__c == 100){
					newProjectTask.buildertek__Actual_Completion_date__c = system.today();
				} else if (newProjectTask.buildertek__Completion__c < 100){
					newProjectTask.buildertek__Actual_Completion_date__c = null;
				}
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

	public void OnBeforeUpdate(Project_Task__c[] oldProjectTasks, Project_Task__c[] updatedProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap, Map<Id, Project_Task__c> oldProjectTaskMap){
		Set<Id> accountIds = new Set<Id>();
		for (Project_Task__c updatedProjectTask : updatedProjectTasks){
			accountIds.add(updatedProjectTask.buildertek__Contractor__c);
		}
		Map<id, Account> updatedMapAccounts = new Map<id, Account>([Select id, buildertek__Trade_Type_Lookup__c
		                                                            from Account
		                                                            where id IN:accountIds]);
		for (Project_Task__c updatedProjectTask : updatedProjectTasks){
			//Calculate Start Date And End Date with Weekends.
			//system.debug(updatedProjectTask.buildertek__Start__c);

			//Actual Completion date
			if (updatedProjectTask.buildertek__Completion__c == 100){
				updatedProjectTask.buildertek__Actual_Completion_date__c = system.today();
				updatedProjectTask.buildertek__Completed__c = true;
			} else if (updatedProjectTask.buildertek__Completion__c < 100){
				updatedProjectTask.buildertek__Actual_Completion_date__c = null;
				updatedProjectTask.buildertek__Completed__c = false;
			}
			if (updatedProjectTask.buildertek__Completion__c > 0 && updatedProjectTask.buildertek__Completion_updated__c == false){
				updatedProjectTask.buildertek__Actual_Start_Date__c = system.today();
				updatedProjectTask.buildertek__Completion_updated__c = true;
			}

			//duration should not be 0
			if (updatedProjectTask.buildertek__Duration__c != null && updatedProjectTask.buildertek__Duration__c <= 0){
				updatedProjectTask.buildertek__Duration__c = 1;
			}

			if (!updatedProjectTask.buildertek__Milestone__c){
				Date finishDate = updatedProjectTask.buildertek__Finish__c;
				Decimal duration = updatedProjectTask.buildertek__Duration__c;

				if (updatedProjectTask.buildertek__Start__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c){
					//0 0 1 => Update Finish Date
					Date sDate = updatedProjectTask.buildertek__Start__c;
					Date eDate = sDate.addDays(Integer.valueOf(updatedProjectTask.buildertek__Duration__c) - 1);
					finishDate = getEndDate(sDate, eDate);
				} else if ((updatedProjectTask.buildertek__Start__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c) || (updatedProjectTask.buildertek__Start__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c)){
					//0 1 1 => Update Finish Date
					Date sDate = updatedProjectTask.buildertek__Start__c;
					sDate = getStartDate(sDate);
					Date eDate = sDate.addDays(Integer.valueOf(updatedProjectTask.buildertek__Duration__c) - 1);
					finishDate = getEndDate(sDate, eDate);
				} else if ((updatedProjectTask.buildertek__Start__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c) || (updatedProjectTask.buildertek__Start__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c) || (updatedProjectTask.buildertek__Start__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Start__c && updatedProjectTask.buildertek__Finish__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Finish__c && updatedProjectTask.buildertek__Duration__c == oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Duration__c)){
					//0 1 0 => Update Duration
					//1 0 0 => Update Duration
					Date sDate = updatedProjectTask.buildertek__Start__c;
					sDate = ProjectTaskTriggerHandler_v1.getStartDate(sDate);
					duration = calculateDuration(sDate, updatedProjectTask.buildertek__Finish__c);
					System.debug('duration in before ==> ' + duration + ' updatedProjectTask task id ' + updatedProjectTask.id);
				}
				System.debug('duration in before outside condition ==> ' + duration + ' updatedProjectTask task id ' + updatedProjectTask.id);
				updatedProjectTask.buildertek__Finish__c = finishDate;
				updatedProjectTask.buildertek__Duration__c = duration;
			} else{

			}

			//Get 'Trade Type' from selected Contractor[Account] and update 'Trade Type' field in Schedule Item
			if (updatedProjectTask.buildertek__Contractor__c != null && updatedMapAccounts.containsKey(updatedProjectTask.buildertek__Contractor__c)){
				//Check 'Trade Type' in Contractor(Account)
				if (updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c != null){
					// Change 'Trade Type', if Contactor(Account) changed (or) 'Trade Type' in Schedule Item is null (or) 'Trade Type' in Schedule Item not equal to 'Trade Type' in Contractor(Account)
					if (updatedProjectTask.buildertek__Contractor__c != oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Contractor__c || updatedProjectTask.buildertek__Trade_Type__c == null || updatedProjectTask.buildertek__Trade_Type__c != updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c){
						updatedProjectTask.buildertek__Trade_Type__c = updatedMapAccounts.get(updatedProjectTask.buildertek__Contractor__c).buildertek__Trade_Type_Lookup__c;
					}
				}
			} else if (updatedProjectTask.buildertek__Contractor__c == null && oldProjectTaskMap.get(updatedProjectTask.Id).buildertek__Contractor__c != null){
				// if Contractor is removed, making 'Trade Type' field in schedule item as null
				updatedProjectTask.buildertek__Trade_Type__c = null;
			}

			if (String.isBlank(updatedProjectTask.buildertek__Dependency__c)){
				updatedProjectTask.buildertek__Schedule_Item_Dependency_Path__c = '';
			}
		}
	}

	public void OnAfterInsert(Project_Task__c[] ProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap){
		Map<String, Decimal> purchaseOrderMap = new Map<String, Decimal>();
		Map<String, Decimal> budgetLineMap = new Map<String, Decimal>();
		Map<String, String> scheduleIdMap = new Map<String, String>();
		Set<Id> scheduleIds = new Set<Id>();

		//check last date of previous tasks in the schedule
		List<buildertek__Project_Task__c> previuosTasks = [Select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
		                                                   FROM buildertek__Project_Task__c
		                                                   WHERE buildertek__Schedule__c = :ProjectTasks[0].buildertek__Schedule__c AND Id NOT IN:ProjectTaskMap.keySet() AND buildertek__Milestone__c = :false
		                                                   ORDER By CreatedDate ASC, buildertek__Order__c
		                                                   NULLS LAST];//buildertek__Phase__c,buildertek__Milestone__c,buildertek__Start__c//buildertek__Start__c ASC];//buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c
		if (previuosTasks.Size() > 0)
			system.debug('Tasks  Item 00        ' + previuosTasks[previuosTasks.size() - 1]);
		Map<String, buildertek__Project_Task__c> previousTaskmap = new Map<String, buildertek__Project_Task__c>();
		for (buildertek__Project_Task__c task : previuosTasks){
			previousTaskmap.put(task.Id, task);
		}

		for (buildertek__Project_Task__c schItem : ProjectTasks){
			scheduleIds.add(schItem.buildertek__Schedule__c);
		}
		Map<Id, buildertek__Schedule__c> taskCompletionMap = new Map<Id, buildertek__Schedule__c>();
		List<buildertek__Schedule__c> scheduleToCountDays = [Select Id, (Select Id, buildertek__Completed__c, buildertek__Milestone__c, buildertek__Completion__c, buildertek__Duration__c
		                                                                 FROM buildertek__Schedule_Tasks__r
		                                                                 WHERE buildertek__Milestone__c = :false)
		                                                     FROM buildertek__Schedule__c
		                                                     WHERE ID IN:scheduleIds];
		for (buildertek__Schedule__c sc : scheduleToCountDays){
			sc.buildertek__Days_Completed__c = 0;
			for (buildertek__Project_Task__c projectTask : sc.buildertek__Schedule_Tasks__r){
				if (taskCompletionMap.get(sc.Id) == null){
					taskCompletionMap.put(sc.Id, new buildertek__Schedule__c());
				}
				buildertek__Schedule__c scheduleRec = new buildertek__Schedule__c();
				scheduleRec.Id = sc.Id;
				projectTask.buildertek__Completion__c = projectTask.buildertek__Completion__c == null ? 0 : projectTask.buildertek__Completion__c;

				if (taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null){
					scheduleRec.buildertek__Days_Completed__c = taskCompletionMap.get(sc.Id) != null && taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null ? taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c + ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0) : ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0);
				}
				// scheduleRec.buildertek__Days_Completed__c = taskCompletionMap.get(sc.Id) != null && taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null ? taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c + ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0) : ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0);
				taskCompletionMap.put(scheduleRec.Id, scheduleRec);
			}
		}
		update taskCompletionMap.values();
		Map<Id, buildertek__Schedule__c> scheduleMap = new Map<Id, buildertek__Schedule__c>([Select Id, buildertek__Initial_Start_Date__c, Name, buildertek__Contractor__c, buildertek__External_Resource__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c
		                                                                                     FROM buildertek__Schedule__c
		                                                                                     WHERE Id In:scheduleIds]);
		List<buildertek__Purchase_Order__c> POList = new List<buildertek__Purchase_Order__c>();

		List<buildertek__Budget_Item__c> budgetLineList = new List<buildertek__Budget_Item__c>();
		List<Project_Task__c> newScheduleItemList = new List<Project_Task__c>();
		if (ProjectTasks.size() > 0){
			for (Project_Task__c schItem : ProjectTasks){
				Project_Task__c newScheduleItem = new Project_Task__c();
				newScheduleItem.Id = schItem.Id;
				//newScheduleItem.buildertek__Start__c = schItem.buildertek__Start__c;
				newScheduleItem.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler_v1.getStartDate(schItem.buildertek__Start__c);
				if (schItem.buildertek__Duration__c != null && schItem.buildertek__Duration__c > 0){
					newScheduleItem.buildertek__Original_End_Date__c = schItem.buildertek__Start__c.addDays(Integer.valueOf(schItem.buildertek__Duration__c) - 1);
					newScheduleItem.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler_v1.getEndDate(schItem.buildertek__Start__c, newScheduleItem.buildertek__Original_End_Date__c);
				}
				if (schItem.buildertek__Use_External_Resource_from_Schedule__c && scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__External_Resource__c != null){
					newScheduleItem.buildertek__Contractor_Resource__c = scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__External_Resource__c;
				}
				if (schItem.buildertek__Use_Internal_Resource_from_Schedule__c && scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__Internal_Resource_1__c != null){
					newScheduleItem.buildertek__Resource__c = scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__Internal_Resource_1__c;
				}
				if (schItem.buildertek__Use_Project_Manager_from_Schedule__c && scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__Project_Manager__c != null){
					newScheduleItem.buildertek__Project_Manager__c = scheduleMap.get(schItem.buildertek__Schedule__c).buildertek__Project_Manager__c;
				}
				newScheduleItemList.add(newScheduleItem);
				if (schItem.buildertek__Purchase_Order__c != null){
					purchaseOrderMap.put(schItem.buildertek__Purchase_Order__c, schItem.buildertek__Completion__c);
					scheduleIdMap.put(schItem.buildertek__Purchase_Order__c, schItem.Id);
				}
				if (schItem.buildertek__Budget_Line__c != null){
					budgetLineMap.put(schItem.buildertek__Budget_Line__c, schItem.buildertek__Completion__c);
					scheduleIdMap.put(schItem.buildertek__Budget_Line__c, schItem.Id);
				}
			}
			if (newScheduleItemList.size() > 0){
				Boolean flag = ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger;
				ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = !flag;
				update newScheduleItemList;
				ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = flag;
			}
		}

		for (String purchaseOrderId : purchaseOrderMap.keySet()){
			buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
			PO.Id = purchaseOrderId;
			PO.buildertek__Completion__c = purchaseOrderMap.get(purchaseOrderId);
			PO.buildertek__Schedule_Item__c = scheduleIdMap.get(purchaseOrderId);
			POList.add(PO);
		}

		for (String budgetLineId : budgetLineMap.keySet()){
			buildertek__Budget_Item__c Bl = new buildertek__Budget_Item__c();
			Bl.Id = budgetLineId;
			Bl.buildertek__Complete__c = budgetLineMap.get(budgetLineId);
			budgetLineList.add(Bl);
		}

		if (POList.size() > 0){
			update POList;
		}

		if (budgetLineList.Size() > 0){
			update budgetLineList;
		}

		processRecords(scheduleIds, ProjectTasks[0].buildertek__Schedule__c, ProjectTaskMap.keySet(), ProjectTaskTriggerHandler_v1.isFromImport, 'insert');
	}

	public void UpdateOriginalstartandEndDates(Project_Task__c[] ProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap){

		Map<id, Project_Task__c> ProjectTaskIds = new Map<Id, Project_Task__c>();
		for (Project_Task__c ItemRec : ProjectTasks){
			ProjectTaskIds.put(ItemRec.id, ItemRec);
		}
		if (ProjectTaskIds.size() > 0){
			//future_scheduleitembatch(ProjectTaskIds.keyset());
			database.executeBatch(new ScheduleItemBatchClass(ProjectTaskIds)); // Calling batch class.
		}

		/* Set<Id> scheduleIds = new Set<Id>();
		 for (buildertek__Project_Task__c schItem : ProjectTasks){
		 scheduleIds.add(schItem.buildertek__Schedule__c);
		 }
		 List<id> projectids = new List<id>();
		 list<buildertek__Schedule__c> scheduleListAscItems = [Select Id, Name,buildertek__Project__c, buildertek__Contractor__c, buildertek__External_Resource__c,
		 buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c,
		 (select id,Name,buildertek__Schedule__c,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c
		 from buildertek__Schedule_Tasks__r Order by createdDate ASC LIMIT 1) FROM buildertek__Schedule__c WHERE Id In :scheduleIds];
		 list<buildertek__Schedule__c> scheduleListDescItems = [Select Id, Name,buildertek__Project__c, buildertek__Contractor__c, buildertek__External_Resource__c,
		 buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c,
		 (select id,Name,buildertek__Schedule__c,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c
		 from buildertek__Schedule_Tasks__r Order by createdDate DESC LIMIT 1) FROM buildertek__Schedule__c WHERE Id In :scheduleIds];
		 for(buildertek__Schedule__c schRec : scheduleListAscItems){
		 projectids.add(schRec.buildertek__Project__c);
		 }
		 List<buildertek__Project__c> projectList = [select id,buildertek__Original_Start_Date__c,buildertek__Original_End_Date__c from buildertek__Project__c where id IN: projectids];

		 for(buildertek__Project__c projectRec : projectList){
		 for(buildertek__Schedule__c schAsc : scheduleListAscItems){
		 for(buildertek__Project_Task__c item : schAsc.buildertek__Schedule_Tasks__r){
		 if(projectRec.id == schAsc.buildertek__Project__c){
		 projectRec.buildertek__Original_Start_Date__c = item.buildertek__Original_Start_Date__c;
		 }
		 }
		 }
		 for(buildertek__Schedule__c schAsc : scheduleListDescItems){
		 for(buildertek__Project_Task__c item : schAsc.buildertek__Schedule_Tasks__r){
		 if(projectRec.id == schAsc.buildertek__Project__c){
		 projectRec.buildertek__Original_End_Date__c = item.buildertek__Original_End_Date__c;
		 }
		 }
		 }
		 }
		 update projectList;*/
	}

	public void OnAfterUpdateOriginalstartandEndDates(Project_Task__c[] oldProjectTasks, Project_Task__c[] updatedProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap, Map<Id, Project_Task__c> oldProjectTaskMap){
		System.debug('3rd method data in new list ==> ' + updatedProjectTasks);
		List<Project_Task__C> testSIList = new List<Project_Task__C>();
		testSIList = [Select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
		              FROM buildertek__Project_Task__c
		              WHERE buildertek__Schedule__c = :updatedProjectTasks[0].buildertek__Schedule__c];
		for (Project_Task__C task23 : testSIList){
			System.debug('testSILIST Start Date ==> ' + task23.buildertek__Start__c + ' and Id ' + task23.Id);
		}
		Map<id, Project_Task__c> ProjectTaskIds = new Map<Id, Project_Task__c>();
		for (Project_Task__c ItemRec : updatedProjectTasks){
			//system.debug(ItemRec.buildertek__Start__c);
			ProjectTaskIds.put(ItemRec.id, ItemRec);
		}


		if (ProjectTaskIds.size() > 0){
			database.executeBatch(new ScheduleItemBatchClass(ProjectTaskIds));
		}
		System.debug('3rd method data at end of method new list ==> ' + updatedProjectTasks);
	}

	public void OnAfterUpdate(Project_Task__c[] oldProjectTasks, Project_Task__c[] updatedProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap, Map<Id, Project_Task__c> oldProjectTaskMap){
		System.debug('updatedProjectTasks in the beginning of method ==> ' + updatedProjectTasks);
		List<Project_Task__C> testSIList = new List<Project_Task__C>();
		testSIList = [Select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
		              FROM buildertek__Project_Task__c
		              WHERE buildertek__Schedule__c = :updatedProjectTasks[0].buildertek__Schedule__c];
		for (Project_Task__C task23 : testSIList){
			System.debug('2nd method testSILIST onAfterUpdate Start Date ==> ' + task23.buildertek__Start__c + ' and Id' + task23.Id);
		}
		contact con = [Select Id, Email
		               from Contact
		               WHERE Email != null
		               ORDER BY CreatedDate Desc
		               LIMIT 1];
		List<EmailTemplate> vendorEmailTemplate = [Select Id, Subject, Description, HtmlValue, DeveloperName, Body
		                                           from EmailTemplate
		                                           where DeveloperName = 'Vendor_Email'];
		Set<Id> scheduleIdSet = new Set<Id>();
		Set<Id> scheduleIds = new Set<Id>();

		//previous tasks
		List<buildertek__Project_Task__c> previuosTasks = [Select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
		                                                   FROM buildertek__Project_Task__c
		                                                   WHERE buildertek__Schedule__c = :updatedProjectTasks[0].buildertek__Schedule__c AND Id NOT IN:ProjectTaskMap.keySet() AND buildertek__Milestone__c = :false
		                                                   ORDER By CreatedDate ASC, buildertek__Order__c
		                                                   NULLS LAST];//buildertek__Phase__c,buildertek__Milestone__c,buildertek__Start__c//buildertek__Start__c ASC];buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c
		if (previuosTasks.Size() > 0)
			system.debug('Previous Task              ' + previuosTasks[previuosTasks.Size() - 1]);
		Map<String, buildertek__Project_Task__c> previousTaskmap = new Map<String, buildertek__Project_Task__c>();
		for (buildertek__Project_Task__c task : previuosTasks){
			previousTaskmap.put(task.Id, task);
		}

		//Vendor Change Schedule tasks Email
		List<buildertek__CommunityURL__c> vendorCommunityURL = buildertek__CommunityURL__c.getAll().values();
		string SiteUrl;
		if (vendorCommunityURL.size() > 0){
			SiteUrl = vendorCommunityURL[0].buildertek__VendorCommunityURL__c;
		}
		for (buildertek__Project_Task__c schItem : updatedProjectTasks){
			scheduleIds.add(schItem.buildertek__Schedule__c);
		}
		Map<Id, buildertek__Schedule__c> taskCompletionMap = new Map<Id, buildertek__Schedule__c>();
		List<buildertek__Schedule__c> scheduleToCountDays = [Select Id, (Select Id, buildertek__Start__c, buildertek__Finish__c, buildertek__Completed__c, buildertek__Milestone__c, buildertek__Completion__c, buildertek__Duration__c
		                                                                 FROM buildertek__Schedule_Tasks__r
		                                                                 WHERE buildertek__Milestone__c = :false)
		                                                     FROM buildertek__Schedule__c
		                                                     WHERE ID IN:scheduleIds];

		List<buildertek__Schedule__c> updateScheduleList = new List<buildertek__Schedule__c>();
		for (buildertek__Schedule__c sc : scheduleToCountDays){
			sc.buildertek__Days_Completed__c = 0;
			for (buildertek__Project_Task__c projectTask : sc.buildertek__Schedule_Tasks__r){
				if (taskCompletionMap.get(sc.Id) == null){
					taskCompletionMap.put(sc.Id, new buildertek__Schedule__c());
				}
				buildertek__Schedule__c scheduleRec = new buildertek__Schedule__c();
				scheduleRec.Id = sc.Id;
				projectTask.buildertek__Completion__c = projectTask.buildertek__Completion__c == null ? 0 : projectTask.buildertek__Completion__c;
				//scheduleRec.buildertek__Days_Completed__c = taskCompletionMap.get(sc.Id) != null && taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null ? taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c + ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0) : ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0);

				if (taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null){
					scheduleRec.buildertek__Days_Completed__c = taskCompletionMap.get(sc.Id) != null && taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c != null ? taskCompletionMap.get(sc.Id).buildertek__Days_Completed__c + ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0) : ((projectTask.buildertek__Duration__c * projectTask.buildertek__Completion__c) / 100).setScale(0);
				}
				taskCompletionMap.put(scheduleRec.Id, scheduleRec);
			}


		}
		ScheduleTriggerHandler handler = new ScheduleTriggerHandler(true, taskCompletionMap.values().size());
		handler.blnSkipTaskTrigger = true;
		update taskCompletionMap.values();

		handler.blnSkipTaskTrigger = false;
		system.debug(updatedProjectTasks);
		Map<Id, buildertek__Schedule__c> scheduleMap1 = new Map<Id, buildertek__Schedule__c>([Select Id, buildertek__Initial_Start_Date__c, Name, buildertek__Contractor__c, buildertek__Internal_Resource_1__c, buildertek__Project_Manager__c, buildertek__Days_Completed__c
		                                                                                      FROM buildertek__Schedule__c
		                                                                                      WHERE Id In:scheduleIds]);
		List<buildertek__Schedule__c> scheduleUpdatedList = new List<buildertek__Schedule__c>();
		SET<Id> scheduleItemUpdateIds = new SET<Id>();
		list<string> projectTaskId = new list<string>();
		Set<Id> scheduleItemIds = new Set<Id>();
		List<buildertek__Project_Task__c> scheduleItemsToUpdate = new List<buildertek__Project_Task__c>();
		Map<Id, List<buildertek__Project_Task__c>> scheduleItemMap = new Map<Id, List<buildertek__Project_Task__c>>();
		Map<Id, Date> startDateMap = new Map<Id, Date>();
		Map<Id, Date> endDateMap = new Map<Id, Date>();
		for (Project_Task__c scheduleItem : updatedProjectTasks){
			system.debug('check your startDate here scheduleItem.buildertek__Start__c ' + scheduleItem.buildertek__Start__c);
			scheduleIdSet.add(scheduleItem.buildertek__Schedule__c);
			if (scheduleItem.buildertek__Start__c != oldProjectTaskMap.get(scheduleItem.id).buildertek__Start__c){
				scheduleItemUpdateIds.add(scheduleItem.id);
				scheduleItemIds.add(scheduleItem.Id);
			}
			if ((scheduleItem.buildertek__Schedule__c != null) && (scheduleItem.buildertek__Start__c != oldProjectTaskMap.get(scheduleItem.id).buildertek__Start__c || scheduleItem.buildertek__Finish__c != oldProjectTaskMap.get(scheduleItem.id).buildertek__Finish__c)){
				projectTaskId.add(scheduleItem.id);
				scheduleIds.add(scheduleItem.buildertek__Schedule__c);
			}
			// For Days Completed in schedule
			//if (scheduleItem.buildertek__Completion__c != oldProjectTaskMap.get(scheduleItem.id).buildertek__Completion__c){
			// if(scheduleItem.buildertek__Completion__c == 100){
			//     buildertek__Schedule__c schedule = new buildertek__Schedule__c();
			//     schedule.Id = scheduleItem.buildertek__Schedule__c;
			//     schedule.buildertek__Days_Completed__c = scheduleMap1.get(scheduleItem.buildertek__Schedule__c).buildertek__Days_Completed__c + scheduleItem.buildertek__Duration__c;
			//     scheduleUpdatedList.add(schedule);
			// }else{
			//     buildertek__Schedule__c schedule = new buildertek__Schedule__c();
			//     schedule.Id = scheduleItem.buildertek__Schedule__c;
			//     Decimal numberofDays = scheduleItem.buildertek__Completion__c*scheduleItem.buildertek__Duration__c/100;
			//     schedule.buildertek__Days_Completed__c =scheduleMap1.get(scheduleItem.buildertek__Schedule__c).buildertek__Days_Completed__c +  numberofDays.intValue();
			//     scheduleUpdatedList.add(schedule);
			// }
			//}
		}
		// system.debug('scheduleUpdatedList::::' + scheduleUpdatedList);
		// if (scheduleUpdatedList.size() > 0){
		//     update scheduleUpdatedList;
		// }


		/*List<buildertek__Schedule__c> scheduleList = [select id, Name, buildertek__Project__c, buildertek__Project__r.buildertek__Customer__c, buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c, buildertek__Notify_Vendor_on_Schedule_Change__c
		 from buildertek__Schedule__c
		 where buildertek__Notify_Vendor_on_Schedule_Change__c != false and Id IN :scheduleIds];*/
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		// for (buildertek__Schedule__c scheduleRec : scheduleList){
		for (buildertek__Schedule__c scheduleRec : [select id, Name, buildertek__Project__c, buildertek__Project__r.buildertek__Customer__c, buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c, buildertek__Notify_Vendor_on_Schedule_Change__c
		                                            from buildertek__Schedule__c
		                                            where buildertek__Notify_Vendor_on_Schedule_Change__c != false and Id IN:scheduleIds]){

			if (scheduleRec.buildertek__Project__r != null && scheduleRec.buildertek__Project__r.buildertek__Customer__r != null && scheduleRec.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c != null){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				//List of people who should get the email
				List<String> sendTo = new List<String>();
				sendTo.add(scheduleRec.buildertek__Project__r.buildertek__Customer__r.buildertek__Email_Address__c);
				mail.setToAddresses(sendTo);
				// Set email is sent from
				mail.setSenderDisplayName('Builder Tek');
				if (vendorEmailTemplate.size() > 0){
					mail.setTemplateID(vendorEmailTemplate[0].Id);
				}
				mail.setTargetObjectId(con.id);
				mail.setWhatId(scheduleRec.buildertek__Project__r.buildertek__Customer__c);
				mail.setSaveAsActivity(false);
				mail.setTreatTargetObjectAsRecipient(false);
				mails.add(mail);

			}
		}
		if (mails.size() > 0 && vendorEmailTemplate.size() > 0){
			Messaging.sendEmail(mails);
		}

		Map<String, Decimal> purchaseOrderMap = new Map<String, Decimal>();
		Map<String, Decimal> budgetLineMap = new Map<String, Decimal>();


		Map<String, String> scheduleIdMap = new Map<String, String>();
		List<buildertek__Purchase_Order__c> POList = new List<buildertek__Purchase_Order__c>();
		List<buildertek__Budget_Item__c> budgetLineList = new List<buildertek__Budget_Item__c>();

		if (updatedProjectTasks.size() > 0){
			for (Project_Task__c schItem : updatedProjectTasks){
				if (schItem.buildertek__Purchase_Order__c != null){
					purchaseOrderMap.put(schItem.buildertek__Purchase_Order__c, schItem.buildertek__Completion__c);
					scheduleIdMap.put(schItem.buildertek__Purchase_Order__c, schItem.Id);
				}
				if (schItem.buildertek__Budget_Line__c != null){
					budgetLineMap.put(schItem.buildertek__Budget_Line__c, schItem.buildertek__Completion__c);
					scheduleIdMap.put(schItem.buildertek__Budget_Line__c, schItem.Id);
				}
			}
		}
		System.debug('updatedProjectTasks ==> ' + updatedProjectTasks);

		for (String purchaseOrderId : purchaseOrderMap.keySet()){
			buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
			PO.Id = purchaseOrderId;
			PO.buildertek__Completion__c = purchaseOrderMap.get(purchaseOrderId);
			PO.buildertek__Schedule_Item__c = scheduleIdMap.get(purchaseOrderId);
			POList.add(PO);
		}

		for (String budgetLineId : budgetLineMap.keySet()){
			buildertek__Budget_Item__c Bl = new buildertek__Budget_Item__c();
			Bl.Id = budgetLineId;
			Bl.buildertek__Complete__c = budgetLineMap.get(budgetLineId);
			// Bl.buildertek__Schedule_Item__c = scheduleIdMap.get(budgetLineId);
			budgetLineList.add(Bl);
		}

		if (POList.size() > 0){
			update POList;
		}

		if (budgetLineList.Size() > 0){
			update budgetLineList;
		}
		processRecords(scheduleIds, updatedProjectTasks[0].buildertek__Schedule__c, ProjectTaskMap.keySet(), ProjectTaskTriggerHandler_v1.isFromImport, 'update');
		List<Project_Task__c> newProjectTask = [Select Id, Name, buildertek__Schedule__c, buildertek__Order__c, buildertek__Milestone__c, buildertek__Duration__c, buildertek__Lag__c, buildertek__Start__c, buildertek__Dependency__c, buildertek__Phase__c, buildertek__Finish__c
		                                        FROM Project_Task__c
		                                        WHERE Schedule__c = :updatedProjectTasks[0].buildertek__Schedule__c];
		for (Project_Task__c t : newProjectTask){
			System.debug('after processRecords buildertek__Start__c ==> ' + t.buildertek__Start__c + ' And ID ' + t.Id);
		}
		/* updateScheduleItemTaskBacthApex taskBatch = new updateScheduleItemTaskBacthApex(scheduleIds,ProjectTaskMap,previuosTasks,previousTaskmap);
		 Database.executeBatch(taskBatch, 1000);*/
		// ProjectTaskBatch taskBatch = new ProjectTaskBatch(scheduleIds);
		// Database.executeBatch(taskBatch, 1000);
	}

	//@future
	public static void processRecords(Set<Id> scheduleIds, Id schId, Set<Id> TaskIds, Boolean isFromImportTask, String isAfterInsert){
		system.debug(isFromImportTask);

		List<buildertek__Project_Task__c> previuosTasks = [Select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c
		                                                   FROM buildertek__Project_Task__c
		                                                   WHERE buildertek__Schedule__c = :schId AND Id NOT IN:TaskIds AND buildertek__Milestone__c = :false
		                                                   ORDER By CreatedDate ASC, buildertek__Order__c
		                                                   NULLS LAST];//buildertek__Phase__c,buildertek__Milestone__c,buildertek__Start__c//buildertek__Start__c ASC];buildertek__Phase__c ASC NULLS LAST,buildertek__Milestone__c
		if (previuosTasks.Size() > 0)
			system.debug(previuosTasks[previuosTasks.Size() - 1]);
		Map<String, buildertek__Project_Task__c> previousTaskmap = new Map<String, buildertek__Project_Task__c>();
		for (buildertek__Project_Task__c task : previuosTasks){
			previousTaskmap.put(task.Id, task);
		}
		system.debug(previuosTasks.Size());
		List<buildertek__Project_Task__c> projectTaskToUpdate;
		Map<Id, buildertek__Project_Task__c> mapAllTask;
		projectTaskToUpdate = new List<buildertek__Project_Task__c>();
		Map<String, buildertek__Project_Task__c> milestoneList;
		Map<String, Project_Task__c> containMilestoneCheck = new Map<String, Project_Task__c>();
		// List<buildertek__Project_Task__c> projectTaskToUpdate;
		//Map<Id, buildertek__Project_Task__c> mapAllTask;
		projectTaskToUpdate = new List<buildertek__Project_Task__c>();
		mapAllTask = new Map<Id, buildertek__Project_Task__c>();

		List<Project_Task__c> newProjectTask = [Select Id, Name, buildertek__Schedule__c, buildertek__Order__c, buildertek__Milestone__c, buildertek__Duration__c, buildertek__Lag__c, buildertek__Start__c, buildertek__Dependency__c, buildertek__Phase__c, buildertek__Finish__c
		                                        FROM Project_Task__c
		                                        WHERE Schedule__c IN:scheduleIds
		                                        Order By buildertek__Order__c
		                                        Nulls Last, CreatedDate ASC];
		for (Project_Task__c t : newProjectTask){
			System.debug('newproject Task list buildertek__Start__c ==> ' + t.buildertek__Start__c);
		}
		Map<Id, List<Project_Task__c>> projectTaskMaps = new Map<Id, List<Project_Task__c>>();
		List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
		//Add milestone if do not exist
		for (Project_Task__c projectTask : newProjectTask){
			mapAllTask.put(projectTask.Id, projectTask);
			if (!projectTaskMaps.containsKey(projectTask.buildertek__Schedule__c)){
				projectTaskMaps.put(projectTask.buildertek__Schedule__c, new List<Project_Task__c>());
			}
			projectTaskMaps.get(projectTask.buildertek__Schedule__c).add(projectTask);
		}

		milestoneList = new Map<String, buildertek__Project_Task__c>();
		Map<String, buildertek__Project_Task__c> taskMaps = new Map<String, buildertek__Project_Task__c>();
		for (Id key : projectTaskMaps.keySet()){
			for (Project_Task__c projectTask : projectTaskMaps.get(key)){
				// system.debug(projectTask);
				if (projectTask.buildertek__Phase__c != null && projectTask.buildertek__Phase__c != ''){
					if (!projectTask.buildertek__Milestone__c){
						taskMaps.put(key + projectTask.buildertek__Phase__c, projectTask);
					} else{
						milestoneList.put(key + projectTask.buildertek__Phase__c, projectTask);
					}
				}
			}
		}

		List<Project_Task__c> updateMilestoneList = new List<Project_Task__c>();

		if (isAfterInsert == 'insert'){

			Date startDate;
			Date endDate;
			DateTime currDate;
			Integer numberDaysDue;
			Integer count = 0;
			buildertek__Project_Task__c LastTask = new buildertek__Project_Task__c();
			List<buildertek__Project_Task__c> predesecorTaskList = new List<buildertek__Project_Task__c>();
			predesecorTaskList = [select Id, buildertek__Dependency__c
			                      from buildertek__Project_Task__c
			                      Where Id IN:TaskIds];

			Map<string, string> parentTaskMap1 = new Map<string, string>();
			for (Id taskId : mapAllTask.keySet()){
				buildertek__Project_Task__c projectTask = mapAllTask.get(taskId);
				Id Dependency = projectTask.buildertek__Dependency__c;

				if (projectTask.buildertek__Dependency__c != null){
					buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask.buildertek__Dependency__c);
					if (parentTask != null){

						Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
						if (parentTask.buildertek__finish__c != null){
							startDate = parentTask.buildertek__finish__c.addDays(1);//parentTask.buildertek__finish__c.addDays(1);
							//startDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate);
							//endDate = parentTask.buildertek__finish__c.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
							if (Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c) > 0){
								endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
							} else{
								endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(1);
							}
							//endDate =  ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
						} else{
							startDate = parentTask.buildertek__Start__c.addDays(Integer.valueOf(parentTask.buildertek__Duration__c));
							//startDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate);
							if (Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c) > 0){
								endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
							} else{
								endDate = startDate.addDays(1);
							}
							//endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
						}
						numberDaysDue = startDate.daysBetween(endDate);

						projectTask.buildertek__Start__c = ProjectTaskTriggerHandler_v1.getStartDate(startDate);//startDate;
						if (numberDaysDue <= 0){
							projectTask.buildertek__finish__c = projectTask.buildertek__Start__c;
							System.debug('duration before reseting ==> ' + projectTask.buildertek__Duration__c + ' project task id ' + projectTask.Id);
							projectTask.buildertek__Duration__c = 1;
						} else{
							projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
							// projectTask.buildertek__Duration__c =numberDaysDue ;
						}
						//projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
						//projectTaskToUpdate.add(projectTask);
					}
				} else if (previuosTasks.Size() > 0 && !previousTaskmap.containsKey(projectTask.Id) && !projectTask.buildertek__Milestone__c && isFromImportTask){
					//getting end date of previous task set and assign that date as start date to tasks that donot have predessesor
					Integer lastIndex = previuosTasks.Size() - 1;
					if (lastIndex >= 0){
						projectTask.buildertek__Start__c = previuosTasks[lastIndex].buildertek__finish__c;//.addDays(1);
						//if(previuosTasks.Size() > 0 && !previousTaskmap.containsKey(projectTask.Id) &&  !projectTask.buildertek__Milestone__c && ProjectTaskTriggerHandler_v1.isFromImport){
						projectTask.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler_v1.getStartDate(projectTask.buildertek__Start__c);
						if (projectTask.buildertek__Duration__c != null && projectTask.buildertek__Duration__c > 0){
							projectTask.buildertek__Original_End_Date__c = projectTask.buildertek__Start__c.addDays(Integer.valueOf(projectTask.buildertek__Duration__c) - 1);
							projectTask.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler_v1.getEndDate(projectTask.buildertek__Start__c, projectTask.buildertek__Original_End_Date__c);
						}
						//}
						Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
						startDate = projectTask.buildertek__Start__c;
						startDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate);
						if (mapAllTask.get(projectTask.Id).buildertek__Duration__c != null){
							if (Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c) > 0){
								endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c) - 1);
							} else{
								endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c));
							}
						} else{
							endDate = startDate.addDays(1);
						}

						//endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c)-1);
						//endDate = projectTask.buildertek__Start__c.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c)-1);
						numberDaysDue = startDate.daysBetween(endDate);
						projectTask.buildertek__Start__c = startDate;
						System.debug('checking start date in processRecords method ' + projectTask.buildertek__Start__c);

						projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);

						if (!parentTaskMap1.containskey(projectTask.Id)){
							projectTaskToUpdate.add(projectTask);
							parentTaskMap1.put(projectTask.Id, projectTask.Id);
						}
					}
				}
				// after updating dependency tasks milestones are not updating, so updating here

			}

			if (projectTaskToUpdate.size() > 0){
				ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
				update projectTaskToUpdate;

				ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
			}
		}


		projectTaskToUpdate = new List<buildertek__Project_Task__c>();
		mapAllTask = new Map<Id, buildertek__Project_Task__c>();

		newProjectTask = [Select Id, Name, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Duration__c, buildertek__Lag__c, buildertek__Start__c, buildertek__Dependency__c, buildertek__Phase__c, buildertek__Finish__c
		                  FROM Project_Task__c
		                  WHERE Schedule__c IN:scheduleIds
		                  Order By buildertek__Order__c
		                  NULLS LAST, CreatedDate ASC];


		projectTaskMaps = new Map<Id, List<Project_Task__c>>();
		projectTasks = new List<buildertek__Project_Task__c>();

		//Add milestone if do not exist
		for (Project_Task__c projectTask : newProjectTask){
			mapAllTask.put(projectTask.Id, projectTask);
			if (!projectTaskMaps.containsKey(projectTask.buildertek__Schedule__c)){
				projectTaskMaps.put(projectTask.buildertek__Schedule__c, new List<Project_Task__c>());
			}
			projectTaskMaps.get(projectTask.buildertek__Schedule__c).add(projectTask);
		}

		milestoneList = new Map<String, buildertek__Project_Task__c>();
		taskMaps = new Map<String, buildertek__Project_Task__c>();
		for (Id key : projectTaskMaps.keySet()){
			for (Project_Task__c projectTask : projectTaskMaps.get(key)){
				if (projectTask.buildertek__Phase__c != null && projectTask.buildertek__Phase__c != ''){
					System.debug('In Phase if condition ==>');
					if (!projectTask.buildertek__Milestone__c){
						taskMaps.put(key + projectTask.buildertek__Phase__c, projectTask);
					} else{
						if (!milestoneList.containsKey(key + projectTask.buildertek__Phase__c)){
							milestoneList.put(key + projectTask.buildertek__Phase__c, projectTask);
						}
					}
				} else {
					System.debug('In Phase else condition ==>');
				}
			}
		}

		//Delete milestoneList.values();

		//system.debug(milestoneList.values());
		//milestoneList.clear();
		List<Project_Task__c> updateMilestoneListTwo = new List<Project_Task__c>();
		Map<String, Project_Task__c> containMilestoneCheck2 = new Map<String, Project_Task__c>();
		Map<Id, Decimal> projectCompletedTask = new Map<Id, Decimal>();
		//Start Date Based on Dependent Task.
		Date startDate;
		Date endDate;
		DateTime currDate;
		Integer numberDaysDue;
		String todayDay;
		Integer count = 0;
		buildertek__Project_Task__c LastTask = new buildertek__Project_Task__c();

		List<buildertek__Project_Task__c> predesecorTaskList = new List<buildertek__Project_Task__c>();
		predesecorTaskList = [select Id, buildertek__Dependency__c
		                      from buildertek__Project_Task__c
		                      Where Id IN:TaskIds];
		Map<string, string> parentTaskMap = new Map<string, string>();
		Map<String, String> updatedDependentTasks = new Map<String, String>();


		for (Id taskId : mapAllTask.keySet()){

			buildertek__Project_Task__c projectTask = mapAllTask.get(taskId);
			//system.debug(projectTask.buildertek__Milestone__c);
			Id Dependency = projectTask.buildertek__Dependency__c;
			if (previuosTasks.Size() > 0 && !previousTaskmap.containsKey(projectTask.Id) && !projectTask.buildertek__Milestone__c && isFromImport){
				Integer lastIdx = previuosTasks.Size() - 1;
				if (lastIdx >= 0){
					projectTask.buildertek__Start__c = previuosTasks[lastIdx].buildertek__finish__c.addDays(1);
					projectTask.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler_v1.getStartDate(projectTask.buildertek__Start__c);
					if (projectTask.buildertek__Duration__c != null && projectTask.buildertek__Duration__c > 0){
						projectTask.buildertek__Original_End_Date__c = projectTask.buildertek__Start__c.addDays(Integer.valueOf(projectTask.buildertek__Duration__c) - 1);
						projectTask.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler_v1.getEndDate(projectTask.buildertek__Start__c, projectTask.buildertek__Original_End_Date__c);
					}
				}
			}

			System.debug('3rd method before updating start date ' + projectTask.buildertek__Start__c + ' id ' + projectTask.Id);

			if (projectTask.buildertek__Dependency__c != null){
				buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask.buildertek__Dependency__c);
				System.debug('parentTask '+parentTask);
				if (parentTask != null){
					Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
					System.debug('parent task debug finish '+parentTask.buildertek__finish__c+' id '+projectTask.id + ' parent id '+parentTask.id);
					if (parentTask.buildertek__finish__c != null){

						Integer totalDay;
						if (projectTask.buildertek__Lag__c != null){
							Integer lagDays = Integer.valueOf(projectTask.buildertek__Lag__c);
							totalDay = lagDays + 1;
						} else{
							totalDay = 0;
						}
						System.debug('totalDay  ====>   ' + totalDay);

						startDate = parentTask.buildertek__finish__c;
						System.debug('start date GOG BOB ==> '+startDate+' id '+parentTask.Id);
						startDate = addDaysSkippingWeekends(parentTask.buildertek__finish__c, totalDay);
						System.debug('start date after reseting BOB ==> '+startDate+' id '+parentTask.Id);

						// startDate = parentTask.buildertek__finish__c.addDays(totalDay);
						System.debug('parentTask.buildertek__finish__c ==>' + parentTask.buildertek__finish__c + 'Id ==> ' + parentTask.Id);
						System.debug('1st Start Date  ===> ' + startDate);
						if (mapAllTask.get(taskId).buildertek__Duration__c != null){
							// endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
							// added new logic here for end date by Nishit (MV Clouds)

							endDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c) - 1);
						} else{
							// calculate duration from (mapAllTask.get(taskId)buildertek__finish__c).daysbetween.mapAllTask.get(taskId).buildertek__Start__c if needed
							Date d1 = mapAllTask.get(taskId).buildertek__finish__c;
							Date d2 = mapAllTask.get(taskId).buildertek__Start__c;
							Integer daysDiff = d2.daysbetween(d1);
							System.debug('days Diff ==> ' + daysDiff);
							// endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(daysDiff + 1);

							// added new logic by Nishit (MV Clouds)
							endDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate).addDays(daysDiff);

							mapAllTask.get(taskId).buildertek__Duration__c = daysDiff + 1;
							System.debug('duration seted ==> ' + mapAllTask.get(taskId).buildertek__Duration__c);

							// endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
						}
						// endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
					} else{
						Integer Duration = Integer.valueOf(parentTask.buildertek__Duration__c);
						Integer totalDay;
						if (projectTask.buildertek__Lag__c != null){
							Integer lagDays = Integer.valueOf(projectTask.buildertek__Lag__c);
							totalDay = Duration + lagDays;
						} else{
							totalDay = Duration;
						}
						System.debug('totalDay  ====>   ' + totalDay);
						startDate = addDaysSkippingWeekends(parentTask.buildertek__Start__c, totalDay);
						// startDate = parentTask.buildertek__Start__c.addDays(totalDay);
						if (mapAllTask.get(taskId).buildertek__Duration__c == null){
							mapAllTask.get(taskId).buildertek__Duration__c = 1;
						}
						// endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__Start__c.addDays(Duration)).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
						// logic added by Nishit (MV Clouds)
						endDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate.addDays(Duration)).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
					}

					//startDate =  parentTask.buildertek__finish__c.addDays(1);
					//startDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate);
					//endDate = ProjectTaskTriggerHandler_v1.getStartDate(parentTask.buildertek__finish__c).addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
					//endDate = parentTask.buildertek__finish__c.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
					numberDaysDue = startDate.daysBetween(endDate);
					System.debug('3rd method before changing start Date ==> ' + projectTask.buildertek__Start__c + ' Id ' + projectTask.Id);
					// projectTask.buildertek__Start__c = ProjectTaskTriggerHandler_v1.getStartDate(startDate);//startDate;


					System.debug(' 2nd startDate=====> ' + startDate);
					projectTask.buildertek__Start__c = ProjectTaskTriggerHandler_v1.getStartDate(startDate);//startDate;


					System.debug('3rd method after changing start Date ==> ' + projectTask.buildertek__Start__c + ' Id ' + projectTask.Id);

					if (numberDaysDue <= 0){
						projectTask.buildertek__finish__c = projectTask.buildertek__Start__c;
						projectTask.buildertek__Duration__c = 1;
					} else{
						projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
					}
					//projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
					projectTaskToUpdate.add(projectTask);
				}
			} else if (previuosTasks.Size() > 0 && !previousTaskmap.containsKey(projectTask.Id) && !projectTask.buildertek__Milestone__c && isFromImportTask){
				
				Integer lastIndex = previuosTasks.Size() - 1;
				if (lastIndex >= 0){
					projectTask.buildertek__Start__c = previuosTasks[lastIndex].buildertek__finish__c.addDays(1);
					System.debug('start date if lastIndex > 0 ==> ' + projectTask.buildertek__Start__c);
					projectTask.buildertek__Original_Start_Date__c = ProjectTaskTriggerHandler_v1.getStartDate(projectTask.buildertek__Start__c);
					if (projectTask.buildertek__Duration__c != null && projectTask.buildertek__Duration__c > 0){
						projectTask.buildertek__Original_End_Date__c = projectTask.buildertek__Start__c.addDays(Integer.valueOf(projectTask.buildertek__Duration__c) - 1);
						projectTask.buildertek__Original_End_Date__c = ProjectTaskTriggerHandler_v1.getEndDate(projectTask.buildertek__Start__c, projectTask.buildertek__Original_End_Date__c);
					}
					Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
					startDate = projectTask.buildertek__Start__c;
					startDate = ProjectTaskTriggerHandler_v1.getStartDate(startDate);
					endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c) - 1);
					//endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c)-1);
					//endDate = projectTask.buildertek__Start__c.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c)-1);
					numberDaysDue = startDate.daysBetween(endDate);
					projectTask.buildertek__Start__c = startDate;
					projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
					if (!parentTaskMap.containskey(projectTask.Id)){
						projectTaskToUpdate.add(projectTask);
						parentTaskMap.put(projectTask.Id, projectTask.Id);
					}
				}
			}else{
				system.debug('if predessesor is null then here '+projectTask.Id);
				// this logic is added for predessesor is equal to null
					// added by Nishit (MV Clouds)
					Integer totalDay1;
						if (projectTask.buildertek__Lag__c != null){
							Integer lagDays1 = Integer.valueOf(projectTask.buildertek__Lag__c);
							totalDay1 = lagDays1;
						} else{
							totalDay1 = 0;
						}
					startDate = projectTask.buildertek__Start__c;
					System.debug('start date in else '+startDate);
					startDate = addDaysSkippingWeekends(projectTask.buildertek__Start__c, totalDay1);
					System.debug('start date excluding weekend in else '+startDate);
					endDate = startDate.addDays(Integer.valueOf(mapAllTask.get(projectTask.Id).buildertek__Duration__c) - 1);
					System.debug('endDate in else '+endDate);
					projectTask.buildertek__Start__c = startDate;
					projectTask.buildertek__finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
					System.debug('endDate excluding weekend in else '+projectTask.buildertek__finish__c);
					projectTaskToUpdate.add(projectTask);
					// logic ended here
			}

			System.debug('3rd method after else if condition updating start date ' + projectTask.buildertek__Start__c + ' id ' + projectTask.Id);
		}

		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
		if (projectTaskToUpdate.size() > 0){
			update projectTaskToUpdate;
		}
		/*if(predesecorTaskList.size()> 0){
		 ProjectTaskTriggerHandler_v1.checkDependency(predesecorTaskList);
		 }*/

		/* UpdateScheduleItemDatesBatch be = new UpdateScheduleItemDatesBatch(mapAllTask.keySet());
		 database.executeBatch(be,1);*/
		// UpdateScheduleItemdatesbatchhelper.batchjobexcute(mapAllTask.keySet());

		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
	}

	public void insertUpdateMilestones(Project_Task__c[] ProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap){
		System.debug('In insertUpdateMilestones Method');
		Set<Id> scheduleIds = new Set<Id>();
		Map<string, Project_Task__c> insertUpdateMilestoneMap = new Map<string, Project_Task__c>();
		Map<string, Project_Task__c> milestoneMap = new Map<string, Project_Task__c>();
		Map<string, List<Project_Task__c>> taskPhaseMap = new Map<string, List<Project_Task__c>>();
		Map<string, Project_Task__c> deletemilestoneMap = new Map<string, Project_Task__c>();

		for (buildertek__Project_Task__c schItem : ProjectTasks){

			scheduleIds.add(schItem.buildertek__Schedule__c);
			System.debug('insertUpdate milestones duration ==> ' + schItem.buildertek__Duration__c + ' id ' + schItem.Id);

		}

		Map<Id, Project_Task__c> newProjectTaskMap = new Map<Id, Project_Task__c>([select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c, buildertek__Dependency__c, buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Phase__c, buildertek__Type__c, isDeleted
		                                                                           from buildertek__Project_Task__c
		                                                                           where buildertek__Schedule__c IN:scheduleIds
		                                                                           Order by buildertek__Order__c
		                                                                           NULLS LAST, CreatedDate ASC]);
		for (Project_Task__c task : newProjectTaskMap.values()){
			System.debug('updated in  milestones duration ==> ' + task.buildertek__Duration__c + ' id ' + task.Id);
			if (task.buildertek__Phase__c != null){
				if (taskPhaseMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c) != null){
					list<Project_Task__c> onproTaskList = taskPhaseMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c);
					onproTaskList.add(task) ;
					taskPhaseMap.put(task.buildertek__Schedule__c + task.buildertek__Phase__c, onproTaskList);
				} else{
					list<Project_Task__c> onproTaskList = new list<Project_Task__c>();
					onproTaskList.add(task) ;
					taskPhaseMap.put(task.buildertek__Schedule__c + task.buildertek__Phase__c, onproTaskList);
				}

				if (task.buildertek__Milestone__c){
					milestoneMap.put(task.buildertek__Schedule__c + task.buildertek__Phase__c, task);
				}
			}

		}

		for (Project_Task__c task : newProjectTaskMap.values()){
			Project_Task__c project = new Project_Task__c();
			if (task.buildertek__Phase__c != null){
				if (!task.buildertek__Milestone__c && milestoneMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c) == null){
					System.debug('mileston boolean ' + task.buildertek__Milestone__c);

					project.Name = 'Milestone Complete';
					project.buildertek__Phase__c = task.buildertek__Phase__c;
					if (task.buildertek__Finish__c != null){
						project.buildertek__Start__c = task.buildertek__Finish__c;
						project.buildertek__Finish__c = task.buildertek__Finish__c; //.addDays(1); //projectTask.buildertek__Start__c.addDays(1);
					} else{
						project.buildertek__Start__c = task.buildertek__Start__c;
						project.buildertek__Finish__c = task.buildertek__Start__c;//.addDays(1); //projectTask.buildertek__Start__c.addDays(1);
					}
					project.buildertek__Duration__c = 1;
					project.buildertek__Schedule__c = task.buildertek__Schedule__c;
					project.buildertek__Milestone__c = true;
					project.buildertek__Type__c = 'Milestone';
					insertUpdateMilestoneMap.put(task.buildertek__Schedule__c + task.buildertek__Phase__c, project);
				} else if (milestoneMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c) != null){
					System.debug('map key ' + milestoneMap.keyset());
					System.debug('map values  ' + milestoneMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c));
					project = milestoneMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c);
					if (task.buildertek__Finish__c != null){
						project.buildertek__Start__c = task.buildertek__Finish__c;
						project.buildertek__Finish__c = task.buildertek__Finish__c; //.addDays(1); //projectTask.buildertek__Start__c.addDays(1);
					} else{
						project.buildertek__Start__c = task.buildertek__Start__c;
						project.buildertek__Finish__c = task.buildertek__Start__c;//.addDays(1); //projectTask.buildertek__Start__c.addDays(1);
					}
					insertUpdateMilestoneMap.put(task.buildertek__Schedule__c + task.buildertek__Phase__c, project);
				}

				//delete milestones if there are no tasks for that phase but only milestone
				if (taskPhaseMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c) != null){
					if (taskPhaseMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c).size() == 1){
						Project_Task__c milestoneTaskItem = taskPhaseMap.get(task.buildertek__Schedule__c + task.buildertek__Phase__c)[0];
						if (milestoneTaskItem.buildertek__Milestone__c == true && !milestoneTaskItem.isDeleted){
							deletemilestoneMap.put(milestoneTaskItem.Id, milestoneTaskItem);
						}
					}
				}
			}
		}

		if (insertUpdateMilestoneMap.values().size() > 0){
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
			upsert insertUpdateMilestoneMap.values();
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
		}

		if (deletemilestoneMap.values().size() > 0){
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
			delete deletemilestoneMap.values();
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
		}
	}

	public void updateChildDatesWithPredecessor(Project_Task__c[] ProjectTasks, Map<ID, Project_Task__c> ProjectTaskMap){
		List<Project_Task__c> tempList = new List<Project_Task__c>();
		tempList = [select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c, buildertek__Dependency__c, buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Phase__c
		            from buildertek__Project_Task__c
		            where buildertek__Schedule__c = :ProjectTasks[0].buildertek__Schedule__c];

		for (Project_Task__c tt : tempList){
			System.debug('trigger.new start ==> ' + tt.buildertek__Start__c + ' Id ==> ' + tt.Id);
		}
		Set<Id> scheduleIds = new Set<Id>();
		Boolean dependencyPathExist = false;
		for (buildertek__Project_Task__c schItem : ProjectTasks){
			scheduleIds.add(schItem.buildertek__Schedule__c);
		}
		//set dependency path
		//List<Project_Task__c> newProjectTaskList = [select Id,Name,buildertek__Dependency__c,buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule_Item_Dependency_Path__c,buildertek__Schedule__c from buildertek__Project_Task__c where buildertek__Schedule__c IN: scheduleIds];

		Map<Id, Project_Task__c> newProjectTaskMap = new Map<Id, Project_Task__c>([select Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c, buildertek__Dependency__c, buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule_Item_Dependency_Path__c, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Phase__c
		                                                                           from buildertek__Project_Task__c
		                                                                           where buildertek__Schedule__c IN:scheduleIds]);

		List<Project_Task__c> newProjectTaskList = newProjectTaskMap.values();

		Map<Id, Project_Task__c> newUpdateProjectTaskMap = new Map<Id, Project_Task__c>();

		for (Project_Task__c task : newProjectTaskList){
			if (task.buildertek__Dependency__c != null){
				if (task.buildertek__Schedule_Item_Dependency_Path__c == '' || task.buildertek__Schedule_Item_Dependency_Path__c == null){
					system.debug('null value');
					task.buildertek__Schedule_Item_Dependency_Path__c = task.buildertek__Dependency__c;
					if (task.buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c != null){
						task.buildertek__Schedule_Item_Dependency_Path__c += ',' + task.buildertek__Dependency__r.buildertek__Schedule_Item_Dependency_Path__c;
					}
				}
			} else if (String.isBlank(task.buildertek__Dependency__c)){
				task.buildertek__Schedule_Item_Dependency_Path__c = '';
			}
		}

		// get parent dates and update task
		set<string> taskIdSet = new set<string>();
		List<Project_Task__c> updateDatesTaskList = new List<Project_Task__c>();
		for (Project_Task__c taskItem : newProjectTaskList){
			Project_Task__c lastTask = new Project_Task__c();
			List<String> dependecyPathList = new List<String>();
			if (taskItem.buildertek__Schedule_Item_Dependency_Path__c != null){
				dependencyPathExist = true;
				// system.debug('taskItem-->' + taskItem);
				dependecyPathList = taskItem.buildertek__Schedule_Item_Dependency_Path__c.split(',');
			}
			if (dependecyPathList.size() > 0){
				// system.debug('taskItem-->' + taskItem);
				Project_Task__c prevParent = new Project_Task__c();

				for (Integer i = dependecyPathList.size() - 1; i >= 0; i--){
					String pathItem = dependecyPathList[i];
					Date startDate;
					Date endDate;
					Project_Task__c currentTask = new Project_Task__c();
					// System.debug('<--pathItem-->' + pathItem);
					if (!String.isBlank(pathItem)){
						if (newProjectTaskMap.get(Id.valueOf(pathItem)) != null){
							if (prevParent.Id == null){

								prevParent = newProjectTaskMap.get(Id.valueOf(pathItem));
								// System.debug('prevParent-->' + prevParent);
								newUpdateProjectTaskMap.put(prevParent.Id, prevParent);
								lastTask = prevParent;
								System.debug('prevParent.Id should be null' + prevParent.Id);
								// System.debug('lastTask-->' + lastTask);
							} else{
								currentTask = newProjectTaskMap.get(Id.valueOf(pathItem));
								// System.debug('currentTask-->' + currentTask);
								if (newUpdateProjectTaskMap.get(Id.valueOf(pathItem)) != null){
									currentTask = newUpdateProjectTaskMap.get(Id.valueOf(pathItem));
									// System.debug('currentTask-->' + currentTask);
								}
								// System.debug('prevParent.buildertek__finish__c-->' + prevParent.buildertek__finish__c);
								currentTask.buildertek__Start__c = ProjectTaskTriggerHandler_v1.getStartDate(prevParent.buildertek__finish__c.addDays(1));
								// System.debug('currentTask.buildertek__Start__c-->' + currentTask.buildertek__Start__c);
								// System.debug('currentTask.buildertek__Duration__c-->' + currentTask.buildertek__Duration__c);
								if (Integer.valueOf(currentTask.buildertek__Duration__c) > 0){
									endDate = currentTask.buildertek__Start__c.addDays(Integer.valueOf(currentTask.buildertek__Duration__c) - 1);
									System.debug('if endDate ==> ' + endDate);
								} else{
									endDate = currentTask.buildertek__Start__c; //.addDays(1)
									System.debug('else endDate ==> ' + endDate);
								}
								// System.debug('endDate-->' + endDate);
								currentTask.buildertek__Finish__c = endDate;
								// System.debug('currentTask.buildertek__Finish__c-->' + currentTask.buildertek__Finish__c);
								prevParent = currentTask;
								lastTask = currentTask;

								newUpdateProjectTaskMap.put(currentTask.Id, currentTask);
							}
							taskIdSet.add(currentTask.Id);
						}
					}

				}
			}
			if (lastTask.Id != null && lastTask.buildertek__finish__c != null){
				// System.debug('lastTask.buildertek__finish__c  ==> ' + lastTask.buildertek__finish__c);
				System.debug('1st method fixed start date here ==> ' + taskItem.buildertek__Start__c + 'and Id ' + taskItem.Id);
				taskItem.buildertek__Start__c = ProjectTaskTriggerHandler_v1.getStartDate(lastTask.buildertek__finish__c.addDays(1));
				System.debug('1st method after fixed start date here ==> ' + taskItem.buildertek__Start__c + 'and Id ' + taskItem.Id);
				// System.debug('null checking :: ' + lastTask.buildertek__Duration__c);

				Date taskEndDate;
				if (Integer.valueOf(lastTask.buildertek__Duration__c) > 0){
					system.debug('1-->');
					taskEndDate = taskItem.buildertek__Start__c.addDays(Integer.valueOf(taskItem.buildertek__Duration__c) - 1);
				} else{
					system.debug('2-->');
					taskEndDate = taskItem.buildertek__Start__c; //.addDays(1)
				}
				// system.debug('taskEndDate -->' + taskEndDate);
				taskItem.buildertek__Finish__c = taskEndDate;
				// system.debug('taskItem.buildertek__Finish__c -->' + taskItem.buildertek__Finish__c);
				newUpdateProjectTaskMap.put(taskItem.Id, taskItem);
			}
		}

		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
		system.debug('ProjectTasks-->' + ProjectTasks);
		// System.debug('newUpdateProjectTaskMap-->' + newUpdateProjectTaskMap.values());
		if (dependencyPathExist && newUpdateProjectTaskMap.values().size() > 0){
			update newUpdateProjectTaskMap.values();
		}
		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
		ProjectTaskTriggerHandler_v1.isFromImport = false;
	}

	public static void checkDependency(List<buildertek__Project_Task__c> scheduleItemId){
		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
		List<buildertek__Project_Task__c> scheduleItem = [SELECT Id, buildertek__Start__c, buildertek__Finish__c, buildertek__Duration__c, buildertek__Dependency__c, buildertek__Dependency__r.buildertek__Start__c, buildertek__Dependency__r.buildertek__Finish__c, buildertek__Dependency__r.buildertek__Duration__c
		                                                  FROM buildertek__Project_Task__c
		                                                  WHERE buildertek__Dependency__c IN:scheduleItemId];
		if (scheduleItem.size() > 0){
			List<buildertek__Project_Task__c> projectTaskToUpdateNew = new List<buildertek__Project_Task__c>();
			for (buildertek__Project_Task__c tsk : scheduleItem){
				Date startDate;
				if (tsk.buildertek__Dependency__r.buildertek__Finish__c != null){
					startDate = tsk.buildertek__Dependency__r.buildertek__Finish__c.addDays(1);
				} else{
					startDate = tsk.buildertek__Dependency__r.buildertek__Start__c.addDays(Integer.valueOf(tsk.buildertek__Dependency__r.buildertek__Duration__c));
				}

				//Date startDate = tsk.buildertek__Dependency__r.buildertek__Finish__c.addDays(1);
				DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
				String todayDay = currDate.format('EEEE');
				if (todayDay == 'Saturday'){
					startDate = startDate.addDays(2);
				} else if (todayDay == 'Sunday'){
					startDate = startDate.addDays(1);
				}
				buildertek__Project_Task__c scheduleItemUpdate = new buildertek__Project_Task__c();
				scheduleItemUpdate.Id = tsk.Id;
				Date endDate;
				// system.debug(tsk);
				// system.debug(tsk.buildertek__Duration__c);
				if (tsk.buildertek__Duration__c != null){
					if (Integer.valueOf(tsk.buildertek__Duration__c) > 0){
						endDate = startDate.addDays(Integer.valueOf(tsk.buildertek__Duration__c) - 1);
					} else{
						endDate = startDate.addDays(Integer.valueOf(tsk.buildertek__Duration__c));
					}
				}

				//Date endDate = startDate.addDays(Integer.valueOf(tsk.buildertek__Duration__c)-1);
				scheduleItemUpdate.buildertek__Start__c = startDate;
				scheduleItemUpdate.buildertek__Finish__c = ProjectTaskTriggerHandler_v1.getEndDate(startDate, endDate);
				projectTaskToUpdateNew.add(scheduleItemUpdate);
			}
			if (projectTaskToUpdateNew.size() > 0){
				ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
				update projectTaskToUpdateNew;

				checkDependency(projectTaskToUpdateNew);
			}
		}
	}

	public void OnBeforeDelete(Project_Task__c[] ProjectTaskToDelete, Map<ID, Project_Task__c> ProjectTaskMap){
	}

	public void OnAfterDelete(Project_Task__c[] ProjectTasks){
		Map<id, Project_Task__c> ProjectTaskIds = new Map<Id, Project_Task__c>();
		list<id> scheduleIds = new list<id>();
		list<id> projectIds = new list<id>();
		for (Project_Task__c ItemRec : ProjectTasks){
			scheduleIds.add(ItemRec.buildertek__Schedule__c);
			projectIds.add(ItemRec.id);
		}
		if (scheduleIds.size() > 0){
			list<Project_Task__c> scheduleitemsList = [select id, Name, buildertek__Schedule__c
			                                           from Project_Task__c
			                                           where buildertek__Schedule__c IN:scheduleIds AND ID NOT IN:projectIds];
			for (Project_Task__c projecttask : scheduleitemsList){
				ProjectTaskIds.put(projecttask.id, projecttask);
			}
			//database.executeBatch(new ScheduleItemBatchClass(ProjectTaskIds)); // Calling batch class.
		}
		if (ProjectTaskIds.size() > 0){
			database.executeBatch(new ScheduleItemBatchClass(ProjectTaskIds)); // Calling batch class.
		}
	}

	Public static void reSchedule(string objTaskNew, string objTaskOld){
		Map<Id, Project_Task__c> mapAllTask = new map<Id, Project_Task__c>([Select Id, Dependency__c, Duration__c, Expected_End_Date__c, Expected_Start_Date__c, Start__c, Finish__c, Lag__c, Order__c
		                                                                    from Project_Task__c
		                                                                    where Project__c = :objTaskNew
		                                                                    order by ORDER__c ASC
		                                                                    NULLS LAST]);

		Date startDate;
		Date endDate;
		Integer numberDaysDue;
		for (Id taskId : mapAllTask.keySet()){
			Project_Task__c projectTask = mapAllTask.get(taskId);
			Id Dependency = projectTask.Dependency__c;
			if (projectTask.Dependency__c != null){
				Project_Task__c parentTask = mapAllTask.get(projectTask.Dependency__c);
				Integer lag = projectTask.Lag__c != null ? Integer.valueOf(projectTask.Lag__c) : 0;
				startDate = projectTask.Start__c;
				endDate = projectTask.finish__c;
				numberDaysDue = startDate.daysBetween(endDate);
				projectTask.duration__c = numberDaysDue + 1;
				projectTask.finish__c = addBussinessDays(projectTask.Start__c, Integer.valueOf(projectTask.duration__c > 0 ? projectTask.duration__c : projectTask.duration__c));
			}
		}
		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
		update mapAllTask.values();
		ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
	}

	public static Date addBussinessDays(Date startDate, Integer iDays){
		Integer businessDaysAdded = 0;
		Date currentDate = startDate;
		if (businessDaysAdded <= iDays){
			DateTime d = DateTime.newInstance(currentDate.year(), currentDate.month(), currentDate.day());
			if (d.format('E') != 'Sat' && d.format('E') != 'Sun'){
				// it's a business day, so add 1 to the counter that works towards the amount of days to add
				businessDaysAdded = businessDaysAdded + 1;
				currentDate = currentDate.addDays(iDays - 1);
			} else{
				if (d.format('E') != 'Sat'){
					currentDate = currentDate.addDays(iDays + 1);
				}
				if (d.format('E') != 'Sun'){
					currentDate = currentDate.addDays(iDays + 2);
				}
			}
		}
		return currentDate;
	}

	public static List<Holiday> holidays{
		get{
			if (holidays == null)
				holidays = [Select h.StartTimeInMinutes, h.Name, h.ActivityDate
				            From Holiday h
				            Limit 50000];
			return holidays;
		}
		private set;
	}

	public static boolean checkIfItIsWorkingDay(Date currentDate){
		Date weekStart = currentDate.toStartOfWeek();
		for (Holiday hDay : holidays){
			if (currentDate.daysBetween(hDay.ActivityDate) == 0){
				return false;
			}
		}
		if (weekStart.daysBetween(currentDate) == 0 || weekStart.daysBetween(currentDate) == 6){
			return false;
		} else
			return true;
	}

	public static Integer getDiffBusinessDays(Date startDt, Date endDt){
		Date tempDate = null;
		if (startDt > endDt){
			tempDate = endDt;
			endDt = startDt;
			startDt = tempDate;
		}
		Integer i = Math.mod((date.newInstance(1985, 6, 24)).daysBetween(startDt), 7); // 24/6/85 was a monday
		Map<Integer, Map<Integer, Integer>> m = new Map<Integer, Map<Integer, Integer>>{ 0 => new Map<Integer, Integer>{ 1 => 2, 2 => 3, 3 => 4, 4 => 5, 5 => 5, 6 => 5 }, 1 => new Map<Integer, Integer>{ 1 => 2, 2 => 3, 3 => 4, 4 => 4, 5 => 4, 6 => 5 }, 2 => new Map<Integer, Integer>{ 1 => 2, 2 => 3, 3 => 3, 4 => 3, 5 => 4, 6 => 5 }, 3 => new Map<Integer, Integer>{ 1 => 2, 2 => 2, 3 => 2, 4 => 3, 5 => 4, 6 => 5 }, 4 => new Map<Integer, Integer>{ 1 => 1, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5 }, 5 => new Map<Integer, Integer>{ 1 => 0, 2 => 1, 3 => 2, 4 => 3, 5 => 4, 6 => 5 }, 6 => new Map<Integer, Integer>{ 1 => 1, 2 => 2, 3 => 3, 4 => 4, 5 => 5, 6 => 5 } };
		Integer i3;
		if (endDt != null){
			Integer i2 = Math.mod((startDt.daysBetween(endDt)), 7);
			if (m.get(i) == null){
				return 0;
			}
			i3 = (m.get(i)).get(i2);
			if (i2 == null || i2 < 1 || i2 > 6){
				if (i >= 0 && i <= 4){
					i3 = 1;
				} else{
					i3 = 0;
				}
			}
			i3 = i3 + 5 * (Math.floor(((Decimal) startDt.daysBetween(endDt)).divide(7, 4))).intValue();
			if (tempDate != null)
				i3 *= -1;
			// negative number of days
		}
		return i3 == 0 ? 1:i3;
	}

	//
	public static Date getStartDate(Date startDate){
		DateTime currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
		String todayDay = currDate.format('EEEE');
		if (todayDay == 'Saturday'){
			startDate = startDate.addDays(2);
		} else if (todayDay == 'Sunday'){
			startDate = startDate.addDays(1);
		}
		return startDate;
	}

	//Calculate and add weekends.
	public static Date getEndDate(Date sDate, Date eDate){
		try{

			for (integer j = 0; j <= sDate.daysBetween(eDate); j++){
				Date dt = sDate + j;
				DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
				String todayDay = currentDate.format('EEEE');
				if (todayDay == 'Saturday' || todayDay == 'Sunday'){
					eDate = eDate.addDays(1);
				}
			}
			return eDate;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	//Calculate and duration.
	public static Decimal calculateDuration(Date sDate, Date eDate){
		try{
			Decimal workingDays = 0;
			for (integer j = 0; j <= sDate.daysBetween(eDate); j++){
				Date dt = sDate + j;
				DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
				String todayDay = currentDate.format('EEEE');
				if (todayDay != 'Saturday' && todayDay != 'Sunday'){
					workingDays++;
				}
			}
			return workingDays;
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
	}

	// Skip weekend and calculate date
	public static Date addDaysSkippingWeekends(Date sDate, Integer days){
		Date result = sDate;
		Integer addedDays = 0;
		while (addedDays < days){
			System.debug('result ==> '+result);
			result = result.addDays(1);
			System.debug('result after adding day ==> '+result);
			// if (!(result.getDayOfWeek() == DayOfWeek.SATURDAY || result.getDayOfWeek() == DayOfWeek.SUNDAY)) {
			//     ++addedDays;
			// }
			DateTime currentDate = DateTime.newInstance(result.year(), result.month(), result.day());
			String todayDay = currentDate.format('EEEE');
			if (todayDay != 'Saturday' && todayDay != 'Sunday'){
				++addedDays;
			}
		}
		System.debug('end result in addDayskepping method ==> '+result);
		return result;
	}

	public void OnBeforeInsert1(Project_Task__c[] newProjectTasks){
		list<id> scheduleIds = new list<id>();
		list<id> taskIds = new list<id>();
		for (Project_Task__c newProjectTask : newProjectTasks){
			if (newProjectTask.buildertek__Add_To_All_Active_Schedules__c == true){
				taskIds.add(newProjectTask.id);
				scheduleIds.add(newProjectTask.buildertek__Schedule__c);
				FutureMethodCallOut_forStripeAPIToUpdate(taskIds, scheduleIds);
			}
		}
	}

	public void OnAfterInsertItemCount(buildertek__Project_Task__c[] newScheduleItems, buildertek__Project_Task__c[] oldScheduleItems){
		Set<Id> setAccountIds = new Set<Id>();

		//Whenever your working with After Undelete operation you can access data through
		//Trigger.new or Trigger.newMap but not with Trigger.old or Trigger.oldmap variables

		if (Trigger.isInsert || Trigger.isUndelete){
			for (buildertek__Project_Task__c con : newScheduleItems){
				setAccountIds.add(con.buildertek__Schedule__c);
			}
		}

		if (Trigger.isDelete){
			//if you use Trigger.new below in place of Trigger.old you will end up with
			//System.NullPointerException:Attempt to de-reference a null object

			for (buildertek__Project_Task__c con : oldScheduleItems){
				setAccountIds.add(con.buildertek__Schedule__c);
			}
		}

		List<buildertek__Schedule__c> listAccs = [Select id, name, buildertek__Schedule_Items_Count__c, (Select id
		                                                                                                 from buildertek__Schedule_Tasks__r)
		                                          from buildertek__Schedule__c
		                                          where Id in:setAccountIds];
		for (buildertek__Schedule__c acc : listAccs){
			acc.buildertek__Schedule_Items_Count__c = acc.buildertek__Schedule_Tasks__r.size();
		}

		if (listAccs.size() > 0){
			ScheduleTriggerHandler schdulehandlerCustom = new ScheduleTriggerHandler(true, listAccs.size());
			schdulehandlerCustom.blnSkipTaskTrigger = true;
			update listAccs;
			schdulehandlerCustom.blnSkipTaskTrigger = false;
		}
	}

	// @future(CallOut = true)
	// private static void FutureMethodCallOut_ForInsertingMilestone(Set<Id> scheduleIdSet){
	//     //Add Milestone.
	//     Map<Id, List<Project_Task__c>> projectTaskMaps = new Map<Id, List<Project_Task__c>>();
	//     List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
	//     Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
	//     Map<String, buildertek__Project_Task__c> taskMaps = new Map<String, buildertek__Project_Task__c>();
	//     List<Project_Task__c> newProjectTask = [Select Id, Name, buildertek__Schedule__c, buildertek__Milestone__c, buildertek__Start__c, buildertek__Phase__c
	//                                             FROM Project_Task__c
	//                                             WHERE Schedule__c IN :scheduleIdSet];
	//     for (Project_Task__c projectTask : newProjectTask){
	//         if (!projectTaskMaps.containsKey(projectTask.buildertek__Schedule__c)){
	//             projectTaskMaps.put(projectTask.buildertek__Schedule__c, new List<Project_Task__c>());
	//         }
	//         projectTaskMaps.get(projectTask.buildertek__Schedule__c).add(projectTask);
	//     }
	//     for (Id key : projectTaskMaps.keySet()){
	//         for (Project_Task__c projectTask : projectTaskMaps.get(key)){
	//             if (projectTask.buildertek__Phase__c != null && projectTask.buildertek__Phase__c != ''){
	//                 if (!projectTask.buildertek__Milestone__c){
	//                     taskMaps.put(key + projectTask.buildertek__Phase__c, projectTask);
	//                 } else{
	//                     milestoneList.put(key + projectTask.buildertek__Phase__c, projectTask);
	//                 }
	//             }
	//         }
	//     }
	//     for (Project_Task__c projectTask : taskMaps.values()){
	//         if (!milestoneList.containsKey(projectTask.buildertek__Schedule__c + projectTask.buildertek__Phase__c) && !projectTask.buildertek__Milestone__c){
	//             Project_Task__c project = new Project_Task__c();
	//             project.Name = 'Milestone Complete';
	//             project.buildertek__Phase__c = projectTask.buildertek__Phase__c;
	//             project.buildertek__Start__c = projectTask.buildertek__Start__c;
	//             project.buildertek__Schedule__c = projectTask.buildertek__Schedule__c;
	//             project.buildertek__Milestone__c = true;
	//             projectTasks.add(project);
	//         }
	//     }
	//     if (projectTasks.size() > 0){
	//         insert projectTasks;
	//     }
	//     //Add milestone Ended.
	// }
	@future(CallOut = true)
	private static void FutureMethodCallOut_forStripeAPIToUpdate(list<id> taskIds, list<id> scheduleIds){
		List<buildertek__Schedule__c> ScheduleList;
		ScheduleList = [SELECT Id, Name, buildertek__Complete__c, buildertek__Community__c, buildertek__Complete1__c, buildertek__Contractor__c, buildertek__Customer_Visible__c, buildertek__Days_Completed__c, buildertek__Description__c, buildertek__Duration__c, buildertek__End_Date__c, buildertek__IsMatch__c, buildertek__Notify_Vendor_on_Schedule_Change__c, buildertek__Primary_Schedule__c, buildertek__Project__c, buildertek__Release_To_Vendor__c, buildertek__Start_Date__c, buildertek__Task_Count__c, buildertek__Total_Duration__c, buildertek__Type__c, buildertek__Vendor_Match__c, buildertek__Vendor_Visible__c
		                from buildertek__Schedule__c
		                Where Id != :scheduleIds and buildertek__Complete__c != 100];
		list<Project_Task__c> projectList = [SELECT Id, Name, buildertek__Actual_Completion_date__c, buildertek__Budget__c, buildertek__Add_To_All_Active_Schedules__c, buildertek__Completed__c, buildertek__Completion__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Cost_Code__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Last_Saved_End_Date__c, buildertek__Last_Saved_Start_Date__c, buildertek__Material_Ordered__c, buildertek__Material_Received__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Payable_Task__c, buildertek__Phase__c, buildertek__Dependency__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Schedule__c, buildertek__Send_Email_Confirmation__c, buildertek__Start__c, buildertek__Trade_Type__c, buildertek__Type__c
		                                     from Project_Task__c
		                                     where Id = :taskIds];

		List<Project_Task__c> scheduleItemList = new List<Project_Task__c>();
		for (Project_Task__c ProjectTask : projectList){
			for (buildertek__Schedule__c schedule : ScheduleList){
				buildertek__Project_Task__c scheduleItemRec = new buildertek__Project_Task__c();
				scheduleItemRec.Name = ProjectTask.Name;
				scheduleItemRec.buildertek__Actual_Completion_date__c = ProjectTask.buildertek__Actual_Completion_date__c;
				scheduleItemRec.buildertek__Budget__c = ProjectTask.buildertek__Budget__c;
				scheduleItemRec.buildertek__Completed__c = ProjectTask.buildertek__Completed__c;
				scheduleItemRec.buildertek__Completion__c = ProjectTask.buildertek__Completion__c;
				scheduleItemRec.buildertek__Contractor__c = ProjectTask.buildertek__Contractor__c;
				scheduleItemRec.buildertek__Contractor_Resource__c = ProjectTask.buildertek__Contractor_Resource__c;
				scheduleItemRec.buildertek__Cost_Code__c = ProjectTask.buildertek__Cost_Code__c;
				scheduleItemRec.buildertek__Duration__c = ProjectTask.buildertek__Duration__c;
				scheduleItemRec.buildertek__Finish__c = ProjectTask.buildertek__Finish__c;
				scheduleItemRec.buildertek__Resource__c = ProjectTask.buildertek__Resource__c;
				scheduleItemRec.buildertek__Lag__c = ProjectTask.buildertek__Lag__c;
				scheduleItemRec.buildertek__Last_Saved_End_Date__c = ProjectTask.buildertek__Last_Saved_End_Date__c;
				scheduleItemRec.buildertek__Last_Saved_Start_Date__c = ProjectTask.buildertek__Last_Saved_Start_Date__c;
				scheduleItemRec.buildertek__Material_Ordered__c = ProjectTask.buildertek__Material_Ordered__c;
				scheduleItemRec.buildertek__Material_Received__c = ProjectTask.buildertek__Material_Received__c;
				scheduleItemRec.buildertek__Milestone__c = ProjectTask.buildertek__Milestone__c;
				scheduleItemRec.buildertek__Notes__c = ProjectTask.buildertek__Notes__c;
				scheduleItemRec.buildertek__Order__c = ProjectTask.buildertek__Order__c;
				scheduleItemRec.buildertek__Original_End_Date__c = ProjectTask.buildertek__Original_End_Date__c;
				scheduleItemRec.buildertek__Original_Start_Date__c = ProjectTask.buildertek__Original_Start_Date__c;
				scheduleItemRec.buildertek__Payable_Task__c = ProjectTask.buildertek__Payable_Task__c;
				scheduleItemRec.buildertek__Phase__c = ProjectTask.buildertek__Phase__c;
				scheduleItemRec.buildertek__Dependency__c = ProjectTask.buildertek__Dependency__c;
				scheduleItemRec.buildertek__Project__c = ProjectTask.buildertek__Project__c;
				scheduleItemRec.buildertek__Purchase_Order__c = ProjectTask.buildertek__Purchase_Order__c;
				scheduleItemRec.buildertek__Reason_for_Date_Change__c = ProjectTask.buildertek__Reason_for_Date_Change__c;
				scheduleItemRec.buildertek__Reason_for_Date_Change_PL__c = ProjectTask.buildertek__Reason_for_Date_Change_PL__c;
				scheduleItemRec.buildertek__Required_Completion_Date__c = ProjectTask.buildertek__Required_Completion_Date__c;
				scheduleItemRec.buildertek__Schedule__c = schedule.Id;
				scheduleItemRec.buildertek__Send_Email_Confirmation__c = ProjectTask.buildertek__Send_Email_Confirmation__c;
				scheduleItemRec.buildertek__Start__c = ProjectTask.buildertek__Start__c;
				scheduleItemRec.buildertek__Trade_Type__c = ProjectTask.buildertek__Trade_Type__c;
				scheduleItemRec.buildertek__Type__c = ProjectTask.buildertek__Type__c;
				scheduleItemList.add(scheduleItemRec);
			}
		}
		if (scheduleItemList.size() > 0){
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = true;
			insert scheduleItemList;
			ProjectTaskTriggerHandler_v1.blnSkipTaskTrigger = false;
		}
	}

}