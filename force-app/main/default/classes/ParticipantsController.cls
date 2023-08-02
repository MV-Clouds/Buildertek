public with sharing class ParticipantsController {
    
    /*@AuraEnabled(cacheable=true)
public static List<Session_Participant__c> getParticipants(String couserSessionId) {
return [
SELECT Id,
Participant_Name__c, 
Participant_Name__r.Name,
Participant_Company__c, 
Participant_Company__r.Name,
Participant_Attended__c,
Participant_Score__c, 
Training_Expiration_Date__c, 
Course_Completed__c, 
Course_Completion_Date__c, 
Notes__c, 
Course_Session_Scheduling__c
FROM Session_Participant__c  
where  Course_Session_Scheduling__c=:couserSessionId  
];
}*/
    @AuraEnabled(cacheable=true)
    public static Contact getParticipantAccount(String participantId) {
       Contact con = [select id,name,AccountId,Account.Name from Contact where id=:participantId];
        return con;
    }
    @AuraEnabled(cacheable=true)
    public static boolean checkDuplicateSessions(String participantEmail,String CourseSessionRecordId) {
        //System.debug(participantEmail);
        boolean isDuplicate=false;
        list<Session_Participant__c> sessions = [select id,Name,Course_Session_Scheduling__c,
                                                        Participant_Name__c 
                                                        from Session_Participant__c
                                                        Where buildertek__Participant_Name__r.Email =:participantEmail
                                                        AND Course_Session_Scheduling__c=:CourseSessionRecordId];
        if(sessions.size()>0){
            isDuplicate = true;
        }
        return isDuplicate;
    }

    @AuraEnabled(cacheable=true)
    public static boolean checkMassDuplicateParticipants(String participantEmails,String CourseSessionRecordId) {
        System.debug(participantEmails);
        boolean isDuplicate=false;
        list<string> emailslist = new list<string>();
       /* if(participantEmails.size() > 0){
            for(Object rec : participantEmails){
                emailslist.add(string.valueOf(rec));
            }
        }*/
        list<Session_Participant__c> sessions = [select id,Name,Course_Session_Scheduling__c,
                                                        Participant_Name__c 
                                                        from Session_Participant__c
                                                        Where buildertek__Participant_Name__r.Email = :participantEmails
                                                        AND Course_Session_Scheduling__c=:CourseSessionRecordId];
        if(sessions.size()>0){
            isDuplicate = true;
        }
        return isDuplicate;
    }


    @AuraEnabled(cacheable=true)
    public static List<ParticipantWrapper> getParticipants(String couserSessionId) {
        system.debug('couserSessionId--->'+couserSessionId);
        List<ParticipantWrapper> ParticipantsWrapper = new List<ParticipantWrapper>();        
        list<Session_Participant__c> participantsList = [ SELECT Id,
                                                         Participant_Name__c, 
                                                         Participant_Name__r.Name,
                                                         Participant_Name__r.Email,
                                                         Participant_Company__c, 
                                                         Participant_Company__r.Name,
                                                         Participant_Attended__c,
                                                         Participant_Score__c, 
                                                         //Is_Participant_Attending__c,
                                                         //Training_Expiration_Date__c, 
                                                         Course_Completed__c, 
                                                         Course_Completion_Date__c, 
                                                         Notes__c, 
                                                         Course_Session_Scheduling__c
                                                         FROM Session_Participant__c  
                                                         where  Course_Session_Scheduling__c=:couserSessionId 
                                                        ];
        integer i=1;
        
        if(participantsList.size() > 0){
            for(Session_Participant__c rec : participantsList){
                ParticipantWrapper obj = new ParticipantWrapper();
                obj.RowNumber = i;
                obj.ParticipantName = rec.Participant_Name__r.Name;
                obj.ParticipantEmail = rec.Participant_Name__r.Email;
                obj.ParticipantCompany = rec.Participant_Company__r.Name;
                obj.ParticipantAttended = rec.Participant_Attended__c;
                obj.ParticipantScore = rec.Participant_Score__c;
                //obj.IsParticipantAttend = rec.Is_Participant_Attending__c;
               // obj.TrainingExpirationDate = rec.Training_Expiration_Date__c;
                obj.CourseCompleted = rec.Course_Completed__c;
                obj.CourseCompletionDate = rec.Course_Completion_Date__c;
                obj.Notes = rec.Notes__c;
                ParticipantsWrapper.add(obj);          
                i++;
            }
        }   
        system.debug(ParticipantsWrapper.size());
        return ParticipantsWrapper;
    }
    public class ParticipantWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public String ParticipantName;
        @AuraEnabled public String ParticipantEmail;
        @AuraEnabled public String ParticipantCompany;
        @AuraEnabled public String ParticipantCompanyId;
        @AuraEnabled public String ParticipantAttended;
        @AuraEnabled public String ParticipantScore;
        @AuraEnabled public String IsParticipantAttend;
        //@AuraEnabled public Date TrainingExpirationDate;
        @AuraEnabled public String CourseCompleted;
        @AuraEnabled public Date CourseCompletionDate;
        @AuraEnabled public String Notes;
        
    } 



    @AuraEnabled
    public static string saveParticipants(list<Object> records,string CourseSessionRecordId){
        List<buildertek__MSA_Settings__c> siteURL =[SELECT Id, Name, buildertek__Site_URL__c FROM buildertek__MSA_Settings__c];
        string message='';
        try{
             system.debug('hello');
                list<Session_Participant__c> ParticipantUpdatesList = new list<Session_Participant__c>();
                for(Object Item : records){            
                    Map<Object, Object> ItemMap = (Map<Object, Object>) Item;

                    string ParticipantName = String.Valueof(ItemMap.get('ParticipantName'));
                    string ParticipantEmail = String.Valueof(ItemMap.get('ParticipantEmail'));
                    string ParticipantCompanyId = String.Valueof(ItemMap.get('ParticipantCompanyId'));
                    string ParticipantAttended = String.Valueof(ItemMap.get('ParticipantAttended'));
                    string ParticipantScore = String.Valueof(ItemMap.get('ParticipantScore'));
                    //string IsParticipantAttend = String.Valueof(ItemMap.get('IsParticipantAttend'));
                    //string TrainingExpirationDate = String.Valueof(ItemMap.get('TrainingExpirationDate'));
                    //system.debug(TrainingExpirationDate);
                    string CourseCompleted = String.Valueof(ItemMap.get('CourseCompleted'));
                    string Notes = String.Valueof(ItemMap.get('Notes'));               

                    Session_Participant__c obj = new Session_Participant__c();
                    obj.Course_Session_Scheduling__c = CourseSessionRecordId;                   
                    obj.Participant_Name__c = ParticipantName;
                    obj.Participant_Company__c = ParticipantCompanyId;
                    obj.Participant_Attended__c = ParticipantAttended;
                    obj.Participant_Score__c = ParticipantScore;
                   // obj.Is_Participant_Attending__c = IsParticipantAttend;
                    //if(TrainingExpirationDate!='null' && TrainingExpirationDate!=null)
                    //obj.Training_Expiration_Date__c =Date.valueOf(TrainingExpirationDate);
                    obj.Course_Completed__c = CourseCompleted;
                    obj.Notes__c = Notes;
                    ParticipantUpdatesList.add(obj);                
                }            
                
                try{
                    
                    insert ParticipantUpdatesList;
                    message = 'Saved';
                   
                    if(message=='Saved'){
                        List<Object> idsList=new List<Object>();
                    for(Integer i=0;i<ParticipantUpdatesList.size();i++){
                        idsList.add(ParticipantUpdatesList[i].id);
                        
                    }
                    buildertek.ParticipantUpdatesController.sendEmialToParticipants(idsList,'Registration Email');
                    }
                   
                    
                    
                }catch(exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                }         
        }catch(Exception e){
            system.debug('error--->'+e.getMessage());
            message = e.getMessage();
        }                           
        return message;                          
    }   
    @AuraEnabled
    public static List <Contact> getContacts(String accId,String couserSessionId){
        
        List<Contact> conList=new List<Contact>();
        List<String> emailList=new List<String>();
        if(accId!=null){
        System.debug('Account Id   *********************** '+accId+'couserSessionId-------------'+couserSessionId);   
        List<Session_Participant__c> partcipantList=[SELECT Id, Participant_Name__c ,Participant_Name__r.Email , Course_Session_Scheduling__c FROM Session_Participant__c where Course_Session_Scheduling__c=:couserSessionId ];    
        for(Session_Participant__c ss:partcipantList){
            emailList.add(ss.Participant_Name__r.Email);
        }
        conList=[select id,LastName,FirstName,Email,AccountId ,Phone from Contact where AccountId=:accId and Email not in : emailList];
        System.debug('contcts'+conList);
        }
        return conList;
    } 
   
}