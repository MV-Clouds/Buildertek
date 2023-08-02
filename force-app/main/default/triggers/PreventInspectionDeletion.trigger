trigger PreventInspectionDeletion on buildertek__Inspection__c (before delete) {

    for(buildertek__Inspection__c Insp : trigger.old){
        if(Insp.buildertek__Status__c == 'Completed' || Insp.buildertek__Status__c == 'Failed' || Insp.buildertek__Status__c == 'In Progress'){
            Insp.adderror('Inspection Cannot be deleted');    
        }
    }

}