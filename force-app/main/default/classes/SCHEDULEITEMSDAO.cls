public with sharing class SCHEDULEITEMSDAO {
    
    /*@AuraEnabled
    public static String getSchedule(List<buildertek__Project_Task__c> scheduleItems){
        String projectId = scheduleItems[0].buildertek__Project__c;
        system.debug(projectId);
        buildertek__Schedule__c scheduleRecord = [SELECT Id FROM buildertek__Schedule__c where buildertek__Project__c =: projectId order by CreatedDate desc LIMIT 1];
        system.debug(scheduleRecord);
        return scheduleRecord.Id;
    }*/
    
    
    
	@AuraEnabled
    public static ResponseBase createScheduleItems(Boolean isCreateNewScheduleAttr,buildertek__Schedule__c newScheduleRecord, List<buildertek__Project_Task__c> scheduleItems, List<String> scheduleRecordsIds){
         ResponseBase res = new ResponseBase();
        try{
            system.debug(scheduleItems);
            system.debug(scheduleRecordsIds);
            
             buildertek__Schedule__c newSchedule = new buildertek__Schedule__c();
            if(isCreateNewScheduleAttr){
               
                if(newScheduleRecord != null){
                    if(newScheduleRecord.buildertek__Project__c != null){
                        newSchedule.buildertek__Project__c = newScheduleRecord.buildertek__Project__c;
                    }
                    if(newScheduleRecord.buildertek__Description__c != null){
                        newSchedule.buildertek__Description__c = newScheduleRecord.buildertek__Description__c;
                    }
                    if(newScheduleRecord.buildertek__Type__c != null && newScheduleRecord.buildertek__Type__c != ''){
                        newSchedule.buildertek__Type__c = newScheduleRecord.buildertek__Type__c;
                    }
                    if(newScheduleRecord.buildertek__Initial_Start_Date__c != null){
                        newSchedule.buildertek__Initial_Start_Date__c = newScheduleRecord.buildertek__Initial_Start_Date__c;
                    }
                    
                    insert newSchedule;
                    
                }
            }
            
            system.debug(newSchedule);
            
           
            /*String projectId = scheduleItems[0].buildertek__Project__c;
            system.debug(projectId);*/
            /*List<buildertek__Schedule__c> scheduleRecord = [SELECT Id FROM buildertek__Schedule__c where buildertek__Project__c =: projectId]; //order by CreatedDate desc LIMIT 1
            system.debug(scheduleRecord);*/
            List<buildertek__Project_Task__c> scheduleItemsList = new List<buildertek__Project_Task__c>();
                system.debug(scheduleRecordsIds);
                for(buildertek__Project_Task__c item : scheduleItems){
                    if(Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable()){
                        if(isCreateNewScheduleAttr){
                            buildertek__Project_Task__c newTask = new buildertek__Project_Task__c();
                            //newtask = item;
                            system.debug(newtask);
                            newTask.buildertek__Budget_Line__c = item.buildertek__Budget_Line__c;
                            newTask.Name = item.Name;
                            newTask.buildertek__Start__c = item.buildertek__Start__c;
                            newTask.buildertek__Duration__c = item.buildertek__Duration__c;
                            newTask.buildertek__Project__c = item.buildertek__Project__c;
                            
                            if(newSchedule != null){
                                newtask.buildertek__Schedule__c = newSchedule.Id;
                            }
                            
                            scheduleItemsList.add(newtask);
                            system.debug(scheduleItemsList);
                        }else{
                            for(Integer i=0;i<scheduleRecordsIds.Size();i++){
                                buildertek__Project_Task__c newTask = new buildertek__Project_Task__c();
                                //newtask = item;
                                system.debug(newtask);
                                newTask.buildertek__Budget_Line__c = item.buildertek__Budget_Line__c;
                                newTask.Name = item.Name;
                                newTask.buildertek__Start__c = item.buildertek__Start__c;
                                newTask.buildertek__Duration__c = item.buildertek__Duration__c;
                                newTask.buildertek__Project__c = item.buildertek__Project__c;
                                newtask.buildertek__Schedule__c = scheduleRecordsIds[i]; //scheduleRecord[0].Id;
                                scheduleItemsList.add(newtask);
                                system.debug(scheduleItemsList);
                            }
                        }
                        
                    }
                }
            insert scheduleItemsList;
            system.debug(scheduleItemsList);
            res.isSuccess = true;
            res.strMessage = 'Success';
            if(isCreateNewScheduleAttr){
                if(newSchedule != null){
                     res.strRecordId = newSchedule.Id;
                }
            }else{
                if(scheduleRecordsIds.Size() == 1){
                    res.strRecordId = scheduleRecordsIds[0];
                }else if(scheduleRecordsIds.Size() > 1){
                    res.strRecordId = scheduleItemsList[0].buildertek__Project__c;
                }  
            }
            
            return res;

        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
            system.debug('Message --------> ' + ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
    }
    
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String strRecordId;

    }
}