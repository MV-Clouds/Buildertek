public without sharing class ParticipantUpdatesController {
    
    @AuraEnabled(cacheable=true)
    public static Course_Session_Scheduling__c getCourseSession(String coursessId) {
        return [SELECT Id,Name FROM Course_Session_Scheduling__c where  Id=:coursessId];
    }
    
    @AuraEnabled(cacheable=true)
    public static Session_Participant__c getParticipantName(String recdId) {
        return [SELECT Id,Name,Participant_Name__r.Name,Course_Completion_Date__c FROM Session_Participant__c where  Id=:recdId];
    }
    @AuraEnabled(cacheable=true)
    public static Course__c getCourse(String coursessId) {
        Course_Session_Scheduling__c cs=[SELECT Id,Name,Course_Name__c  FROM Course_Session_Scheduling__c where  Id=:coursessId];  
        
        return [SELECT Id, Name FROM Course__c where id=:cs.Course_Name__c];
    }
    
    @AuraEnabled(cacheable=true)
    public static list<FieldWrapper> getSkillLevel() {  
        list<FieldWrapper> pickListValuesList=new list<FieldWrapper>();
        Schema.DescribeFieldResult fieldResult = Contact.Skill_Level__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            FieldWrapper fw = new FieldWrapper();
            fw.value = pickListVal.getLabel();
            fw.label = pickListVal.getLabel();
            pickListValuesList.add(fw);
        }                     
        return pickListValuesList;
        
    }
    
    public class FieldWrapper{        
        @AuraEnabled public String value;
        @AuraEnabled public String label;        
    }
    
    @AuraEnabled
    public static List<ParticipantWrapper> getParticipants(String couserSessionId) {
        system.debug('couserSessionId--->'+couserSessionId);
        List<ParticipantWrapper> ParticipantsWrapper = new List<ParticipantWrapper>();        
        list<Session_Participant__c> participantsList = [ SELECT Id,
                                                         Participant_Name__c, 
                                                         Participant_Name__r.Name,
                                                         Participant_Name__r.Email,
                                                         Participant_Name__r.Contact_Phone_No__c ,
                                                         Participant_Name__r.Skill_Level__c,
                                                         Participant_Company__c, 
                                                         Participant_Company__r.Name,
                                                         Participant_Attended__c,
                                                         Participant_Score__c, 
                                                         Is_Participant_Attending__c,
                                                         Participant_Name__r.Title,
                                                         //Training_Expiration_Date__c, 
                                                         Course_Completed__c, 
                                                         Course_Completion_Date__c, 
                                                         Notes__c, 
                                                         Course_Session_Scheduling__c
                                                         FROM Session_Participant__c  
                                                         where  Course_Session_Scheduling__c=:couserSessionId 
                                                        ];
        integer i=1;
        
        if(participantsList.size() > 0){
            for(Session_Participant__c rec : participantsList){
                ParticipantWrapper obj = new ParticipantWrapper();
                obj.RowNumber = i;
                obj.RecordId = rec.Id;
                system.debug(obj.RecordId); 
                obj.ParticipantName = rec.Participant_Name__r.Name;
                obj.ParticipantCompany = rec.Participant_Company__r.Name;
                obj.ParticipantAttended = rec.Participant_Attended__c;
                obj.IsParticipantAttend = rec.Is_Participant_Attending__c;
                obj.ParticipantScore = rec.Participant_Score__c;
                obj.ParticipantTitle = rec.Participant_Name__r.Title;
                obj.ParticipantEmail = rec.Participant_Name__r.Email;
                obj.ParticipantPhone = rec.Participant_Name__r.Contact_Phone_No__c ;
                //obj.TrainingExpirationDate = rec.Training_Expiration_Date__c;
                obj.CourseCompleted = rec.Course_Completed__c;
                obj.CourseCompletionDate = rec.Course_Completion_Date__c;
                obj.CourseCompletionOldDate=rec.Course_Completion_Date__c;
                obj.Notes = rec.Notes__c;
                System.debug('skill*************'+rec.Participant_Name__r.Skill_Level__c);
                if(rec.Participant_Name__r.Skill_Level__c!=null){
                    List<String> skillset = new List<String>();
                    string skilllevel =    rec.Participant_Name__r.Skill_Level__c;
                    if(skilllevel!=null){
                        list<string> skilllevelTmp= new list<string>();
                        skilllevelTmp = skilllevel.split(';');
                        for(integer k=0;k<=skilllevelTmp.size()-1;k++){
                            system.debug(skilllevelTmp[k]);
                            skillset.add(skilllevelTmp[k]);
                        }   
                    }
                    System.debug('skillset-------------------------'+skillset);
                    // obj.SkillLevel.add(skillset);
                    obj.SkillLevel = skillset;
                }
                // obj.SkillLevel = rec.Participant_Name__r.Skill_Level__c; 
                ParticipantsWrapper.add(obj);          
                i++;
            }
        }   
        system.debug(ParticipantsWrapper.size());
        return ParticipantsWrapper;
    }
    
    public class ParticipantWrapper{
        @AuraEnabled public Integer RowNumber;
        @AuraEnabled public Id RecordId;
        @AuraEnabled public String ParticipantName;
        @AuraEnabled public String ParticipantCompany;
        @AuraEnabled public String ParticipantAttended;
        @AuraEnabled public String ParticipantScore;
        @AuraEnabled public String ParticipantTitle;
        @AuraEnabled public String ParticipantEmail;
        @AuraEnabled public String ParticipantPhone;
        @AuraEnabled public String IsParticipantAttend;
        @AuraEnabled public List<String> SkillLevel;
        @AuraEnabled public Date TrainingExpirationDate;
        @AuraEnabled public String CourseCompleted;
        @AuraEnabled public Date CourseCompletionDate;
        @AuraEnabled public Date CourseCompletionOldDate;
        @AuraEnabled public String Notes;
        
    } 
    @AuraEnabled
    public static string updateParticipants(list<Object> records,list<Object> sendemailrecordIds){
        string message='';
        if(records!=null){     
            list<Object> recordIds = new list<Object>();
            
            try{
                
                list<Contact> updateContactsList = new list<Contact>();
                map<string,string> conSkillMap = new map<string,string>();
                map<string,string> conemail = new map<string,string>();
                map<string,string> conphone = new map<string,string>();
                // map<string,string> contitle = new map<string,string>();
                set<string> connamesset = new set<string>();
                // List<String> conEmails=new List<String>();
                // List<String> conPhone=new List<String>();
                
                System.debug('records'+records);  
                
                system.debug('hello');
                list<Session_Participant__c> ParticipantUpdatesList = new list<Session_Participant__c>();
                for(Object Item : records){            
                    Map<Object, Object> ItemMap = (Map<Object, Object>) Item;
                    
                    Integer RowNumber = Integer.valueOf(String.Valueof(ItemMap.get('RowNumber')));
                    String RecordId = string.Valueof(ItemMap.get('RecordId'));
                    system.debug('RecordId'+RecordId);
                    string ParticipantAttended = String.Valueof(ItemMap.get('ParticipantAttended'));
                    string ParticipantScore = String.Valueof(ItemMap.get('ParticipantScore'));
                    // string ParticipantTitle = String.Valueof(ItemMap.get('ParticipantTitle'));
                    string ParticipantEmail = String.Valueof(ItemMap.get('ParticipantEmail'));
                    string ParticipantPhone = String.Valueof(ItemMap.get('ParticipantPhone'));
                    string IsParticipantAttend = String.Valueof(ItemMap.get('IsParticipantAttend'));
                    /*string TrainingExpirationDate = String.Valueof(ItemMap.get('TrainingExpirationDate'));
system.debug(TrainingExpirationDate);*/
                    string CourseCompleted = String.Valueof(ItemMap.get('CourseCompleted'));
                    string CourseCompletionDate = String.Valueof(ItemMap.get('CourseCompletionDate'));
                    string CourseCompletionOldDate = String.Valueof(ItemMap.get('CourseCompletionOldDate'));
                    system.debug(CourseCompletionDate);
                    string Notes = String.Valueof(ItemMap.get('Notes'));               
                    Session_Participant__c obj = new Session_Participant__c();
                    
                    
                    obj.Participant_Attended__c = ParticipantAttended;
                    obj.Participant_Score__c = ParticipantScore;
                    obj.Is_Participant_Attending__c = IsParticipantAttend;
                    //if(TrainingExpirationDate!='null' && TrainingExpirationDate!=null)
                    //obj.Training_Expiration_Date__c =Date.valueOf(TrainingExpirationDate);
                    obj.Course_Completed__c = CourseCompleted;
                    if(CourseCompletionDate!='null' && CourseCompletionDate!=null ){
                        obj.Course_Completion_Date__c =Date.valueOf(CourseCompletionDate);
                    }else{
                        obj.Course_Completion_Date__c =null;
                    }
                    obj.Notes__c = Notes;
                    obj.Id = RecordId; 
                    System.debug(obj.Id);
                    if(CourseCompletionDate!='null' 
                       && CourseCompletionDate!=null
                       && CourseCompletionDate!=''
                       && CourseCompletionOldDate!=CourseCompletionDate){
                           recordIds.add(obj.Id); 
                       }
                    
                    string participantname = String.Valueof(ItemMap.get('ParticipantName'));
                    // string participantemail= String.Valueof(ItemMap.get('ParticipantEmail'));
                    // string participantphone= String.Valueof(ItemMap.get('ParticipantPhone'));               
                    connamesset.add(participantname);
                    // conEmails.add(participantemail);
                    //  conPhone.add(participantphone);
                    conSkillMap.put(ParticipantName,String.Valueof(ItemMap.get('SkillLevel')));
                    conemail.put(ParticipantName,String.Valueof(ItemMap.get('ParticipantEmail')));
                    conphone.put(ParticipantName,String.Valueof(ItemMap.get('ParticipantPhone')));
                    //  contitle.put(ParticipantName,String.Valueof(ItemMap.get('ParticipantTitle')));
                    ParticipantUpdatesList.add(obj);                
                }            
                
                system.debug('connamesset--->'+connamesset);
                List<Contact> conList=[select id,name,Skill_Level__c,Email,Phone from Contact
                                       where name in : connamesset];
                if(conList.size()>0){
                    for(Contact con: conList){
                        if(conSkillMap.get(con.name)!=null){
                            string picklistvalues = conSkillMap.get(con.name);                        
                            picklistvalues = picklistvalues.replace(',',';');
                            picklistvalues = picklistvalues.replace('(','');
                            picklistvalues = picklistvalues.replace(')','');
                            system.debug('picklistvalues--->'+picklistvalues);
                            con.Skill_Level__c = picklistvalues;
                            string contactEmail = conemail.get(con.name); 
                            string contactPhone = conphone.get(con.name);
                            string contactTitle = conphone.get(con.name);
                            con.Email=contactEmail;
                            con.Phone=contactTitle;                       
                        }else{
                            con.Skill_Level__c = ' ';
                        }                    
                    }
                    update conList;
                }
                
                try{
                    
                    recordIds.addAll(sendemailrecordIds);
                    /*for(Session_Participant__c participants:ParticipantUpdatesList){
recordIds.add(participants.Id);
}*/
                    system.debug('recordIds--->'+recordIds);
                    
                    
                    update ParticipantUpdatesList;
                    message = 'updated';
                    if(message =='updated'){
                        //recordIds.addAll(sendemailrecordIds);
                        /*for(Session_Participant__c participants:ParticipantUpdatesList){
recordIds.add(participants.Id);
}*/
                        //system.debug('recordIds--->'+recordIds);
                        
                        //buildertek.ParticipantUpdatesController.sendEmialToParticipants(recordIds,'Course Completed');                
                        if(!Test.isRunningTest()){
                            buildertek.ParticipantUpdatesController.sendCourseCompletionEmail(JSON.serialize(recordIds));                
                        }
                        
                        
                    }
                }catch(exception e){
                    message = 'error';
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                }   
            }catch(Exception e){
                message = 'error';
                system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                message = e.getMessage();
            }
        }else{
            message = 'error';
        }              
        
        System.debug('message---------------------'+message);
        return message;
        
        
    }
    @Future(callout=true)
    public static void sendCourseCompletionEmail(string records) {   
        list<Object>  recordIds = (list<string>)JSON.deserialize(records, list<string>.class);
        System.debug('Participant Id *********** '+recordIds);
        if(recordIds!=null){
            Set<Id> csIds=new Set<Id>();
            Set<Id> cId=new Set<Id>();
            Set<Id> userId=new Set<Id>();
            Set<Id> participantIds=new Set<Id>();
            
            list<string> selectedIdsList = new list<string>();
            if(recordIds.size() > 0){
                for(Object rec : recordIds){
                    system.debug('rec--->'+rec);
                    selectedIdsList.add(string.valueOf(rec));
                }
            }
            
            List<Session_Participant__c> spList=[SELECT Id,Participant_Name__c,Participant_Name__r.Email,Participant_Name__r.phone,Participant_Name__r.Name,
                                                 Course_Session_Scheduling__c,Course_Session_Scheduling__r.Name,Course_Session_Scheduling__r.Session_Date__c,
                                                 Course_Session_Scheduling__r.Session_Time__c,Course_Session_Scheduling__r.Session_Time_NEW__c,
                                                 Course_Session_Scheduling__r.Session_Duration__c,Course_Session_Scheduling__r.Session_Facilitator__c 
                                                 from Session_Participant__c where id In:selectedIdsList ];
            System.debug('Participants List'+spList);
            List<buildertek__Training_Settings__c> trainingSettingsList = new List<buildertek__Training_Settings__c>();
            trainingSettingsList = [SELECT Id, Name, 
                                    buildertek__Course_Completed_Email_Template__c, 
                                    buildertek__Registration_Completed_Email_Template__c,
                                    buildertek__Registration_Email_Template__c
                                    FROM buildertek__Training_Settings__c  Where Name = 'Training Settings'];
            
            string EmailTemplate='Course Completed';
            string Template='';
            if(EmailTemplate=='Course Completed'){
                Template = trainingSettingsList[0].buildertek__Course_Completed_Email_Template__c;
            }
            
            if(spList.size()>0){           
                
                try{
                    for(Session_Participant__c sessionparticipants:spList){
                        string RecId = '';
                        RecId = sessionparticipants.Id;
                        
                        
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        System.debug('Participants List'+sessionparticipants.Participant_Name__r.Email);
                        if(sessionparticipants.Participant_Name__r.Email!=null){
                            Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                            email.setTargetObjectId(sessionparticipants.Participant_Name__c); 
                            email.setSaveAsActivity(false); 
                            EmailTemplate emailTemplaterec = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:Template];
                            email.setTemplateID(emailTemplaterec.Id); 
                            email.setWhatId(sessionparticipants.Id); //This is important for the merge fields in template to work
                            email.setSaveAsActivity(true);
                            
                            if(EmailTemplate=='Course Completed'){
                                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                efa.setFileName('certificate.pdf');
                                efa.setBody(setAttachmentBody(RecId,sessionparticipants.Course_Session_Scheduling__c));
                                fileAttachments.add(efa);
                                email.setFileAttachments(fileAttachments); 
                            }
                            
                            email.toAddresses = new String[] { sessionparticipants.Participant_Name__r.Email};
                                Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                            
                            if (results[0].success) 
                            {
                            } else {
                            }
                        }
                    }                                                        
                    
                }
                catch (exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                }
            }                  
        }
    }
    
    
    
    
    
    
    @AuraEnabled(cacheable=true)
    public static List<String> readFieldSet()
    {
        Map<String, Schema.SObjectType> GlobalDescribeMap = Schema.getGlobalDescribe(); 
        Schema.SObjectType SObjectTypeObj = GlobalDescribeMap.get('Contact');
        Schema.DescribeSObjectResult DescribeSObjectResultObj = SObjectTypeObj.getDescribe();
        
        system.debug('====>' + DescribeSObjectResultObj.FieldSets.getMap().get('buildertek__NewParticipant'));
        
        Schema.FieldSet fieldSetObj = DescribeSObjectResultObj.FieldSets.getMap().get('buildertek__NewParticipant');
        
        List<Schema.FieldSetMember> fieldSetMemberList =  fieldSetObj.getFields();
        system.debug('fieldSetMemberList ====>' + fieldSetMemberList);
        List<String> contactFields=new List<String>();
        for (Schema.FieldSetMember f : fieldSetMemberList){
            system.debug('f.getFieldPath()--->'+f.getFieldPath()); 
            contactFields.add(f.getFieldPath());
            
        }
        system.debug('Contact Field List------>'+contactFields); 
        return contactFields;
        
    }  
    
    // 
    public static Blob setAttachmentBody(String recordId,string coursessionid){
        Pagereference pdf;
        String TmpID = '';
        String certificatename = '';            
        buildertek__Course_Session_Scheduling__c coursedata= [Select Id, 
                                                              buildertek__Course_Name__c, buildertek__Course_Name__r.buildertek__Certification_Template__c 
                                                              From buildertek__Course_Session_Scheduling__c Where Id=:coursessionid];
        
        certificatename = coursedata.buildertek__Course_Name__r.buildertek__Certification_Template__c;
        if(certificatename=='' || certificatename==null){
            certificatename = 'TrainingCertificate';
        }
        if(certificatename!=null){
            EmailTemplate template = [Select Id,Name,Subject,HtmlValue,Body from EmailTemplate where name =: certificatename ];
            if(template!=null){
                TmpID = template.Id;
                pdf = Page.buildertek__BT_Generatepdf;
                pdf.getParameters().put('recordId', recordId);
                pdf.getParameters().put('templateId', TmpID);
                pdf.setRedirect(true);        
            }
        }
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
    
    
    @AuraEnabled
    public static String sendEmialToParticipants(list<Object> recordIds, string EmailTemplate){
        string message='';
        System.debug('Participant Id *********** '+recordIds);
        if(recordIds!=null){
            Set<Id> csIds=new Set<Id>();
            Set<Id> cId=new Set<Id>();
            Set<Id> userId=new Set<Id>();
            Set<Id> participantIds=new Set<Id>();
            
            list<string> selectedIdsList = new list<string>();
            if(recordIds.size() > 0){
                for(Object rec : recordIds){
                    system.debug('rec--->'+rec);
                    selectedIdsList.add(string.valueOf(rec));
                }
            }
            
            List<Session_Participant__c> spList=[SELECT Id,Participant_Name__c,Participant_Name__r.Email,Participant_Name__r.Name,
                                                 Course_Session_Scheduling__c,Course_Session_Scheduling__r.Name,Course_Session_Scheduling__r.Session_Date__c,
                                                 Course_Session_Scheduling__r.Session_Time__c,Course_Session_Scheduling__r.Session_Time_NEW__c,
                                                 Course_Session_Scheduling__r.Session_Duration__c,Course_Session_Scheduling__r.Session_Facilitator__c 
                                                 from Session_Participant__c where id In:selectedIdsList ];
            System.debug('Participants List'+spList);
            List<buildertek__Training_Settings__c> trainingSettingsList = new List<buildertek__Training_Settings__c>();
            trainingSettingsList = [SELECT Id, Name, 
                                    buildertek__Course_Completed_Email_Template__c, 
                                    buildertek__Registration_Completed_Email_Template__c,
                                    buildertek__Registration_Email_Template__c
                                    FROM buildertek__Training_Settings__c  Where Name = 'Training Settings'];
            
            string Template='';
            
            if(EmailTemplate=='Registration Email'){
                Template = trainingSettingsList[0].buildertek__Registration_Email_Template__c;
            }else if(EmailTemplate=='Registration Completed'){
                Template = trainingSettingsList[0].buildertek__Registration_Completed_Email_Template__c;
            }else if(EmailTemplate=='Course Completed'){
                Template = trainingSettingsList[0].buildertek__Course_Completed_Email_Template__c;
            }
            
            if(spList.size()>0){           
                
                try{
                    for(Session_Participant__c sessionparticipants:spList){
                        string RecId = '';
                        RecId = sessionparticipants.Id;
                        
                        
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        System.debug('Participants List'+sessionparticipants.Participant_Name__r.Email);
                        if(sessionparticipants.Participant_Name__r.Email!=null){
                            Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                            email.setTargetObjectId(sessionparticipants.Participant_Name__c); 
                            email.setSaveAsActivity(false); 
                            EmailTemplate emailTemplaterec = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:Template];
                            email.setTemplateID(emailTemplaterec.Id); 
                            email.setWhatId(sessionparticipants.Id); //This is important for the merge fields in template to work
                            email.setSaveAsActivity(true);
                            
                            if(EmailTemplate=='Course Completed'){
                                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                efa.setFileName('certificate.pdf');
                                efa.setBody(setAttachmentBody(RecId,sessionparticipants.Course_Session_Scheduling__c));
                                fileAttachments.add(efa);
                                email.setFileAttachments(fileAttachments); 
                            }
                            
                            email.toAddresses = new String[] { sessionparticipants.Participant_Name__r.Email};
                                Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                            
                            if (results[0].success) 
                            {
                                message = 'success';
                                System.debug('The email was sent successfully.');
                            } else {
                                message = 'fail';
                                message =   results[0].errors[0].message;
                                System.debug('The email failed to send: ' +  results[0].errors[0].message);
                            }
                        }
                    }                                                        
                    
                }
                catch (exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                    message = e.getMessage()+'-'+e.getLineNumber();
                }
            }                  
        }
        return message;
    }
    
    
    
    
    @AuraEnabled
    public static String deleteparticipant(list<Object> deleterecordIds){
        String msg='';
        System.debug('--------------------------'+deleterecordIds);
        try{
            
            list<string> delIdsList = new list<string>();
            if(deleterecordIds.size() > 0){
                for(Object rec : deleterecordIds){
                    system.debug('rec--->'+rec);
                    delIdsList.add(string.valueOf(rec));
                }
            }
            
            system.debug('delIdsList--->'+delIdsList);
            list<Session_Participant__c> delrecords = new list<Session_Participant__c>();
            
            delrecords=[SELECT Id,Participant_Name__c from Session_Participant__c where Id In:delIdsList];
            System.debug('delrecords-----------------------------'+delrecords);
            delete delrecords;  
            msg='sucess';
        }catch (exception e){
            system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
            msg = e.getMessage();
        }
        return msg;
    }
    
    
    
    @AuraEnabled
    public static String resendEmialToParticipants(String participantrecId, string EmailTemplate){
        string message='';
        System.debug('Participant Id *********** '+participantrecId);
        if(participantrecId!=null){
            Set<Id> csIds=new Set<Id>();
            Set<Id> cId=new Set<Id>();
            Set<Id> userId=new Set<Id>();
            Set<Id> participantIds=new Set<Id>();
            List<Session_Participant__c> spList=[SELECT Id,Participant_Name__c,Participant_Name__r.Email,Participant_Name__r.Name,
                                                 Course_Session_Scheduling__c,Course_Session_Scheduling__r.Name,Course_Session_Scheduling__r.Session_Date__c,
                                                 Course_Session_Scheduling__r.Session_Time__c,Course_Session_Scheduling__r.Session_Time_NEW__c,
                                                 Course_Session_Scheduling__r.Session_Duration__c,Course_Session_Scheduling__r.Session_Facilitator__c 
                                                 from Session_Participant__c where id=:participantrecId ];
            System.debug('Participants List'+spList);
            List<buildertek__Training_Settings__c> trainingSettingsList = new List<buildertek__Training_Settings__c>();
            trainingSettingsList = [SELECT Id, Name, 
                                    buildertek__Course_Completed_Email_Template__c, 
                                    buildertek__Registration_Completed_Email_Template__c,
                                    buildertek__Registration_Email_Template__c
                                    FROM buildertek__Training_Settings__c  Where Name = 'Training Settings'];
            
            string Template='';
            
            if(EmailTemplate=='Registration Email'){
                Template = trainingSettingsList[0].buildertek__Registration_Email_Template__c;
            }else if(EmailTemplate=='Registration Completed'){
                Template = trainingSettingsList[0].buildertek__Registration_Completed_Email_Template__c;
            }else if(EmailTemplate=='Course Completed'){
                Template = trainingSettingsList[0].buildertek__Course_Completed_Email_Template__c;
            }
          //  OrgWideEmailAddress owe = [SELECT ID,IsAllowAllProfiles,DisplayName,Address FROM OrgWideEmailAddress WHERE Address='lavanya.palepu@diligentforcelabs.com']; 
            if(spList.size()>0){           
                
                try{
                    for(Session_Participant__c sessionparticipants:spList){
                        string RecId = '';
                        RecId = sessionparticipants.Id;
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                        System.debug('Participants List'+sessionparticipants.Participant_Name__r.Email);
                        if(sessionparticipants.Participant_Name__r.Email!=null){
                            Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                           // email.setOrgWideEmailAddressId(owe.Id);
                            email.setTargetObjectId(sessionparticipants.Participant_Name__c); 
                            //  email.setSaveAsActivity(false); 
                            EmailTemplate emailTemplaterec = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:Template];
                            email.setTemplateID(emailTemplaterec.Id); 
                            email.setWhatId(sessionparticipants.Id); //This is important for the merge fields in template to work
                            email.setSaveAsActivity(true);
                            
                            if(EmailTemplate=='Course Completed'){
                                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                                efa.setFileName('certificate.pdf');
                                efa.setBody(setAttachmentBody(RecId,sessionparticipants.Course_Session_Scheduling__c));
                                fileAttachments.add(efa);
                                email.setFileAttachments(fileAttachments); 
                            }
                            
                            email.toAddresses = new String[] { sessionparticipants.Participant_Name__r.Email};
                                Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                                    Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);
                            
                            if (results[0].success) 
                            {
                                message = 'success';
                                System.debug('The email was sent successfully.');
                            } else {
                                message = 'fail';
                                message =   results[0].errors[0].message;
                                System.debug('The email failed to send: ' +  results[0].errors[0].message);
                            }
                        }
                    }                                                        
                    
                }
                catch (exception e){
                    system.debug('error--->'+e.getMessage()+'line no-->'+e.getLineNumber());
                    message = e.getMessage()+'-'+e.getLineNumber();
                }
            }                  
        }
        return message;
    }
}