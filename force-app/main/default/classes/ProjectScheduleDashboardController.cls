public class ProjectScheduleDashboardController{
	/*@AuraEnabled
	public static List<buildertek__Project_Task__c> getWeekRecordsClone(string fromDate, string toDate, string selectedProjectId){
		List<buildertek__Project_Task__c> projectTaskList = new List<buildertek__Project_Task__c>();
		Date startDate = date.parse(fromDate);
		Date endDate = date.parse(toDate);

		String query = 'select id,Name,buildertek__Duration__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor_Resource__r.buildertek__Simultaneous_Tasks__c,';
		query += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.buildertek__Simultaneous_Tasks__c,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
		query += 'buildertek__Resource__r.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c FROM ';
		query += 'buildertek__Project_Task__c WHERE ';
		query += 'buildertek__Schedule__c != null AND (buildertek__Start__c <=:endDate OR buildertek__Finish__c >=: startDate)';
		if (selectedProjectId != null && selectedProjectId != ''){
			query += ' AND buildertek__Schedule__r.buildertek__Project__c =: selectedProjectId';
		}
		return Database.query(query);
	}

	@AuraEnabled
	public static list<Wrapper> getAllResourcess(List<String> selected){
		list<Wrapper> wraplst = new list<Wrapper>();
		Map<Id, list<buildertek__Project_Task__c>> scheduleitemmap = new Map<Id, list<buildertek__Project_Task__c>>();
		list<buildertek__Project_Task__c> schduleitems = new list<buildertek__Project_Task__c>();
		if (selected.size() > 0){
			schduleitems = [Select id, Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name
			                From buildertek__Project_Task__c
			                where buildertek__Contractor_Resource__c IN :selected];
		} else{
			schduleitems = [Select id, Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name
			                From buildertek__Project_Task__c
			                where buildertek__Contractor_Resource__c != null];
		}
		set<Id> conid = new set<Id>();
		set<Id> accountIDs = new set<Id>();


		Map<Id, string> contactnamemap = new Map<Id, string>();

		for (buildertek__Project_Task__c schitem : schduleitems){
			conid.add(schitem.buildertek__Contractor_Resource__c);

			if (!scheduleitemmap.containsKey(schitem.buildertek__Contractor_Resource__c)){
				scheduleitemmap.put(schitem.buildertek__Contractor_Resource__c, new List<buildertek__Project_Task__c>());
			}
			scheduleitemmap.get(schitem.buildertek__Contractor_Resource__c).add(schitem);

			if (schitem.buildertek__Contractor_Resource__c != null){
				contactnamemap.put(schitem.buildertek__Contractor_Resource__c, schitem.buildertek__Contractor_Resource__r.Name);
			}


		}


		for (Id rec : scheduleitemmap.keySet()){
			Wrapper wraprec = new Wrapper();
			wraprec.recordId = rec;
			wraprec.Name = contactnamemap.get(rec);
			wraprec.Tasks = string.valueof(scheduleitemmap.get(rec).size());
			wraplst.add(wraprec);
		}

		return wraplst;
	}

	@AuraEnabled
	public static list<buildertek__Project_Task__c> getAllProjectTaskscontacts(List<String> selected){
		list<buildertek__Project_Task__c> projectTaskList;
		if (selected.size() > 0){
			projectTaskList = [Select id, Name, buildertek__Schedule__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
			                   From buildertek__Project_Task__c
			                   where buildertek__Contractor_Resource__c IN :selected];
		} else{
			projectTaskList = [Select id, Name, buildertek__Schedule__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource__r.Name, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c
			                   From buildertek__Project_Task__c
			                   where buildertek__Contractor_Resource__c != null];
		}
		return projectTaskList;
	}

	@AuraEnabled
	public static list<ProjectDashboardWrap.ProjectTaskRecords> getWeekRecords(string fromDate, string toDate, string projectId){
		Map<Id, list<buildertek__Project_Task__c>> scheduleitemmap = new Map<Id, list<buildertek__Project_Task__c>>();
		Map<Id, string> contactnamemap = new Map<Id, string>();

		list<buildertek__Project_Task__c> schudleitemList = new list<buildertek__Project_Task__c>();
		list<buildertek__Project__c> schduleitems = new list<buildertek__Project__c>();
		list<buildertek__Schedule__c> SchedulerList = new list<buildertek__Schedule__c>();
		list<contact> conresource = new list<contact>();

		date startDate = date.parse(fromDate);
		date endDate = date.parse(toDate);
		system.debug('-------startDate' + startDate);
		system.debug('-------endDate' + endDate);
		String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';

		List<contact> resources = new List<contact>();
		String query = 'SELECT Id,Name, buildertek__Stage__c, buildertek__Active__c, buildertek__Project_Description__c, buildertek__Address__c, buildertek__Program__c, buildertek__City__c, buildertek__Country__c, buildertek__Zip__c, buildertek__Estimated_Completion_Date__c, buildertek__County__c, buildertek__State__c, buildertek__Project_Manager__c, buildertek__Estimated_Hours__c, buildertek__Ship_To_Account__c, buildertek__Account__c, buildertek__Auto_Number__c, buildertek__Bathrooms__c, buildertek__Bedrooms__c, buildertek__Price__c, buildertek__Size_Sqft__c, buildertek__Contract_Date__c, buildertek__Approval_Date__c, buildertek__Model_Elevation__c, buildertek__Lot__c, buildertek__Community__c, buildertek__Phase__c, buildertek__Firm_Date__c, buildertek__Type__c, buildertek__Plan_Type__c, buildertek__Master_Project__c, buildertek__Opportunity__c, buildertek__Anticipated_Start_Date__c, buildertek__Price_Book__c, buildertek__Project_Tax_Rate__c, buildertek__Site_Contact__c, buildertek__Customer__c, buildertek__Total_Sq_Feet__c, buildertek__Contingency__c, buildertek__GC_Markup__c, buildertek__Project_Id__c, buildertek__Regional_Factor__c, buildertek__Division__c, buildertek__Location_Type__c, buildertek__ERP_Id__c, buildertek__Brand__c, buildertek__Project_Number_Formula__c, buildertek__Actual_Start__c, buildertek__Actual_Completion_Date__c, buildertek__Region__c, buildertek__Work_Description__c, buildertek__Year_Built__c, buildertek__Lot_Size_sqft_sqm__c, buildertek__Parcel__c, buildertek__Loan_Amount__c, buildertek__Contract_Amount__c, buildertek__Source_Project__c, buildertek__What_Time_Can_We_Start__c, buildertek__Where_can_we_store_tools__c, buildertek__Where_can_we_store_materials__c, buildertek__Can_we_park_in_driveway__c, buildertek__Can_we_park_on_the_street__c, buildertek__Can_we_pile_garbage_on_property__c, buildertek__Is_there_an_alarm_system__c, buildertek__Code_and_contact_info_for_alarm_system__c, buildertek__Is_smoke_detector_hard_wired__c, buildertek__Is_smoke_detector_connected_to_alarm__c, buildertek__Where_is_the_main_water_shut_off_located__c, buildertek__Are_there_any_pets__c, buildertek__Project_Completion__c, buildertek__Garage__c, buildertek__Garage_Side__c, buildertek__Basement__c, buildertek__Geolocation__Latitude__s, buildertek__Geolocation__Longitude__s, buildertek__Geolocation__c, buildertek__Master_Bedroom__c, buildertek__Finish__c, buildertek__Foundation__c, buildertek__Latitude__c, buildertek__Longitude__c, buildertek__Gabel__c, buildertek__Project_Tiers__c, buildertek__Estimator__c, buildertek__Administrator__c ';
		query += 'FROM buildertek__Project__c';
		query += ' WHERE (buildertek__Actual_Start__c <=:endDate AND buildertek__Actual_Completion_Date__c >=: startDate)';
		if (projectId != null && projectId != ''){
			query += ' AND Id =:projectId';
		}

		schduleitems = Database.query(query);
		system.debug('schduleitems---->' + schduleitems);

		list<ProjectDashboardWrap.ProjectTaskRecords> projectRecordList = new list<ProjectDashboardWrap.ProjectTaskRecords>();

		for (buildertek__Project__c pse : schduleitems){
			ProjectDashboardWrap.ProjectTaskRecords rec = new ProjectDashboardWrap.ProjectTaskRecords();

			Datetime dt = (DateTime)pse.buildertek__Actual_Start__c;
			String dayOfWeek = dt.format('yyyy-MM-dd');
			rec.title = pse.Name;
			rec.startString = '';
			rec.endString = '';
			string s = string.valueOfGmt(pse.buildertek__Actual_Start__c);
			String strDate = s.split(' ')[0];

			String sMonth = String.valueof(pse.buildertek__Actual_Start__c.month());
			String sDay = String.valueof(pse.buildertek__Actual_Start__c.day());
			if (sMonth.length() == 1){
				sMonth = '0' + sMonth;
			}
			if (sDay.length() == 1){
				sDay = '0' + sDay;
			}
			string ndate = sMonth + '/' + sDay + '/' + String.valueof(pse.buildertek__Actual_Start__c.year());

			//if (pse.buildertek__Actual_Completion_Date__c != null){
			string FinishDate = string.valueOfGmt(pse.buildertek__Actual_Completion_Date__c);
			String FinishDatestrDate = FinishDate.split(' ')[0];
			String FinishDatesMonth = String.valueof(pse.buildertek__Actual_Completion_Date__c.month());
			String FinishDatesDay = String.valueof(pse.buildertek__Actual_Completion_Date__c.day());
			if (FinishDatesMonth.length() == 1){
				FinishDatesMonth = '0' + FinishDatesMonth;
			}
			if (FinishDatesDay.length() == 1){
				FinishDatesDay = '0' + FinishDatesDay;
			}
			string FinishDatendate = FinishDatesMonth + '/' + FinishDatesDay + '/' + String.valueof(pse.buildertek__Actual_Completion_Date__c.year());
			string ndate1 = String.valueof(pse.buildertek__Actual_Start__c.year())+'-' + sMonth + '-' + sDay;
			Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
			String dateStr = dt1.format('EEEE');
			rec.weekName = dateStr;
			system.debug('--dateStr--->' + dateStr);
			//system.debug('--dayOfWeek--->'+dayOfWeek);

			system.debug('--ndate--->' + ndate1);
			rec.day = ndate;
			rec.endday = FinishDatendate;
			rec.projectId = pse.Name;
			rec.Id = pse.id;
			rec.taskdescription = pse.Name;
			Date sDate = pse.buildertek__Actual_Start__c;
			Date eDate = pse.buildertek__Actual_Completion_Date__c;
			rec.taskdays = Integer.valueof(sDate.daysBetween(eDate));
			rec.Completion = Integer.valueof(sDate.daysBetween(eDate));
			rec.startdate = pse.buildertek__Actual_Start__c;
			rec.enddate = pse.buildertek__Actual_Completion_Date__c;
			projectRecordList.add(rec);
		}
		return projectRecordList;
	}

	public class Wrapper{
		@AuraEnabled
		public string recordId{ get; set; }

		@AuraEnabled
		public string Name{ get; set; }

		@AuraEnabled
		public String Tasks{ get; set; }

		@AuraEnabled
		public String TradeType{ get; set; }
	}*/
}