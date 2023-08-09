trigger Opporotunity_DesignWin_BU_AU on Opportunity (Before Update, After Update) {
    /*
        Purpose : This trigger is used to update the Design Win details on the Opportunity for Multi MOU & Single MOU
                  
        Author  : Srinath T
        Date    : 12-March-2020
    
    */
    //Opprtunity Record Type Ids
     
    if(trigger.isBefore && trigger.IsUpdate){
       // OpportunityTriggerHandlerDesignWin opportunityTriggerHandlerdwobj = new OpportunityTriggerHandlerDesignWin();
       // opportunityTriggerHandlerdwobj.designwinbeforeUpdate(Trigger.NewMap, Trigger.OldMap);
       if(!OpportunityTriggerHandlerCtrl.isUpdateDWSSWRecords){
            OpportunityTriggerHandlerCtrl.beforeUpdate(Trigger.NewMap, Trigger.OldMap);
            OpportunityTriggerHandlerCtrl.isUpdateDWSSWRecords = true;

         }


    }
    
    if(trigger.isAfter && trigger.IsUpdate){
        //OpportunityTriggerHandlerDesignWin opportunityTriggerHandlerdwobj = new OpportunityTriggerHandlerDesignWin();
        //opportunityTriggerHandlerdwobj.designwinAfterUpdate(Trigger.NewMap, Trigger.OldMap);
        
        system.debug('SriTest... execution entered to *after block*');
            
        
    }
    
    
}