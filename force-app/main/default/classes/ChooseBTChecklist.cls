public class ChooseBTChecklist {
    @AuraEnabled
    public static list<buildertek__Checklist_Objects__c> getchecklistObjects(){
        list<buildertek__Checklist_Objects__c> checklistObjects = [select id,
                                                                            Name,
                                                                            buildertek__Object_Label__c,
                                                                            buildertek__Object_API_Name__c
                                                                            from buildertek__Checklist_Objects__c
                                                                            where Name != 'Checklist Logo' And Name != 'PreQual Logo'];
        return checklistObjects;
    }
    
    @AuraEnabled
    public static list<string> getAllGroup( ){
        list<buildertek__Questions__c> Questions = [select id,buildertek__group_name__c
                                                           from buildertek__Questions__c ];
        set<string> groupNames = new set<string>();
        list<string> groupNameList = new list<string>();
        for(buildertek__Questions__c question : Questions){
            if(question.buildertek__group_name__c != '' && question.buildertek__group_name__c != null){
                groupNames.add(question.buildertek__group_name__c);
            }
        }
        for(string groupName : groupNames){
            groupNameList.add(groupName);
        }
        return groupNameList;
    }
    
    @AuraEnabled
    public static list<buildertek__Questions__c> getQuestions(){
        list<buildertek__Questions__c> Questions = [select id,
                                                                            buildertek__Customize__c,
                                                                            buildertek__Options__c,
                                                                            buildertek__Question_Type__c,
                                                                            buildertek__group_name__c
                                                                            from buildertek__Questions__c   ];
        return Questions;
    }
      @AuraEnabled
    public static list<buildertek__Questions__c> getQuestion(list<String> QuestionIds){
        system.debug('QuestionIds.......'+QuestionIds);
        list<buildertek__Questions__c> Questionlist = [select id,
                                                                            buildertek__Customize__c,
                                                                            buildertek__Options__c,
                                                                            buildertek__Question_Type__c,
                                                                            buildertek__group_name__c
                                                                            from buildertek__Questions__c   WHERE Id IN: QuestionIds ];
          system.debug(Questionlist);                                                                  
        return Questionlist;
    }
    
    @AuraEnabled
    public static buildertek__Questions__c createQuestions(string type,string QuestionName,string Options){
        buildertek__Questions__c Questions = new buildertek__Questions__c();
        Questions.buildertek__Customize__c = QuestionName;
        Questions.buildertek__Options__c = Options;
        Questions.buildertek__Question_Type__c = type;
        insert Questions;
        
        buildertek__Questions__c NewQuestions = [select id, 
                                                        buildertek__Customize__c, 
                                                        buildertek__Options__c,
                                                        buildertek__Question_Type__c
                                                       from buildertek__Questions__c where id=: Questions.id];
        return NewQuestions;
    }
    
      @AuraEnabled
    public static Map<String, List<String>> getPickValues(String objectName, String fieldName) {      
        List<String> fieldNames = fieldName.split(',');
        
        Map<String, List<String>> nameToValueMap = new Map<String, List<String>>();
        for(String s : fieldNames){
            Schema.sObjectType sobject_type = Schema.getGlobalDescribe().get(objectName); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
            List<Schema.PicklistEntry> pick_list_values = field_map.get(s).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
            List<String> options = new List<String>(); //new list for holding all of the picklist options
            for(Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list       
                options.add(a.getValue()); //add the value and label to our final list
            }
            nameToValueMap.put(s, options);
        }
            return nameToValueMap; //return the List
    }
    
   @AuraEnabled
    public static buildertek__Questions__c saveQuestion(string QuestionType,string QuestionText,string Options,string groupname,string selectedgroup,string recordid){
        buildertek__Questions__c qt = new buildertek__Questions__c();
        qt.ID= recordid;
        qt.buildertek__Question_Type__c = QuestionType;
        qt.buildertek__Customize__c =  QuestionText;
        qt.buildertek__Options__c = Options;
        if(selectedgroup != null && selectedgroup != ''){
            qt.buildertek__group_name__c = selectedgroup;
        }
        else{
            qt.buildertek__group_name__c = groupname;
        }
        insert qt;
        //upsert qt;
         buildertek__Questions__c NewQuestions = [select id, 
                                                        buildertek__Customize__c, 
                                                        buildertek__Options__c,
                                                        buildertek__Question_Type__c,
                                                        buildertek__group_name__c
                                                       from buildertek__Questions__c where id=: qt.id];
        return NewQuestions;
       // system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'+qt);
    }
     @AuraEnabled
    public static buildertek__Questions__c savingQuestion(string QuestionType,string QuestionText,string Options,string groupname,string selectedgroup,string recordid){
        buildertek__Questions__c qt = new buildertek__Questions__c();
        qt.ID= recordid;
        qt.buildertek__Question_Type__c = QuestionType;
        qt.buildertek__Customize__c =  QuestionText;
        qt.buildertek__Options__c = Options;
        if(selectedgroup != null && selectedgroup != ''){
            qt.buildertek__group_name__c = selectedgroup;
        }
        else{
            qt.buildertek__group_name__c = groupname;
        }
       // insert qt;
        upsert qt;
         buildertek__Questions__c NewQuestions = [select id, 
                                                        buildertek__Customize__c, 
                                                        buildertek__Options__c,
                                                        buildertek__Question_Type__c
                                                       from buildertek__Questions__c where id=: qt.id];
        return NewQuestions;
       // system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'+qt);
    }
      @AuraEnabled
    public static buildertek__Questions__c saveQuestions(string QuestionType,string QuestionText,string Options,string groupname,string selectedgroup,string recordid){
        buildertek__Questions__c qt = new buildertek__Questions__c();
        qt.ID= recordid;
        qt.buildertek__Question_Type__c = QuestionType;
        qt.buildertek__Customize__c =  QuestionText;
        qt.buildertek__Options__c = Options;
        if(selectedgroup != null && selectedgroup != ''){
            qt.buildertek__group_name__c = selectedgroup;
        }
        else{
            qt.buildertek__group_name__c = groupname;
        }
       // insert qt;
        upsert qt;
         buildertek__Questions__c NewQuestions = [select id, 
                                                        buildertek__Customize__c, 
                                                        buildertek__Options__c,
                                                        buildertek__Question_Type__c
                                                       from buildertek__Questions__c where id=: qt.id];
        return NewQuestions;
       // system.debug('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%'+qt);
    }
    
     @AuraEnabled
    public static string ChecklistConfiguration(List<string> QuestionIds,string Name,string SelectedObject,string recordId){
        try{
            system.debug(' SelectedObject ' + SelectedObject);
            createlookup(SelectedObject);
            List<buildertek__Checklist_Questions__c> bcqList = new List<buildertek__Checklist_Questions__c>();
            buildertek__Checklist_Configuration__c bcc = new buildertek__Checklist_Configuration__c();
            bcc.Name = Name;
            bcc.buildertek__Object_Name__c = SelectedObject;
            if(recordId != null && recordId !=''){
                bcc.Id = Id.valueOf(recordId);
            }
            upsert bcc;
            if(recordId != null && recordId !=''){
            list<buildertek__Checklist_Questions__c> questionlist = [select id from buildertek__Checklist_Questions__c where buildertek__Checklist_Configuration__c=: bcc.Id];
            delete questionlist;
            }
            //List<buildertek__Questions__c> questionsList = [SELECT Id,];
            
            
            
            
            for(string id:QuestionIds){
                system.debug(id);
                buildertek__Checklist_Questions__c bcq = new buildertek__Checklist_Questions__c();
                bcq.buildertek__Checklist_Configuration__c   = bcc.id;
                bcq.buildertek__Questions__c = id;
                bcqList.add(bcq);
            }
            if(!bcqList.isEmpty()){
                insert bcqList;
            }
            
            
            return 'Success';
       }
        catch(Exception e){
            return e.getMessage();
        }  
    }
    @future(callout=true)
    public static void createlookup(string objectname){
    system.debug('@@@@@ create lookup called');
         //String objectname = Id.valueof(recordId).getSObjectType().getDescribe().getName();
         MetadataService.MetadataPort service1 = new MetadataService.MetadataPort();
          service1.SessionHeader = new MetadataService.SessionHeader_element();
      service1.SessionHeader.sessionId = getSessionIdFromVFPage(Page.SessionId_VF); 
         
       MetadataService.MetadataPort service = service1;
        MetadataService.CustomField customField = new MetadataService.CustomField();
         system.debug('objectname **** ' + objectname);
        string referenceobject = objectname;
        
        if(objectname.contains('__c')){
            objectname = objectname.replace('__c','');
        }
        if(objectname.contains('__')){
            string[] obj = objectname.split('__'); 
            objectname = obj[1];
        }
        String fieldname=objectname;
        if(fieldname.equalsIgnoreCase('__c')){
            customField.fullName = 'buildertek__Checklist_Response__c.'+objectname.subString(0,objectname.length()-3)+'Checklist__c';
            customField.label = objectname.subString(0,objectname.length()-3) + ' Checklist';
            customField.relationshipLabel = objectname.subString(0,objectname.length()-3)+'Checklist';
            customField.relationshipName = objectname.subString(0,objectname.length()-3)+'Checklist';
        }else{
            customField.fullName = 'buildertek__Checklist_Response__c.'+objectname+'Checklist__c';
            //customField.label = 'Lookup'+objectname;
            customField.label = objectname + ' Checklist';
            customField.relationshipLabel = objectname+' Checklist';
            customField.relationshipName = objectname+ 'Checklist';
        }
        
       
        customField.type_x = 'Lookup';
        system.debug('referenceobject **** ' + referenceobject);
        customField.referenceTo = referenceobject;
        if(!Test.isRunningtest()){
        List<MetadataService.SaveResult> results =
            service.createMetadata(
                new MetadataService.Metadata[] { customField });
        
        
        MetadataService.Profile admin = new MetadataService.Profile();
        admin.fullName = 'Admin';
        admin.custom = false;
        MetadataService.ProfileFieldLevelSecurity fieldSec = new MetadataService.ProfileFieldLevelSecurity();
        if(fieldname.equalsIgnoreCase('__c')){
            if(objectname.contains('__')){

            }
            fieldSec.field='buildertek__Checklist_Response__c.'+objectname.subString(0,objectname.length()-3)+'Checklist__c';
        }else{
            fieldSec.field='buildertek__Checklist_Response__c.'+objectname+'Checklist__c';
        }
        fieldSec.editable=true;
        admin.fieldPermissions  = new MetadataService.ProfileFieldLevelSecurity[] {fieldSec} ;
        List<MetadataService.SaveResult> resultsPermissions =
            service.updateMetadata(
                new MetadataService.Metadata[] { admin });
                 system.debug('results'+results);
                 system.debug(fieldSec);
        }
        system.debug(customField);
       
        
        }
    

    public static String getSessionIdFromVFPage(PageReference visualforcePage){
        if(Test.isRunningTest()) {
            return null;
        }else{
        String content = visualforcePage.getContent().toString();
        Integer s = content.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length(),
                e = content.indexOf('End_Of_Session_Id');
        return content.substring(s, e);
        }
    }
    
     @AuraEnabled
    public static List<buildertek__Checklist_Configuration__c > getCheckListCofigRecords(){
         List<buildertek__Checklist_Configuration__c> CheckListCofigRecordsList = [select id,buildertek__Object_Name__c,Name,Createddate from buildertek__Checklist_Configuration__c order by createddate desc];
         return CheckListCofigRecordsList;
    }
    
    @AuraEnabled
    public static buildertek__Checklist_Configuration__c geteditRecord(string recId){
    
        buildertek__Checklist_Configuration__c CheckListCofigRecord = [select id,
    buildertek__Object_Name__c,
Name,(select id,buildertek__Questions__r.Id,buildertek__Questions__r.buildertek__Customize__c from buildertek__Checklist_Questions__r) 
from buildertek__Checklist_Configuration__c 
where id=:recId];
         //update CheckListCofigRecord;
        return CheckListCofigRecord;
       
    }
     @AuraEnabled
      public static buildertek__Questions__c editRecord(string recId){
       getAllGroup();
         buildertek__Questions__c Questions = [select id,
                                                                            buildertek__Customize__c,
                                                                            buildertek__Options__c,
                                                                            buildertek__Question_Type__c,
                                                                            buildertek__group_name__c
                                                                            from buildertek__Questions__c where id=:recId];
    
      
        return Questions;
       
    }
    
    @AuraEnabled
    public static void getDeleteRecord(string recId){
    List<buildertek__Checklist_Configuration__c> bcc = [select id from buildertek__Checklist_Configuration__c where id=:recId];
    
    if(bcc.size()>0){
       delete bcc;
    }
          //buildertek__Checklist_Configuration__c CheckListCofigRecord = [select id,];
         /* buildertek__Checklist_Configuration__c bcc = new buildertek__Checklist_Configuration__c();
          bcc.id = recId;
          delete bcc;*/
    }
     @AuraEnabled
    public static void getDeleteQuestion(string recId){
        system.debug('recId'+recId);
        List<buildertek__Questions__c> BcList = [select id from buildertek__Questions__c where id=:recId];
        system.debug('BcList'+BcList);
        if(BcList.size()>0){
        delete BcList;
        }
          //buildertek__Checklist_Configuration__c CheckListCofigRecord = [select id,];
         /* buildertek__Questions__c bcc = new buildertek__Questions__c();
          bcc.id = recId;
          delete bcc;*/
    }
   
}