trigger Totalcaseonlocation on Case (after insert, after update, after delete, after undelete, before insert) {
    /*
    List<SVMXC__Site__c> UpdateLocList = new list<SVMXC__Site__c>();  //added 4/13/2017 neelima
     Set<Id> Case_Id= new Set<Id>();
     if(Trigger.isDelete) {
        for(Case ct:Trigger.Old) {
            if(!String.isEmpty(ct.SVMXC__Site__c)){
                Case_Id.add(ct.SVMXC__Site__c);   
            }    
        }   
        
    }
    else
        if(Trigger.isUpdate) {
            
            for(Case ct:Trigger.New) {
                if(!String.isEmpty(ct.SVMXC__Site__c)){
                    Case_Id.add(ct.SVMXC__Site__c);   
                }    
            }
            
            for(Case ct:Trigger.Old) {
                if(!String.isEmpty(ct.SVMXC__Site__c)){
                    Case_Id.add(ct.SVMXC__Site__c);   
                }
            }   
            
        } 
    else
    {
        for(Case ct:Trigger.New) {
            if(!String.isEmpty(ct.SVMXC__Site__c)){
                Case_Id.add(ct.SVMXC__Site__c);   
            }
        }
    }
    
    if(!Case_Id.isEmpty())
    {  
           // AggregateResult[] groupedResults = [SELECT COUNT(Id), Opportunity__c FROM Case where Opportunity__c IN :Case_Id GROUP BY Opportunity__c];
          AggregateResult[] groupedResults = [SELECT COUNT(Id), SVMXC__Site__c FROM Case where SVMXC__Site__c IN :Case_Id And Status NOT IN ('Closed','Resolved','Solution Requested','Solution Pending','Solution Provided','Solution Provided - Closed') AND Case_Tag__c NOT IN ('Spam','Duplicate','Non-Case') AND RecordType.Id ='012E00000001fgdIAA'  GROUP BY SVMXC__Site__c];
            //Aggregation contains Count , opp-Id grouping by Opportunity__c
            //'New','Initial Contact','Customer Pending','Field Work Pending','Engineering Pending','Pending Site Operations','Work Inprogress','On Hold','Case Reopened','Closed Pending','Escalated'
            System.debug('===groupedResults '+ groupedResults);
            for(AggregateResult ar:groupedResults) {
                
                Integer count = (INTEGER)ar.get('expr0'); //expr0 is Count, parsing into integer and storing in variable
                
                Id OppId= (ID)ar.get('SVMXC__Site__c'); // Acc Id of that count
                System.debug('========> OPP ID '+ ar);
               SVMXC__Site__c opp = new SVMXC__Site__c (Id=OppId); // Fetching Opportunity of above Id to update count
                
                opp.Total_No_of_cases__c= count; // updating count for the retrieved Opportunity
                
                UpdateLocList.add(opp);
            }
        
    }
    
    if(!UpdateLocList.isEmpty())
    {
        update UpdateLocList;
        
    }
    */
}