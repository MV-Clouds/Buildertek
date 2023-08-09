public class RevertDatesScheduleController {
    @AuraEnabled
    public static void revertScheduletaskdates(String recordId){
        buildertek__Schedule__c Schedule = [select Id from buildertek__Schedule__c where Id =: recordId];
        if(Schedule !=null){
            List<buildertek__Project_Task__c> projectTask = [Select Id,
                                                             name,
                                                             buildertek__Schedule__c,
                                                             buildertek__Last_Saved_End_Date__c,
                                                             buildertek__Last_Saved_Start_Date__c,
                                                             buildertek__Start__c,
                                                             buildertek__Finish__c
                                                             from buildertek__Project_Task__c WHERE buildertek__Schedule__c =:Schedule.Id  ];
            if(projectTask.size()>0){
                list<buildertek__Project_Task__c> revertprojectatsklist = new list<buildertek__Project_Task__c>();
                for(buildertek__Project_Task__c taskrec : projectTask){
                    if(taskrec.buildertek__Last_Saved_Start_Date__c !=null){
                    if(taskrec.buildertek__Start__c != taskrec.buildertek__Last_Saved_Start_Date__c){
                        taskrec.buildertek__Start__c = taskrec.buildertek__Last_Saved_Start_Date__c;
                            }
                    }
                    if(taskrec.buildertek__Last_Saved_End_Date__c !=null){
                    if(taskrec.buildertek__Finish__c != taskrec.buildertek__Last_Saved_End_Date__c){
                        taskrec.buildertek__Finish__c = taskrec.buildertek__Last_Saved_End_Date__c;
                     }
                    }
                    revertprojectatsklist.add(taskrec);
                    
                }
                if(revertprojectatsklist.size()>0){
                    update revertprojectatsklist;
                }
            }
        }
        
    }
}