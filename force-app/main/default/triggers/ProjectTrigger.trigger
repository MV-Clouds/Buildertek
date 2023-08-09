trigger ProjectTrigger on buildertek__Project__c (after insert,after update , before delete, after delete) {

    System.debug('*** ** ProjectTrigger ** ***');
    System.debug('1st Condition ==> ' + BT_Utils.isTriggerDeactivate('Project__c'));
    System.debug('2nd Condition ==> ' + ProjectTriggerHandler.blnSkipProjectTrigger);
     if(!BT_Utils.isTriggerDeactivate('Project__c') && !ProjectTriggerHandler.blnSkipProjectTrigger){
        System.debug('*** ProjectTrigger Run ***');
        
        ProjectTriggerHandler handler = new ProjectTriggerHandler (Trigger.isExecuting, Trigger.size);
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurationslist = [Select Id,buildertek__Retreive_Aerial_Photo_of_project__c,buildertek__Google_Map_API_Key__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Project Configuration' limit 1];
        /*if(Trigger.isInsert && Trigger.isBefore){
            handler.OnBeforeInsert(Trigger.new);
        }*/
         
        if(Trigger.isInsert && Trigger.isAfter){
            handler.OnAfterInsert(Trigger.new, Trigger.newMap,Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            handler.OnAfterInsetCreateWarranty(Trigger.new, Trigger.newMap);
            // handler.dummyMethod(Trigger.new);
            // handler.CreatePermits(Trigger.new);
             handler.CreatePermitsForNewProject(Trigger.new);
            if(adminInterfaceNodeConfigurationslist.size()>0 && adminInterfaceNodeConfigurationslist[0].buildertek__Retreive_Aerial_Photo_of_project__c == true){
            // handler.AfterUpdateProjects(Trigger.new,trigger.oldMap);
            handler.AfterInsertProject(Trigger.new);
            }
        }
        
        else if(Trigger.isUpdate && Trigger.isBefore){
            handler.OnBeforeUpdate(Trigger.old, Trigger.new, Trigger.newMap);
        }
        
        else if(Trigger.isUpdate && Trigger.isAfter){
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, trigger.oldMap);
            if(adminInterfaceNodeConfigurationslist.size()>0 && adminInterfaceNodeConfigurationslist[0].buildertek__Retreive_Aerial_Photo_of_project__c == true){
             handler.AfterUpdateProjects(Trigger.new,trigger.oldMap);
            }
        }
        
        /*else if(Trigger.isDelete && Trigger.isBefore){
            handler.OnBeforeDelete(Trigger.old, Trigger.oldMap); 
        }*/
        
        /*else if(Trigger.isDelete && Trigger.isAfter){
            handler.OnAfterDelete(Trigger.old); 
        }*/
    }
}