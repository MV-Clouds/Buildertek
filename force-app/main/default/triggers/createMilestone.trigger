trigger createMilestone on Opportunity (after insert,before update) {
    
    /*
  
  List<Milestone1_Milestone__c> mileStonesToInsert = new  List<Milestone1_Milestone__c>();
  Map<String,Milestone_Config__c> mileStoneConfigMap = Milestone_Config__c.getAll();

  if(!mileStoneConfigMap.isEmpty()){  
          
      for(Opportunity opp:Trigger.New){
          Boolean entryCriteria = opp.Install_Status__c == 'Active' && opp.Project_Manager__c != NULL && (opp.StageName == 'Closed: Won' || opp.StageName == 'Closed / Won');
          if(
              Trigger.isInsert && entryCriteria
              ||
              (
                  Trigger.isUpdate && entryCriteria 
                  &&
                  ((Trigger.oldMap.get(opp.id).StageName != opp.StageName ) || (Trigger.oldMap.get(opp.id).Install_Status__c != opp.Install_Status__c) ||  (Trigger.oldMap.get(opp.id).Project_Manager__c !=opp.Project_Manager__c))
              )
            )
          {
        
              for(Milestone_Config__c mConfig:mileStoneConfigMap.values()){
                  Milestone1_Milestone__c mileStone = new Milestone1_Milestone__c(
                      Name = mConfig.Name,
                      Opportunity__c = opp.Id,
                      Type__c = mConfig.Type__c,
                      OwnerId = opp.Project_Manager__c  
                  );

                  mileStonesToInsert.add(mileStone);
              }
          }   
      }
  }
  if(!mileStonesToInsert.isEmpty()){
    insert mileStonesToInsert;
  }
*/
}