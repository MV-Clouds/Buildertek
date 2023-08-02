trigger CSMMilestone on CSM_Milestone__c (before insert) {
   
   /*When a new Customer Kickoff meeting milestone is created, find the IGU Ship milestone on the parent opportunity and if the 
     Deadline date on the IGU Ship milestone is populated, set it as the Kickoff date on Customer Kickoff Meeting milestone.*/
   
   //List of CSM Milestone which are in trigger.new and their name is 'Customer Kickoff Meeting'
   /*
   List<CSM_Milestone__c> csmMilestoneList = new List<CSM_Milestone__c>();
   
   for(CSM_Milestone__c csm :trigger.new){
      if(csm.Name.equalsIgnoreCase('Initial engagement with customer')||csm.Name.equalsIgnoreCase('BOS Commissioning')
         ||csm.Name.equalsIgnoreCase('Attend Sales to Ops Turnover MTG')||csm.Name.equalsIgnoreCase('Meet with PM to get customer details')
         ||csm.Name.equalsIgnoreCase('BOS Design Check')||csm.Name.equalsIgnoreCase('Architectural Zoning')
         ||csm.Name.equalsIgnoreCase('Intelligence Commissioning')||csm.Name.equalsIgnoreCase('Initial POC training on product and controls')
         ||csm.Name.equalsIgnoreCase('Occupant Engagement')||csm.Name.equalsIgnoreCase('Training and initial verbal feedback')
         ||csm.Name.equalsIgnoreCase('Resolve occupant issues')||csm.Name.equalsIgnoreCase('Final feedback survey')
        ){
         csmMilestoneList.add(csm);          
      }
   }
   
   MilestoneTriggerHandler handler = new MilestoneTriggerHandler();
   if(csmMilestoneList.size() > 0){
      system.debug('calling handler --');
      system.debug(csmMilestoneList);
      handler.setKickoffDateMethod(csmMilestoneList);
   }
*/
}