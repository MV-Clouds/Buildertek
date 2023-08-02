public class BT_Dashboard_Controller {
    @AuraEnabled
public static List <buildertek__Course_Session_Scheduling__c> fetchCourseSession() {
        
        List<buildertek__Course_Session_Scheduling__c> courseList = [SELECT Id, Name,
                                 buildertek__Course_Name__c,
                                  buildertek__Course_Name__r.Name,                                  
                                 buildertek__Session_Date_Time__c, 
                                 buildertek__Session_Date__c,
                                 buildertek__Session_Duration__c, 
                                 buildertek__Session_Facilitator__c,
                                 buildertek__Session_Facilitator__r.Name                                    
                                 FROM buildertek__Course_Session_Scheduling__c limit 10];
    System.debug('courseList'+courseList);
        //return list of accounts
        return courseList;
    }
     @AuraEnabled
public static List <buildertek__Session_Participant__c> fetchParticipants(String parentRecordId) {
        
        List<buildertek__Session_Participant__c> participantList = [SELECT Id, 
                                                                     buildertek__Course_Completed__c, 
                                                                     buildertek__Course_Completion_Date__c,
                                                                     buildertek__Course_Session_Scheduling__c,
                                                                     buildertek__Is_Participant_Attending__c,
                                                                     buildertek__Notes__c,
                                                                     buildertek__Participant_Attended__c,
                                                                     buildertek__Participant_Company__c, 
                                                                     buildertek__Participant_Name__c,
                                                                     buildertek__Participant_Score__c 
                                                                     FROM buildertek__Session_Participant__c where buildertek__Course_Session_Scheduling__c=:parentRecordId];
    System.debug('courseList'+participantList);
        //return list of accounts
        return participantList;
    }
}