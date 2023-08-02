trigger OpportunityAfterInsertUpdate on Opportunity (after insert, after update) {

    if(Trigger.isAfter ) {
        if(Trigger.isInsert || Trigger.isUpdate) {
           System.debug('In Trigger');
            OpportunityTriggerHandler opportunityTriggerHandlerObj = new OpportunityTriggerHandler();
            opportunityTriggerHandlerObj.sumWinningProjectInfo(Trigger.New);
        }
        if(Trigger.isUpdate){
            Set<Id> rollupOppIds = new Set<Id>();
            for(Opportunity opp:trigger.new){
             if(Trigger.oldMap.get(opp.Id).IGU_Amount_Roll_Up__c != opp.IGU_Amount_Roll_Up__c || Trigger.oldMap.get(opp.Id).CSS_Amount_Roll_Up__c != opp.CSS_Amount_Roll_Up__c ){
                    rollupOppIds.add(opp.id);        
                } 
            }
            system.debug('rollupOppIds>>>'+rollupOppIds);
             if(!rollupOppIds.isempty() || Test.isRunningTest()){
                          SalesShipmentForecastLineExt shipmentext= new SalesShipmentForecastLineExt ();
                          shipmentext.reclculateAmountandSftfromOpty(rollupOppIds,Trigger.newMap);
            }
            
        }
    }
 
    
}