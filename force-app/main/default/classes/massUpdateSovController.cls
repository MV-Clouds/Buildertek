public class massUpdateSovController {
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Schedule_of_Value_Lines__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__Mass_Update_SOV_Lines')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__Mass_Update_SOV_Lines').getFields()){
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
    public static String getRecords(String recordId, String fieldNameJson, Integer pageNumber, Integer pageSize){
        List<buildertek__Schedule_of_Value_Lines__c > lstResult = new List<buildertek__Schedule_of_Value_Lines__c >();
        system.debug('fieldNameJson=====>>>>>>>>>'+fieldNameJson);
        String result = '[]';
        try{
            if (String.isNotBlank(recordId)){
                system.debug('recordId exists'+recordId);
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',');
                
                query += ' FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c=: recordId';
                
                system.debug('query'+query);
                
                for (buildertek__Schedule_of_Value_Lines__c s : Database.query(query)){
                    lstResult.add(s);
                }
                
                
                List<sObject> pageSizeTaskList = new List<sObject>();
                if (lstResult.size() > 0){
                    if(pageSize+offset <= lstResult.Size()){
                        for(Integer j= offset; j< offset+pageSize ; j++){
                            pageSizeTaskList.add(lstResult[j]);
                        }
                    }else if(pageSize+offset > lstResult.Size()){
                        for(Integer j= offset; j<lstResult.Size(); j++){
                            pageSizeTaskList.add(lstResult[j]);
                        }
                    }else{
                        pageSizeTaskList.addAll(lstResult);
                    }
                    
                    //result = JSON.serialize(updatetaskList);
                    result = JSON.serialize(pageSizeTaskList);
                    system.debug('result'+result);
                    return result;
                }
            }
        } catch (Exception e){
            System.debug('Error' + e.getMessage());
            return e.getMessage();
            //throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static Integer getCount(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                system.debug('COunt record:::' + [Select COUNT()
                                                  FROM buildertek__Schedule_of_Value_Lines__c
                                                  WHERE buildertek__Schedule_of_Values__c = :recordId]);
                return [Select COUNT()
                        FROM buildertek__Schedule_of_Value_Lines__c
                        WHERE buildertek__Schedule_of_Values__c = :recordId];
                
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    
    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords, String fieldSetName, Integer pageNumber, Integer pageSize){
        String errorMessage = '';
        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        try{
            if (String.isNotBlank(updatedRecords)){
                List<buildertek__Schedule_of_Value_Lines__c> items = (List<buildertek__Schedule_of_Value_Lines__c>)JSON.deserialize(updatedRecords, List<buildertek__Schedule_of_Value_Lines__c>.class);
                
              
                
                if (items.size() > 0){
                    upsert items;
                }
                for(buildertek__Schedule_of_Value_Lines__c item : items){
                    system.debug(item);
                }
               
                    return getRecords(recordId, fieldSetName, pageNumber, pageSize);
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
    public static String massDeleteProjectTask(List<String> deleteRecordId, String recordId, String fieldSetName, Integer pageNumber, Integer pageSize ){
        try{
            if (deleteRecordId.size() > 0){
                delete [Select Id
                        FROM buildertek__Schedule_of_Value_Lines__c
                        WHERE ID IN :deleteRecordId];
                return getRecords(recordId, fieldSetName, pageNumber, pageSize);
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
      @AuraEnabled
    public static String getSOVName(List<String> deleteRecordId, String recordId ){
        buildertek__Schedule_of_Values__c recordName = [select Id, Name from buildertek__Schedule_of_Values__c where Id =:recordId];
        return recordName .Name;
    }
    
    
     @AuraEnabled 
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    
    @AuraEnabled
    public static String isSovSubmitted(String recordId){
        system.debug(recordId);
        buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id =:recordId];
        system.debug(updateStatus);
        
        return updateStatus.buildertek__Status__c;
    }
    
    
}