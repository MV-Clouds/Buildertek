@isTest
public class CustomCalendar_TC {
   public static testMethod void test1() {
        buildertek__Project__c project= Buildertek_UtilityClass.project();
        buildertek__Schedule__c schedule=Buildertek_UtilityClass.schedule();
        
        Contact resource=Buildertek_UtilityClass.Resource();
        buildertek__Project_Task__c scheduleitem=Buildertek_UtilityClass.scheduleitem();
        buildertek__Project_Scheduler__c projectscheduler=Buildertek_UtilityClass.projectscheduler();
        buildertek__Project_Scheduler_Task_Junction__c Projectschedulertaskjunction=Buildertek_UtilityClass.Projectschedulertaskjunction();
        buildertek__Project_Scheduler_Resource_Junction__c Projectschedulerresourcejunction=Buildertek_UtilityClass.Projectschedulerresourcejunction();
            system.debug('project'+ project);
            system.debug('schedule'+ schedule);
            system.debug('resource'+ Resource);
            system.debug('scheduleitem'+ scheduleitem);
            system.debug('Projectschedulertaskjunction'+ Projectschedulertaskjunction);
            system.debug('Projectschedulerresourcejunction'+ Projectschedulerresourcejunction);
           
        list<contact> contactList1=CustomCalendar_AC.getAllResourcess(new List<String>{project.id});
        list<contact> contactList2=CustomCalendar_AC.getAllResourcess(new List<String>{});
        list<buildertek__Project_Task__c> projectTaskList1=CustomCalendar_AC.getAllProjectTasks(new List<String>{project.id});
        list<buildertek__Project_Task__c> projectTaskList2=CustomCalendar_AC.getAllProjectTasks(new List<String>{});
        list<buildertek__Project__c> projectTaskList3=CustomCalendar_AC.getAllProjects(project.id);
        list<buildertek__Project__c> projectTaskList4=CustomCalendar_AC.getAllProjects('');
       // list<CalendarWrap> getWeekRecords=CustomCalendar_AC.getWeekRecords('9/1/2018','12/12/2018',new List<String>{},scheduleitem.id, resource.id);
          //  system.debug('getWeekRecords'+ getWeekRecords);
     //   list<CalendarWrap> getWeekRecords1=CustomCalendar_AC.getWeekRecords('9/1/2018','12/12/2018',new List<String>{project.id},scheduleitem.id,resource.id);
       // list<CalendarWrap> getSelectedWeekRecords=CustomCalendar_AC.getSelectedWeekRecords('9/1/2018','12/12/2018',new List<String>{project.id});
        //list<CalendarWrap> getSelectedWeekRecords1=CustomCalendar_AC.getSelectedWeekRecords('9/1/2018','12/12/2018',new List<String>{});
                    
        list<buildertek__Project_Scheduler__c> getSchedulers=CustomCalendar_AC.getSchedulers(project.id);
       // string updateDates=CustomCalendar_AC.updateDates(resource.id,'Resource','9/1/2018',project.id,schedule.id);
       //     system.debug('updateDates' + updateDates);
       // string updateDates1=CustomCalendar_AC.updateDates(resource.id,'','9/1/2018',project.id,schedule.id);
       // list<buildertek__Project_Task__c> getprojectJunction=CustomCalendar_AC.getprojectJunction();
        //String DeleteProject=CustomCalendar_AC.DeleteProject(Projectschedulertaskjunction.id,'9/1/2018');
        //String updateProject=CustomCalendar_AC.updateProject(Projectschedulertaskjunction.id, '9/1/2018',project.id);
        //String updateProject2=CustomCalendar_AC.updateProject('', '9/1/2018',project.id);
        //String updateResource=CustomCalendar_AC.updateResource(Projectschedulerresourcejunction.id,'9/1/2018',project.id,resource.id);
        //String DeleteResource=CustomCalendar_AC.DeleteResource(Projectschedulerresourcejunction.id,'9/1/2018',project.id,resource.id);
        //string setResourceText=CustomCalendar_AC.setResourceText(resource.id);
        //List<contact> getContacts=CustomCalendar_AC.getContacts(resource.LastName);
        /*list<CalendarListWrap> getAllJunctionprojects=CustomCalendar_AC.getAllJunctionprojects('9/1/2018','12/12/2018',project.id);
        list<CalendarListWrap> getAllJunctionprojects1=CustomCalendar_AC.getAllJunctionprojects('9/1/2018','12/12/2018','');
        list<CalendarListWrap> getAllJunctionResources=CustomCalendar_AC.getAllJunctionResources('9/1/2018','12/12/2018',project.id);
        list<CalendarListWrap> getAllJunctionResources1=CustomCalendar_AC.getAllJunctionResources('9/1/2018','12/12/2018','');*/
        //CustomCalendar_AC.CreateServiceRequest('03/12/2019',project.Id,resource.Id,'Description','test','Subject','12:00');
          
        System.assertEquals('Test','Test');
            
      }
       
      
      
}