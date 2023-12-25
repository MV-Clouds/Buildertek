public with sharing class NewTakeOffComponentController {
    
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
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }
            
        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
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

    public class masterTakeOffWrapper{
        @AuraEnabled
        public  List<buildertek__Project_Takeoff__c> TakeOffList;
        @AuraEnabled
        public Integer totalTakeOffs;
    }

    @AuraEnabled
    public static masterTakeOffWrapper getAllMasterTakeOff(Integer recordLimit, Integer recordOffset){
        masterTakeOffWrapper  masterTakeOffWrapperRecords= new masterTakeOffWrapper();
        masterTakeOffWrapperRecords.TakeOffList= new List<buildertek__Project_Takeoff__c>();
        masterTakeOffWrapperRecords.TakeOffList=[SELECT Id, Name, buildertek__Status__c, buildertek__Name__c,buildertek__Description__c, buildertek__Type__c  From buildertek__Project_Takeoff__c WHERE buildertek__Type__c = 'Master' ORDER BY Name ASC LIMIT :recordLimit Offset :recordOffset ];
       
       
        AggregateResult results = [SELECT Count(Id) TotalTakeOffs  From buildertek__Project_Takeoff__c WHERE buildertek__Type__c = 'Master' ];
        Integer totalTakeOffsRec = (Integer)results.get('TotalTakeOffs');

        masterTakeOffWrapperRecords.totalTakeOffs=totalTakeOffsRec;
        return masterTakeOffWrapperRecords;
    }

    @AuraEnabled
    public static string saveRecord(String data , String masterTakeOffId){
        buildertek__Project_Takeoff__c TakeOffToInsert = (buildertek__Project_Takeoff__c)JSON.deserialize(data, buildertek__Project_Takeoff__c.class);
        insert TakeOffToInsert;

        if(masterTakeOffId !=null && TakeOffToInsert.Id !=null){
            // NewTakeOffComponentController.cloneTakeOffSection(TakeOffToInsert.Id , masterTakeOffId);
            NewTakeOffComponentController.cloneTakeOffLines(TakeOffToInsert.Id , masterTakeOffId);
        }
        return TakeOffToInsert.ID;
    }

    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }

    public static void cloneTakeOffLines(String TakeOffId , String masterTakeOffId){
        Set<String> SobjectFields = Schema.getGlobalDescribe().get('buildertek__Project_Takeoff_Lines__c').getDescribe().fields.getMap().keySet();  
        List<String> fieldsInList = new List<String>(SobjectFields);
        String query = 'SELECT ' + String.join(fieldsInList, ',') + ' FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c=:masterTakeOffId'; 
        System.debug(query);
        List<buildertek__Project_Takeoff_Lines__c> TakeOffItemList = Database.query(query);
        list<buildertek__Project_Takeoff_Lines__c> newTakeOffItemList= new List<buildertek__Project_Takeoff_Lines__c>();
        for(buildertek__Project_Takeoff_Lines__c TakeOffItem:TakeOffItemList){

            buildertek__Project_Takeoff_Lines__c newTakeOffItemRec=TakeOffItem.clone(false, false, false, false);
            newTakeOffItemRec.buildertek__Project_Takeoff__c=TakeOffId;
            newTakeOffItemList.add(newTakeOffItemRec);
        
        }
        if(newTakeOffItemList.size() >0){

            insert newTakeOffItemList;
        }
    
    }

    // public static void cloneTakeOffSection(String TakeOffId , String masterTakeOffId){

    //     buildertek__Project_Takeoff__c TakeOffList=[SELECT Id,buildertek__Build_Phase__c, buildertek__Community__c, buildertek__Description__c, buildertek__Linear_Feet__c, buildertek__Number_of_TakeOff_Lines__c, buildertek__Plan_Type__c , buildertek__SFQT_L_W__c, buildertek__SQFT_LH__c FROM buildertek__Project_Takeoff__c WHERE Id=:masterTakeOffId LIMIT 1 ];

    //     buildertek__Project_Takeoff__c TakeOffRec= TakeOffList.clone(false, false, false, false);
    //     TakeOffRec.Id=TakeOffId;
    //     update TakeOffRec;    
    // }

}