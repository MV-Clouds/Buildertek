trigger BT_Project_warranty on buildertek__Warranty__c (before insert, before update) {
    
    ProjectWarrantyCreateHelper handler = new ProjectWarrantyCreateHelper ();
    
    if(Trigger.isInsert && Trigger.isBefore){
        handler.OnBeforeInsertUpdate(Trigger.new);
    }
    else if(Trigger.isUpdate && Trigger.isBefore){
        handler.OnBeforeInsertUpdate(Trigger.new);
        //handler.OnBeforeUpdate(Trigger.old, Trigger.new);//, Trigger.newMap);
    }
}