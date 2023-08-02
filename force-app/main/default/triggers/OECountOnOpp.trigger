trigger OECountOnOpp on Order_Entry_Release__c (after insert, after update, after delete, after undelete, before insert) {
    List<Opportunity> UpdateLocList = new list<Opportunity>();  
     Set<Id> Case_Id= new Set<Id>();
     if(Trigger.isDelete) {
        for(Order_Entry_Release__c ct:Trigger.Old) {
            if(!String.isEmpty(ct.Opportunity__c)){
                Case_Id.add(ct.Opportunity__c);   
            }    
        }   
        
    }
    else
        if(Trigger.isUpdate) {
            
            for(Order_Entry_Release__c ct:Trigger.New) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }    
            }
            
            for(Order_Entry_Release__c ct:Trigger.Old) {
                if(!String.isEmpty(ct.Opportunity__c)){
                    Case_Id.add(ct.Opportunity__c);   
                }
            }   
            
        } 
    else
    {
        for(Order_Entry_Release__c ct:Trigger.New) {
            if(!String.isEmpty(ct.Opportunity__c)){
                Case_Id.add(ct.Opportunity__c);   
            }
        }
    }
    
    if(!Case_Id.isEmpty())
    {  
          
          AggregateResult[] groupedResults = [SELECT COUNT(Id), Opportunity__c FROM Order_Entry_Release__c where Opportunity__c IN :Case_Id And Status__c NOT IN ('Cancelled','Cancellation Integration Requested','Cancellation Confirmed','Cancellation Confirmation Requested','Cancellation Confirmation Pending','Cancellation Requested') GROUP BY Opportunity__c];
            
            System.debug('===groupedResults '+ groupedResults);
            for(AggregateResult ar:groupedResults) {
                
                Integer count = (INTEGER)ar.get('expr0'); //expr0 is Count, parsing into integer and storing in variable
                
                Id OppId= (ID)ar.get('Opportunity__c'); // Acc Id of that count
                System.debug('========> OPP ID '+ ar);
               Opportunity opp = new Opportunity (Id=OppId); // Fetching Opportunity of above Id to update count
                
                opp.OE_Count__c= count; // updating count for the retrieved Opportunity
                
                UpdateLocList.add(opp);
            }
           
    } 
    
    if(!UpdateLocList.isEmpty())
    {
        update UpdateLocList;
        
    }
    

}