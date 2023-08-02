public with sharing class MeetingTriggerHandler {
    
    List<buildertek__Meeting__c> recordsNewList = new List<buildertek__Meeting__c>();
    Map<Id,buildertek__Meeting__c> recordsOldMap = new Map<Id,buildertek__Meeting__c>();
    
    public void MeetingTriggerHandler(List<buildertek__Meeting__c> recordsNewList, Map<Id,buildertek__Meeting__c> recordsOldMap){        
        this.recordsNewList = recordsNewList;
        this.recordsOldMap = recordsOldMap;   
    }
    
    public void OnBeforeInsertEvent(){
        List<buildertek__Meeting__c> lastResult = new List<buildertek__Meeting__c>();
        for(buildertek__Meeting__c mr : recordsNewList){
            if (mr.buildertek__End_Time__c == null) {
                if(mr.buildertek__Start_Time__c != null && mr.buildertek__Duration__c != null){
                    mr.buildertek__End_Time__c = mr.buildertek__Start_Time__c.addMinutes(Integer.valueOf(mr.buildertek__Duration__c));
                    System.debug('mr.buildertek__End_Time__c ==>>> '+mr.buildertek__End_Time__c);
                }
            }
        }
    } 

    public void OnBeforeUpdateEvent(){
        List<buildertek__Meeting__c> lastResult = new List<buildertek__Meeting__c>();
        for(buildertek__Meeting__c mr : recordsNewList){
            buildertek__Meeting__c oldMt = recordsOldMap.get(mr.Id);
            if (mr.buildertek__End_Time__c == oldMt.buildertek__End_Time__c) {
                if(mr.buildertek__Start_Time__c != null && mr.buildertek__Duration__c != null){
                    mr.buildertek__End_Time__c = mr.buildertek__Start_Time__c.addMinutes(Integer.valueOf(mr.buildertek__Duration__c));
                    System.debug('mr.buildertek__End_Time__c ==>>> '+mr.buildertek__End_Time__c);
                }
            }
        }
    }

    public void OnAfterInsertEvent(){
        // updateEndTime();
    } 
    
    public void OnAfterUpdateEvent(){
        // updateEndTime();
    } 

    public void updateEndTime(){
        // List<buildertek__Meeting__c> lastResult = new List<buildertek__Meeting__c>();
        // for(buildertek__Meeting__c mr : recordsNewList){
        //     buildertek__Meeting__c oldMt = recordsOldMap.get(mr.Id);
        //     if (mr.buildertek__End_Time__c == oldMt.buildertek__End_Time__c) {
        //         if(mr.buildertek__Start_Time__c != null && mr.buildertek__Duration__c != null){
        //             mr.buildertek__End_Time__c = mr.buildertek__Start_Time__c.addMinutes(Integer.valueOf(mr.buildertek__Duration__c));
        //             System.debug('mr.buildertek__End_Time__c ==>>> '+mr.buildertek__End_Time__c);
        //         }
        //     }
        // }
    }
}