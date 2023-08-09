public class ChooseChecklistControllerClass {
  @auraEnabled
  public static List<buildertek__Checklist_Objects__c> getChecklistControllerRecords(){
     List<buildertek__Checklist_Objects__c> checklistObjectlist = [select Id,
                                                                        Name,
                                                                        buildertek__Object_API_Name__c,
                                                                        buildertek__Object_Label__c 
                                                                        from buildertek__Checklist_Objects__c 
                                                                        where Name != 'Checklist Logo' AND Name != 'PreQual Logo'
                                                                        Order by createddate desc];
     return checklistObjectlist;
  }
  @auraEnabled
  public static void deleterecord(string recId){
     buildertek__Checklist_Objects__c bc = [select id,buildertek__Object_API_Name__c,buildertek__Object_Label__c from buildertek__Checklist_Objects__c where id =:recId];
     delete bc;
  }
  @auraEnabled
  public static string saveChecklistControllerRecord(string APIName,string LabelName){
    List<buildertek__Checklist_Objects__c> Checklist = [select id,buildertek__Object_API_Name__c
                                                               from buildertek__Checklist_Objects__c
                                                                where buildertek__Object_API_Name__c =: APIName];
                                                                
      if(Checklist.size()>0){
      string message = 'ERROR';
         return message;
      }else{
             string message = 'SUCCESS';
                   buildertek__Checklist_Objects__c check = new buildertek__Checklist_Objects__c();
                   check.Name = LabelName;
                   check.buildertek__Object_API_Name__c = APIName;
                   check.buildertek__Object_Label__c = LabelName;
                   check.Name = LabelName;
                   insert check;
                   return message;
      }                                                        
      
  }
  @auraEnabled
  public static List<ObjectClass> getObjectName(){
      List<buildertek__Checklist_Objects__c> checklistObjectlist = [select Id,
                                                                        Name,
                                                                        buildertek__Object_API_Name__c,
                                                                        buildertek__Object_Label__c 
                                                                        from buildertek__Checklist_Objects__c 
                                                                        where Name != 'Checklist Logo'
                                                                        Order by createddate desc];
             Map<string,string> Mapstrings = new Map<string,string>();
              for(buildertek__Checklist_Objects__c Objs : checklistObjectlist){
                  Mapstrings.put(Objs.buildertek__Object_API_Name__c,Objs.Id);
              }
            List<String> objects=new List<String>();
            Map<String, String> objectNameMap = new Map<String, String>();
            List<ObjectClass> ObjectClassList = new List<ObjectClass>();
            List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values(); 
            for(SObjectType sot : gd){
                String name = sot.getDescribe().getName();
                if(!name.containsignorecase('history') && !name.containsignorecase('tag')&& !name.containsignorecase('event') &&  sot.getDescribe().isCreateable() &&
                   !name.containsignorecase('share') && !name.containsignorecase('feed') && !sot.getDescribe().isCustomSetting() && sot.getDescribe().getRecordTypeInfos().size() > 0){  
                       objects.add(sot.getDescribe().getName());
                       objects.sort();  
                       objectNameMap.put(sot.getDescribe().getName(), sot.getDescribe().getLabel());
                   }
            }
            for(String objLabel : objects){
                if(Mapstrings.get(objLabel) == null){
                    ObjectClassList.add(new ObjectClass(objLabel,objectNameMap.get(objLabel)));  
                }
            }
            return ObjectClassList;
        }
        public class ObjectClass{
            @AuraEnabled public String objectName;
            @AuraEnabled public String objectLabel;
            public ObjectClass(String objectName, String objectLabel){
                this.objectName = objectName;
                this.objectLabel = objectLabel;
            }
        }
}