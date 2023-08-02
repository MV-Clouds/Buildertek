public class CalendarListWrap {
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled
        public String Id {get;set;} 
        
         @AuraEnabled
        public String Projects {get;set;} 
        @AuraEnabled
        public String Role {get;set;} 
    
      @AuraEnabled
        public list<ProjectRecords> ProjectRecordsList {get;set;}   
      @AuraEnabled
        public list<ProjectTaskRecords> ProjectTaskRecordsList {get;set;}   
      @AuraEnabled
        public list<ResourceRecords> ResourceRecordsList {get;set;}    
        
        
         @AuraEnabled
        public list<ServiceRequest> ServiceRecordList {get;set;} 
        
        public class ServiceRequest{
        @AuraEnabled
        public String Id {get;set;}
        @AuraEnabled
        public String Name {get;set;}
        @AuraEnabled  
        public Date Datevalue {get;set;} 
        @AuraEnabled
        public String ProjectId {get;set;} 
        @AuraEnabled
        public String Resource {get;set;} 
        @AuraEnabled
        public Datetime DatetimeValue {get;set;} 
        
        }

    public class ProjectRecords{ 
            @AuraEnabled
            public String Name {get;set;}
            @AuraEnabled
            public String Id {get;set;} 
            @AuraEnabled
            public String EId {get;set;} 
            @AuraEnabled
            public String startString {get;set;}   
            
            @AuraEnabled
            public String UnitId {get;set;}
             @AuraEnabled
            public String ScheuleItemName {get;set;}
            @AuraEnabled
            public String day {get;set;} 
            @AuraEnabled
            public String endday {get;set;} 
            @AuraEnabled
            public String weekName {get;set;}
        }
    
    public class ProjectTaskRecords{
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
    }
    
    public class ResourceRecords{
        @AuraEnabled
        public String title {get;set;}
        @AuraEnabled
        public String role {get;set;}        
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
        public String day {get;set;}
        @AuraEnabled
        public String endday {get;set;}
        @AuraEnabled
        public String Sid {get;set;}
        @AuraEnabled
        public String weekName {get;set;}
    }     
 
}