trigger OpptySetSDO on Opportunity (before insert)
{
    Id profileId = Id.valueOf(UserInfo.getProfileId());
    Id currentUserId = Id.valueOf(UserInfo.getUserId());
    
    Profile userProfile = [SELECT Id, Name from Profile WHERE ID=:profileId LIMIT 1];


    if (trigger.isBefore && trigger.isInsert && userProfile.name == 'Sales Development')
    {
        for (Opportunity opty : Trigger.new)
        {
            opty.Inside_Sales_Owner__c = currentUserId;
        }
    }
}