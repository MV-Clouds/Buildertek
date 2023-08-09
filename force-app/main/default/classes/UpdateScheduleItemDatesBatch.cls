global class UpdateScheduleItemDatesBatch implements Database.Batchable<sObject>,Database.stateful {
    public set <Id> scheduletaskid;
    public  list<Project_Task__c> childtasks = new list<Project_Task__c>();
    public  List<Project_Task__c> updatescheitemslstDup= new List<Project_Task__c>();
    global UpdateScheduleItemDatesBatch (set<Id> taskids){
        scheduletaskid = new set<Id>();
        for(Id  tskid : taskids){
            scheduletaskid.add(tskid);   
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
         String Query = 'select Id,Name,buildertek__Start__c, buildertek__Finish__c,buildertek__Schedule__c,buildertek__Expected_Start_Date__c,buildertek__Expected_End_Date__c,buildertek__Duration__c,buildertek__Dependency__c from Project_Task__c  WHERE Id IN: scheduletaskid';
        return DataBase.getQueryLocator(Query);  
        
    }
    global void execute(Database.BatchableContext BC,List<Project_Task__c> updatescheitemslst) {
      updatescheitemslstDup = updatescheitemslst;
       // childtasks = new list<Project_Task__c>();
        set<id>parentids = new set<id>();
        map<Id,Project_Task__c> parentrecmap = new map<Id,Project_Task__c>();
        for(Project_Task__c scheItem : updatescheitemslstDup ){
            parentrecmap.put(scheItem.Id,scheItem);
            parentids.add(scheItem.Id);
        }
         childtasks = [select Id,Name,buildertek__Start__c, buildertek__Finish__c,buildertek__Schedule__c,buildertek__Expected_Start_Date__c,buildertek__Duration__c,buildertek__Expected_End_Date__c,buildertek__Dependency__c from Project_Task__c where buildertek__Dependency__c IN :parentids order by createddate asc];
        
       
            system.debug(''+childtasks.size()+'childtasks------'+childtasks);

    }
     //finish method
    global void finish(Database.BatchableContext BC) {
        system.debug('childtasks-list--'+childtasks);
        set<Id>  scheduleitemupdateids = new set<Id>();
        if(childtasks.size() > 0){
         list<Project_Task__c> projecttasklst = new list<Project_Task__c>();
        set<id>parentids = new set<id>();
        map<Id,Project_Task__c> parentrecmap = new map<Id,Project_Task__c>();
        for(Project_Task__c scheItem : updatescheitemslstDup ){
            parentrecmap.put(scheItem.Id,scheItem);
            parentids.add(scheItem.Id);
        }
         for(Project_Task__c chld : childtasks){
            If(parentrecmap.get(chld.buildertek__Dependency__c) != null){
                if(chld.buildertek__Duration__c != null){
                    date findate =parentrecmap.get(chld.buildertek__Dependency__c).buildertek__Finish__c;
                    system.debug('findate---->'+findate);
                    chld.buildertek__Start__c = findate.addDays(1);
                    chld.buildertek__finish__c = chld.buildertek__Start__c.addDays(Integer.valueOf(chld.buildertek__Duration__c));
                }
            }
        }
         
       update childtasks;
        for(Project_Task__c taskid: childtasks){
            scheduleitemupdateids.add(taskid.id);
        }
            if(scheduleitemupdateids .size() > 0){
            UpdateScheduleItemdatesbatchhelper.batchjobexcute(scheduleitemupdateids);
            }
        }
        
    }
}