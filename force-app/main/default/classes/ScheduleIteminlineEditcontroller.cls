public class ScheduleIteminlineEditcontroller {

  @AuraEnabled
    public static List < Account > fetchAccts() {
        return [ SELECT Id, Name, Industry, Type FROM Account LIMIT 10 ];
    }
  @AuraEnabled
    public static String getFieldSet(String sObjectName, String fieldSetName,String parentRecordId) {
        String result = '';
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(sObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            system.debug('>>>>>>> FsMap >>> ' + FsMap);
            if(FsMap.containsKey(fieldSetName))
                for(Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()) {
                    if(result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    jsonPart += '}';
                    result += jsonPart;
            }
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }
        return '['+result+']';
    }

    @AuraEnabled
    public static String getRecords(String sObjectName, String parentFieldName, String parentRecordId, String fieldNameJson){

        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            System.debug(fieldNameJson);
            List<String> fieldNames = (List<String>) JSON.deserialize(fieldNameJson, List<String>.class);
            System.debug(fieldNames);
            Set<String> setFieldNames = new Set<String>();
            System.debug(setFieldNames);
            String query = 'SELECT ' + String.join(fieldNames, ',') + ' FROM ' + sObjectName;
            System.debug(query);
            
            if(parentFieldName != NULL && parentFieldName != '' && parentRecordId != NULL){
                query += ' WHERE ' + parentFieldName + '= \'' +  parentRecordId + '\' ';
            }
            for(sObject s : Database.query(query)){
                lstResult.add(s);
            }
            if(lstResult.size() > 0) {
                result = JSON.serialize(lstResult);
            }
            system.debug('result---'+result);
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
            System.debug(result);
        }
        return result;
    }
        
    @AuraEnabled    
    public static List < buildertek__Project_Task__c> fetchprojecttasks(string parentId) {    
            system.debug('parentid===>'+parentId);
         List < buildertek__Project_Task__c > lstOfscheduleitems= [select id, Name,buildertek__Start__c,buildertek__Finish__c,buildertek__Dependency__c,buildertek__Dependency__r.Name,buildertek__Schedule__c,buildertek__Project_ID__c,buildertek__Completed__c  from buildertek__Project_Task__c where buildertek__Schedule__c = : parentId];
        
        return lstOfscheduleitems;
            
    }    
      
    @AuraEnabled    
    public static boolean updateprojeccttasks( List < buildertek__Project_Task__c > updatedprojecttaskList ) {    
            
        try {  
          
            update updatedprojecttaskList;  
            return true;  
              
        } catch(Exception e) {  
          
            return false;  
              
        }  
            
    }    
    
    
    @AuraEnabled    
    public static String updateprojeccttasksDuplicate( String updatedprojecttaskListJSON , String scheduleId,Integer currentPage) {    
            
        try {  
             List<buildertek__Project_Task__c> updatedprojecttaskList= (List<buildertek__Project_Task__c>)System.JSON.deserialize(updatedprojecttaskListJSON, List<buildertek__Project_Task__c>.class);
            system.debug('updatedprojecttaskList ---->'+updatedprojecttaskList.size());
            List < buildertek__Project_Task__c > insertList = new List < buildertek__Project_Task__c >();
            List < buildertek__Project_Task__c > updateList = new List < buildertek__Project_Task__c >();
             Integer pageNumber = 25*(currentPage - 1);
            List<buildertek__Project_Task__c> scheduleItemList = new List<buildertek__Project_Task__c>();
            if(updatedprojecttaskList.Size() > 0){
                for(Integer i=0;i<updatedprojecttaskList.Size();i++){
                    updatedprojecttaskList[i].buildertek__Order__c = i+pageNumber+1;
                    scheduleItemList.add(updatedprojecttaskList[i]);
                }
            }
            for(buildertek__Project_Task__c task :scheduleItemList ){
                system.debug(task);
                String taskId='';
                if(task.Id != null){
                  taskId  = String.valueOf(task.Id);
                }
                if(!taskId.contains('row') && taskId != '' && taskId != null){
                    updateList.add(task);
                }else{
                    Id taskrecId;
                    buildertek__Project_Task__c newTask = new buildertek__Project_Task__c();
                    if( task.buildertek__Phase__c != 'null'){
                        newTask.buildertek__Phase__c = task.buildertek__Phase__c;
                    }
                    newTask.buildertek__Order__c = task.buildertek__Order__c;
                    if(task.buildertek__Order__c != null){
                        newTask.buildertek__Order__c = task.buildertek__Order__c;
                    }
                    newTask.buildertek__Dependency__c = task.buildertek__Dependency__c;
                    newTask.buildertek__Contractor_Resource__c = task.buildertek__Contractor_Resource__c;
                    newTask.buildertek__Resource__c = task.buildertek__Resource__c;
                    newTask.buildertek__Contractor__c = task.buildertek__Contractor__c;
                    newTask.buildertek__Completion__c = task.buildertek__Completion__c;
                    newTask.buildertek__Finish__c = task.buildertek__Finish__c;
                    newTask.Name = task.Name;
                    if( task.buildertek__Start__c != null){
                        newTask.buildertek__Start__c = task.buildertek__Start__c;
                    }else{
                         newTask.buildertek__Start__c =  system.today();
                    }
                    newTask.buildertek__Schedule__c = scheduleId;
                   /* task.Id = taskrecId;
                    task.buildertek__Schedule__c = scheduleId;
                    system.debug(task);
                    
                    task.buildertek__Start__c = system.today();*/
                    insertList.add(newTask);
                }
            }
            
            if(insertList.size()>0){
                insert insertList;
            }
            if(updateList.size()>0){
                update updateList;
            }
            
            //update updatedprojecttaskList;  
            return 'true';  
              
        } catch(Exception e) {  
              system.debug(e);
            system.debug(e.getMessage());
            //Srtring msg = e.getMessage();
            return e.getMessage();  
              
        } 
            
    }  
    
    
    //Delete Schedule Item
    @AuraEnabled
    public static void deletescheduleitemrec(string projecttasks){
        system.debug('projecttasks'+projecttasks);
        buildertek__Project_Task__c projecttask = [select id,Name from buildertek__Project_Task__c where id =: projecttasks];
        if(projecttask != null){
            Delete projecttask;
        }
    }
        
    @AuraEnabled
    public static DataTableDetails getDataTableDetails(String objApi, String fieldSetName, string scheduleid){
        DataTableDetails dataTableDtls = new DataTableDetails();
        List<FieldsetUtilityClass.FieldSetProperties> lstOfFieldSetProperties = FieldsetUtilityClass.getFieldFromFieldSet(objApi, fieldSetName);
        
        if(lstOfFieldSetProperties != null && lstOfFieldSetProperties.size() > 0){
            String strQuery = 'SELECT ';
            for(FieldsetUtilityClass.FieldSetProperties inst : lstOfFieldSetProperties){
                dataTableDtls.lstOfFieldLabels.add(inst);
                if(inst.type == 'reference'){
                    string refname =inst.fieldName;
                    if(refname.contains('__c')){
                        refname = refname.replace('__c', '__r.Name');
                    }
                    else{
                        refname = refname+'.Name';
                    }
                    strQuery = strQuery + refname + ',';
                }
                strQuery = strQuery + inst.fieldName + ',';
            }
            if(!strQuery.equalsIgnoreCase('SELECT '))
                //strQuery = strQuery + 'Id ,buildertek__Milestone__c FROM ' + objApi + ' where buildertek__Schedule__c = :  scheduleid Order By CreatedDate,buildertek__Phase__c ASC,buildertek__Milestone__c' ;//CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
            strQuery = strQuery + 'Id ,buildertek__Milestone__c,buildertek__Order__c,CreatedDate FROM ' + objApi + ' where buildertek__Schedule__c = :  scheduleid Order By buildertek__Order__c NULLS LAST,CreatedDate' ;//CreatedDate//Order by buildertek__Milestone__c , Order__c ASC NULLS LAST, Auto_Number__c ASC
                system.debug('strQuery---'+strQuery);
            
            dataTableDtls.lstOfSObjs = Database.query(strQuery);
            
            List<buildertek__Project_Task__c> projectTasksSorted = dataTableDtls.lstOfSObjs;
            
            String milestonequery = 'Select buildertek__Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
             milestonequery = milestonequery + ' From buildertek__Project_Task__c where buildertek__Schedule__c =:scheduleid AND buildertek__Milestone__c= true';
           List<buildertek__Project_Task__c>  milestoneTaskList = DataBase.query(milestonequery);
            
            Map<String,List<buildertek__Project_Task__c>> TaskWithPhaseMap = new Map<String,List<buildertek__Project_Task__c>>();
            
            for(buildertek__Project_Task__c task:projectTasksSorted){ //projectTasks1
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
                        if(newProjectTaskList != null){
                            newProjectTaskList.add(milestone);    
                            TaskWithPhaseMap.put(milestone.buildertek__Phase__c,newProjectTaskList);                              
                        }
                        /* newProjectTaskList.add(milestone);    
                        TaskWithPhaseMap.put(milestone.buildertek__Phase__c,newProjectTaskList);  */
                    }else{
                        milestoneMap.put(milestone.Id,milestone);
                    }
                }
            }
            
            Integer i=0;
            DataTableDetailsChild dataTableDtlsChild =  new DataTableDetailsChild();
            Map<String,Integer> newTaskWithPhaseMap = new Map<String,Integer>();
            List<buildertek__Project_Task__c> updatetaskList = new List<buildertek__Project_Task__c>();
            List<buildertek__Project_Task__c> newProjectTaskList = new List<buildertek__Project_Task__c>();
            List<DataTableDetailsChild> innerTaskList =  new List<DataTableDetailsChild>();
            Integer ListSize = 0;
            Integer k = 1;
          
            for(Integer j=0; j<projectTasksSorted.Size(); j++){
                buildertek__Project_Task__c task = projectTasksSorted[j];
                if(!string.isBlank(task.buildertek__Phase__c)){
                    if(TaskWithPhaseMap.Size() > 0){
                        if(newTaskWithPhaseMap.get(task.buildertek__Phase__c) == null){
                            if(TaskWithPhaseMap.get(task.buildertek__Phase__c) != null){
                                newProjectTaskList = TaskWithPhaseMap.get(task.buildertek__Phase__c);
                                Integer v = 1;
                                for(buildertek__Project_Task__c newProjectTask : newProjectTaskList){
                                    DataTableDetailsChild dataTableDtlsChild2 =  new DataTableDetailsChild();
                                    dataTableDtlsChild2.SObjs  = newProjectTask;
                                    dataTableDtlsChild2.wbs =  String.valueOf(k)+'.'+String.valueOf(v);
                                    innerTaskList.add(dataTableDtlsChild2);
                                    v++;
                                    
                                }
                                k++;
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
                    DataTableDetailsChild dataTableDtlsChild3 = new DataTableDetailsChild();
                    dataTableDtlsChild3.SObjs = task;
                    System.debug(task.Name);
                    dataTableDtlsChild3.wbs  = String.valueOf(k);
                    innerTaskList.add(dataTableDtlsChild3);
                    k++;
                }
            }
           if(updatetaskList.size() > 0){
                dataTableDtls.lstOfSObjs = updatetaskList;
               dataTableDtls.lstOfSObjsChild = innerTaskList;
               dataTableDtls.noMaplstOfSObjs = projectTasksSorted;
            }
            system.debug('Schedule Items ::'+dataTableDtls.lstOfSObjs);
        }
        system.debug('Schedule Item ::'+dataTableDtls);
     return dataTableDtls;
    }
    
    @AuraEnabled
    public static String updateTaskOrder(String scheduleItemListJSON,Integer currentPage){
     String result = '';
        try{
            System.debug(scheduleItemListJSON);
            List<buildertek__Project_Task__c> scheduleItemList= (List<buildertek__Project_Task__c>)System.JSON.deserialize(scheduleItemListJSON, List<buildertek__Project_Task__c>.class);
            system.debug(scheduleItemList.Size());
            List<buildertek__Project_Task__c> updateList = new List<buildertek__Project_Task__c>();
            Integer pageNumber = 25*(currentPage - 1);
            if(scheduleItemList.Size() > 0){
                for(Integer i=0;i<scheduleItemList.Size();i++){
                    scheduleItemList[i].buildertek__Order__c = i+pageNumber+1;
                    updateList.add(scheduleItemList[i]);
                }
            }
            if(updateList.size() > 0){
                update updateList;
            }
            result= 'true';
        }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
            System.debug(result);
        }
        return result;
    }
    
    
   /* public class DataTableDetails{
        @AuraEnabled
        public List<sObject> lstOfSObjs = new List<sObject>();
        @AuraEnabled
        public List<FieldsetUtilityClass.FieldSetProperties> lstOfFieldLabels = new List<FieldsetUtilityClass.FieldSetProperties>();
    }*/
    
    public class DataTableDetails{
        @AuraEnabled
        public List<sObject> lstOfSObjs = new List<sObject>();
        @AuraEnabled
        public List<sObject> noMaplstOfSObjs = new List<sObject>();
        @AuraEnabled
        public List<FieldsetUtilityClass.FieldSetProperties> lstOfFieldLabels = new List<FieldsetUtilityClass.FieldSetProperties>();
         @AuraEnabled
        public List<DataTableDetailsChild> lstOfSObjsChild =  new List<DataTableDetailsChild>();
    }
    
    public class DataTableDetailsChild{
        @AuraEnabled
        public buildertek__Project_Task__c SObjs = new buildertek__Project_Task__c();
        @AuraEnabled
        public string wbs;
    }
    
    @AuraEnabled
    public static Map<string,List<buildertek__Project_Task__c>>  getScheduleRecord(string recordId){ 
         List<buildertek__Project_Task__c> listrecs = new  List<buildertek__Project_Task__c>();
        listrecs =[Select id,buildertek__Phase__c,Name,buildertek__Lag__c,buildertek__Schedule__c,buildertek__Schedule__r.Name,
                                                      buildertek__Duration__c,buildertek__Dependency__c,buildertek__Dependency__r.Name,buildertek__Start__c,
                                                      buildertek__Finish__c,buildertek__Resource__c,buildertek__Resource__r.Name,buildertek__Contractor__c,buildertek__Contractor__r.Name,
                                                      buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,buildertek__Completed__c,
                                                      buildertek__Completion__c,buildertek__Milestone__c from buildertek__Project_Task__c where buildertek__Schedule__c = : recordId Order By CreatedDate,buildertek__Phase__c ASC,buildertek__Milestone__c];
        
         String milestonequery = 'Select buildertek__Project__r.Name, buildertek__Dependency__r.Finish__c,buildertek__Contractor_Resource__r.Name,buildertek__Contractor__r.Name,buildertek__Resource__r.Name, ' + BT_Utils.getQueryStringForObjectWithAllFields('Project_Task__c');
             milestonequery = milestonequery + ' From buildertek__Project_Task__c where buildertek__Schedule__c =:recordId AND buildertek__Milestone__c= true';
           List<buildertek__Project_Task__c>  milestoneTaskList = DataBase.query(milestonequery);
        
        for(buildertek__Project_Task__c pr :listrecs){
            system.debug('listrecs===>'+pr.Name);
            system.debug('listrecs===>'+pr.buildertek__Phase__c);
        }
        Map<String,buildertek__Project_Task__c []> oppMap = new Map<String, buildertek__Project_Task__c[]>();
        for(buildertek__Project_Task__c oppRec: listrecs) {
            if(!oppRec.buildertek__Milestone__c){
                if(oppMap.get(oppRec.buildertek__Phase__c) != null) {
                    oppMap.get(oppRec.buildertek__Phase__c).add(oppRec);
                } else {
                    oppMap.put(oppRec.buildertek__Phase__c, new List<buildertek__Project_Task__c>{oppRec});
                }
            }
           
        }
          System.debug(milestoneTaskList);
         if(milestoneTaskList.Size()>0){
           System.debug('inisde if');

                for(buildertek__Project_Task__c milestone : milestoneTaskList){
                       System.debug(milestone);
                   // if(milestone.buildertek__Phase__c != null){
                        list<buildertek__Project_Task__c> newProjectTaskList = oppMap.get(milestone.buildertek__Phase__c);
                       System.debug(newProjectTaskList);
                        newProjectTaskList.add(milestone);    
                        oppMap.put(milestone.buildertek__Phase__c,newProjectTaskList);  
                  /*  }else{
                        milestoneMap.put(milestone.Id,milestone);
                    }*/
                }
            }
        
        Innerclass Inn = new Innerclass();
            Inn.ResultMap = oppMap;
            Inn.lstOfSObj = milestoneTaskList;
            system.debug('Inn===>'+Inn);
            return oppMap;
    }
    
    public class Innerclass{
            @AuraEnabled
            public Map<string,List<buildertek__Project_Task__c>> ResultMap;
            @AuraEnabled
            public List<sObject> lstOfSObj = new List<sObject>();   
           // @AuraEnabled public buildertek__Project_Task__c performanceMetric{get;set;}
           // @AuraEnabled public list<optionWrapper> organizations{get;set;}
        }
       /* public class optionWrapper{
             @AuraEnabled public string label;
             @AuraEnabled public string value;
        }*/
    
    @AuraEnabled
    public static String UPandINTaskOrder(String scheduleItemsListJSON, string scheduleId,Integer currentPage){
   
     List<buildertek__Project_Task__c> scheduleItemList= (List<buildertek__Project_Task__c>)System.JSON.deserialize(scheduleItemsListJSON, List<buildertek__Project_Task__c>.class);
     system.debug(scheduleItemList);
     String result = '';
     //  try{
            list<buildertek__Project_Task__c> newUpdateList = new List<buildertek__Project_Task__c>();
            list<buildertek__Project_Task__c> newInsertList = new List<buildertek__Project_Task__c>();
            system.debug(scheduleItemList.Size());
            List<buildertek__Project_Task__c> updateList = new List<buildertek__Project_Task__c>();
            List<string> updateIdList = new List<string>();
            Integer pageNumber = 25*(currentPage - 1);
            if(scheduleItemList.Size() > 0){
                for(Integer i=0;i<scheduleItemList.Size();i++){
                    scheduleItemList[i].buildertek__Order__c = i+pageNumber+1;
                    system.debug(scheduleItemList[i]);
                    updateList.add(scheduleItemList[i]);
                    if(scheduleItemList[i].Id != null){
                        updateIdList.add(scheduleItemList[i].Id);
                    }
                }
            }
        Map<ID, buildertek__Project_Task__c> taskListMapWithId = new Map<ID, buildertek__Project_Task__c>([SELECT Id,buildertek__Dependency__c,buildertek__Start__c,buildertek__Finish__c,buildertek__Duration__c,
                                                                                           Name FROM buildertek__Project_Task__c Where Id IN:updateIdList ]);
            system.debug('test');
            if(updateList.size() > 0){
               // update updateList;
               String taskId = '';
                for(buildertek__Project_Task__c item : updateList){
                    if(item.Id != null){
                        taskId  = String.valueOf(item.Id);
                    }
                   //taskId  = String.valueOf(item.Id);
                    if(item.Id != null && taskId != ''){
                        newUpdateList.add(item);
                    }else{
                        buildertek__Project_Task__c newTask = new buildertek__Project_Task__c();
                        if( item.buildertek__Phase__c != 'null'){
                            newTask.buildertek__Phase__c = item.buildertek__Phase__c;
                        }
                        newTask.buildertek__Order__c = item.buildertek__Order__c;
                        if(item.buildertek__Order__c != null){
                            newTask.buildertek__Order__c = item.buildertek__Order__c;
                        }
                        newTask.buildertek__Dependency__c = item.buildertek__Dependency__c;
                        system.debug(item.buildertek__Dependency__c);
                        if(item.buildertek__Dependency__c != null){
                            system.debug(taskListMapWithId.get(item.buildertek__Dependency__c));
                            newTask.buildertek__Start__c = taskListMapWithId.get(item.buildertek__Dependency__c).buildertek__Finish__c;
                            system.debug(newTask.buildertek__Start__c);
                        }
                        newTask.buildertek__Contractor_Resource__c = item.buildertek__Contractor_Resource__c;
                        newTask.buildertek__Resource__c = item.buildertek__Resource__c;
                        newTask.buildertek__Contractor__c = item.buildertek__Contractor__c;
                        newTask.buildertek__Completion__c = item.buildertek__Completion__c;
                        newTask.buildertek__Finish__c = item.buildertek__Finish__c;
                        newTask.buildertek__Duration__c = item.buildertek__Duration__c;
                       /* if(newTask.buildertek__Duration__c == null){
                            if(newTask.buildertek__Finish__c != null){
                                Date d1 =item.buildertek__finish__c;
                                Date d2 = item.buildertek__Start__c;
                                Integer daysDiff = d2.daysbetween(d1);
                                    newTask.buildertek__Finish__c= item.buildertek__Start__c.addDays(daysDiff+1);
                                
                            }
                        }*/
                        
                        newTask.Name = item.Name;
                        if( item.buildertek__Start__c != null){
                            newTask.buildertek__Start__c = item.buildertek__Start__c;
                        }else{
                            newTask.buildertek__Start__c =  system.today();
                        }
                        newTask.buildertek__Schedule__c = scheduleId;
                        
                        newInsertList.add(newTask);
                    }
                }
                
                if(newInsertList.size()>0){
                    insert newInsertList;
                }
                if(newUpdateList.size()>0){
                    /*if(newInsertList.size()>0){
                        newUpdateList.addAll(newInsertList) ;
                    }*/
                    update newUpdateList;
                }
            }
            result= 'true';
       /* }
        catch(Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
        }*/
        return result;
    }
}