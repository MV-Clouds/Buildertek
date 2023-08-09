public class NewScheduleOverride{
    @AuraEnabled
    public static TypeAndManagerId getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();
        buildertek__Project__c[] projectRecord = [select Id, buildertek__Project_Manager__c
                                                  from buildertek__Project__c
                                                  where Id = :recordId];
        TypeAndManagerId getResult = new TypeAndManagerId();
        if (!projectRecord.isEmpty()){
            if (projectRecord[0].buildertek__Project_Manager__c != null){
                getResult.sobjectType = sObjName;
                getResult.projectManagerId = projectRecord[0].buildertek__Project_Manager__c;
                return getResult;
            } else{
                getResult.sobjectType = sObjName;
                getResult.projectManagerId = 'Error';
                return getResult;
            }
        } else{
            getResult.sobjectType = sObjName;
            getResult.projectManagerId = 'Error';
            return getResult;
        }
        //   return sObjName;
    }

    public class TypeAndManagerId{
        @AuraEnabled
        public string sobjectType;
        @AuraEnabled
        public string projectManagerId;
    }

    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(fieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel() + '",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired()) + '",';
                    jsonPart += '"type":"' + (f.getType()) + '",';
                    jsonPart += '"name":"' + f.getFieldPath() + '"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }

        } catch (Exception e){
            result += e.getLineNumber() + ' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
        }
        return '[' + result + ']';
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
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';
        list<User> userRec = Database.query(strQry);
        if (userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return userRec[0];
    }

    /* @AuraEnabled
     public buildertek__Schedule__c sch { get; set; }

     public List<Schema.FieldSetMember> getFields() {
     return SObjectType.buildertek__Schedule__c.FieldSets.buildertek__NewScheduleOverride.getFields();
     }*/
    @AuraEnabled
    Public static string insertSchedule(buildertek__Schedule__c schObj){
        insert schObj;
        return schObj.Id;
    }

    @AuraEnabled
    public static list<buildertek__Schedule__c> fetchScheduleList(){

        return [select id, Name, buildertek__Type__c, buildertek__Total_Duration__c, buildertek__Description__c
                from buildertek__Schedule__c
                where buildertek__Type__c = 'Master'];
    }

    @AuraEnabled
    public static list<buildertek__Project_Task__c> getScheduleItemList(String masterId){
        string mId = masterId;
        return [select id, Name, buildertek__Start__c, buildertek__Phase__c, buildertek__Schedule__c, buildertek__Budget__c, buildertek__Budget_Line__c, buildertek__Completed__c, buildertek__Completion__c, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Cost_Code__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Last_Saved_End_Date__c, buildertek__Last_Saved_Start_Date__c, buildertek__Material_Ordered__c, buildertek__Material_Received__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Payable_Task__c, buildertek__Project__c
                from buildertek__Project_Task__c
                where buildertek__Schedule__c = :mId
                order by createdDate];
    }

    @AuraEnabled
    public static String newSchedule(String newScheduleId, List<String> masterId){
        /*string SchId = newScheduleId;
         Date initialDate = [select Id,buildertek__Initial_Start_Date__c from buildertek__Schedule__c where id =:SchId].buildertek__Initial_Start_Date__c;
         system.debug('initialDate'+initialDate);
         List<buildertek__Project_Task__c > itemList = new List<buildertek__Project_Task__c >();

         system.debug('masterSchItems--->'+masterSchItems);

         for (Integer i = 0; i < masterSchItems.size(); i++) {
         buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
         //schItem.buildertek__Start__c = masterSchItems[i].buildertek__Start__c;
         system.debug('schItem.buildertek__Start__c'+schItem.buildertek__Start__c);
         if (i == 0) {
         schItem.buildertek__Start__c = initialDate;
         system.debug('startdate inside if'+schItem.buildertek__Start__c);
         }else{
         schItem.buildertek__Start__c = masterSchItems[i].buildertek__Start__c;
         }
         schItem.buildertek__Schedule__c = Id.valueOf(SchId);
         system.debug('masterSchItems[i].buildertek__Phase__c;'+masterSchItems[i].buildertek__Phase__c);
         schItem.buildertek__Phase__c = masterSchItems[i].buildertek__Phase__c;
         schItem.Name = masterSchItems[i].Name;
         //buildertek__Dependency__c
         schItem.buildertek__Duration__c =  masterSchItems[i].buildertek__Duration__c;
         schItem.buildertek__Lag__c =  masterSchItems[i].buildertek__Lag__c;
         itemList.add(schItem);
         }

         insert itemList;
         system.debug('afterfor insert'+itemList);*/

        // ImportScheduleLinesController createScheduleItems = new ImportScheduleLinesController();
        system.debug(newScheduleId + ' ' + masterId);
        if (masterId != null){
            /*  Date initialDate = [select Id,buildertek__Initial_Start_Date__c from buildertek__Schedule__c where id =:newScheduleId].buildertek__Initial_Start_Date__c;
             String projectManagerId =  [select Id,buildertek__Project_Manager__c from buildertek__Schedule__c where id =:newScheduleId].buildertek__Project_Manager__c; */
            Date initialDate;
            String projectManagerId;
            List<buildertek__Schedule__c> schedulesRecord = [select Id, buildertek__Project_Manager__c, buildertek__Initial_Start_Date__c
                                                             from buildertek__Schedule__c
                                                             where id = :newScheduleId];
            if (schedulesRecord.size() > 0){
                initialDate = schedulesRecord[0].buildertek__Initial_Start_Date__c;
                projectManagerId = schedulesRecord[0].buildertek__Project_Manager__c;
            }
            Boolean fromNewSchedule = true;
            ProjectTaskTriggerHandler.isFromImport = true;
            ImportMasterSchedules.importMasterScheduleLines(masterId, newScheduleId, initialDate, projectManagerId);
        }

        return 'null';
    }

    @AuraEnabled
    public static List<ListView> getListViews(){
        List<ListView> listviews = [SELECT Id, Name
                                    FROM ListView
                                    WHERE SobjectType = 'buildertek__Schedule__c' and Name = 'All'];

        // Perform isAccessible() check here
        return listviews;
    }

    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public string Message{ get; set; }

    }

    /* @Author        Hemanth ch
     * Date               1-8-22
     * Description :  This method is used to get Project Manager field in Project Object.
     * Ticket         :  BUIL - 2617
     */
    @AuraEnabled
    public static String getProjectManager(String recordId){
        buildertek__Project__c[] projectRecord = [select Id, buildertek__Project_Manager__c
                                                  from buildertek__Project__c
                                                  where Id = :recordId];
        if (!projectRecord.isEmpty()){
            if (projectRecord[0].buildertek__Project_Manager__c != null){
                return projectRecord[0].buildertek__Project_Manager__c;
            } else{
                return 'Error';
            }
        } else{
            return 'Error';
        }
    }

}