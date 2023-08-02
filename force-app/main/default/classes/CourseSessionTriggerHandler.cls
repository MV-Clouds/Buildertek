public class CourseSessionTriggerHandler {
    public static void updateParticipantsCount(List<Course_Session_Scheduling__c> triggerList,Map<Id,Course_Session_Scheduling__c> oldTrigger){
        try{
            
            Set<Id> courseIds=new Set<Id>();                       
            for(Course_Session_Scheduling__c rec:triggerList){
                if(rec.Course_Name__c!=null){
                    system.debug('new --->'+rec.Course_Name__c);
                    courseIds.add(rec.Course_Name__c); 
                }               
                if(oldTrigger.get(rec.Id).Course_Name__c!=null){
                    system.debug('old --->'+oldTrigger.get(rec.Id).Course_Name__c);
                    courseIds.add(oldTrigger.get(rec.Id).Course_Name__c); 
                }               
            }
            
            if(courseIds.size()>0){
                ParticipantsCount.calculateCourseParticipants(null,null,courseIds);                
            }
            
        }catch(Exception e){
            system.debug('error--->'+e.getMessage()+' line no--->'+e.getLineNumber());           
        }
        
    }
public static void deleteMethod(List<Course_Session_Scheduling__c> sessionList){
   
    Set<Id> csids=new Set<Id>();
    for(Course_Session_Scheduling__c cs:sessionList){
        csids.add(cs.Id);
    }
    
    List<Session_Participant__c> ss=[SELECT Id, Name, Course_Session_Scheduling__c FROM Session_Participant__c where Course_Session_Scheduling__c in : csids];
   
      if(ss.size() > 0){ // Checking if the list contains records.
            delete ss; // Deleting records.
        }
    }
}