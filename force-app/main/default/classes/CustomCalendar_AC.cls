public with sharing class CustomCalendar_AC {
  
    @AuraEnabled
    public static list<contact> getAllResourcess(list<String> selected){
       list<contact> contactList ; 
       if(selected.size() > 0){
        list<buildertek__Project_Task__c> projectTaskList ; 
         if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible() &&
                 Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isAccessible() &&
                  Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Project__c.isAccessible()){
                    projectTaskList = [Select buildertek__Resource__c,buildertek__Contractor_Resource__c From buildertek__Project_Task__c where buildertek__Schedule__r.buildertek__Project__c IN: selected]; 
                  }
        list<id> IdsList = new list<id>();
        for(buildertek__Project_Task__c Con : projectTaskList){
            if(con.buildertek__Contractor_Resource__c !=null){
            IdsList.add(con.buildertek__Contractor_Resource__c);
            }
        }
        if (Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                Schema.sObjectType.Contact.fields.AccountId.isAccessible()){
                contactList = [Select id,Name,Accountid,Account.Name From Contact where id IN: IdsList]; 
         }
       }
       else{
            if (Schema.sObjectType.Contact.fields.Id.isAccessible() &&
                Schema.sObjectType.Contact.fields.Name.isAccessible() &&
                Schema.sObjectType.Contact.fields.AccountId.isAccessible() &&
                Schema.sObjectType.Account.fields.Name.isAccessible()){
        contactList = [Select id,Name,Accountid,Account.Name From Contact];  
                 }
       }
       return contactList;
    }
    
    @AuraEnabled
    public static list<buildertek__Project_Task__c> getAllProjectTasks(list<String> selected){
       list<buildertek__Project_Task__c> projectTaskList ; 
       if(selected.size() > 0){
           if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible() &&
                 Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isAccessible() &&
                  Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Project__c.isAccessible()){
                projectTaskList = [Select id,Name From buildertek__Project_Task__c where buildertek__Schedule__r.buildertek__Project__c IN: selected]; 
                }
       }
       else{
           if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible()){
         projectTaskList = [Select id,Name From buildertek__Project_Task__c];   
                }
       }
       return projectTaskList;
    }
    
    @AuraEnabled
    public static list<buildertek__Project__c> getAllProjects(string selected){
        list<buildertek__Project__c> projectTaskList ; 
        if(selected == ''){
            if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
                projectTaskList = [Select id,Name From buildertek__Project__c]; 
                }
        }
        else{
             if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
            projectTaskList = [Select id,Name From buildertek__Project__c where id=: selected ]; 
             }
        }
        return projectTaskList;
    }
    
     @AuraEnabled
    public static list<CalendarWrap> getWeekRecords(string fromDate, string toDate,list<String> selected, string ChildSelected, string ContChildSelected){
        
        map<id, string> projectmap = new map<id, string>();
        map<id, set<string>> equipmentmap = new map<id, set<string>>();
        map<id, set<string>> resourcemap = new map<id, set<string>>();
        map<id, set<string>> datemap = new map<id, set<string>>();   
        
        list<buildertek__Project_Task__c> pseList = new list<buildertek__Project_Task__c>();
        list<buildertek__Project_Task__c> psrList = new list<buildertek__Project_Task__c>();
        list<buildertek__Schedule__c> projectSchedulerList = new list<buildertek__Schedule__c>();
        list<buildertek__Project__c> projectList = new list<buildertek__Project__c>();
         
         
        date startDate = date.parse(fromDate);   
        date endDate = date.parse(toDate);  
        system.debug('-------startDate'+startDate); 
        system.debug('-------endDate'+endDate); 
        String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        list<CalendarWrap> ProjectRecordList = new list<CalendarWrap>(); 
          
        list<buildertek__Project__c> buildertekProject = new list<buildertek__Project__c>();
        if(selected.size() <= 0){ 
           
            projectSchedulerList = [select Id,Name,buildertek__Project__c,buildertek__Project__r.Name from buildertek__Schedule__c ];
            
             if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() ){
              buildertekProject = [select id from buildertek__Project__c ];
             }
        }
        else{
                
     
            projectSchedulerList = [select Id,Name,buildertek__Project__c,buildertek__Project__r.Name from buildertek__Schedule__c where buildertek__Project__c IN: selected ];
            
           
            buildertekProject = [select id from buildertek__Project__c where id IN: selected];   
           
        }
        system.debug('****LoggingLevel logLevel'+projectSchedulerList.size());
        set<id> ProjectIds = new set<id>();
        for(buildertek__Project__c p : buildertekProject){
            ProjectIds.add(p.Id);
        }
       
         string Query = 'select id,Name,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,';
                Query += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
                Query += 'buildertek__Resource__r.Name,buildertek__Resource__c,buildertek__Start__c,buildertek__Finish__c from ';
                Query += 'buildertek__Project_Task__c where ';
                Query += 'buildertek__Schedule__c != null and (buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate)';
                Query += 'and buildertek__Schedule__r.buildertek__Project__c IN:ProjectIds';
        		system.debug(ChildSelected+'-----ContChildSelected----->'+ContChildSelected);
        
             if(ChildSelected != null && ContChildSelected == null){
                 Query += ' and id =: ChildSelected';
                
             }    
             else if(ChildSelected == null && ContChildSelected !=null){
                Query += ' and buildertek__Contractor_Resource__c =: ContChildSelected';
              
             }
             else if(ChildSelected !=null && ContChildSelected !=null){
                 Query += ' and id =: ChildSelected and buildertek__Contractor_Resource__c =: ContChildSelected';
             }
        
       
            pseList = Database.query(Query); 
        system.debug('pseList----->'+pseList);
          
        
      
                projectList = [Select id,Name,buildertek__Stage__c From buildertek__Project__c Where id IN: ProjectIds ORDER BY Name ASC];
		 
    for(buildertek__Project__c PL : projectList){
        CalendarWrap projectRec= new CalendarWrap();
        list<CalendarWrap.SchedulerRecords> SchedulerRecordList = new list<CalendarWrap.SchedulerRecords>();  
                
                projectRec.projectId =PL.id;
                projectRec.projectName =PL.Name; 
                projectRec.projectStatus = PL.buildertek__Stage__c; 
                System.debug('projectSchedulerList'+projectSchedulerList);
               System.debug(projectRec.projectId);
                for(buildertek__Schedule__c equ : projectSchedulerList){
                    if(PL.id == equ.buildertek__Project__c){
                        CalendarWrap.SchedulerRecords SchedulerRec = new CalendarWrap.SchedulerRecords(); 
                          SchedulerRec.ScheduleName =equ.Name;
                            SchedulerRec.ScheduleId =equ.Id;
                            //SchedulerRec.JobStatus =equ.Status__c;
                          SchedulerRec.ScheduleProjectId = equ.buildertek__Project__r.Id;
                          
                          list<CalendarWrap.ProjectTaskRecords> EquipmentRecordList = new list<CalendarWrap.ProjectTaskRecords>();
                          list<CalendarWrap.ResourceRecords> ResourceRecordList = new list<CalendarWrap.ResourceRecords>();

                                for(buildertek__Project_Task__c pse : pseList){
                                     if(equ.id == pse.buildertek__Schedule__c){
                                        CalendarWrap.ProjectTaskRecords EquipmentRec = new CalendarWrap.ProjectTaskRecords();
                                        Datetime dt = (DateTime)pse.buildertek__Start__c;
                                        String dayOfWeek = dt.format('yyyy-MM-dd'); 
                                        
                                        EquipmentRec.title = pse.Name;
                                        EquipmentRec.startString ='';
                                        EquipmentRec.endString = '';
                                        string s = string.valueOfGmt(pse.buildertek__Start__c);
                                        String strDate = s.split(' ')[0]; 
                                        
                                        String sMonth = String.valueof(pse.buildertek__Start__c.month());
                                        String sDay = String.valueof(pse.buildertek__Start__c.day());
                                        if(sMonth.length()==1){
                                          sMonth = '0' + sMonth;
                                        }
                                        if(sDay.length()==1){
                                          sDay = '0' + sDay;
                                        }
                                        string ndate = sMonth+'/'+sDay+'/'+String.valueof(pse.buildertek__Start__c.year());
                                        
                                        if(pse.buildertek__Finish__c != null){
                                        string FinishDate = string.valueOfGmt(pse.buildertek__Finish__c);
                                        String FinishDatestrDate = FinishDate.split(' ')[0]; 
                                        String FinishDatesMonth = String.valueof(pse.buildertek__Finish__c.month());
                                        String FinishDatesDay = String.valueof(pse.buildertek__Finish__c.day());
                                        if(FinishDatesMonth.length()==1){
                                          FinishDatesMonth = '0' + FinishDatesMonth;
                                        }
                                        if(FinishDatesDay.length()==1){
                                          FinishDatesDay = '0' + FinishDatesDay;
                                        }
                                        string FinishDatendate = FinishDatesMonth+'/'+FinishDatesDay+'/'+String.valueof(pse.buildertek__Finish__c.year());
                                        string ndate1 = String.valueof(pse.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                                        Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
                                        String dateStr = dt1.format('EEEE');
                                        EquipmentRec.weekName =dateStr;
                                        system.debug('--dateStr--->'+dateStr);
                                         //system.debug('--dayOfWeek--->'+dayOfWeek);
                                        
                                        system.debug('--ndate--->'+ndate1);
                                        EquipmentRec.day = ndate;
                                        EquipmentRec.endday = FinishDatendate;
                                        EquipmentRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__c; 
                                        EquipmentRec.Id = pse.id;
                                        EquipmentRec.Eid = pse.buildertek__Schedule__c; 
                                        EquipmentRec.Model = pse.buildertek__Schedule__r.Name;
                                        EquipmentRec.UnitId = pse.buildertek__Resource__r.Name;
                                        EquipmentRecordList.add(EquipmentRec); 
                                        
                                        CalendarWrap.ResourceRecords ResourceRec = new CalendarWrap.ResourceRecords();
                                        ResourceRec.title = pse.buildertek__Resource__r.Name;
                                        ResourceRec.startString ='';
                                        ResourceRec.endString = '';
                                        ResourceRec.weekName =dateStr;
                                        ResourceRec.day = ndate;
                                        ResourceRec.endday = FinishDatendate;
                                        ResourceRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__c; 
                                        ResourceRec.Id = pse.id;
                                        ResourceRec.Sid = pse.buildertek__Contractor_Resource__c;
                                        ResourceRecordList.add(ResourceRec); 
                                        }
                      
                                     }
                                }
                             
    
                        SchedulerRec.ProjectTaskRecordsList = EquipmentRecordList;
                        SchedulerRec.ResourceRecordsList = ResourceRecordList;
                        SchedulerRecordList.add(SchedulerRec);
                    }
                    
               // }
                }
              projectRec.SchedulerRecordList =SchedulerRecordList;
                ProjectRecordList.add(projectRec);    
        }
        
        list<buildertek__Service_Request__c> ServiceClass;
        if(Schema.sObjectType.buildertek__Service_Request__c.fields.Id.isAccessible()&&
          Schema.sObjectType.buildertek__Service_Request__c.fields.Name.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Preferred_Date_of_Service__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.Account.fields.Name.isAccessible() ){ 
                                                ServiceClass  = [Select id,Name,
                                                                buildertek__Project__c,
                                                                buildertek__Customer_Name__c,
                                                                buildertek__Customer_Name__r.Name,
                                                                buildertek__Preferred_Date_of_Service__c 
                                                                From buildertek__Service_Request__c Where buildertek__Project__c IN: ProjectIds and (buildertek__Preferred_Date_of_Service__c >=: startDate or buildertek__Preferred_Date_of_Service__c <=: endDate) ORDER BY Name ASC];
          }
        
        list<CalendarWrap.ServiceRequest> ServiceRequestList = new list<CalendarWrap.ServiceRequest>();  
        
        for(buildertek__Service_Request__c BSR : ServiceClass){
            if(BSR.buildertek__Preferred_Date_of_Service__c != null){
           
           CalendarWrap.ServiceRequest SchedulerRecs = new CalendarWrap.ServiceRequest(); 
           SchedulerRecs.Id = BSR.Id;
           SchedulerRecs.ProjectId = BSR.buildertek__Project__c;
           SchedulerRecs.Datevalue = Date.valueof(BSR.buildertek__Preferred_Date_of_Service__c);
           SchedulerRecs.Name = BSR.Name;
           SchedulerRecs.Resource = BSR.buildertek__Customer_Name__r.Name;
           
            TimeZone tz = UserInfo.getTimeZone();
            DateTime localTime = BSR.buildertek__Preferred_Date_of_Service__c.AddSeconds(tz.getOffset(BSR.buildertek__Preferred_Date_of_Service__c)/1000);
       
           SchedulerRecs.DatetimeValue = localTime;
           system.debug('SchedulerRecs.DatetimeValue ********** ' + localTime);
           ServiceRequestList.add(SchedulerRecs);
            }
        }
        
        for(CalendarWrap Cal : ProjectRecordList){
        //     for(CalendarWrap.ServiceRequest ServiceRequest : ServiceRequestList){
        //         if(Cal.ProjectId == ServiceRequest.ProjectId){
                    Cal.ServiceRecordList = ServiceRequestList;
        //         }
        //     }
         }
        

        return ProjectRecordList;
    }
    
    
     @AuraEnabled
    public static list<CalendarWrap> getSelectedWeekRecords(string fromDate, string toDate, list<String> selected){
        
        map<id, string> projectmap = new map<id, string>();
        map<id, set<string>> equipmentmap = new map<id, set<string>>();
        map<id, set<string>> resourcemap = new map<id, set<string>>();
        map<id, set<string>> datemap = new map<id, set<string>>();   
        
        list<buildertek__Project_Task__c> pseList = new list<buildertek__Project_Task__c>();
        list<buildertek__Schedule__c> projectSchedulerList = new list<buildertek__Schedule__c>();
        list<buildertek__Project__c> projectList = new list<buildertek__Project__c>();
         
         
        date startDate = date.parse(fromDate);   
        date endDate = date.parse(toDate);  
        system.debug('-------startDate'+startDate); 
        system.debug('-------endDate'+endDate); 
        String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        list<CalendarWrap> ProjectRecordList = new list<CalendarWrap>(); 
        if (Schema.sObjectType.buildertek__Schedule__c.fields.Id.isAccessible() && 
				Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible() &&
				Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Project__c.isAccessible() &&
				Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible() ){
                projectSchedulerList = [select Id,Name,buildertek__Project__c,buildertek__Project__r.Name from buildertek__Schedule__c where buildertek__Project__c IN: selected];
            }
        list<buildertek__Project__c> buildertekProject ;
        if(Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() ){
            buildertekProject = [select id from buildertek__Project__c where Id IN: selected];
          }
        system.debug('****LoggingLevel logLevel'+projectSchedulerList.size());
        set<id> ProjectIds = new set<id>();
        for(buildertek__Project__c p : buildertekProject){
            ProjectIds.add(p.Id);
        }
      
                pseList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            buildertek__Resource__r.Name,
                            buildertek__Resource__c,
                           buildertek__Contractor_Resource__c,
                           buildertek__Contractor_Resource__r.Name,
                            buildertek__Start__c from 
                            buildertek__Project_Task__c where 
                            buildertek__Schedule__c != null and buildertek__Start__c >=:startDate 
                            and buildertek__Schedule__r.buildertek__Project__c IN:ProjectIds];
		                   
     if(Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() &&
           Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Project__c.fields.buildertek__Stage__c.isAccessible()){
           projectList = [Select id,Name,buildertek__Stage__c From buildertek__Project__c Where id IN: ProjectIds ORDER BY Name ASC];
         }
    for(buildertek__Project__c PL : projectList){
            CalendarWrap projectRec= new CalendarWrap();
        list<CalendarWrap.SchedulerRecords> SchedulerRecordList = new list<CalendarWrap.SchedulerRecords>();  
                
                projectRec.projectId =PL.id;
                projectRec.projectName =PL.Name; 
                projectRec.projectStatus = PL.Stage__c; 
                for(buildertek__Schedule__c equ : projectSchedulerList){
                    if(PL.id == equ.buildertek__Project__c){
                        CalendarWrap.SchedulerRecords SchedulerRec = new CalendarWrap.SchedulerRecords(); 
                          SchedulerRec.ScheduleName =equ.Name;
                            SchedulerRec.ScheduleId =equ.Id;
                            //SchedulerRec.JobStatus =equ.Status__c;
                          SchedulerRec.ScheduleProjectId = equ.buildertek__Project__r.Id;
                          
                          list<CalendarWrap.ProjectTaskRecords> EquipmentRecordList = new list<CalendarWrap.ProjectTaskRecords>();
                          list<CalendarWrap.ResourceRecords> ResourceRecordList = new list<CalendarWrap.ResourceRecords>();

                                for(buildertek__Project_Task__c pse : pseList){
                                     if(equ.id == pse.buildertek__Schedule__c){
                                        CalendarWrap.ProjectTaskRecords EquipmentRec = new CalendarWrap.ProjectTaskRecords();
                                        Datetime dt = (DateTime)pse.buildertek__Start__c;
                                        String dayOfWeek = dt.format('yyyy-MM-dd'); 
                                        
                                        EquipmentRec.title = pse.Name;
                                        EquipmentRec.startString ='';
                                        EquipmentRec.endString = '';
                    string s = string.valueOfGmt(pse.buildertek__Start__c);
                    String strDate = s.split(' ')[0]; 
                    
                    String sMonth = String.valueof(pse.buildertek__Start__c.month());
                    String sDay = String.valueof(pse.buildertek__Start__c.day());
                    if(sMonth.length()==1){
                      sMonth = '0' + sMonth;
                    }
                    if(sDay.length()==1){
                      sDay = '0' + sDay;
                    }
                    string ndate = sMonth+'/'+sDay+'/'+String.valueof(pse.buildertek__Start__c.year());
                    string ndate1 = String.valueof(pse.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                    Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
                    String dateStr = dt1.format('EEEE');
                    EquipmentRec.weekName =dateStr;
                    system.debug('--dateStr--->'+dateStr);
                     //system.debug('--dayOfWeek--->'+dayOfWeek);
                    
                    system.debug('--ndate--->'+ndate1);
                                        EquipmentRec.day = ndate;
                                        EquipmentRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__c; 
                                        EquipmentRec.Id = pse.id;
                                        EquipmentRec.Eid = pse.buildertek__Schedule__c; 
                                        EquipmentRec.Model = pse.buildertek__Schedule__r.Name;
                                        EquipmentRec.UnitId = pse.buildertek__Resource__r.Name;
                                        EquipmentRecordList.add(EquipmentRec);                                    
                                    }                                   
                                    

                        SchedulerRec.ProjectTaskRecordsList = EquipmentRecordList;
                     //   SchedulerRec.ResourceRecordsList = ResourceRecordList;
            SchedulerRecordList.add(SchedulerRec);
                    }
                    
                }
                }
              projectRec.SchedulerRecordList =SchedulerRecordList;
                ProjectRecordList.add(projectRec);    
        }

        return ProjectRecordList;
    }
    
    
     @AuraEnabled
    public static list<buildertek__Project_Scheduler__c> getSchedulers( string ProjectID){
       list<buildertek__Project_Scheduler__c> SchedulersList; 
        if(Schema.sObjectType.buildertek__Project_Scheduler__c.fields.Id.isAccessible() &&
           Schema.sObjectType.buildertek__Project_Scheduler__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
         SchedulersList = [Select id,Name From buildertek__Project_Scheduler__c Where buildertek__Project__c=:ProjectID order by Name DESC];
        }
       return SchedulersList;
    } 
    
     @AuraEnabled
    public static string updateDates(string ResourceId,string DataType,string ResourceSetDate,string ProjectId,string ScheduleId){
      string returnStr='';
        date Datevalue = date.parse(ResourceSetDate);  

        list<buildertek__Project_Scheduler__c> projectSchedulerList;
        if(Schema.sObjectType.buildertek__Project_Scheduler__c.fields.Id.isAccessible()){
                    projectSchedulerList= [Select id from buildertek__Project_Scheduler__c Where buildertek__Project__c=:ProjectId];
        }
        system.debug('projectSchedulerListuhjh' +projectSchedulerList);
        if(projectSchedulerList.size()>0 && ScheduleId != null && ScheduleId != ''){
            if(DataType == 'Resource'){
                list<buildertek__Project_Scheduler_Resource_Junction__c> checkResource;
                 if(Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Date__c.isAccessible()&&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Contact__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Project_Scheduler__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Status__c.isAccessible()){
                      checkResource= [Select id from buildertek__Project_Scheduler_Resource_Junction__c Where buildertek__Date__c=:Datevalue And buildertek__Contact__c=:ResourceId AND buildertek__Project_Scheduler__r.buildertek__Status__c != 'Cancel' ];
                      }
                system.debug('checkResource---->'+checkResource);
                if(checkResource.size() ==  0){
                    system.debug('checkResource---->'+checkResource.size());
                    buildertek__Project_Scheduler_Resource_Junction__c ResourceRec = new buildertek__Project_Scheduler_Resource_Junction__c();
                        ResourceRec.buildertek__Contact__c = ResourceId;
                        ResourceRec.buildertek__Date__c = Datevalue;
                        ResourceRec.buildertek__Project_Scheduler__c = ScheduleId;
                        if(Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Date__c.isCreateable()&&
                          Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Contact__c.isCreateable() &&
                          Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Project_Scheduler__c.isCreateable()){
                           insert ResourceRec; 
                          }
                    
                        returnStr = 'SUCCESS';
                }
                else{
                    returnStr = 'ASSIGNED';  
                }

            }
            if(DataType == 'projectTask'){
                list<buildertek__Project_Scheduler_Task_Junction__c> checkEquipment;
                if(Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Date__c.isAccessible()&&
                      Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Task__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Scheduler__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Status__c.isAccessible()){
                     checkEquipment = [Select id from buildertek__Project_Scheduler_Task_Junction__c Where buildertek__Date__c=:Datevalue And buildertek__Project_Task__c=:ResourceId AND buildertek__Project_Scheduler__r.buildertek__Status__c != 'Cancel' ];
                }
                if(checkEquipment.size() ==  0){ 
                    buildertek__Project_Scheduler_Task_Junction__c EquipmentRec = new buildertek__Project_Scheduler_Task_Junction__c();
                        EquipmentRec.buildertek__Date__c = Datevalue;
                        EquipmentRec.buildertek__Project_Task__c = ResourceId;
                        EquipmentRec.buildertek__Project_Scheduler__c = ScheduleId; 
                         if(Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Date__c.isCreateable()&&
                          Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Task__c.isCreateable() &&
                          Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Scheduler__c.isCreateable()){
                           insert EquipmentRec; 
                          }
                        
                        returnStr = 'SUCCESS';
                }
                else{
                     returnStr = 'ASSIGNED';  
                }
            }
        }
        else{

            if(DataType == 'Resource'){
                list<buildertek__Project_Scheduler_Resource_Junction__c> checkResource;
                if(Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Date__c.isAccessible()&&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Contact__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Project_Scheduler__c.isAccessible() &&
                      Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Status__c.isAccessible()){
                     checkResource = [Select id from buildertek__Project_Scheduler_Resource_Junction__c Where buildertek__Date__c=:Datevalue And buildertek__Contact__c=:ResourceId AND buildertek__Project_Scheduler__r.buildertek__Status__c != 'Cancel' ];
                      }
                if(checkResource.size() ==  0){
                    buildertek__Project_Scheduler__c schedulerRec = new buildertek__Project_Scheduler__c();
                    schedulerRec.buildertek__Project__c = ProjectId;
                    schedulerRec.buildertek__Project_End_Date__c = Datevalue;
                    
                     if(Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Project__c.isCreateable()&&
                        Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Project_End_Date__c.isCreateable()){ 
                       insert schedulerRec;  
                      }
                    
                    buildertek__Project_Scheduler_Resource_Junction__c ResourceRec = new buildertek__Project_Scheduler_Resource_Junction__c();
                    ResourceRec.buildertek__Contact__c = ResourceId;
                    ResourceRec.buildertek__Date__c = Datevalue;
                    ResourceRec.buildertek__Project_Scheduler__c = schedulerRec.id;
                    if(Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Date__c.isCreateable()&&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Contact__c.isCreateable() &&
                      Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.buildertek__Project_Scheduler__c.isCreateable()){
                       insert ResourceRec;
                      }
                    returnStr = 'SUCCESS';  
                }
                else{
                  returnStr = 'ASSIGNED';    
                }
            }
            if(DataType == 'projectTask'){
                list<buildertek__Project_Scheduler_Task_Junction__c> checkEquipment;
                if(Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.Id.isAccessible()&&
                    Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Date__c.isAccessible() &&
                    Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Task__c.isAccessible() &&
                    Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Status__c.isAccessible()){
                    checkEquipment= [Select id from buildertek__Project_Scheduler_Task_Junction__c Where buildertek__Date__c=:Datevalue And buildertek__Project_Task__c=:ResourceId AND buildertek__Project_Scheduler__r.buildertek__Status__c != 'Cancel' ];
                    }
                if(checkEquipment.size() ==  0){  
                    buildertek__Project_Scheduler__c schedulerRec = new buildertek__Project_Scheduler__c();
                    schedulerRec.buildertek__Project__c = ProjectId;
                    schedulerRec.buildertek__Project_End_Date__c = Datevalue;
                    if(Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Project__c.isCreateable()&&
                      Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Project_End_Date__c.isCreateable()){
                      insert schedulerRec; 
                      }
                    
                    buildertek__Project_Scheduler_Task_Junction__c EquipmentRec = new buildertek__Project_Scheduler_Task_Junction__c();
                    EquipmentRec.buildertek__Date__c = Datevalue;
                    EquipmentRec.buildertek__Project_Task__c = ResourceId;
                    EquipmentRec.buildertek__Project_Scheduler__c = schedulerRec.id;
                    
                    if(Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Date__c.isCreateable()&&
                      Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Task__c.isCreateable() &&
                      Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.buildertek__Project_Scheduler__c.isCreateable()){
                      insert EquipmentRec;
            		  }
                    
                    returnStr = 'SUCCESS';   
                }
                else{
                    returnStr = 'ASSIGNED';    
                }
            }

        } 
        return returnStr;
    } 
    
    @AuraEnabled
    public static list<buildertek__Project_Task__c> getprojectJunction(){
       list<buildertek__Project_Task__c> projList ;
    if(Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible()){
       projList = [Select id,Name From buildertek__Project_Task__c limit 10000]; 
    }
       return projList;
    }
    
    @AuraEnabled
    public static String DeleteProject(string junctionId, string ResourceSetDate){  
    	string returnStr='';
    	date Datevalue = date.parse(ResourceSetDate);
    	
    	list<Project_Scheduler_Task_Junction__c> DeleteProject;
    	if(Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Project_Task__c.isAccessible() && 
    	    Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Id.isAccessible() &&
    	    Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Date__c.isAccessible()){
    	   DeleteProject = [Select id,Project_Task__c from Project_Scheduler_Task_Junction__c Where Date__c=:Datevalue And id=:junctionId];
        }
    	if(DeleteProject.size()>0){ 
    	    If(Project_Scheduler_Task_Junction__c.sObjectType.getDescribe().isDeletable()){
    		Delete DeleteProject;
    	   }
    		returnStr = 'SUCCESS'; 
    	}
    	else{
    		returnStr = 'ASSIGNED'; 
    	}
    	return returnStr;
    }
    
    @AuraEnabled
    public static String updateProject(string junctionId, string ResourceSetDate,string projectJunctionId){
        string returnStr='';
        date Datevalue = date.parse(ResourceSetDate);
        system.debug(projectJunctionId + ' ************** Values' + junctionId + ' ********* ' + Datevalue);
        list<Project_Scheduler_Task_Junction__c> updateProject;
        if(Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Project_Task__c.isAccessible() && Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Date__c.isAccessible()){
        updateProject = [Select id,Project_Task__c from Project_Scheduler_Task_Junction__c Where Date__c=:Datevalue And id=:junctionId];
        }
        system.debug(updateProject + ' ************** updateEquipment');
        if(updateProject.size()>0){
            for(Project_Scheduler_Task_Junction__c pse : updateProject){
                if(projectJunctionId.contains(';')){ 
                    projectJunctionId =projectJunctionId.removeStart(';') ; 
                }
                pse.Project_Task__c = projectJunctionId;
            }
            if(Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Project_Task__c.isUpdateable() &&
              Schema.sObjectType.Project_Scheduler_Task_Junction__c.fields.Id.isUpdateable()){
             update updateProject;
              }
            returnStr = 'SUCCESS'; 
            
        }
        else{
            returnStr = 'ASSIGNED'; 
        }
        return returnStr;
    }
    
    @AuraEnabled
    public static String updateResource(string junctionId, string ResourceSetDate,string ProjectId,string ResourceId){
        string returnStr='';
        date Datevalue = date.parse(ResourceSetDate);
        list<Project_Scheduler_Resource_Junction__c> updateResource;
         if(Schema.sObjectType.Project_Scheduler_Resource_Junction__c.fields.Contact__c.isAccessible() && 
            Schema.sObjectType.Project_Scheduler_Resource_Junction__c.fields.Id.isAccessible()){
          updateResource = [Select id,Contact__c from Project_Scheduler_Resource_Junction__c Where Date__c=:Datevalue And id=:junctionId];
         }
        system.debug('@@@@@'+ ResourceId);
        if(updateResource.size()>0){
            for(Project_Scheduler_Resource_Junction__c psr : updateResource){
                if(ResourceId.contains(';')){
                    system.debug('@@@@@1'+ ResourceId);
                    ResourceId =ResourceId.removeStart(';') ;
                    system.debug('@@@@@2'+ ResourceId);
                }
                list<contact> conlist;
                if(Schema.sObjectType.contact.fields.Id.isAccessible()
                    && Schema.sObjectType.contact.fields.Name.isAccessible()){
                    conlist = [select id,Name from contact where Name =:ResourceId];    
                }
                if(conlist.size()>0){
                psr.Contact__c = conlist[0].id;
                }
            }
            if(Schema.sObjectType.Project_Scheduler_Resource_Junction__c.fields.Contact__c.isUpdateable() ){
            update updateResource;
            }
            returnStr = 'SUCCESS'; 
          // }
        }
        else{
            returnStr = 'ASSIGNED'; 
        }
        return returnStr;   
    }
    
    @AuraEnabled
    public static String DeleteResource(string junctionId, string ResourceSetDate,string ProjectId,string ResourceId){
        string returnStr='';
        date Datevalue = date.parse(ResourceSetDate);
        list<Project_Scheduler_Resource_Junction__c> DeleteResource;
        if(Schema.sObjectType.Project_Scheduler_Resource_Junction__c.fields.Id.isAccessible() && Schema.sObjectType.Project_Scheduler_Resource_Junction__c.fields.Name.isAccessible()){
            
          DeleteResource = [Select id,Name from Project_Scheduler_Resource_Junction__c Where Date__c=:Datevalue And id=:junctionId];
        }
        if(DeleteResource.size()>0){ 
          if(Schema.sObjectType.Project_Scheduler_Resource_Junction__c.isDeletable() ){
            Delete DeleteResource;
          }
            returnStr = 'SUCCESS'; 
          
        }
        else{
            returnStr = 'ASSIGNED'; 
        }
        return returnStr;   
    }
    
    @auraEnabled
    public static string setResourceText(String rid){ 
        list<contact> conlist;
        if(Schema.sObjectType.contact.fields.Id.isAccessible()
            && Schema.sObjectType.contact.fields.Name.isAccessible()){
            conlist = [select id,Name from contact where id=:rid];    
        }
        
        return conlist[0].Name;
        
    }
    
     @auraEnabled
    public static List<contact> getContacts(String contactName){

        String fnd = '%' +contactName + '%';
        list<contact> conlist;
        if(Schema.sObjectType.contact.fields.Id.isAccessible()
            && Schema.sObjectType.contact.fields.Name.isAccessible()){
            conlist = [select id,name FROM Contact where name like:fnd order by Name ASC];    
        }
        return conlist;
    }
    
    
     @AuraEnabled
    public static list<CalendarListWrap> getAllJunctionprojects(string fromDate, string toDate,string recordId,string projecttaskrec,string Resourcerecs){
        list<CalendarListWrap> RecordList = new list<CalendarListWrap>(); 
        list<buildertek__Project__c> projectList1 = new list<buildertek__Project__c>();
        
        if(recordId == ''){
            if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && 
				Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
            projectList1 = [Select id,Name From buildertek__Project__c];
        }
            
        }
        else{
            if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && 
				Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
            projectList1 = [Select id,Name From buildertek__Project__c where id=: recordId]; 
        }
            
        }
          
        set<id> ProjectIds = new set<id>();
        for(buildertek__Project__c p : projectList1){
            ProjectIds.add(p.id);
            system.debug('ProjectIds----'+ProjectIds);
        }
        
        date startDate = date.parse(fromDate); 
        system.debug('startDate -----------> '+startDate);
        date endDate = date.parse(toDate);
        system.debug('endDate -----------> '+endDate);
        set<id>EquipmentIDs = new set<id>();
        list<Project_Task__c> pseList = new list<Project_Task__c>();
             if(!Test.isRunningTest()){ 
                
              pseList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            buildertek__Resource__r.Name,
                            buildertek__Resource__c,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Finish__c,
                            buildertek__Start__c from 
                            buildertek__Project_Task__c Where  buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds  ];
              
    				    
    				
    			
                 
             }
              else{
                
               pseList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            buildertek__Resource__r.Name,
                            buildertek__Resource__c,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Start__c,
                            buildertek__Finish__c from 
                            buildertek__Project_Task__c Where (buildertek__Start__c >=:startDate OR buildertek__Finish__c<=:endDate) and buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds ];
              
    				    
    				
              }
        list<buildertek__Project_Task__c> psrList = new list<buildertek__Project_Task__c>();
            if(!Test.isRunningTest()){  
          
              psrList = [
                  select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            
                            buildertek__Resource__c,
                            buildertek__Resource__r.Name,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Start__c,
                            buildertek__Finish__c from 
                            buildertek__Project_Task__c where buildertek__Schedule__c != null  and buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds];
              
    				   
    				
                
            }
            else{
               

                psrList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            
                            buildertek__Resource__c,
                            buildertek__Resource__r.Name,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Start__c,
                            buildertek__Finish__c from 
                            buildertek__Project_Task__c where buildertek__Schedule__c != null and (buildertek__Start__c >=:startDate OR buildertek__Finish__c<=:endDate)];  
              
    			    
    				    
    				
    				}
        
        system.debug(pseList.size()+'pseList-------------'+pseList);
        system.debug(psrList.size()+'psrList -------------> '+psrList);
        //system.debug('psrList size -------------> '+);
         list<string> ProjectListIds = new list<string>();
        for(Project_Task__c equip:psrList){
            CalendarListWrap rec = new CalendarListWrap();
            rec.Name = equip.Name;   
            rec.Id = equip.Id;
            rec.Projects = equip.buildertek__Schedule__r.buildertek__Project__c;
            list<CalendarListWrap.ProjectRecords> projectList = new list<CalendarListWrap.ProjectRecords>();
            list<CalendarListWrap.ProjectTaskRecords> WrapEquipmentList = new list<CalendarListWrap.ProjectTaskRecords>();
            list<CalendarListWrap.ResourceRecords> WrapResourceList = new list<CalendarListWrap.ResourceRecords>();
            set<Date>dateList = new set<Date>();
            CalendarListWrap.ProjectRecords Projectrec;
                     Projectrec = new CalendarListWrap.ProjectRecords();
                      Projectrec.Name = equip.Name;
                        Projectrec.Id = equip.buildertek__Schedule__c;
                        Projectrec.startString ='';
                      string s = string.valueOfGmt(equip.buildertek__Start__c);
                        String strDate = s.split(' ')[0];
                        
                        String sMonth = String.valueof(equip.buildertek__Start__c.month());
                        String sDay = String.valueof(equip.buildertek__Start__c.day());
                        if(sMonth.length()==1){
                          sMonth = '0' + sMonth;
                        }
                        if(sDay.length()==1){
                          sDay = '0' + sDay;
                        }
                        string ndate = sMonth+'/'+sDay+'/'+String.valueof(equip.buildertek__Start__c.year());
                        if(equip.buildertek__Finish__c != null){
                        string FinishDate = string.valueOfGmt(equip.buildertek__Finish__c);
                                        String FinishDatestrDate = FinishDate.split(' ')[0]; 
                                        String FinishDatesMonth = String.valueof(equip.buildertek__Finish__c.month());
                                        String FinishDatesDay = String.valueof(equip.buildertek__Finish__c.day());
                                        if(FinishDatesMonth.length()==1){
                                          FinishDatesMonth = '0' + FinishDatesMonth;
                                        }
                                        if(FinishDatesDay.length()==1){
                                          FinishDatesDay = '0' + FinishDatesDay;
                                        }
                                        string FinishDatendate = FinishDatesMonth+'/'+FinishDatesDay+'/'+String.valueof(equip.buildertek__Finish__c.year());
						
                        string newdate = String.valueof(equip.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                        Datetime dt1 = DateTime.newInstance(date.valueOf(newdate), Time.newInstance(0, 0, 0, 0));
                        String dateStr = dt1.format('EEEE');
                        Projectrec.weekName =dateStr;
                        
                        Projectrec.day = ndate;
                        Projectrec.EId = equip.id;
                        Projectrec.endday = FinishDatendate;
                        Projectrec.UnitId = equip.buildertek__Contractor_Resource__r.Name;
                        Projectrec.ScheuleItemName = equip.Name;
                      projectList.add(Projectrec);
                    dateList.add(equip.buildertek__Start__c); 
                    system.debug('------dateList-->'+dateList);
                //}
            //} 
            for(Date d:dateList){
                    if(d == equip.buildertek__Start__c && equip.buildertek__Schedule__r.buildertek__Project__c ==  Projectrec.Id){ 
                        system.debug('------resour.Contact__r.Name-->'+equip.buildertek__Resource__r.Name);
                        CalendarListWrap.ResourceRecords ResourceRec = new CalendarListWrap.ResourceRecords(); 
                        
                        Datetime dt = (DateTime)equip.buildertek__Start__c;
                        String dayOfWeek = dt.format('yyyy-MM-dd');
                        ResourceRec.title = equip.buildertek__Resource__r.Name;
                        
                        ResourceRec.startString ='';
                        ResourceRec.endString = '';
                        string s1 = string.valueOfGmt(equip.buildertek__Start__c);
                        String strDate1 = s1.split(' ')[0];
                        
                        String sMonth1 = String.valueof(equip.buildertek__Start__c.month());
                        String sDay1 = String.valueof(equip.buildertek__Start__c.day());
                        if(sMonth1.length()==1){
                          sMonth1 = '0' + sMonth1;
                        }
                        if(sDay1.length()==1){
                          sDay1 = '0' + sDay1;
                        }
                        string ndate1 = sMonth1+'/'+sDay1+'/'+String.valueof(equip.buildertek__Start__c.year());
                        
                         string FinishDate1 = string.valueOfGmt(equip.buildertek__Finish__c);
                                        String FinishDatestrDate1 = FinishDate1.split(' ')[0]; 
                                        String FinishDatesMonth1 = String.valueof(equip.buildertek__Finish__c.month());
                                        String FinishDatesDay1 = String.valueof(equip.buildertek__Finish__c.day());
                                        if(FinishDatesMonth1.length()==1){
                                          FinishDatesMonth1 = '0' + FinishDatesMonth1;
                                        }
                                        if(FinishDatesDay1.length()==1){
                                          FinishDatesDay1 = '0' + FinishDatesDay1;
                                        }
                                        string FinishDatendate1 = FinishDatesMonth1+'/'+FinishDatesDay1+'/'+String.valueof(equip.buildertek__Finish__c.year());
					
                        string newdate1 = String.valueof(equip.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                        Datetime dt2 = DateTime.newInstance(date.valueOf(newdate1), Time.newInstance(0, 0, 0, 0));
                        String dateStr1 = dt2.format('EEEE');
                        ResourceRec.weekName =dateStr1;
                        
                        ResourceRec.day = ndate1;
                        ResourceRec.endday = FinishDatendate1;
                        ResourceRec.projectId = equip.buildertek__Schedule__c; 
                        ResourceRec.Id = equip.id;
                        WrapResourceList.add(ResourceRec);
                    }
                    }
                }
            dateList = new set<Date>();
            
            
            system.debug('-------locationId'+projectList.size());
            system.debug('-------locationId'+WrapResourceList.size());
            rec.ProjectRecordsList = projectList;
            rec.ResourceRecordsList = WrapResourceList;
             system.debug('-------rec'+rec);           
            RecordList.add(rec);  
           
           ProjectListIds.add(equip.buildertek__Schedule__r.buildertek__Project__c);
        }
           list<buildertek__Service_Request__c> ServiceClass;
           if(Schema.sObjectType.buildertek__Service_Request__c.fields.Id.isAccessible()&&
          Schema.sObjectType.buildertek__Service_Request__c.fields.Name.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Preferred_Date_of_Service__c.isAccessible() &&
          Schema.sObjectType.Account.fields.Name.isAccessible() ){ 
          ServiceClass = [Select id,Name,
                            buildertek__Project__c,
                            buildertek__Customer_Name__c,
                            buildertek__Customer_Name__r.Name,
                            buildertek__Preferred_Date_of_Service__c 
                            From buildertek__Service_Request__c Where buildertek__Project__c IN: ProjectListIds and (buildertek__Preferred_Date_of_Service__c >=: startDate or buildertek__Preferred_Date_of_Service__c <=: endDate) ORDER BY Name ASC];
          }
        list<CalendarListWrap.ServiceRequest> ServiceRequestList = new list<CalendarListWrap.ServiceRequest>();  
        
        for(buildertek__Service_Request__c BSR : ServiceClass){
            if(BSR.buildertek__Preferred_Date_of_Service__c != null){
           
           CalendarListWrap.ServiceRequest SchedulerRecs = new CalendarListWrap.ServiceRequest(); 
           SchedulerRecs.Id = BSR.Id;
           SchedulerRecs.ProjectId = BSR.buildertek__Project__c;
           SchedulerRecs.Datevalue = Date.valueof(BSR.buildertek__Preferred_Date_of_Service__c);
           SchedulerRecs.Name = BSR.Name;
           SchedulerRecs.Resource = BSR.buildertek__Customer_Name__r.Name;
           
            TimeZone tz = UserInfo.getTimeZone();
            DateTime localTime = BSR.buildertek__Preferred_Date_of_Service__c.AddSeconds(tz.getOffset(BSR.buildertek__Preferred_Date_of_Service__c)/1000);
       
           SchedulerRecs.DatetimeValue = localTime;
           system.debug('SchedulerRecs.DatetimeValue ********** ' + localTime);
           ServiceRequestList.add(SchedulerRecs);
            }
        }
        
        for(CalendarListWrap Cal : RecordList){
        //     for(CalendarWrap.ServiceRequest ServiceRequest : ServiceRequestList){
        //         if(Cal.ProjectId == ServiceRequest.ProjectId){
                    Cal.ServiceRecordList = ServiceRequestList;
        //         }
        //     }
         } 
       // }
        system.debug(RecordList.size()+'-------rec'+RecordList); 
       
        return RecordList;
    }
   
    
    
    @AuraEnabled
     public static list<CalendarListWrap> getAllJunctionResources(string fromDate, string toDate,string recordId){
        list<CalendarListWrap> RecordList = new list<CalendarListWrap>(); 
        list<buildertek__Project__c> projectList1 = new list<buildertek__Project__c>();
        
        if(recordId != null){
           projectList1 = [Select id,Name From buildertek__Project__c where id =: recordId];
               
				
        }
        else{
            
               projectList1 = [Select id,Name From buildertek__Project__c ];
            
        }
           
        set<id> ProjectIds = new set<id>();
        for(buildertek__Project__c p : projectList1){
            ProjectIds.add(p.id);
        }

        date startDate = date.parse(fromDate);
        date endDate = date.parse(toDate);
        set<id>ResourceIDs = new set<id>();
        
        list<Project_Task__c> pseList = new list<Project_Task__c>();
             if(!Test.isRunningTest()){
           
              pseList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            
                            buildertek__Resource__c,
                            buildertek__Resource__r.Name,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Start__c,
                            buildertek__Finish__c from 
                            buildertek__Project_Task__c Where (start__c >=:startDate OR Finish__c<=:endDate) and buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds  ];
				
              }
              else{
            
               pseList = [select id,Name,buildertek__Schedule__c,
                            buildertek__Dependency__c,
                            buildertek__Schedule__r.buildertek__Project__c,
                            buildertek__Schedule__r.buildertek__Project__r.Name,
                            buildertek__Schedule__r.Name,
                            buildertek__Dependency__r.Name,
                            buildertek__Resource__c,
                            buildertek__Resource__r.Name,
                            buildertek__Contractor_Resource__r.Name,
                            buildertek__Contractor_Resource__c,
                            buildertek__Start__c,
                            buildertek__Finish__c from 
                            buildertek__Project_Task__c Where (buildertek__Start__c >=:startDate OR Finish__c<=:endDate) and buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds ];
				
              }
           
        // list<buildertek__Project_Task__c> psrList = new list<buildertek__Project_Task__c>();
        //     if(!Test.isRunningTest()){  
        //       psrList = [
        //           select id,Name,buildertek__Schedule__c,
        //                     buildertek__Dependency__c,
        //                     buildertek__Schedule__r.buildertek__Project__c,
        //                     buildertek__Schedule__r.buildertek__Project__r.Name,
        //                     buildertek__Schedule__r.Name,
        //                     buildertek__Dependency__r.Name,
        //                     buildertek__Contractor_Resource__r.Name,
        //                     buildertek__Contractor_Resource__c,
        //                     buildertek__Start__c,
        //                     buildertek__Finish__c from 
        //                     buildertek__Project_Task__c where buildertek__Schedule__c != null  and (buildertek__Start__c >=:startDate OR Finish__c<=:endDate) and buildertek__Schedule__r.buildertek__Project__c IN : ProjectIds];
        //       }
        //       else{
        //         psrList = [select id,Name,buildertek__Schedule__c,
        //                     buildertek__Dependency__c,
        //                     buildertek__Schedule__r.buildertek__Project__c,
        //                     buildertek__Schedule__r.buildertek__Project__r.Name,
        //                     buildertek__Schedule__r.Name,
        //                     buildertek__Dependency__r.Name,
        //                     buildertek__Contractor_Resource__r.Name,
        //                     buildertek__Contractor_Resource__c,
        //                     buildertek__Start__c,
        //                     buildertek__Finish__c from 
        //                     buildertek__Project_Task__c where buildertek__Schedule__c != null and (buildertek__Start__c >=:startDate OR Finish__c<=:endDate) ];  
        //       }
           
        
        for(buildertek__Project_Task__c e:pseList){
          ResourceIDs.add(e.buildertek__Contractor_Resource__c); 
        }
        list<contact> ResourceList;
        if(Schema.sObjectType.contact.fields.Id.isAccessible()&&
          Schema.sObjectType.contact.fields.Name.isAccessible() ){
          ResourceList = [Select Id,Name From contact where id in:ResourceIDs];
          }
        
        list<string> ProjectListIds = new list<string>();
        for(contact c:ResourceList){
            CalendarListWrap rec = new CalendarListWrap();
            rec.Name = c.Name;   
            rec.Id = c.Id;
            list<CalendarListWrap.ProjectRecords> projectList = new list<CalendarListWrap.ProjectRecords>();
            list<CalendarListWrap.ProjectTaskRecords> WrapEquipmentList = new list<CalendarListWrap.ProjectTaskRecords>();
            list<CalendarListWrap.ResourceRecords> WrapResourceList = new list<CalendarListWrap.ResourceRecords>();
            set<Date>dateList = new set<Date>();
            CalendarListWrap.ProjectRecords Projectrec;
            for(buildertek__Project_Task__c equip:pseList){
                if(c.id == equip.buildertek__Contractor_Resource__c){
                    system.debug('-------@@@@'+c.id+'---------'+equip.buildertek__Contractor_Resource__c);
                     Projectrec = new CalendarListWrap.ProjectRecords();
                        Projectrec.Name = equip.buildertek__Schedule__r.buildertek__Project__r.Name;
                        Projectrec.Id = equip.buildertek__Schedule__r.buildertek__Project__c;
                        Projectrec.startString ='';
                      string s = string.valueOfGmt(equip.buildertek__Start__c);
                        String strDate = s.split(' ')[0];
                        
                        String sMonth = String.valueof(equip.buildertek__Start__c.month());
                        String sDay = String.valueof(equip.buildertek__Start__c.day());
                        if(sMonth.length()==1){
                          sMonth = '0' + sMonth;
                        }
                        if(sDay.length()==1){
                          sDay = '0' + sDay;
                        }
                        string ndate = sMonth+'/'+sDay+'/'+String.valueof(equip.buildertek__Start__c.year());
                        if(equip.buildertek__Finish__c != null){
                        string FinishDate = string.valueOfGmt(equip.buildertek__Finish__c);
                        String FinishDatestrDate = FinishDate.split(' ')[0]; 
                        String FinishDatesMonth = String.valueof(equip.buildertek__Finish__c.month());
                        String FinishDatesDay = String.valueof(equip.buildertek__Finish__c.day());
                        if(FinishDatesMonth.length()==1){
                          FinishDatesMonth = '0' + FinishDatesMonth;
                        }
                        if(FinishDatesDay.length()==1){
                          FinishDatesDay = '0' + FinishDatesDay;
                        }
                        string FinishDatendate = FinishDatesMonth+'/'+FinishDatesDay+'/'+String.valueof(equip.buildertek__Finish__c.year());
						
										
                        string newdate = String.valueof(equip.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                        Datetime dt1 = DateTime.newInstance(date.valueOf(newdate), Time.newInstance(0, 0, 0, 0));
                        String dateStr = dt1.format('EEEE');
                        Projectrec.weekName =dateStr;
                        
                        Projectrec.EId = equip.Id;
                        Projectrec.day = ndate;
                        Projectrec.endday = FinishDatendate;
                        Projectrec.UnitId = equip.buildertek__Contractor_Resource__r.Name; //equip.Name;
                        Projectrec.ScheuleItemName = equip.Name;
                      projectList.add(Projectrec);
                    dateList.add(equip.buildertek__Start__c); 
                //}
            //} 
            for(Date d:dateList){
                //for(Project_Scheduler_Task_Junction__c equip1:pseList){
                    system.debug('-------#####'+pseList.size()+'---------'+pseList);
                    if(d == equip.buildertek__Start__c && equip.buildertek__Schedule__r.buildertek__Project__c ==  Projectrec.Id){ 
                        system.debug('-------@@@@'+d+'---------'+equip.buildertek__Start__c);
                      CalendarListWrap.ProjectTaskRecords EquipmentRec = new CalendarListWrap.ProjectTaskRecords(); 
                        
                        Datetime dt = (DateTime)equip.buildertek__Start__c;
                        String dayOfWeek = dt.format('yyyy-MM-dd');
                        EquipmentRec.title = equip.Name; 
                        EquipmentRec.startString ='';
                        EquipmentRec.endString = '';
                        string s1 = string.valueOfGmt(equip.buildertek__Start__c);
                        String strDate1 = s1.split(' ')[0];
                        
                        String sMonth1 = String.valueof(equip.buildertek__Start__c.month());
                        String sDay1 = String.valueof(equip.buildertek__Start__c.day());
                        if(sMonth1.length()==1){
                          sMonth1 = '0' + sMonth1;
                        }
                        if(sDay1.length()==1){
                          sDay1 = '0' + sDay1;
                        }
                        string ndate1 = sMonth1+'/'+sDay1+'/'+String.valueof(equip.buildertek__Start__c.year());
                        
                        string FinishDate1 = string.valueOfGmt(equip.buildertek__Finish__c);
                                        String FinishDatestrDate1 = FinishDate1.split(' ')[0]; 
                                        String FinishDatesMonth1 = String.valueof(equip.buildertek__Finish__c.month());
                                        String FinishDatesDay1 = String.valueof(equip.buildertek__Finish__c.day());
                                        if(FinishDatesMonth1.length()==1){
                                          FinishDatesMonth1 = '0' + FinishDatesMonth1;
                                        }
                                        if(FinishDatesDay1.length()==1){
                                          FinishDatesDay1 = '0' + FinishDatesDay1;
                                        }
                                        string FinishDatendate1 = FinishDatesMonth1+'/'+FinishDatesDay1+'/'+String.valueof(equip.buildertek__Finish__c.year());
										 
                        string newdate1 = String.valueof(equip.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                        Datetime dt2 = DateTime.newInstance(date.valueOf(newdate1), Time.newInstance(0, 0, 0, 0));
                        String dateStr1 = dt2.format('EEEE');
                        EquipmentRec.weekName =dateStr1;
                        
                        EquipmentRec.day = ndate1;
                        EquipmentRec.endday = FinishDatendate1;
                        EquipmentRec.projectId = equip.buildertek__Schedule__c; 
                        EquipmentRec.Id = equip.id;
                        WrapEquipmentList.add(EquipmentRec);
                    }
                    
                //}
            }
                }
            }
            
                 ProjectListIds.add(equip.buildertek__Schedule__r.buildertek__Project__c);
                dateList = new set<Date>();
            }
        
            system.debug('-------locationId'+projectList.size());
            system.debug('-------locationId'+WrapEquipmentList.size());
            rec.ProjectRecordsList = projectList;
            rec.ProjectTaskRecordsList = WrapEquipmentList;
            RecordList.add(rec); 
        /*for(contact e:ResourceList){
            CalendarListWrap rec = new CalendarListWrap();
            rec.Name = e.Name;
            rec.Id = e.Id; 
            rec.Role = e.Role__c; 
            RecordList.add(rec);  
            
        }*/
        }
        
        list<buildertek__Service_Request__c> ServiceClass;
        if(Schema.sObjectType.buildertek__Service_Request__c.fields.Id.isAccessible()&&
          Schema.sObjectType.buildertek__Service_Request__c.fields.Name.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Preferred_Date_of_Service__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.Account.fields.Name.isAccessible() ){
            ServiceClass= [Select id,Name,
                            buildertek__Project__c,
                            buildertek__Customer_Name__c,
                            buildertek__Customer_Name__r.Name,
                            buildertek__Preferred_Date_of_Service__c 
                            From buildertek__Service_Request__c Where buildertek__Project__c IN: ProjectListIds and (buildertek__Preferred_Date_of_Service__c >=: startDate or buildertek__Preferred_Date_of_Service__c <=: endDate) ORDER BY Name ASC];
         }
        
        list<CalendarListWrap.ServiceRequest> ServiceRequestList = new list<CalendarListWrap.ServiceRequest>();  
        
        for(buildertek__Service_Request__c BSR : ServiceClass){
             if(BSR.buildertek__Preferred_Date_of_Service__c != null){
          
           CalendarListWrap.ServiceRequest SchedulerRecs = new CalendarListWrap.ServiceRequest(); 
           SchedulerRecs.Id = BSR.Id;
           SchedulerRecs.ProjectId = BSR.buildertek__Customer_Name__c;
           SchedulerRecs.Datevalue = Date.valueof(BSR.buildertek__Preferred_Date_of_Service__c);
           SchedulerRecs.Name = BSR.Name;
           SchedulerRecs.Resource = BSR.buildertek__Customer_Name__r.Name;
           
            TimeZone tz = UserInfo.getTimeZone();
            DateTime localTime = BSR.buildertek__Preferred_Date_of_Service__c.AddSeconds(tz.getOffset(BSR.buildertek__Preferred_Date_of_Service__c)/1000);
       
           SchedulerRecs.DatetimeValue = localTime;
           system.debug('SchedulerRecs.DatetimeValue ********** ' + localTime);
           ServiceRequestList.add(SchedulerRecs);  
             }
        }
        
        for(CalendarListWrap Cal : RecordList){
        //     for(CalendarWrap.ServiceRequest ServiceRequest : ServiceRequestList){
        //         if(Cal.ProjectId == ServiceRequest.ProjectId){
                    Cal.ServiceRecordList = ServiceRequestList;
        //         }
        //     }
         }
        return RecordList;
    }  
    
    @AuraEnabled
    Public Static string CreateServiceRequest(string Datevalue,String ProjectId,String ContactId,String Description,String PrimaryAssign,string Subject,String Timevalue){
        String Values = '';
        try{
        // string[] Strlist = Datevalue.split('/');
        // String DtYear = '';f
        // String Dtmonth = '';
        // String DtDate = '';
        // if(Strlist.size() > 2){
        //     DtYear = Strlist[2];
        //     Dtmonth = Strlist[0];
        //     DtDate = Strlist[1];
        // }
        
       // Date i = Date.valueof(DtYear +'-'+Dtmonth+'-'+DtDate);
        Date i = Date.valueof(Datevalue);
        system.debug(i);// returns 2015-08-07 00:00:00
        DateTime t ;
        if(Timevalue != ''){
        String[] Timevalues = Timevalue.split(':');
             t = dateTime.newInstance(i, Time.newInstance(Integer.valueof(Timevalues[0]),Integer.valueof(Timevalues[1]),00,00));
        }
        else{
             t = dateTime.newInstance(i, Time.newInstance(00,00,00,00));    
        }
        buildertek__Service_Request__c ServiceRequest = new buildertek__Service_Request__c();
        ServiceRequest.buildertek__Project__c = ProjectId;
        ServiceRequest.buildertek__Customer_Name__c = ContactId;
        ServiceRequest.buildertek__Preferred_Date_of_Service__c = t;
        ServiceRequest.buildertek__Subject__c = Subject;
        ServiceRequest.buildertek__Request_Status__c = 'New';
        ServiceRequest.buildertek__Description__c = Description;
        ServiceRequest.buildertek__Primary_Assignee__c = PrimaryAssign;
        if(Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isCreateable() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isCreateable() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Preferred_Date_of_Service__c.isCreateable() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Subject__c.isCreateable() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Request_Status__c.isCreateable()&&
		  Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Description__c.isCreateable() && 
		  Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Primary_Assignee__c.isCreateable()){
		      
          insert ServiceRequest;
        }
        Values = 'Success';
        }
        catch(Exception e){
        Values = e.getMessage();    
        }
        return Values;
    }
    
   
    
    @AuraEnabled
    Public Static list<buildertek__Service_Request__c> getServiceRequest(string Datevalue,String ProjectId){
        list<buildertek__Service_Request__c> NewServiceClass = new list<buildertek__Service_Request__c>();
         list<buildertek__Service_Request__c> ServiceClass;
         if(Schema.sObjectType.buildertek__Service_Request__c.fields.Id.isAccessible()&&
          Schema.sObjectType.buildertek__Service_Request__c.fields.Name.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Customer_Name__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Preferred_Date_of_Service__c.isAccessible() &&
          Schema.sObjectType.buildertek__Service_Request__c.fields.buildertek__Project__c.isAccessible() &&
          Schema.sObjectType.Account.fields.Name.isAccessible() ){
                                                ServiceClass= [Select id,Name,
                                                                buildertek__Project__c,
                                                                buildertek__Customer_Name__c,
                                                                buildertek__Customer_Name__r.Name,
                                                                buildertek__Preferred_Date_of_Service__c 
                                                                From buildertek__Service_Request__c Where buildertek__Project__c =: ProjectId ORDER BY Name ASC];
                                                                //and buildertek__Preferred_Date_of_Service__c =: Datevalue 
          }
        for(buildertek__Service_Request__c Serv : ServiceClass){
            if(Serv.buildertek__Preferred_Date_of_Service__c != null){
                String Str = String.valueof(Serv.buildertek__Preferred_Date_of_Service__c);
                System.debug(Str + ' *************** ');
                String[] Services = Str.split(' ');
                String[] ServicesNew = Services[0].split('-'); 
                if(ServicesNew.size() > 2){
                    String Strs = ServicesNew[1]+'/'+ServicesNew[2]+'/'+ServicesNew[0];
                    if(Strs == Datevalue){
                        NewServiceClass.add(Serv);
                    }
                }
            
            }
            
        }
        
        return NewServiceClass;
    }
    
    
}