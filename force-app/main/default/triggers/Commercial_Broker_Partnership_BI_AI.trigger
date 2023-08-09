// Updated Date         Developer       Project             Tracking Id                         		Requirement                         
// 25-Jan-2021          Srikanth        Commercial Broker   COMMERCIAL_BROKER_TEAM_MEMBER_IN_OPPTY    	When Commercial Broker Partnership record is created, create  team members in Oppty with users in Newmark Partners profile 

trigger Commercial_Broker_Partnership_BI_AI on Commercial_Broker_Partnership__c (After Insert) {

    if (trigger.isAfter && trigger.isInsert)
    {
       Commercial_Broker_Partnership_Ctrl.invokeOpptyTeamMemberCreation(trigger.new);
    }
}