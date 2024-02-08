public with sharing class BTCloneProject {
    @AuraEnabled
    public static buildertek__Project__c getProjects(String projectId) {
        buildertek__Project__c project = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c,buildertek__Type__c,buildertek__Customer__c,buildertek__Customer_Contact__c, buildertek__Address__c from buildertek__Project__c where Id = :projectId];
        return project;
    }

    public BTCloneProject() {

    }


	// ================== TO Solve "TOO many SOQL : 101", BUIL-3692 & BUIL-3883 =================

        @AuraEnabled
        public static String createRollBackProject(string sourceProjectId, List<String> ObjectList, Boolean roll_back){
            // Savepoint sp = Database.setSavepoint();
            try {

                buildertek__Project__c sourceProject = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c,buildertek__Type__c,buildertek__Customer__c,buildertek__Customer_Contact__c, buildertek__Address__c from buildertek__Project__c where Id = :sourceProjectId];
                buildertek__Project__c clonedProject = new buildertek__Project__c(
                    Name = sourceProject.Name + ' clone',
                    buildertek__Customer__c = sourceProject.buildertek__Customer__c
                );
                insert clonedProject;
                system.debug('rolback project Id : ' + clonedProject.Id);
                
                // Database.rollback(sp);
                return clonedProject.Id;
            } catch (Exception e) {
                // Database.rollback(sp);
                System.debug('Error in cloneChildObj ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                return null;
            }
        }

        @AuraEnabled
        public static string deleteRollbackProject(string rollBackProjectId){
            try {
                buildertek__Project__c rollBackProject = [SELECT Id, Name, buildertek__County__c, buildertek__County_Text__c,buildertek__Type__c,buildertek__Customer__c,buildertek__Customer_Contact__c, buildertek__Address__c from buildertek__Project__c where Id = :rollBackProjectId];
                delete rollBackProject;

                return 'success';
            } catch (Exception e) {
                System.debug('Error in cloneChildObj ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                return null;
            }
        }

        @AuraEnabled
        public static string cloneChildObj(string clonedProjectId, string sourceProjectId, string objName, Boolean roll_back){

            try{
                Set<String> sourceProjectIds = new Set<String>();
                Map<String, String> sourceToProjectMap = new  Map<String, String>();

                sourceProjectIds.add(sourceProjectId);
                sourceToProjectMap.put(sourceProjectId, clonedProjectId);

                string returnValue;

                    if(objName == 'Purchase Order') {
                        returnValue = CloneAny2(objName, 'buildertek__Purchase_Order__c', 'buildertek__Purchase_Order_Item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Schedule') {
                        returnValue =  CloneAny2(objName, 'buildertek__Schedule__c', 'buildertek__Project_Task__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'PunchList') {
                        returnValue =  CloneAny2(objName, 'buildertek__Punch_List__c', 'buildertek__Punch_List_item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Inspections') {
                        returnValue = CloneAny2(objName, 'buildertek__Inspection__c', 'buildertek__Inspection_Line__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Warranty') {
                        returnValue = CloneAny2(objName, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Contract') {
                        returnValue = CloneAny2(objName, 'buildertek__Contract__c', 'buildertek__Contract_Item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Quote') {
                        returnValue = CloneAny2(objName, 'buildertek__Quote__c', 'buildertek__Quote_Item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Budget') {
                        returnValue = CloneAny2(objName, 'buildertek__Budget__c', 'buildertek__Budget_Item__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Selection') {
                        returnValue = CloneAny2(objName, 'buildertek__Selection__c', 'buildertek__Section__c', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    if(objName == 'Project Vendors') {
                        returnValue = CloneAny2(objName, 'buildertek__Project_Vendors__c', '', sourceProjectIds, sourceToProjectMap, roll_back);
                    }

                    return returnValue;
                } catch (Exception e) {
                    System.debug('Error in cloneChildObj ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                    return e.getMessage();
                }
        }

        // To solve - TOO many SOQL query....
        public static String CloneAny2(String objName, String objAPI, String childObjAPI, Set<String> sourceProjectIds, Map<String, String> sourceToProjectMap, Boolean roll_back){
                Savepoint sp = Database.setSavepoint();
            try {
                
                System.debug('CloneAny2 Method');
                System.debug('objName ==> '+objName);
    
        
                // Set<String> sourceProjectIds = ProjectTriggerHandler.sourceProjectIdsSet;
                // Map<String, String> sourceToProjectMap = ProjectTriggerHandler.sourceToProjectIdsMap;
                // Map<String, List<String>> sourceObjectMap = ProjectTriggerHandler.sourceObjectsMap;
                string qryStr = (objName == 'Project Vendors') ? prepareQuery(objAPI, 'buildertek__BT_Project__c', sourceProjectIds) : prepareQuery(objAPI, 'buildertek__Project__c', sourceProjectIds);
        
                List<SObject> sobjListToClone = database.query(qryStr);
        
                // List<SObject> newSobjListToClone = database.query(qryStr);
                // for (SObject sObj : sobjListToClone) {
                //     String oldProjectId = (objName == 'Project Vendors') ? String.valueOf(sObj.get('buildertek__BT_Project__c')) : String.valueOf(sObj.get('buildertek__Project__c'));
                //     if (sourceObjectMap.get(oldProjectId).contains(objName)) {
                //         newSobjListToClone.add(sObj);
                //     }
                // }
        
                Map<String, SObject> cloneSObjList = new Map<String, SObject>();
                for (SObject sObj : sobjListToClone) {
                    String oldProjectId = (objName == 'Project Vendors') ? String.valueOf(sObj.get('buildertek__BT_Project__c')) : String.valueOf(sObj.get('buildertek__Project__c'));
                    SObject obj = sobj.clone(false, true);
        
                    if (objName == 'Project Vendors') {
                        obj.put('buildertek__BT_Project__c', sourceToProjectMap.get(oldProjectId));
                    } else {
                        obj.put('buildertek__Project__c', sourceToProjectMap.get(oldProjectId));
                    }
                    cloneSObjList.put(sobj.Id, obj);
                }
        
                if (objAPI == 'buildertek__Purchase_Order__c'){
                    for (SObject sObj : cloneSObjList.values()){
                        sObj.put('buildertek__Status__c', 'Pending');
                        sObj.put('buildertek__Budget__c', null);
                        sObj.put('buildertek__Budget_Line__c', null);
                    }
                }
        
                if (objAPI == 'buildertek__Warranty__c'){
        
                    Map<String, SObject> warrantyMap = new Map<String, SObject>();
                    Map<String, String> parentMap = new Map<String, String>();
        
                    for (SObject sObj : cloneSObjList.values()){
                        parentMap.put(String.valueOf(sObj.Id), String.valueOf(sObj.get('buildertek__Warranty__c')));
                        sObj.put('buildertek__Warranty__c', null);
        
                        SObject obj = sobj.clone(false, true);
        
                        warrantyMap.put(String.valueOf(sObj.Id), obj);
                    }
                    insert warrantyMap.values();
        
                    Map<String, String> newParentMap = new Map<String, String>();
                    for (String oldRecId : parentMap.keySet()) {
                        if (parentMap.get(oldRecId) != null) {
                            String newRecId = warrantyMap.get(oldRecId).Id;
                            String newParentRecId = warrantyMap.get(parentMap.get(oldRecId)).Id;
                            newParentMap.put(newRecId, newParentRecId);
                        }
                    }
        
                    cloneSObjList = new Map<String, SObject>();
                    for (String warrantyId : warrantyMap.keySet()) {
                        SObject warrantyVal = warrantyMap.get(warrantyId);
                        warrantyVal.put('buildertek__Warranty__c', newParentMap.get(String.valueOf(warrantyVal.Id)));
        
                        cloneSObjList.put(warrantyId, warrantyVal);
                    }
        
                    update cloneSObjList.values();
        
                } else {
        
                    insert cloneSObjList.values();
                }
        
                if (String.isNotBlank(childObjAPI)) {
                    String childQry = prepareQuery(childObjAPI, objAPI, cloneSObjList.keySet());
                    System.debug('childQry ==> '+childQry);
                    List<SObject> childSobjList = database.query(childQry);
                    System.debug('childSobjList ==> '+childSobjList);
        
                    List<SObject> cloneChildRec= new List<SObject>();
        
                    if (childObjAPI == 'buildertek__Project_Task__c') {
        
                        Map<String, String> predecessorMap = new Map<String, String>();
                        Map<String, SObject> scheduleTaskMap = new Map<String, SObject>();
        
                        for (SObject sObj : childSobjList){
                            predecessorMap.put(String.valueOf(sObj.Id), String.valueOf(sObj.get('buildertek__Dependency__c')));
                            sObj.put('buildertek__Dependency__c', null);
        
                            String oldParentId = String.valueOf(sObj.get(objAPI));
                            SObject obj = sobj.clone(false, true);
                            obj.put(objAPI, cloneSObjList.get(oldParentId).Id);
        
                            scheduleTaskMap.put(String.valueOf(sObj.Id), obj);
                        }
        
                        if (scheduleTaskMap.size() > 0) {
                            insert scheduleTaskMap.values();
        
                            Map<String, String> newPredecessorMap = new Map<String, String>();
                            for (String taskId : predecessorMap.keySet()) {
                                if (predecessorMap.get(taskId) != null) {
                                    String newTaskId = scheduleTaskMap.get(taskId).Id;
                                    String newParentId = scheduleTaskMap.get(predecessorMap.get(taskId)).Id;
                                    newPredecessorMap.put(newTaskId, newParentId);
                                }
                            }
        
                            List<SObject> updateTaskList = new List<SObject>();
                            for (SObject task : scheduleTaskMap.values()) {
                                task.put('buildertek__Dependency__c', newPredecessorMap.get(String.valueOf(task.Id)));
                                updateTaskList.add(task);
                            }
        
                            if (updateTaskList.size() > 0) {
                                update updateTaskList;
                            }
                        }
        
                    } else {
        
                        for (SObject sobj : childSobjList){
                            System.debug('sobj ==> '+sobj);
                            String oldParentId = String.valueOf(sObj.get(objAPI));
        
                            SObject obj = sobj.clone(false, true);
                            System.debug('objAPI ==> '+objAPI);
                            System.debug('cloneSObjList.get(oldParentId)) ==> '+cloneSObjList.get(oldParentId));
                            obj.put(objAPI, cloneSObjList.get(oldParentId).Id);
        
                            cloneChildRec.add(obj);
                        }
        
                        System.debug('cloneChildRec ==> '+cloneChildRec);
        
                        if(cloneChildRec.size() > 0){
                            insert cloneChildRec;
                        }
                    }
                }
                if(roll_back == true){
                    Database.rollback(sp);
                }
                return 'success';
            } catch (Exception e) {
                if(roll_back == true){
                    Database.rollback(sp);
                }
                System.debug('Error in CloneAny2 ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                return e.getMessage();
            }
    
        }

        public static List<String> parentRecordList;

        public static String prepareQuery(String sObjName, String fieldName, Set<String> recIdList){

            System.debug('ProjectTriggerHandler -> prepareQuery -> '+sObjName);
    
            Map<String, Schema.SObjectField> fieldsMap = Schema.getGlobalDescribe().get(sObjName.toLowerCase()).getDescribe().Fields.getMap();
            String fields = '';
    
            for (Schema.SObjectField sf : fieldsMap.values()){
                Schema.DescribeFieldResult fr = sf.getDescribe();
                if (fr.isCreateable()){
                    fields += fr.getName()+',';
                }
            }
    
            if (fields.endsWith(',')){
                fields = fields.substring(0, fields.lastIndexOf(','));
            }
    
            parentRecordList = new List<String>();
            for (Id recId : recIdList) {
                parentRecordList.add(recId);
            }
    
            String qryString;
            if (sObjName == 'buildertek__Project_Task__c') {
                qryString = 'SELECT ' + fields + ' , buildertek__Dependency__r.Name FROM ' + sObjName + ' where ' + fieldName + ' IN: parentRecordList';
            }
            else{
                qryString = 'SELECT ' + fields + ' FROM ' + sObjName + ' where ' + fieldName + ' IN: parentRecordList';
            }
    
            return qryString;
        }
    
    



    @AuraEnabled
    public static string getFieldSet(){
        try {
            String ObjectAPI = 'buildertek__Project__c';
            String FieldSetName = 'buildertek__Create_Clone_Project_Field';

            String result = '';
            List<String> pickListValuesList = new List<String>();

            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectAPI);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(FieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(FieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (f.getFieldPath() == 'Name'){
                        jsonPart += ',"readOnly":"' + 'true' + '"';
                    }
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(ObjectAPI, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;

                }
            }
            return '[' + result + ']';
        } catch (Exception e) {
            System.debug('Error in cloneProjectNew ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
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
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }
}