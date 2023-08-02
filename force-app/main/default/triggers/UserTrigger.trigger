trigger UserTrigger on User (before insert, after insert) {
    
    UserTriggerHandler UserTriggerHandler = new UserTriggerHandler();
    
    
    
    
   List<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__User_SOV_Sharing__c	
                                                                                          from buildertek__Admin_Interface_Node_Configuration__c
                                                                                          WHERE Name = :'Payment Application Configuration'];
    Boolean isUserEnable = false;
    if(!adminInterfaceNodeConfigurations.isEmpty()){
        if(adminInterfaceNodeConfigurations[0].buildertek__User_SOV_Sharing__c	 == true){
        isUserEnable = true;
    }
    
    }
    
    if(isUserEnable == false){
        if(Trigger.isInsert){
            if (Trigger.isAfter){
                system.debug('is after');
                UserTriggerHandler.isAfterInsert(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            }
        }    
    }
    
    
}