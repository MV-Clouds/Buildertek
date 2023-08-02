global with sharing class TradeTypeScheduleItems{
	/*public Project__c project{ get; set; }

	public Project_Task__c newTask{ get; set; }

	public Project_Task__c existingTask{ get; set; }

	public String existingTask1{ get; set; }

	public string ganttJSON{ get; set; }

	public string projectId{ get; set; }

	public string recordId{ get; set; }

	public string tradeTypeId{ get; set; }

	public Schedule__c schedule{ get; set; }

	public boolean istaskview{ get; set; }

	public string viewas{ get; set; }

	public TradeTypeScheduleItems(ApexPages.StandardController controller){
		this.schedule = (Schedule__c)controller.getRecord();
		recordId = schedule.Id;
		if (Schema.sObjectType.schedule__c.fields.id.isAccessible() && Schema.sObjectType.schedule__c.fields.Project__c.isAccessible() && Schema.sObjectType.Project__c.fields.Name.isAccessible()){
			projectId = [Select Id, Project__c, Project__r.Name
			             from schedule__c
			             where Id = :recordId].Project__c;
		}
	}

	public TradeTypeScheduleItems(){

		istaskview = false;
		viewas = 'Ganntview';
		if (ApexPages.currentPage().getParameters().get('sId') != null)
			tradeTypeId = ApexPages.currentPage().getParameters().get('sId');
		if (ApexPages.currentPage().getParameters().get('Id') != null)
			recordId = ApexPages.currentPage().getParameters().get('Id');
		if (ApexPages.currentPage().getParameters().get('recordId') != null)
			tradeTypeId = ApexPages.currentPage().getParameters().get('recordId');
		if (String.isBlank(tradeTypeId) && ApexPages.currentPage().getParameters().get('Id') != null){
			tradeTypeId = ApexPages.currentPage().getParameters().get('Id');
		}

		if (tradeTypeId != null){
			try{
				// projectId = [Select Id, Project__c, Project__r.Name
				//              from buildertek__Trade_Type__c
				//              where Id = :tradeTypeId].Project__c;
			} catch (exception e){
				System.debug('Error' + e.getMessage()+'::' + e.getLineNumber());
			}
		}
		newTask = new Project_Task__c();
		ganttJSON = TradeTypeScheduleItems.getJSON(null, tradeTypeId);
	}

	public pageReference redirect(){
		pageReference pg = new pageReference('/lightning/r/' + projectId + '/related/buildertek__Schedules__r/view');
		return pg.setRedirect(true);
	}

	@AuraEnabled
	public static List<buildertek__Trade_Type__c> getAllTradeTypes(){
		try{
			List<buildertek__Trade_Type__c> tradeTypes = [Select Id, Name, (Select Id
			                                                                FROM buildertek__Schedule_Items__r)
			                                              FROM buildertek__Trade_Type__c
			                                              Order By Name];
			if (tradeTypes.size() > 0){
				return tradeTypes;
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	public static String getJSON(String projectId, String tradeTypeId){
		String query = 'Select Project__r.Name, Resource__r.Name,buildertek__Dependency__r.Finish__c, buildertek__Contractor_Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
		if (tradeTypeId != null){
			query = query + ' From Project_Task__c where buildertek__Trade_Type__c =:tradeTypeId Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC';
		}

		List<buildertek__Trade_Type__c> schedules;
		if (tradeTypeId != null){
			schedules = [Select Id, Name
			             FROM buildertek__Trade_Type__c
			             where Id = :tradeTypeId];
		}
		Project__c project = new Project__c();
		if (projectId != null){
			project = [Select Id, Name
			           from Project__c
			           where id = :projectId][0];
		}
		List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();
		projectTasks = DataBase.query(query);
		GanttChart GanttChart = new GanttChart(schedules, projectTasks);
		return GanttChart.getJSON();
	}

	public void cancelTask(){
		newTask = new Project_Task__c();
		existingTask1 = '';
	}

	public void initNewTask(){
		existingTask1 = '';
		String parentId = ApexPages.currentPage().getParameters().get('parentId').escapeHtml4();
		String taskIdToEdit = ApexPages.currentPage().getParameters().get('taskIdToEdit').escapeHtml4();
		newTask = new Project_Task__c();
		newTask.Project__c = projectId;
		try{
			if (tradeTypeId != null){
				newTask.Schedule__c = tradeTypeId;
			}

			if (!String.isBlank(taskIdToEdit)){
				newTask.id = taskIdToEdit;
			} else if (!String.isBlank(parentId) && parentId.length() > 1){
				if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_PROJECT_TASK).equals(parentId.substring(0, 3))){
					List<Project_Task__c> parentTask;

					parentTask = [Select Id, Phase__c, Type__c, buildertek__Milestone__c, Finish__c
					              from Project_Task__c
					              where id = :parentId];


					newTask.Dependency__c = parentId;
					newTask.phase__c = parentTask[0].Phase__c;
					newTask.Type__c = parentTask[0].Type__c;
					if (parentTask[0].Finish__c != null){
						newTask.Start__c = ProjectTaskTriggerHandler.addBussinessDays(parentTask[0].Finish__c, 1);
					}
					newTask.Finish__c = newTask.Start__c;
					newTask.duration__c = 1;
					newTask.lag__c = 0;

				} else if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_PROJECT).equals(parentId.substring(0, 3))){
					newTask.phase__c = '';
					newTask.Start__c = system.today();
					newTask.Finish__c = system.today();
					newTask.duration__c = 1;
					newTask.lag__c = 0;
				} else if (BT_Utils.getSObjectPrefix(BT_Constants.OBJECT_TYPE_SCHEDULE).equals(parentId.substring(0, 3))){
					newTask.Schedule__c = parentId;
					newTask.Start__c = system.today();
					newTask.Finish__c = system.today();
					newTask.duration__c = 1;
					newTask.lag__c = 0;

				} else{
					newTask.phase__c = parentId;
					newTask.Start__c = system.today();
					newTask.Finish__c = system.today();
					newTask.duration__c = 1;
					newTask.lag__c = 0;
				}
			} else{
				newTask.Start__c = system.today();
				newTask.Finish__c = system.today();
				newTask.duration__c = 1;
				newTask.lag__c = 0;
			}
		} catch (Exception exp){

		}
	}

	@RemoteAction
	global static String insertBTTask(String taskJson, String tradeTypeId){
		System.debug('New Task::' + taskJson);
		Project_Task__c newtask = (Project_Task__c)System.JSON.deserialize(taskJson, Project_Task__c.class);

		Date sDate = newtask.buildertek__Start__c;
		if (newtask.buildertek__Duration__c != null){
			newtask.buildertek__Finish__c = sDate.addDays(Integer.valueOf(newtask.buildertek__Duration__c)+1);
		} else{
			if (newtask.buildertek__Finish__c != null){
				newtask.buildertek__Finish__c = sDate.addDays(1);
			}
		}

		if (newtask.Id != null){
			newtask.buildertek__Trade_Type__c = tradeTypeId;
			update newtask;
		} else{
			newtask.buildertek__Trade_Type__c = tradeTypeId;
			newtask.buildertek__Original_Start_Date__c = newtask.buildertek__Start__c;
			newtask.buildertek__Original_End_Date__c = newtask.buildertek__Finish__c;
			insert newtask;
		}

		Project_Task__c projTask;
		projTask = [Select Id, Project__c, buildertek__Schedule__c
		            from Project_Task__c
		            where id = :newTask.Id];

		return getJSON(projTask.Project__c, tradeTypeId);
	}

	@RemoteAction
	global static String updateBTTask(String taskJson, String tradeTypeId){
		System.debug('Task ::' + taskJson);
		Project_Task__c newtask = (Project_Task__c)System.JSON.deserialize(taskJson, Project_Task__c.class);
		Date startDate = newtask.buildertek__Start__c;
		Date endDate = newtask.buildertek__Finish__c;
		if (newtask.buildertek__Duration__c != null){
			newtask.buildertek__Finish__c = endDate.addDays(Integer.valueOf(newtask.buildertek__Duration__c)+1);
		}

		if (newtask.Id != null){
			update newtask;
		} else{
			newtask.buildertek__Original_Start_Date__c = newtask.buildertek__Start__c;
			newtask.buildertek__Original_End_Date__c = newtask.buildertek__Finish__c;
			insert newtask;
		}

		Project_Task__c projTask;
		projTask = [Select Id, Name, Project__c, Start__c, Finish__c, buildertek__Milestone__c, Duration__c, Completion__c, schedule__c, Phase__c, Resource__r.Name, buildertek__Contractor_Resource__r.Name, buildertek__Dependency__c, buildertek__Lag__c, buildertek__Notes__c, buildertek__Contractor__c, buildertek__Resource__c
		            from Project_Task__c
		            where id = :newTask.Id];


		Map<String, buildertek__Project_Task__c> milestoneList = new Map<String, buildertek__Project_Task__c>();
		Map<String, buildertek__Project_Task__c> projectTaskMap = new Map<String, buildertek__Project_Task__c>();
		List<buildertek__Project_Task__c> projectTasks = new List<buildertek__Project_Task__c>();

		//If milestone not created for that Phase, Create here.
		List<Project_Task__c> task = [Select Id, Name, buildertek__Phase__c, buildertek__Start__c, buildertek__Schedule__c, buildertek__Milestone__c
		                              FROM Project_Task__c
		                              WHERE buildertek__Schedule__c = :tradeTypeId];
		for (Project_Task__c tasks : task){
			if (!tasks.buildertek__Milestone__c){
				projectTaskMap.put(tasks.buildertek__Phase__c, tasks);
			} else{
				milestoneList.put(tasks.buildertek__Phase__c, tasks);
			}
		}
		for (Project_Task__c tasks : projectTaskMap.values()){
			if (!milestoneList.containsKey(tasks.buildertek__Phase__c) && !tasks.buildertek__Milestone__c){
				Project_Task__c project = new Project_Task__c();
				project.Name = 'Milestone Complete';
				project.buildertek__Phase__c = tasks.buildertek__Phase__c;
				project.buildertek__Start__c = tasks.buildertek__Start__c;
				project.buildertek__Schedule__c = tradeTypeId;
				project.buildertek__Milestone__c = true;
				projectTasks.add(project);
			}
		}
		System.debug('Project Task::' + projectTasks);
		insert projectTasks;

		return getUpdatedJSON(projTask);
	}

	public static String getUpdatedJSON(Project_Task__c projectTask){
		Data d = new Data();
		d.id = projectTask.Id;
		d.text = projectTask.Name;
		d.contractorResource = '-';
		if (projectTask.buildertek__Contractor_Resource__r.Name != null){
			d.contractorResource = projectTask.buildertek__Contractor_Resource__r.Name;
		}
		if (projectTask.Start__c != null){
			d.start_date = projectTask.Start__c.month()+'-' + projectTask.Start__c.day()+'-' + projectTask.Start__c.year();
		}
		if (projectTask.Finish__c != null){
			d.end_date = projectTask.Finish__c.month()+'-' + projectTask.Finish__c.day()+'-' + projectTask.Finish__c.year();
		}
		d.duration = string.valueOf(projectTask.Duration__c);
		d.progress = string.valueOf(projectTask.Completion__c != null ? projectTask.Completion__c / 100 : 0);
		d.progress1 = string.valueOf((projectTask.Completion__c != null ? projectTask.Completion__c : 0).round())+'%';
		d.open = true;
		if (projectTask.buildertek__Milestone__c){
			d.type = 'milestone';
		} else{
			d.type = 'task';
		}
		if (projectTask.Resource__c != null)
			d.resource = projectTask.Resource__r.Name;
		else
			d.resource = '-';
		if (!String.isBlank(projectTask.Phase__c))
			d.parent = projectTask.Phase__c;
		else
			d.parent = projectTask.schedule__c;
		d.contractorResource = projectTask.buildertek__Contractor_Resource__r.Name;
		if (String.isNotBlank(projectTask.buildertek__Dependency__c)){
			d.dependency = projectTask.buildertek__Dependency__c;
		} else{
			d.dependency = '';
		}

		if (projectTask.buildertek__Lag__c != null){
			d.lag = projectTask.buildertek__Lag__c;
		}
		if (projectTask.buildertek__Notes__c != null)
			d.notes = projectTask.buildertek__Notes__c;
		else
			d.notes = '';
		if (projectTask.buildertek__Contractor__c != null){
			d.contractor = projectTask.buildertek__Contractor__c;
		}
		if (projectTask.buildertek__Resource__c != null){
			d.internalResource = projectTask.buildertek__Resource__c;
		}
		return JSON.serialize(d);
	}

	@RemoteAction
	global static String insertNewTaskLinks(String taskJson){
		return null;
	}

	@RemoteAction
	global static String getNewTaskFieldsetInfo(String taskJson){
		return null;
	}

	@RemoteAction
	global static String changeTaskSchedulingMode(String taskJson){
		return null;
	}

	@RemoteAction
	global static String getAllProjectJSON(String taskJson){
		return null;
	}

	@RemoteAction
	global static String saveGanttData(String taskJson, String taskLinkJson){
		List<GanttChart.Data> tasks = (List<GanttChart.Data>)JSON.deserializeStrict(taskJson, List<GanttChart.Data>.class);
		List<GanttChart.Links> links = (List<GanttChart.Links>)JSON.deserializeStrict(taskLinkJson, List<GanttChart.Links>.class);

		Map<Id, GanttChart.Links> ganttTargetLinks = new Map<Id, GanttChart.Links>();
		for (GanttChart.Links link : links){
			ganttTargetLinks.put(link.target, link);
		}

		List<Project_Task__c> taskToUpdate = new List<Project_Task__c>();
		List<string> ListRec = new List<string>();
		Integer i = 0;
		Map<String, GanttChart.Data> MapGanttChart = new Map<String, GanttChart.Data>();
		Integer o = 1;
		for (GanttChart.Data data : tasks){
			Project_Task__c projectTask = new Project_Task__c();

			//         task.Id = data.Id;
			ListRec.add(data.Id);
			data.order = o;
			MapGanttChart.put(data.Id, data);
			o++;
		}


		system.debug('MapGanttChart ---------> ' + MapGanttChart);


		taskToUpdate = [select id, Name, Duration__c, Start__c, Finish__c, Completion__c, lag__c, Dependency__c, Order__c, Schedule__c
		                from Project_Task__c
		                where id IN :ListRec];


		for (Project_Task__c projectTask : taskToUpdate){
			if (MapGanttChart.get(projectTask.Id) != null){
				system.debug('Task Id :: ' + MapGanttChart.get(projectTask.Id));
				projectTask.Name = MapGanttChart.get(projectTask.Id).text;
				projectTask.Duration__c = double.valueof(MapGanttChart.get(projectTask.Id).duration);
				projectTask.Start__c = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
				//task.Finish__c = Date.valueOf(MapGanttChart.get(task.Id).end_date);
				Date sDate = Date.valueOf(MapGanttChart.get(projectTask.Id).start_date);
				Date eDate = Date.valueOf(MapGanttChart.get(projectTask.Id).end_date);
				projectTask.Finish__c = sDate.addDays(Integer.valueOf(projectTask.Duration__c)+1);
				
				System.debug('Name::' + MapGanttChart.get(projectTask.Id).text);
				System.debug('Start Date:' + Date.valueOf(MapGanttChart.get(projectTask.Id).start_date));
				System.debug('End Date:' + Date.valueOf(MapGanttChart.get(projectTask.Id).end_date));
				System.debug('Map Gantt Chart::' + MapGanttChart.get(projectTask.Id).progress);
				projectTask.Completion__c = MapGanttChart.get(projectTask.Id).progress != '' && MapGanttChart.get(projectTask.Id).progress != null ? Double.valueOf(MapGanttChart.get(projectTask.Id).progress) * 100:0;

				if (ganttTargetLinks.containsKey(projectTask.Id)){
					projectTask.lag__c = ganttTargetLinks.get(projectTask.Id).lag;
					projectTask.Dependency__c = ganttTargetLinks.get(projectTask.Id).source;
				} else{
					projectTask.lag__c = 0;
					projectTask.Dependency__c = null;
				}

				projectTask.Order__c = double.valueof(MapGanttChart.get(projectTask.Id).order);
				i++;
			}

		}

		System.debug('@@taskToUpdate ::' + taskToUpdate.size());
		update taskToUpdate;

		//Integer a=1/0;
		return null;
	}

	@RemoteAction
	global static String deleteTaskLinkById(String taskJson){
		return null;
	}

	@RemoteAction
	global static String deleteTaskById(String taskId, String projectId, String tradeTypeId){
		System.debug('Task Id::' + taskId);
		System.debug('Project Id::' + projectId);
		System.debug('SC::' + tradeTypeId);
		List<Schedule__c> sc = [Select Id, name
		                        from Schedule__c
		                        WHERE ID = :taskId];
		if (sc.size() > 0){
			sc[0].Id = taskId;
			if (Schedule__c.sObjectType.getDescribe().isDeletable()){
				delete sc;
			}
		}

		List<Project_Task__c> projectTask = [Select Id, name, Phase__c
		                                     from Project_Task__c
		                                     WHERE (Phase__c = :taskId AND Schedule__c = :tradeTypeId) OR (Id = :taskId AND Schedule__c = :tradeTypeId)];
		if (projectTask.size() > 0){
			if (Project_Task__c.sObjectType.getDescribe().isDeletable()){
				delete projectTask;
			}
		}

		//Project_Task__c task = new Project_Task__c();
		//task.Id = taskId;

		return getJSON(projectId, tradeTypeId);
	}

	public class Json2ApexConverter{
		public Attributes attributes{ get; set; }

		public String buildertekProjectzz{ get; set; }

		public String buildertekSchedulezz{ get; set; }

		public String Name{ get; set; }

		public String buildertekPhasezz{ get; set; }

		public Integer buildertekDurationzz{ get; set; }

		public String buildertekStartzz{ get; set; }
	}

	public class Attributes{
		public String type_Z{ get; set; }

		// in json: type
	}

	public class Data{
		public String id{ get; set; }

		public String text{ get; set; }

		public String start_date{ get; set; }

		public String end_date{ get; set; }

		public String duration{ get; set; }

		public String progress{ get; set; }

		public string progress1{ get; set; }

		public string contractorResource{ get; set; }

		public Boolean open{ get; set; }

		public String type{ get; set; }

		public String dependency{ get; set; }

		public String contractor{ get; set; }

		public String notes{ get; set; }

		public String internalResource{ get; set; }

		public Decimal lag{ get; set; }

		public String parent{ get; set; }

		public String resource{ get; set; }

		public String color{ get; set; }

		public Integer order{ get; set; }

		public String templates{ get; set; }
	}*/
}