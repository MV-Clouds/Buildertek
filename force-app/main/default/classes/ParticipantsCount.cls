public class ParticipantsCount {
    public static void calculateCourseParticipants(List<Session_Participant__c> triggerList,
                                                   Set<Id> updateSessionIds,
                                                  Set<Id> updateCourseIds){
        try{
            Set<Id> participantsIds=new Set<Id>();
            if(triggerList!=null){
                for(Session_Participant__c rec:triggerList){
                    participantsIds.add(rec.Id);
                }                
            }
            
            map<string,list<Session_Participant__c>> courseParticipantsMap = new map<string,list<Session_Participant__c>>();
            map<string,list<Session_Participant__c>> courseSessionParticipantsMap = new map<string,list<Session_Participant__c>>();

            Set<Id> sessionIds=new Set<Id>();
            Set<Id> courseIds=new Set<Id>();
            if(updateSessionIds!=null){
                sessionIds.addAll(updateSessionIds);    
            }
            if(updateCourseIds!=null){
                courseIds.addAll(updateCourseIds);    
            } 
            
            system.debug('sessionIds--->'+sessionIds);
            system.debug('courseIds--->'+courseIds);
            List<Session_Participant__c> triggerParticipantsList=[SELECT 
                                                                  Id, 
                                                                  Name,
                                                                  Participant_Name__c,
                                                                  Participant_Company__c,
                                                                  Course_Completed__c, 
                                                                  Course_Completion_Date__c, 
                                                                  Participant_Score__c, 
                                                                  Participant_Attended__c, 
                                                                  Course_Session_Scheduling__c,
                                                                  Notes__c, 
                                                                  Is_Participant_Attending__c,
                                                                  Course_Session_Scheduling__r.Course_Name__c 
                                                                  FROM Session_Participant__c 
                                                                  Where id in : participantsIds];
            
            
            for(Session_Participant__c rec:triggerParticipantsList){
                sessionIds.add(rec.Course_Session_Scheduling__c);
                courseIds.add(rec.Course_Session_Scheduling__r.Course_Name__c );
            }
            system.debug('sessionIds--->'+sessionIds);
            system.debug('courseIds--->'+courseIds);
            
            List<Session_Participant__c> ParticipantsList=[SELECT 
                                                           Id, 
                                                           Name,
                                                           Participant_Name__c,
                                                           Participant_Company__c,
                                                           Course_Completed__c, 
                                                           Course_Completion_Date__c, 
                                                           Participant_Score__c, 
                                                           Participant_Attended__c, 
                                                           Course_Session_Scheduling__c,
                                                           Notes__c, 
                                                           Is_Participant_Attending__c,
                                                           Course_Session_Scheduling__r.Course_Name__c 
                                                           FROM Session_Participant__c 
                                                           Where Course_Session_Scheduling__r.Course_Name__c In :courseIds ];
            
            
            for(Session_Participant__c rec:participantsList){ 
                if(courseParticipantsMap.get(rec.Course_Session_Scheduling__r.Course_Name__c)!=null){
                    list<Session_Participant__c> courseParticipantsList = courseParticipantsMap.get(rec.Course_Session_Scheduling__r.Course_Name__c);
                    courseParticipantsList.add(rec);   
                    courseParticipantsMap.put(rec.Course_Session_Scheduling__r.Course_Name__c,courseParticipantsList);                                        
                }else{
                    list<Session_Participant__c> courseParticipant = new list<Session_Participant__c>();
                    courseParticipant.add(rec);
                    courseParticipantsMap.put(rec.Course_Session_Scheduling__r.Course_Name__c,courseParticipant);                    
                }  
                
                if(courseSessionParticipantsMap.get(rec.Course_Session_Scheduling__c+'~'+rec.Course_Session_Scheduling__r.Course_Name__c)!=null){
                    list<Session_Participant__c> courseParticipantsList = courseSessionParticipantsMap.get(rec.Course_Session_Scheduling__c+'~'+rec.Course_Session_Scheduling__r.Course_Name__c);
                    courseParticipantsList.add(rec);   
                    courseSessionParticipantsMap.put(rec.Course_Session_Scheduling__c+'~'+rec.Course_Session_Scheduling__r.Course_Name__c,courseParticipantsList);                                        
                }else{
                    list<Session_Participant__c> courseParticipant = new list<Session_Participant__c>();
                    courseParticipant.add(rec);
                    courseSessionParticipantsMap.put(rec.Course_Session_Scheduling__c+'~'+rec.Course_Session_Scheduling__r.Course_Name__c,courseParticipant);                    
                }  
            }
            
            List<Course__c> coursesList=[SELECT Id, Name, No_of_Participants__c FROM Course__c 
                                         Where id in : courseIds];
            
            
            if(coursesList.size()>0){
                for(Course__c course : coursesList){
                    list<Session_Participant__c> courseParticipantsList = new list<Session_Participant__c>();
                    courseParticipantsList = courseParticipantsMap.get(course.Id);
                    if(courseParticipantsList!=null){
                        course.No_of_Participants__c =courseParticipantsList.size();    
                    }else{
                        course.No_of_Participants__c = 0;
                    }
                    
                }
                update coursesList;
            }
            
            List<Course_Session_Scheduling__c> courseSessionsList=[SELECT Id, 
                                                                   Name,
                                                                   Session_Date_Time__c,
                                                                   Session_Date__c, 
                                                                   Session_Duration__c,
                                                                   Session_Facilitator__c,
                                                                   No_of_Scheduled_Participants__c,
                                                                   No_of_Attended_Participants__c,
                                                                   Session_Time_NEW__c, 
                                                                   Course_Name__c 
                                                                   FROM Course_Session_Scheduling__c 
                                                                   where Id In : sessionIds 
                                                                   and Course_Name__c In :courseIds ];                                    
            if(courseSessionsList.size()>0){
                for(Course_Session_Scheduling__c coursesession : courseSessionsList){
                    list<Session_Participant__c> courseParticipantsList = new list<Session_Participant__c>();
                    courseParticipantsList = courseSessionParticipantsMap.get(coursesession.Id+'~'+coursesession.Course_Name__c);
                    system.debug('coursesession.Id--->'+coursesession.Id);
                    system.debug('coursesession.Course_Name__c--->'+coursesession.Course_Name__c);
                    system.debug('courseParticipantsList size-->'+courseParticipantsList.size());
                    if(courseParticipantsList!=null){
                        coursesession.No_of_Scheduled_Participants__c =courseParticipantsList.size();
                        integer attendedParticipantsCount = 0;
                        for(Session_Participant__c courseparticipant : courseParticipantsList){
                            if(courseparticipant.Participant_Attended__c=='Yes'){
                                attendedParticipantsCount = attendedParticipantsCount+1;
                            }               
                        }
                        system.debug('attendedParticipantsCount--->'+attendedParticipantsCount);
                        coursesession.No_of_Attended_Participants__c =attendedParticipantsCount;                                            
                    }else{
                        coursesession.No_of_Scheduled_Participants__c =0;
                        coursesession.No_of_Attended_Participants__c =0;
                    }
                    
                }
                update courseSessionsList;
            }               
            
            
            
        }catch(Exception e){
            system.debug('error--->'+e.getMessage()+' line no--->'+e.getLineNumber());
        }
          
    
    }
    
    public static void updateParticipants(List<Session_Participant__c> triggerList,Map<Id,Session_Participant__c> oldTrigger){
       try{
           
           Set<Id> sessionIds=new Set<Id>();           
           Set<Id> courseIds=new Set<Id>();           

           for(Session_Participant__c rec:triggerList){
               if(rec.Course_Session_Scheduling__c!=null){
                   system.debug('new --->'+rec.Course_Session_Scheduling__c);
                   sessionIds.add(rec.Course_Session_Scheduling__c); 
               }               
               if(oldTrigger.get(rec.Id).Course_Session_Scheduling__c!=null){
                   system.debug('old --->'+oldTrigger.get(rec.Id).Course_Session_Scheduling__c);
                   sessionIds.add(oldTrigger.get(rec.Id).Course_Session_Scheduling__c); 
               }               
           }
           
           if(sessionIds.size()>0){
               List<Session_Participant__c> ParticipantsList=[SELECT 
                                                              Id, 
                                                              Name,
                                                              Participant_Name__c,
                                                              Participant_Company__c,
                                                              Course_Completed__c, 
                                                              Course_Completion_Date__c, 
                                                              Participant_Score__c, 
                                                              Participant_Attended__c, 
                                                              Course_Session_Scheduling__c,
                                                              Notes__c, 
                                                              Is_Participant_Attending__c,
                                                              Course_Session_Scheduling__r.Course_Name__c 
                                                              FROM Session_Participant__c 
                                                              Where Course_Session_Scheduling__c In :sessionIds ];
               system.debug('ParticipantsList size--->'+ParticipantsList.size());
               if(ParticipantsList.size()>0){
                   for(Session_Participant__c rec : ParticipantsList){
                       if(rec.Course_Session_Scheduling__r.Course_Name__c!=null){
                           courseIds.add(rec.Course_Session_Scheduling__r.Course_Name__c); 
                       }
                   }  
                   calculateCourseParticipants(ParticipantsList,sessionIds,courseIds);
               }
           
           }
           
       }catch(Exception e){
            system.debug('error--->'+e.getMessage()+' line no--->'+e.getLineNumber());           
       }
        
    }
    
    
    public static void deleteParticipants(List<Session_Participant__c> triggerList){
       try{
           
           Set<Id> sessionIds=new Set<Id>();  
           map<Id,Id> csschIdMap = new map<Id,Id>();
           for(Session_Participant__c rec:triggerList){
               if(rec.Course_Session_Scheduling__c!=null){
                   system.debug('new --->'+rec.Course_Session_Scheduling__c);
                   sessionIds.add(rec.Course_Session_Scheduling__c);  
                   csschIdMap.put(rec.Course_Session_Scheduling__c,rec.Course_Session_Scheduling__c);
               }                                           
           }
           
           system.debug('csschIdMap--->'+csschIdMap);
           
           if(sessionIds.size()>0){
               
               map<Id,list<Session_Participant__c>> sclistmpa = new map<Id,list<Session_Participant__c>>();
               List<Session_Participant__c> ParticipantsList=[SELECT 
                                                              Id, 
                                                              Name,
                                                              Participant_Name__c,
                                                              Participant_Company__c,
                                                              Course_Completed__c, 
                                                              Course_Completion_Date__c, 
                                                              Participant_Score__c, 
                                                              Participant_Attended__c, 
                                                              Course_Session_Scheduling__c,
                                                              Notes__c, 
                                                              Is_Participant_Attending__c,
                                                              Course_Session_Scheduling__r.Course_Name__c 
                                                              FROM Session_Participant__c 
                                                              Where Course_Session_Scheduling__c In :sessionIds ];
               system.debug('ParticipantsList size--->'+ParticipantsList.size());
               
               if(ParticipantsList.size()>0){
                   calculateCourseParticipants(ParticipantsList,null,null);                                    
                   for(Session_Participant__c rec : ParticipantsList){ 
                       if(sclistmpa.get(rec.Course_Session_Scheduling__c)!=null){
                           list<Session_Participant__c> courseParticipantsList = sclistmpa.get(rec.Course_Session_Scheduling__c);
                           courseParticipantsList.add(rec);   
                           sclistmpa.put(rec.Course_Session_Scheduling__c,courseParticipantsList);                                        
                       }else{
                           list<Session_Participant__c> courseParticipant = new list<Session_Participant__c>();
                           courseParticipant.add(rec);
                           sclistmpa.put(rec.Course_Session_Scheduling__c,courseParticipant);                    
                       }                         
                   }
                   
               }
               
               
            
               list<Course_Session_Scheduling__c> csreclist = new list<Course_Session_Scheduling__c>();
               
               for(Id key: csschIdMap.keySet()){
                   system.debug('key--->'+key);
                   system.debug('get map--->'+sclistmpa.get(key));
                   if(sclistmpa.get(key)==null){
                       system.debug('null');
                       Course_Session_Scheduling__c csc = new Course_Session_Scheduling__c();
                       csc.Id=key;
                       csc.No_of_Scheduled_Participants__c=0;
                       csc.No_of_Attended_Participants__c=0;  
                       csreclist.add(csc);
                   }
               }
               system.debug('csreclist--->'+csreclist);
               if(csreclist.size()>0){
                   update csreclist;
               }               
               
               
           
           }
           
       }catch(Exception e){
            system.debug('error--->'+e.getMessage()+' line no--->'+e.getLineNumber());           
       }
        
    }
    
    
    
    
    


    
}