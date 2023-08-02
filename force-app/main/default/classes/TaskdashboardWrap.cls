public class TaskdashboardWrap {

    
    public class ProjectTaskRecords{
         @AuraEnabled
        public Integer slippage {get;set;}
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String startString {get;set;}
        @AuraEnabled
        public String endString {get;set;}        
        @AuraEnabled
        public String url {get;set;}
        @AuraEnabled
        public String className {get;set;}
        @AuraEnabled
        public String Id {get;set;}          
        @AuraEnabled
        public String projectId {get;set;} 
         @AuraEnabled
        public String contractresourceId {get;set;} 
         @AuraEnabled
        public String internelresource {get;set;}
         @AuraEnabled
        public String ContractorName {get;set;}
        @AuraEnabled
        public String day {get;set;} 
        @AuraEnabled
        public String endday {get;set;} 
        @AuraEnabled
        public String Eid {get;set;} 
        @AuraEnabled
        public String Model {get;set;}  
        @AuraEnabled
        public String UnitId {get;set;}  
        @AuraEnabled
        public String weekName {get;set;}
         @AuraEnabled
        public String taskdescription {get;set;}  
          @AuraEnabled
        public String taskNotes {get;set;}  
        @AuraEnabled
        public Integer taskdays {get;set;}  
        @AuraEnabled
        public Integer Completion {get;set;}
         @AuraEnabled
        public Date startdate {get;set;}  
        @AuraEnabled
        public Date enddate {get;set;}
        @AuraEnabled
        public String Type {get;set;}
    }
    
   
}