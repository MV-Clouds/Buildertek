trigger CustomerSatisfactionVisitAIAU on Customer_Satisfaction_Visit__c (after insert, after update) {
    /*CustomerSatisfactionVisit Obj = new CustomerSatisfactionVisit();
    for (Customer_Satisfaction_Visit__c  csv: Trigger.new){
        obj.populateRecentCSVisitREquest(csv.Related_Opportunity__c);
    }*/
    List<Id> csvRelOppIds= new list<Id>();
    for (Customer_Satisfaction_Visit__c  csv: Trigger.new){
        //System.debug(csv.Related_Opportunity__c);
        //System.debug(csv.Related_Opportunity__r.Id);
        if(csv.Related_Opportunity__c!=null){
            csvRelOppIds.add(csv.Related_Opportunity__c);
        }
    }
    if(csvRelOppIds!=null && csvRelOppIds.size()>0){        
        CustomerSatisfactionVisit Obj = new CustomerSatisfactionVisit();
        //system.debug('##Calling populateRecentCSVisitREquest###');
        obj.populateRecentCSVisitREquest(csvRelOppIds);
        //system.debug('##Calling Done populateRecentCSVisitREquest###');
    }
}