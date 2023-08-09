public class ResourceCalendarWrap{
    @AuraEnabled
	public String FirstLetterofContractresourceName{ get; set; }
    
	@AuraEnabled
	public String ContractresourceName{ get; set; }

	@AuraEnabled
	public String ContractresourceId{ get; set; }

	@AuraEnabled
	public String tasks{ get; set; }

	@AuraEnabled
	public String TradeType{ get; set; }

	@AuraEnabled
	public String Companyname{ get; set; }

	@AuraEnabled
	public Decimal simultaneousTasksContractor{ get; set; }

	@AuraEnabled
	public Decimal simultaneousTasksContractorResources{ get; set; }

	@AuraEnabled
	public list<ProjectTaskRecords> ProjectTaskRecordsList{ get; set; }

	@AuraEnabled
	public list<ProjectTaskRecords> year{ get; set; }

	public class SchedulerRecords{
		@AuraEnabled
		public String ScheduleName{ get; set; }

		@AuraEnabled
		public String ScheduleId{ get; set; }

		@AuraEnabled
		public String ScheduleProjectId{ get; set; }

		@AuraEnabled
		public String JobStatus{ get; set; }

		@AuraEnabled
		public list<ProjectTaskRecords> ProjectTaskRecordsList{ get; set; }
	}

	public class ProjectTaskRecords{
		@AuraEnabled
		public String title{ get; set; }

		@AuraEnabled
		public String startString{ get; set; }

		@AuraEnabled
		public String endString{ get; set; }

		@AuraEnabled
		public String url{ get; set; }

		@AuraEnabled
		public String className{ get; set; }

		@AuraEnabled
		public String Id{ get; set; }

		@AuraEnabled
		public String projectId{ get; set; }

		@AuraEnabled
		public String contractresourceId{ get; set; }

		@AuraEnabled
		public String day{ get; set; }

		@AuraEnabled
		public String endday{ get; set; }

		@AuraEnabled
		public String Eid{ get; set; }

		@AuraEnabled
		public String Model{ get; set; }

		@AuraEnabled
		public String UnitId{ get; set; }

		@AuraEnabled
		public String weekName{ get; set; }

		@AuraEnabled
		public String taskdescription{ get; set; }

		@AuraEnabled
		public Integer taskdays{ get; set; }

		@AuraEnabled
		public Integer Completion{ get; set; }

		@AuraEnabled
		public Date startdate{ get; set; }

		@AuraEnabled
		public Date enddate{ get; set; }
	}
}