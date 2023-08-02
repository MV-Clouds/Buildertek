public class phaseSubTabForProjectController {
    @AuraEnabled
    public static List<PhaseInnerClass> getPhaseData(String recordId){
        List<String> scheduleIds = new List<String>();
        List <buildertek__Schedule__c> scheduleList = [select id, Name, buildertek__Project__c, CreatedDate from buildertek__Schedule__c where buildertek__Project__c =: recordId ];
        if(!scheduleList.isEmpty()){
            for(buildertek__Schedule__c sch : scheduleList){
                scheduleIds.add(sch.Id);
            }
        }

        List <buildertek__Schedule__c> firstCreatedSchedule = [select id, Name, buildertek__Project__c, CreatedDate from buildertek__Schedule__c where buildertek__Project__c =: recordId order by CreatedDate ASC limit 1];
        
        List<buildertek__Project_Task__c> TaskList = new List<buildertek__Project_Task__c>();
        Map<String,date> dueDateMap = new Map<String,date>();
        if(!scheduleList.isEmpty()){
            TaskList = [select Id, Name, buildertek__Finish__c,buildertek__Phase__c, CreatedDate, buildertek__Schedule__c from buildertek__Project_Task__c where buildertek__Schedule__c IN: scheduleIds order by buildertek__Finish__c desc];
            if(!TaskList.isEmpty()){
                for(buildertek__Project_Task__c task : TaskList){
                    if(dueDateMap.get(task.buildertek__Phase__c) == null){
                        dueDateMap.put(task.buildertek__Phase__c,task.buildertek__Finish__c);
                    }
                }
            }
        }
        
        List<buildertek__Project_Task__c> ASCTaskList = new List<buildertek__Project_Task__c>();
        Map<String,date> startDateMap = new Map<String,date>();
        if(!scheduleList.isEmpty()){
            ASCTaskList = [select Id, Name, buildertek__Start__c,buildertek__Phase__c, CreatedDate, buildertek__Schedule__c from buildertek__Project_Task__c where buildertek__Schedule__c IN: scheduleIds order by buildertek__Start__c ASC];
            if(!ASCTaskList.isEmpty()){
                for(buildertek__Project_Task__c task : ASCTaskList){
                    if(startDateMap.get(task.buildertek__Phase__c) == null){
                        startDateMap.put(task.buildertek__Phase__c,task.buildertek__Start__c);
                    }
                }
            }
        }
        
        integer Sno = 1;
        
        List<PhaseInnerClass> poInnClassList = new List<PhaseInnerClass>();
        if(!scheduleIds.isEmpty()){ 
            List<AggregateResult> result =  [SELECT buildertek__Phase__c value, COUNT(Id)
                                             recordCount, AVG(buildertek__Completion__c) completion,buildertek__Schedule__c
                                             FROM buildertek__Project_Task__c where buildertek__Schedule__c IN:scheduleIds and buildertek__Milestone__c=false
                                             GROUP BY buildertek__Phase__c,buildertek__Schedule__c Order By buildertek__Phase__c  ASC NULLS last];
            if(result != null){
                for(AggregateResult agg : result){
                    PhaseInnerClass poInn = new PhaseInnerClass();
                    poInn.PhaseName = (string)agg.get('value');
                    poInn.TaskCount = (Integer)agg.get('recordCount');
                    poInn.CompletionPercent = (Decimal)agg.get('completion');
                    poInn.DueDate = dueDateMap.get((string)agg.get('value'));
                    poInn.SNO = Sno;
                    poInn.ScheduleId = firstCreatedSchedule[0].Id;
                    poInn.StartDate = startDateMap.get((string)agg.get('value'));
                    if( (Decimal)agg.get('completion') >= 0){
                        poInn.PercentSymbol = '%';
                    }else{
                        poInn.PercentSymbol = '%';
                        poInn.Status = 'Not Started';
                        poInn.StyleClass = 'notStarted';
                    }
                    
                    if(system.Today() > dueDateMap.get((string)agg.get('value')) && (Decimal)agg.get('completion') != 100){
                        poInn.Status = 'Past Due';  
                        poInn.StyleClass = 'pastDue';
                    }else if((Decimal)agg.get('completion') == 0){
                        poInn.Status = 'Not Started';
                        poInn.StyleClass = 'notStarted';
                    }else if ((Decimal)agg.get('completion') == 100){
                        poInn.Status = 'Completed';
                        poInn.StyleClass = 'completed';
                        
                    }
                    else if((Decimal)agg.get('completion') > 0 && (Decimal)agg.get('completion') < 100){
                        poInn.Status = 'In Progress';  
                        poInn.StyleClass = 'inProgress';
                    }
                    poInnClassList.add(poInn);
                    Sno++;
                }
            }
        }     
        return poInnClassList;   
    }
    
    
    public class MainDataInnerClass{
        @AuraEnabled public List<PhaseInnerClass> PhaseInnerList;
    }
    
    public class PhaseInnerClass{
        @AuraEnabled public Integer SNO;
        @AuraEnabled public String PhaseName;
        @AuraEnabled public Integer TaskCount;
        @AuraEnabled public Decimal CompletionPercent;
        @AuraEnabled public Date DueDate;
        @AuraEnabled public Date StartDate;
        @AuraEnabled public Date FinishDate;
        @AuraEnabled public String PercentSymbol;
        @AuraEnabled public String Status;
        @AuraEnabled public String StyleClass;
        @AuraEnabled public String ScheduleId;
    }
    
}