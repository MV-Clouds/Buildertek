/*
        Name           : VOpportunityProductTrigger 
        Author         : AV
        Reviewer       : Veltig Dev, Ashwani
        Date           : 21st April 2015
        Description    : This trigger update schedule date of OpportunityProduct's schedule
*/


trigger VOpportunityProductTrigger on OpportunityLineItem(after update)
{
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        VOpportunityProductTriggerHandler.onAfterUpdate(Trigger.newMap,Trigger.oldMap);
    }    
}