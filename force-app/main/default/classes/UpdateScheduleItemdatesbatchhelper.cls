global  class UpdateScheduleItemdatesbatchhelper {
  public list<buildertek__Project_Task__c> itemlst = new list<buildertek__Project_Task__c>();
    
    public static void  batchjobexcute(Set<Id> updatetaskitemid){ 
       list<Project_Task__c> updatetaskitemlst = [select Id,Name,
                                                  buildertek__Start__c,
                                                  buildertek__Finish__c,
                                                  buildertek__Schedule__c,
                                                  buildertek__Expected_Start_Date__c,
                                                  buildertek__Expected_End_Date__c,
                                                  buildertek__Duration__c,
                                                  buildertek__Dependency__c from Project_Task__c  WHERE Id IN: updatetaskitemid]; 
 

        set<Id> scheduleitemIds = new set<Id>();
        for(Project_Task__c task : updatetaskitemlst){ 
          
            scheduleitemIds.add(task.Id);
            
        }
        
        
        UpdateScheduleItemDatesBatch schitems =new UpdateScheduleItemDatesBatch(scheduleitemIds);
        
        database.executebatch(schitems,1);
        
        
    }

}