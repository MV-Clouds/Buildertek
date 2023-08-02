public with sharing class CloneMeetingController {

    /*
    Description:- This method used for get meeting record
    Created Date:- 30th November
    */
    @AuraEnabled
    public static buildertek__Meeting__c getMeetingData(String recordId){
        buildertek__Meeting__c meeting = [SELECT Id, buildertek__Subject__c	 ,buildertek__Location__c, buildertek__Project__c,buildertek__Meeting_Date__c,buildertek__Opportunity__c,
                                        buildertek__Status__c,buildertek__Start_Time__c,buildertek__Duration__c,buildertek__End_Time__c FROM buildertek__Meeting__c WHERE Id =: recordId LIMIT 1];
        return meeting;
    }

    /*
    Description:- This method clone meeting and its related list
    Created Date:- 30th November
    */

    @AuraEnabled
    public static String cloneMeeting(buildertek__Meeting__c meeting, String recordId){

        insert meeting;

        //Cloning the Attendee Record 
        list<buildertek__Attendee__c> oldAtendeeList = [SELECT Id, Name, buildertek__Attendee_s_FirstName__c, buildertek__Attendee_s_LastName__c, CurrencyIsoCode, buildertek__Email_Address__c, 
                                                        buildertek__Meeting_Date__c, buildertek__Meeting_Subject__c, buildertek__Phone__c, buildertek__Present__c, buildertek__Role__c, 
                                                        buildertek__Meeting__c, buildertek__Contact__c FROM buildertek__Attendee__c WHERE buildertek__Meeting__c =: recordId];

        if (oldAtendeeList.size() > 0) {
            List<buildertek__Attendee__c> newAtendeeList = new List<buildertek__Attendee__c>();
            for(buildertek__Attendee__c attendObj : oldAtendeeList){
                attendObj.buildertek__Meeting__c = meeting.Id;
                buildertek__Attendee__c cloneAtendee  = attendObj.clone(false, false, false, false);
                newAtendeeList.add(cloneAtendee);
            }
            insert newAtendeeList;                
        }

        //Cloning the Action Item  Record 
        List<buildertek__Action_Item__c> oldActionItemList = [SELECT Id, buildertek__Owner__c, Name, CurrencyIsoCode, buildertek__Description__c, buildertek__Details__c, buildertek__Due_Date__c,
                                                                buildertek__Meeting__c, buildertek__Status__c FROM buildertek__Action_Item__c WHERE buildertek__Meeting__c =: recordId];

        if (oldActionItemList.size() > 0) {
            List<buildertek__Action_Item__c> newActionItemList = new List<buildertek__Action_Item__c>();
            for(buildertek__Action_Item__c actionObj : oldActionItemList){
                actionObj.buildertek__Meeting__c = meeting.Id;
                buildertek__Action_Item__c cloneActionItem  = actionObj.clone(false, false, false, false);
                newActionItemList.add(cloneActionItem);

            }
            insert newActionItemList;
        }

        return meeting.Id;
    }
   
}