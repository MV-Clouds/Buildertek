public without sharing class checkListQuestionsCtrl { 
    @auraEnabled
   public static string getAttachmentData(){
       buildertek__Checklist_Objects__c checkobj = [select id,Name from buildertek__Checklist_Objects__c where Name = 'Checklist Logo'];
       Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
       return Att.id; 
   }
    @auraEnabled
    public static string getProjectName(String Ids){
        
        if(Id.valueof(Ids).getSObjectType().getDescribe().getName() == 'buildertek__Project__c'){
        buildertek__Project__c checkobj = [select id,Name,buildertek__Account__r.Name from buildertek__Project__c where id =: Ids];
        if(checkobj.buildertek__Account__r.Name != null && checkobj.buildertek__Account__r.Name != ''){
            String proAccName = checkobj.Name+'-'+ checkobj.buildertek__Account__r.Name;
            return proAccName;
        }
        else{
            String proAccName = checkobj.Name;
            return proAccName;
        }
        }
        else if(Id.valueof(Ids).getSObjectType().getDescribe().getName() == 'Contact'){
        
          Contact checkobj = [select id,Name,Account.Name from Contact where id =: Ids];
        if(checkobj.Account.Name != null && checkobj.Account.Name != ''){
            String proAccName = checkobj.Name+'-'+ checkobj.Account.Name;
            return proAccName;
        }
        else{
            String proAccName = checkobj.Name;
            return proAccName;
        }
        
        }
        
         else if(Id.valueof(Ids).getSObjectType().getDescribe().getName() == 'buildertek__Quote__c'){
        
          buildertek__Quote__c checkobj = [select id,Name,buildertek__Project__r.Id from buildertek__Quote__c where id =: Ids];
          if(checkobj.buildertek__Project__r.Id != null){
         buildertek__Project__c checkobj2 = [select id,Name,buildertek__Account__r.Name from buildertek__Project__c where id =: checkobj.buildertek__Project__r.Id];
           if(checkobj2.buildertek__Account__r.Name != null && checkobj2.buildertek__Account__r.Name != ''){
            String proAccName = checkobj.Name+'-'+ checkobj2.buildertek__Account__r.Name;
            return proAccName;
        }
        else{
            String proAccName = checkobj.Name;
            return proAccName;
        }
          }
          else{
             return checkobj.Name;
        }
        }
        else if(Id.valueof(Ids).getSObjectType().getDescribe().getName() == 'Account'){
            Account acc = [select Name from Account where id =: Ids];
            String proAccName = acc.Name;
            return proAccName;
        }
        else{
            return 'error';
        }
      
      
   }
    
      @auraEnabled
    public static string getAccountName(String Ids){
    
        Contact checkobj = [select id,Name,Account.Name from Contact where id =: Ids];
        if(checkobj.Account.Name != null && checkobj.Account.Name != ''){
            String proAccName = checkobj.Name+'-'+ checkobj.Account.Name;
            return proAccName;
        }
        else{
            String proAccName = checkobj.Name;
            return proAccName;
        }
      
      
   }
   @AuraEnabled
    public Static String getsubject(String recordId){
        string subject = '';
        String objectAPIName = Id.valueof(recordId).getSObjectType().getDescribe().getName();
        if (objectAPIName == 'buildertek__Quote__c'){
            buildertek__Quote__c quoteRec = [select id, Name from buildertek__Quote__c where Id =: recordId]; 
            subject = quoteRec.Name;
        }else if (objectAPIName == 'buildertek__Project__c'){
            buildertek__Project__c projectRec = [select id, Name from buildertek__Project__c where Id =: recordId];
            subject = projectRec.Name;
        }else if (objectAPIName == 'Contact'){
            Contact contractRec = [select id, Name from Contact where Id =: recordId];
            subject = contractRec.Name;
        }else{
            subject = '';
        }
        return subject;
    }
   @auraEnabled 
   public static List<ObjectClass> getCheckListConfigurationData(string recordId){
       String objectname = Id.valueof(recordId).getSObjectType().getDescribe().getName();
              system.debug(objectname);
             
       List<Schema.DescribeSObjectResult> describeSobjectsResult = Schema.describeSObjects(new List<String>{objectname}); 
        String objectLabel = describeSobjectsResult[0].getLabel();
        system.debug('objectLabel'+objectLabel);
       
      
      
       //Map<string,string> ConfigNameIdMap = new Map<string,string>();
       List<ObjectClass> objList = new List<ObjectClass>();
       List<buildertek__Checklist_Configuration__c> checkListQuestionslist = [select id,Name,buildertek__Object_Name__c from buildertek__Checklist_Configuration__c where buildertek__Object_Name__c=: objectname];
         system.debug(checkListQuestionslist);
         if(checkListQuestionslist.size()>0){
       for(buildertek__Checklist_Configuration__c bcc : checkListQuestionslist){
           ObjectClass obj = new ObjectClass();
           obj.Id = bcc.Id;
           obj.Name =bcc.Name;
           obj.ObjectName = objectname ;
           system.debug(objectname);
           obj.ObjectLabel = objectLabel;
           objList.add(obj);
       }
    }
       system.debug('objList'+objList);
       return objList;
   }
   
  
   public class ObjectClass{
           @AuraEnabled public String Id;
           @AuraEnabled public String Name;
           @AuraEnabled public String ObjectName;
           @AuraEnabled public String ObjectLabel;

}
    @AuraEnabled 
    public static string getvalues(string CheckQuestionIds, string sub){
        system.debug('CheckQuestionIds'+CheckQuestionIds);
        system.debug('sub'+sub);
        
       List<buildertek__Checklist_Questions__c> questionLists = [select id,Name,
                                                                  buildertek__Questions__c,
                                                                  buildertek__Checklist_Configuration__r.Name
                                                                  //buildertek__Questions__r.Name,
                                                                  //buildertek__Questions__r.buildertek__Options__c,
                                                                  //buildertek__Questions__r.buildertek__group_name__c,
                                                                 //buildertek__Questions__r.buildertek__Customize__c,
                                                                 // buildertek__Questions__r.buildertek__Question_Type__c
                                                                  from buildertek__Checklist_Questions__c 
                                                                  where buildertek__Checklist_Configuration__c =:CheckQuestionIds];
       return sub + ': ' + questionLists[0].buildertek__Checklist_Configuration__r.Name;
        //return  questionLists[0].buildertek__Checklist_Configuration__r.Name;
    }
    @AuraEnabled 
    public static string signaturetext(){
        String sign='';
         List<buildertek__Check_List_Settings__c> sitesUrl = [SELECT Id,buildertek__Signature__c FROM buildertek__Check_List_Settings__c limit 1];
        if(sitesUrl[0].buildertek__Signature__c != null){
      sign = '\n'+'\n'+'\n'+'\n'+'\n'+'\n'+sitesUrl[0].buildertek__Signature__c;
        }
         return sign ; 
        
       //return sitesUrl[0].buildertek__Signature__c;
    }

   @AuraEnabled
   public static List<groupinnerclass> getQuestions(string CheckQuestionId){
    system.debug('CheckQuestionId'+CheckQuestionId);
    List<string> questionIds = new List<string>();
      List<buildertek__Checklist_Questions__c> questionList = [select id,
                                                                       buildertek__Questions__c,
                                                                       
                                                                       buildertek__Questions__r.buildertek__Options__c,
                                                                       buildertek__Questions__r.buildertek__group_name__c,
                                                                       buildertek__Questions__r.buildertek__Customize__c,
                                                                       buildertek__Questions__r.buildertek__Question_Type__c
                                                                       from buildertek__Checklist_Questions__c 
                                                                       where buildertek__Checklist_Configuration__c =:CheckQuestionId
                                                                        ORDER BY buildertek__Questions__r.buildertek__group_name__c ASC NULLS LAST];
       
       Map<String, List<buildertek__Checklist_Questions__c>> qustMap = new Map<String, List<buildertek__Checklist_Questions__c>>();
           for(buildertek__Checklist_Questions__c Ques : questionList){
               if(qustMap.get(ques.buildertek__Questions__r.buildertek__group_name__c) == null){
                   qustMap.put(ques.buildertek__Questions__r.buildertek__group_name__c,new list<buildertek__Checklist_Questions__c>());
               }
               qustMap.get(ques.buildertek__Questions__r.buildertek__group_name__c).add(Ques);
           }
       list<groupinnerclass> groupinnerclasslist = new list<groupinnerclass>();
       for(string groupname : qustMap.keyset()){
           groupinnerclass groupinnerclassrec = new groupinnerclass();
            groupinnerclassrec.GroupName = groupname ;
            list<QuestionsInnerclass> QuestionsInnerclasslist = new list<QuestionsInnerclass>();
            for(buildertek__Checklist_Questions__c Ques : qustMap.get(groupname)){
               QuestionsInnerclass QuestionsInnerclassrec = new QuestionsInnerclass();
               QuestionsInnerclassrec.QuestionId = Ques.buildertek__Questions__c;
               QuestionsInnerclassrec.QuestionName = Ques.buildertek__Questions__r.buildertek__Customize__c;
               QuestionsInnerclassrec.QuestionType = Ques.buildertek__Questions__r.buildertek__Question_Type__c;
               if(Ques.buildertek__Questions__r.buildertek__Options__c != null && Ques.buildertek__Questions__r.buildertek__Options__c != ''){
               Ques.buildertek__Questions__r.buildertek__Options__c = Ques.buildertek__Questions__r.buildertek__Options__c.replace('#$#','##st##');
                   string[] questionseperatelist = Ques.buildertek__Questions__r.buildertek__Options__c.split('##st##');
                   list<QuestionOption> QuestionOptionlist = new list<QuestionOption>();
                   for(string str : questionseperatelist){
                       QuestionOption QuestionOptionrec = new QuestionOption();
                       QuestionOptionrec.label = str;
                       QuestionOptionrec.value = str;
                       QuestionOptionlist.add(QuestionOptionrec);
                   }
                  QuestionsInnerclassrec.QuestionOptions = QuestionOptionlist;
               }
               
               QuestionsInnerclasslist.add(QuestionsInnerclassrec);
           }
            groupinnerclassrec.QuestionsInnerclasslist = QuestionsInnerclasslist;
            groupinnerclasslist.add(groupinnerclassrec);
       }
      
      return groupinnerclasslist;
   }
   
   @AuraEnabled
   public static string createchecklistquestion(string QuestionString,string recordId,string checkName){
      try{
          
           String objectname = Id.valueof(recordId).getSObjectType().getDescribe().getName();
           system.debug(objectname);
          system.debug(QuestionString);
           if(objectname.contains('__c')){
               objectname = objectname.replace('__c','');
           }
           if(objectname.contains('__')){
               string[] obj = objectname.split('__'); 
               objectname = obj[1];
           }
           list<groupinnerclass> QuestionsInner = (list<groupinnerclass>)System.JSON.deserialize(QuestionString,list<groupinnerclass>.class);
           buildertek__Checklist_Response__c checklistresponse = new buildertek__Checklist_Response__c();
           checklistresponse.buildertek__Submitted_Date__c = System.Now();
           checklistresponse.buildertek__Checklist_Name__c = checkName;
           String fieldname=objectname;
          if(!Test.isRunningTest()){
               checklistresponse.put(objectname +'Checklist__c',recordId);   
          }
          system.debug(QuestionsInner);
            system.debug(objectname +'Checklist__c');
           insert checklistresponse;
           
           list<buildertek__Questionnaire__c> Questionnairelist = new list<buildertek__Questionnaire__c>();
           List<string> questionList = new List<string>();
           Map<string,string> questionMap = new Map<string,string>();
           List<buildertek__Questions__c> bclist;
           
            for(groupinnerclass groups : QuestionsInner){
                for(QuestionsInnerclass Ques : groups.QuestionsInnerclasslist){
                    questionList.add(Ques.QuestionId);
                }
            }
           if(!questionList.isEmpty()){
                 bclist= [select id,buildertek__Customize__c from buildertek__Questions__c where id IN:questionList];
           }
           
           for(buildertek__Questions__c b :bclist){
               questionMap.put(b.id,b.buildertek__Customize__c);
           }
           for(groupinnerclass groups : QuestionsInner){
                for(QuestionsInnerclass Ques : groups.QuestionsInnerclasslist){
                   buildertek__Questionnaire__c Questionnaire= new buildertek__Questionnaire__c();
                   Questionnaire.buildertek__Questions__c = Ques.QuestionId;
                   Questionnaire.buildertek__Checklist_Response__c = checklistresponse.Id;
                   if(bclist.size()>0){
                   Questionnaire.buildertek__QuestionireQuestion__c  = questionMap.get(Ques.QuestionId);
                   }
                   if(Ques.QuestionType != 'Multi Select Answer'){
                       Questionnaire.buildertek__Answer__c = Ques.QuestionValue;
                   }
                   else{
                       if(Ques.QuestionValues == null){
                          Questionnaire.buildertek__Answer__c = ''; 
                       }else{
                          Questionnaire.buildertek__Answer__c = ''+Ques.QuestionValues; 
                       }
                       
                   }
                   Questionnairelist.add(Questionnaire);
               }
           }
           insert Questionnairelist;
           return 'Success';
      }
       catch(Exception e){
       system.debug(e.getMessage());
           system.debug('@!@!@'+e.getLineNumber());
           return e.getMessage()+e.getLineNumber();
           
       }
   }
   
   @AuraEnabled
   public static string sendchecklist(string checklistId,Id recordId,string Email,string FieldName,Boolean isparent,string parentObj,string recipient,string text,string subject,string contactEmail,string selectCheckListName){
   system.debug('Email'+Email);
   system.debug('FieldName'+FieldName);
   system.debug('isparent'+isparent);
   system.debug('parentObj'+parentObj);
   system.debug('checklistId'+checklistId);
        system.debug('recordId'+recordId);
       system.debug('text'+text);
       string objName;
       string ParentName;
       try{
           Organization org = [select id,name from organization limit 1];
           buildertek__Check_List_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__Check_List_Settings__c LIMIT 1];
           List<String> emaillist = new List<string>();
           List<String> sendemaillist = Email.split(';');
           if(isparent == true){
               if(parentObj.contains('__')){
                   ParentName = parentObj.substring(0,parentObj.length()-3);
                   ParentName = ParentName+'__r';
               }else{
                   ParentName = parentObj.substring(0,parentObj.length()-2);
               }
               if(FieldName != null && FieldName !=''){
                   String objectName = recordId.getSObjectType().getDescribe().getName();
                   string query = 'select Id,'+ParentName+'.'+FieldName + ' from ' +  objectName +' Where Id =:recordId';
                   system.debug(query+'query');
                   sObject accList = Database.query(query);
                   if(accList.getSObject(ParentName) != null){
                       if(accList.getSObject(ParentName).get(FieldName) != null){
                           
                           emaillist.add(''+accList.getSObject(ParentName).get(FieldName));
                           
                       } 
                   } 
               }
               
               
               
               
           }
           else{
               String objectName = recordId.getSObjectType().getDescribe().getName();
               if(FieldName != null && FieldName !=''){
                   string query = 'select Id,' + FieldName + ' from ' +  objectName +' Where Id =:recordId';
                   system.debug(query);
                   sObject accList = Database.query(query);
                   if(accList.get(FieldName) != null){
                       emaillist.add(''+accList.get(FieldName));
                   } 
               }
           }
                      if(sendemaillist.size()>0){
               for(string str : sendemaillist){
                   if(str != '' && str != null){
                       emaillist.add(str);
                   }
               }
           } 
           system.debug('@@@'+contactEmail);
           if(contactEmail != '' && contactEmail != null){
               emaillist.add(contactEmail);
           }
           system.debug('emaillist'+emaillist);
           //if(text  == null && text  ==''){
           // if(text != null){
            text = text.replace('{URL}','<a href="'+sitesUrl.buildertek__Site_URL__c+'/buildertek__ChecklistForm?id='+recordId+'&checklistId='+checklistId+'&selectCheckListName='+selectCheckListName+'">Checklist Form</a>');
         
          // contact con = [select id,Name,email from contact where id =: recordId];
            Messaging.SingleEmailMessage sendMessage = new Messaging.SingleEmailMessage();
               sendMessage.toAddresses = emaillist;  
               sendMessage.subject = subject;
               sendMessage.HTMLBody = text;
               Messaging.SingleEmailMessage[] Sendermessages =   new List<Messaging.SingleEmailMessage> {sendMessage};
               Messaging.SendEmailResult[] sendMessageslist = Messaging.sendEmail(Sendermessages);
              // }
               return 'Success';
       
       }
       catch(Exception e){
           return e.getMessage();
       }
   }
    
    public class groupinnerclass{
        @AuraEnabled public string GroupName{get;set;}
        @AuraEnabled public list<QuestionsInnerclass> QuestionsInnerclasslist{get;set;}
    }
  
   public class QuestionsInnerclass{
       @AuraEnabled public string QuestionId{get;set;}
       @AuraEnabled public string QuestionName{get;set;}
       @AuraEnabled public string QuestionValue{get;set;}
       @AuraEnabled public list<string> QuestionValues{get;set;}
       @AuraEnabled public string QuestionType{get;set;}
       @AuraEnabled public list<QuestionOption> QuestionOptions{get;set;}
   }
   
   public class QuestionOption{
       @AuraEnabled public string label{get;set;}
       @AuraEnabled public string value{get;set;}
   }
   @auraEnabled
   public static List<string> getEmailFieldsList(Id recId){
       String objName = recId.getSObjectType().getDescribe().getName();
       List<string> emaillist = new List<string>();
       SObjectType r = ((SObject)(Type.forName('Schema.'+objName).newInstance())).getSObjectType();
       
       for(Schema.SObjectField field : r.getDescribe().fields.getMap().values()){
          if(Schema.DisplayType.EMAIL == field.getDescribe().getType())
        //strEmailFiels += ', ' + field.getDescribe().getName();
           emaillist.add(field.getDescribe().getName());
       }
       return emaillist;
    }
    
    @AuraEnabled
    public static ResultWrapper getObjectLabelName(string ObjAPIName){
       //String ObjAPIName = recordId.getSObjectType().getDescribe().getName();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try{
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(ObjAPIName).getDescribe().fields.getMap();
            List<ObjectWrapper> ObjectWrapperList = new List<ObjectWrapper>();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug(dfield.getLabel()+'-------'+dfield.getType());
                ObjectWrapper wrapper = new ObjectWrapper();
                if( String.ValueOf(dfield.getType()) == 'EMAIL'){
                    if(String.ValueOf(dfield.getType()) == 'REFERENCE'){
                        system.debug('666666'+string.valueOf(dfield.getLabel()));
                        wrapper.Label = string.valueOf(dfield.getLabel())+'>'; 
                        wrapper.LookUpAPIName = dfield.getReferenceTo()[0].getDescribe().getName();              
                    }else{
                        wrapper.Label = string.valueOf(dfield.getLabel()); 
                        wrapper.LookUpAPIName = '';      
                    }
                    wrapper.APIName = dfield.getName(); 
                    ObjectWrapperList.Add(wrapper);
                }
            }
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = true;
            Result.Message = 'Success';
            Result.WrapperList = ObjectWrapperList;
            return Result;
        }catch(Exception ex){
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = false;
            Result.Message = ex.getMessage();
            return Result;
        }
    }
    
   public class ResultWrapper{
        @AuraEnabled
        public List<ObjectWrapper> WrapperList{get;set;}
        @AuraEnabled
        public boolean IsSuccess{get;set;}
        @AuraEnabled
        public string Message{get;set;}
    }
    
     public class ObjectWrapper{
        @AuraEnabled
        public string Label{get;set;}
        @AuraEnabled
        public string APIName{get;set;}
        @AuraEnabled
        public string LookUpAPIName{get;set;}
    }
   
   @AuraEnabled
    public static ResultWrapper getinitialObjectFields(string ObjAPIName){
     //String ObjAPIName = recordId.getSObjectType().getDescribe().getName();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try{
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(ObjAPIName).getDescribe().fields.getMap();
            List<ObjectWrapper> ObjectWrapperList = new List<ObjectWrapper>();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug(dfield.getLabel()+'-------'+dfield.getType());
                ObjectWrapper wrapper = new ObjectWrapper();
                if((String.ValueOf(dfield.getType()) == 'REFERENCE' || String.ValueOf(dfield.getType()) == 'EMAIL') && string.valueOf(dfield.getLabel()) != 'Product' && string.valueOf(dfield.getLabel()) != 'Doc Template' && string.valueOf(dfield.getLabel()) != 'Record Type ID' && string.valueOf(dfield.getLabel()) != 'Email Template' && string.valueOf(dfield.getLabel()) != 'Service Request' && string.valueOf(dfield.getLabel()) != 'Created By ID' && string.valueOf(dfield.getLabel()) != 'Last Modified By ID'){
                    if(String.ValueOf(dfield.getType()) == 'REFERENCE' ){
                        wrapper.Label = string.valueOf(dfield.getLabel())+'>'; 
                        wrapper.LookUpAPIName = dfield.getReferenceTo()[0].getDescribe().getName();              
                    }else{
                        wrapper.Label = string.valueOf(dfield.getLabel()); 
                        wrapper.LookUpAPIName = '';      
                    }
                    wrapper.APIName = dfield.getName(); 
                    ObjectWrapperList.Add(wrapper);
                }
            }
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = true;
            Result.Message = 'Success';
            Result.WrapperList = ObjectWrapperList;
            return Result;
        }catch(Exception ex){
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = false;
            Result.Message = ex.getMessage();
            return Result;
        }
    }
     @AuraEnabled
    public static ResultWrapper getAllObjectFields(string ObjAPIName){
     //String ObjAPIName = recordId.getSObjectType().getDescribe().getName();
        Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        try{
            Map <String, Schema.SObjectField> fieldMap = schemaMap.get(ObjAPIName).getDescribe().fields.getMap();
            List<ObjectWrapper> ObjectWrapperList = new List<ObjectWrapper>();
            for(Schema.SObjectField sfield : fieldMap.Values())
            {
                schema.describefieldresult dfield = sfield.getDescribe();
                system.debug(dfield.getLabel()+'-------'+dfield.getType());
                ObjectWrapper wrapper = new ObjectWrapper();
                if( String.ValueOf(dfield.getType()) == 'REFERENCE' || String.ValueOf(dfield.getType()) == 'EMAIL'){
                    if(String.ValueOf(dfield.getType()) == 'REFERENCE'){
                        wrapper.Label = string.valueOf(dfield.getLabel())+'>';
                        wrapper.LookUpAPIName = dfield.getReferenceTo()[0].getDescribe().getName();
                    }else{
                        wrapper.Label = string.valueOf(dfield.getLabel());
                        wrapper.LookUpAPIName = string.valueOf(dfield.getName());
                    }
                    wrapper.APIName = dfield.getName(); 
                    ObjectWrapperList.Add(wrapper);
                }
            }
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = true;
            Result.Message = 'Success';
            Result.WrapperList = ObjectWrapperList;
            return Result;
        }catch(Exception ex){
            ResultWrapper Result = new ResultWrapper();
            Result.IsSuccess = false;
            Result.Message = ex.getMessage();
            return Result;
        }
    }
    @AuraEnabled
    public static string GetSecLevelFieldDetailscontroller(string ObjectName,string FirstField, string SecondField){
        List<string> FieldAPI = SecondField.split('-');
        if(ObjectName.substring(ObjectName.length()-3,ObjectName.length()) == '__c'){
            ObjectName = ObjectName.substring(0,ObjectName.length()-3);
            ObjectName = ObjectName+'__r';
        }else if(ObjectName.substring(ObjectName.length()-2, ObjectName.length()) == 'Id'){
            ObjectName = ObjectName.substring(0, ObjectName.length()-2);
        }
        
        if(FirstField.substring(FirstField.length()-3,FirstField.length()) == '__c'){
            FirstField = FirstField.substring(0,FirstField.length()-3);
            FirstField = FirstField+'__r';
        }else if(FirstField.substring(FirstField.length()-2, FirstField.length()) == 'Id'){
            FirstField = FirstField.substring(0, FirstField.length()-2);
        }
        
        //string FieldToReturn = ObjectName+'.'+FirstField+'.'+FieldAPI[0];
        string FieldToReturn = FirstField+'.'+FieldAPI[0];
        return FieldToReturn;
    }
    @AuraEnabled
    public static string GetFieldDetails(string ObjectName,string FirstField){
     
        List<string> FieldAPI = FirstField.split('-');
        //string FieldToReturn = ObjectName+'.'+FieldAPI[0];
        string FieldToReturn = FieldAPI[0];
        return FieldToReturn;
    }
    @AuraEnabled
    public static List<String> validateEmail(Boolean isparent,string FieldName,Id recordId,string parentObj){
    system.debug('isparent'+isparent);
    string objName = '';
   string ParentName = '';
        List<String> emaillist = new List<string>();
         if(isparent == true){
             if(parentObj.contains('__')){
                 ParentName = parentObj.substring(0,parentObj.length()-3);
                 ParentName = ParentName+'__r';
             }else{
                 ParentName = parentObj.substring(0,parentObj.length()-2);
             }
             if(FieldName != null && FieldName !=''){
                 String objectName = recordId.getSObjectType().getDescribe().getName();
                 string query = 'select Id,'+ParentName+'.'+FieldName + ' from ' +  objectName +' Where Id =:recordId';
                 system.debug(query+'query');
                 sObject accList = Database.query(query);
                 if(accList.getSObject(ParentName) != null){
                     if(accList.getSObject(ParentName).get(FieldName) != null){
                         
                         emaillist.add(''+accList.getSObject(ParentName).get(FieldName));
                         
                     } 
                 } 
             }
             system.debug('sendEmailList'+emaillist);
             return emaillist;
             
         }
        else{
            String objectName = recordId.getSObjectType().getDescribe().getName();
            if(FieldName != null && FieldName !=''){
                string query = 'select Id,' + FieldName + ' from ' +  objectName +' Where Id =:recordId';
                system.debug(query);
                sObject accList = Database.query(query);
                if(accList.get(FieldName) != null){
                    emaillist.add(''+accList.get(FieldName));
                } 
            }
            system.debug('sendEmailList'+emaillist);
            return emaillist;
        }
        
    }
    @AuraEnabled
    public static string getContactEmail(string ContactrecordId){
        List<contact> conList = [select id,name,Email from contact where id=:ContactrecordId];
        return conList[0].Email;
    } 
    
     @AuraEnabled
    public static String sendEmail(){
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toAddresses = new String[] { 'hemanth.chintada@diligentforcelabs.com' };
            message.optOutPolicy = 'FILTER';
        message.subject = 'Subject Test Message';
        message.plainTextBody = 'This is the message body.';
        Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
            Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        if (results[0].success) {
            System.debug('The email was sent successfully.');
            return 'Success';
        } else {
            System.debug('The email failed to send: ' + results[0].errors[0].message);
            return 'Error';
        }
    }
    
  
}