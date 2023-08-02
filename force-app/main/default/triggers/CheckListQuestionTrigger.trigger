trigger CheckListQuestionTrigger on buildertek__Checklist_Questions__c (before insert) {
    CheckListQuestionTriggerHandler handler = new CheckListQuestionTriggerHandler ();
    if (Trigger.isInsert && Trigger.isBefore){
			handler.OnBeforeInsert(Trigger.new);
		}
}