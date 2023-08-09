public class MassUpdateTakeScheduleItem{
    Public String recordId{ get; set; }
    
    @AuraEnabled
    public static Integer getCount(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                system.debug('COunt record:::' + [Select COUNT()
                                                  FROM buildertek__Project_Task__c
                                                  WHERE buildertek__Schedule__c = :recordId]);
                return [Select COUNT()
                        FROM buildertek__Project_Task__c
                        WHERE buildertek__Schedule__c = :recordId];
                
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Project_Task__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__Schedule_Item_field_set')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__Schedule_Item_field_set').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    // if (f.getFieldPath() == 'Name'){
                    //     jsonPart += ',"readOnly":"' + 'true' + '"';
                    // }
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Project_Task__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                    
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
        }
        return '[' + result + ']';
    }
    
    @AuraEnabled
    public static String getRecords(String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize, String phase, String contractor, String contractorResources, String TradeType){
        List<buildertek__Project_Task__c > lstResult = new List<buildertek__Project_Task__c >();
        String result = '[]';
        try{
            if (String.isNotBlank(recordId)){
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',');
                if (!fieldNames.contains('buildertek__Milestone__c')){
                    query += ' ,buildertek__Milestone__c';
                }
                query += ' FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c=: recordId';
                if (String.isNotBlank(phase)){
                    phase = '%' + phase + '%';                    
                    query += ' AND buildertek__Phase__c LIKE : phase';
                }
                if (String.isNotBlank(contractor)){
                    contractor = '%' + contractor + '%';                    
                    query += ' AND buildertek__Contractor__r.Name LIKE : contractor';
                }
                if (String.isNotBlank(contractorResources)){
                    contractorResources = '%' + contractorResources + '%';                    
                    query += ' AND buildertek__Contractor_Resource__r.Name LIKE : contractorResources';
                }
                if (String.isNotBlank(TradeType)){
                    TradeType = '%' + TradeType + '%';                    
                    query += ' AND buildertek__Trade_Type__r.Name LIKE : TradeType';
                }
                query += ' Order by Order__c NULLS LAST,CreatedDate' ;//CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
                //query += ' Order by Order__c ASC NULLS LAST, buildertek__Phase__c ASC NULLS LAST, buildertek__Milestone__c,buildertek__Start__c , Auto_Number__c ASC';
                //query += ' LIMIT : pageSize OFFSET : offset';                                

                for (buildertek__Project_Task__c s : Database.query(query)){
                    lstResult.add(s);
                }
                String milestonequery = 'Select buildertek__Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
                milestonequery = milestonequery + ' From buildertek__Project_Task__c where buildertek__Schedule__c =:recordId AND buildertek__Milestone__c= true';
                List<buildertek__Project_Task__c>  milestoneTaskList = DataBase.query(milestonequery);
                
                Map<String,List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String,List<buildertek__Project_Task__c>>();
                                
                for(buildertek__Project_Task__c  task:lstResult){ //projectTasks1
                    if(!task.buildertek__Milestone__c){
                        if(task.buildertek__Phase__c !=null){
                            // system.debug(task.Name);
                            if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                                list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                                newProjectTaskList.add(task);                                    
                                TaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList);  
                            }else{
                                List<buildertek__Project_Task__c> newTaskList = new List<buildertek__Project_Task__c>();
                                newTaskList.add(task);
                                TaskWithPhaseMap.put(task.buildertek__Phase__c,newTaskList);  
                            }
                        }
                    }
                }                
                
                Map<String,buildertek__Project_Task__c> milestoneMap = new Map<String,buildertek__Project_Task__c>();
                if(milestoneTaskList.Size()>0){
                    for(buildertek__Project_Task__c milestone : milestoneTaskList){
                        if(milestone.buildertek__Phase__c != null){
                            list<buildertek__Project_Task__c> newProjectTaskList = TaskWithPhaseMap.get(milestone.buildertek__Phase__c);
                                                        
                            if(newProjectTaskList!=null)
                                newProjectTaskList.add(milestone);    
                            TaskWithPhaseMap.put(milestone.buildertek__Phase__c,newProjectTaskList);  
                        }else{
                            milestoneMap.put(milestone.Id,milestone);
                        }
                    }
                }
                
                Integer i=0;
                Map<String,Integer> newTaskWithPhaseMap = new Map<String,Integer>();
                List<sObject> updatetaskList = new List<sObject>();
                List<buildertek__Project_Task__c> newProjectTaskList = new List<buildertek__Project_Task__c>();
                Integer ListSize = 0;
                for(Integer j=0; j<lstResult.Size(); j++){
                    buildertek__Project_Task__c task = lstResult[j];
                    if(!string.isBlank(task.buildertek__Phase__c)){
                        if(TaskWithPhaseMap.Size() > 0){
                            if(newTaskWithPhaseMap.get(task.buildertek__Phase__c) == null){
                                if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                                    newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                                    if(newProjectTaskList != null){
                                        ListSize = ListSize+newProjectTaskList.Size();
                                    }  
                                    newTaskWithPhaseMap.put(task.buildertek__Phase__c,newProjectTaskList.Size());
                                    updatetaskList.addAll(newProjectTaskList);
                                    i = i+ListSize;
                                }
                            }
                        }
                    }else{
                        updatetaskList.add(task);
                        i++;
                    }
                }
                List<sObject> pageSizeTaskList = new List<sObject>();
                if (lstResult.size() > 0){
                 if(pageSize+offset <= updatetaskList.Size()){
                     for(Integer j= offset; j< offset+pageSize ; j++){
                        pageSizeTaskList.add(updatetaskList[j]);
                    }
                 }else if(pageSize+offset > updatetaskList.Size()){
                     for(Integer j= offset; j<updatetaskList.Size(); j++){
                        pageSizeTaskList.add(updatetaskList[j]);
                    }
                 }else{
                     pageSizeTaskList.addAll(updatetaskList);
                 }
                    
                    //result = JSON.serialize(updatetaskList);
                    result = JSON.serialize(pageSizeTaskList);
                    return result;
                }
            }
        } catch (Exception e){
            System.debug('Error' + e.getMessage());
            System.debug('Error line:::'+e.getLineNumber());
            return e.getMessage();
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
    
    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize, String phase, String contractor, String contractorResources, String TradeType){
        String errorMessage = '';
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Project_Task__c> items = (List<buildertek__Project_Task__c>)JSON.deserialize(updatedRecords, List<buildertek__Project_Task__c>.class);
                
                for(buildertek__Project_Task__c item : items){
                    if(item.buildertek__Completion__c != null){
                        item.buildertek__Completion__c = Decimal.valueOf(''+item.buildertek__Completion__c);
                    }else{
                        item.buildertek__Completion__c = 0;
                    }
                    
                    if(item.buildertek__Duration__c != null && item.buildertek__Duration__c <= 0){
                        item.buildertek__Duration__c = 1;
                    }
                    if(item.buildertek__Finish__c != null && item.buildertek__Duration__c != null){
                        item.buildertek__Finish__c= item.buildertek__Start__c.addDays(Integer.valueOf(item.buildertek__Duration__c)-1);
                        
                    }else if(item.buildertek__Finish__c == null){
                        if(item.buildertek__Duration__c != null){
                            item.buildertek__Finish__c= item.buildertek__Start__c.addDays(Integer.valueOf(item.buildertek__Duration__c)-1);
                        }
                    }else if(item.buildertek__Finish__c != null){
                        if(item.buildertek__Duration__c == null){
                            Date d1 =item.buildertek__finish__c;
                            Date d2 = item.buildertek__Start__c;
                            Integer daysDiff = d2.daysbetween(d1);
                            
                            item.buildertek__Duration__c = Decimal.valueOf(daysDiff+1);
                        }
                    }
                    system.debug('item>>>>>'+item);
                }
                
                if (items.size() > 0){
                    upsert items;
                }
                for(buildertek__Project_Task__c item : items){
                    system.debug(item);
                }
                // List<buildertek__Project_Task__c> projectTaskToUpdate = new List<buildertek__Project_Task__c>();
                // Map<Id, buildertek__Project_Task__c> mapAllTask = new Map<Id, buildertek__Project_Task__c>([Select Id, buildertek__Dependency__c, buildertek__Milestone__c, buildertek__Schedule__c, buildertek__Phase__c, buildertek__Duration__c, buildertek__Expected_End_Date__c, buildertek__Expected_Start_Date__c, buildertek__Start__c, buildertek__Finish__c, buildertek__Lag__c, buildertek__Order__c
                //                                                                                             FROM buildertek__Project_Task__c
                //                                                                                             WHERE buildertek__Schedule__c = :recordId
                //                                                                                             ORDER by buildertek__ORDER__c ASC
                //                                                                                             NULLS LAST]);
                // Date startDate;
                // Date endDate;
                // Integer numberDaysDue;
                // for (Id taskId : mapAllTask.keySet()){
                //  buildertek__Project_Task__c projectTask = mapAllTask.get(taskId);
                //  Id Dependency = projectTask.buildertek__Dependency__c;
                //  if (projectTask.buildertek__Dependency__c != null){
                //      buildertek__Project_Task__c parentTask = mapAllTask.get(projectTask.buildertek__Dependency__c);
                //      Integer lag = projectTask.buildertek__Lag__c != null ? Integer.valueOf(projectTask.buildertek__Lag__c) : 0;
                //      startDate = parentTask.buildertek__finish__c.addDays(1);
                //      endDate = parentTask.buildertek__finish__c.addDays(Integer.valueOf(mapAllTask.get(taskId).buildertek__Duration__c));
                //      numberDaysDue = startDate.daysBetween(endDate);
                //      projectTask.buildertek__Start__c = startDate;
                //      projectTask.buildertek__finish__c = ProjectTaskTriggerHandler.getEndDate(startDate, endDate);
                //      projectTaskToUpdate.add(projectTask);
                //  }
                // }
                // update projectTaskToUpdate;
                return getRecords(recordId, fieldSetName, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            errorMessage = e.getMessage();
            throw new AuraHandledException(e.getMessage());
        }
        return errorMessage;
    }
    
    @AuraEnabled
    public static String deleteProject(String deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize, String phase, String contractor, String contractorResources, String TradeType){
        try{
            if (String.isNotBlank(deleteRecordId)){
                delete [Select Id
                        FROM buildertek__Project_Task__c
                        WHERE ID = :deleteRecordId];
                return getRecords(recordId, fieldSetName, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static String massDeleteProjectTask(List<String> deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize, String phase, String contractor, String contractorResources, String TradeType){
        try{
            if (deleteRecordId.size() > 0){
                delete [Select Id
                        FROM buildertek__Project_Task__c
                        WHERE ID IN :deleteRecordId];
                return getRecords(recordId, fieldSetName, pageNumber, pageSize, phase, contractor, contractorResources, TradeType);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
}