@isTest
public class Buildertek_UtilityClass{
    public static buildertek__Project__c project() {
          buildertek__Project__c project=new buildertek__Project__c();
          if (Schema.sObjectType.buildertek__Project__c.fields.Name.isCreateable()){
             project.Name='SampleTest';
          }
             insert project;
             return project;
    }
    public static buildertek__Schedule__c schedule(){
             buildertek__Project__c project=project();
             buildertek__Schedule__c schedule=new buildertek__Schedule__c();
             if (Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Project__c.isCreateable()){
             schedule.buildertek__Project__c=project.id;
             }
             insert schedule;
             return schedule;
    }
    public static buildertek__Project_Scheduler__c projectscheduler(){
        buildertek__Project_Scheduler__c projectscheduler=new buildertek__Project_Scheduler__c();
        buildertek__Project__c project=project();
         if (Schema.sObjectType.buildertek__Project_Scheduler__c.fields.buildertek__Project__c.isCreateable()){
           projectscheduler.buildertek__Project__c=project.id;
         }
        insert projectscheduler;
        return projectscheduler;
    }
    public static Contact Resource(){
             Contact resource=new Contact();
              if (Schema.sObjectType.Contact.fields.LastName.isCreateable()){
             resource.LastName='Harika';
                  resource.Email='test@gmail.com'; 
              }
             insert resource;
             return resource;
    }
    public static buildertek__Project_Task__c scheduleitem(){
            buildertek__Project__c project=project();    
            buildertek__Schedule__c schedule=schedule();
            Contact Resource=resource();
            
             buildertek__Project_Task__c scheduleitem=new buildertek__Project_Task__c();
             if(Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable() 
              && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Project__c.isCreateable() 
              && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isCreateable()
              && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Resource__c.isCreateable()
              && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Start__c.isCreateable()
              && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Finish__c.isCreateable()){
                 scheduleitem.Name='Test class';
                 scheduleitem.buildertek__Project__c=project.id;
                 scheduleitem.buildertek__Schedule__c=schedule.id;
                 scheduleitem.buildertek__Resource__c=resource.id;
                 scheduleitem.buildertek__Start__c=date.parse('9/1/2018');
                 scheduleitem.buildertek__Finish__c=date.parse('12/12/2018');
              }
             insert scheduleitem;
             return scheduleitem;
    }
    public static buildertek__Project_Scheduler_Task_Junction__c Projectschedulertaskjunction(){

             buildertek__Project_Scheduler_Task_Junction__c Projectschedulertaskjunction = new buildertek__Project_Scheduler_Task_Junction__c();
              if(Schema.sObjectType.buildertek__Project_Scheduler_Task_Junction__c.fields.Date__c.isCreateable() ){
             Projectschedulertaskjunction.Date__c=date.parse('9/1/2018');
              }
             insert Projectschedulertaskjunction;
             return Projectschedulertaskjunction;
    }
    public static buildertek__Project_Scheduler_Resource_Junction__c Projectschedulerresourcejunction(){


             buildertek__Project_Scheduler_Resource_Junction__c Projectschedulerresourcejunction=new buildertek__Project_Scheduler_Resource_Junction__c();
             if(Schema.sObjectType.buildertek__Project_Scheduler_Resource_Junction__c.fields.Date__c.isCreateable() ){
             Projectschedulerresourcejunction.Date__c=date.parse('9/1/2018');
             }
             insert Projectschedulerresourcejunction;
             return Projectschedulerresourcejunction;
             
            
    }
                
}