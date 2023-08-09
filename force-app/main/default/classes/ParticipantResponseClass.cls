public without sharing class ParticipantResponseClass {

   @AuraEnabled
    public static buildertek__Session_Participant__c getCousreDetails(String sId){
        System.debug('Id'+sId);
      Session_Participant__c sp = [SELECT Id, Name,buildertek__Participant_Company__r.Name,
                                                      buildertek__Participant_Name__r.FirstName,buildertek__Participant_Name__r.lastName,
                                                      buildertek__Participant_Name__r.Phone,buildertek__Participant_Name__r.Title,
                                                      buildertek__Participant_Name__r.Email,buildertek__Participant_Name__r.MailingAddress,
                                                      buildertek__Participant_Name__r.MailingCity,buildertek__Participant_Name__r.MailingStreet,
                                                      buildertek__Participant_Name__r.MailingPostalCode,buildertek__Participant_Name__r.MailingCountry,
                                                      buildertek__Participant_Name__r.MailingState,
                                                      buildertek__Course_Session_Scheduling__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Date_Time__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Date__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Facilitator__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Time_NEW__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Time__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Duration__c,buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Facilitator__r.Name
                                                      FROM buildertek__Session_Participant__c where id=:sId limit 1];  
        
        // Course_Session_Scheduling__c cs = [SELECT Id, buildertek__Course_Name__c,buildertek__Course_Name__r.Name, buildertek__Session_Date_Time__c, buildertek__Session_Date__c, 
             //buildertek__Session_Facilitator__c,buildertek__Session_Facilitator__r.Name, buildertek__Session_Time_NEW__c, buildertek__Session_Time__c,buildertek__Session_Duration__c  FROM 
             //buildertek__Course_Session_Scheduling__c  where Id=:sp[0].Course_Session_Scheduling__c limit 1];
        return sp;
    }
@AuraEnabled
    public static Session_Participant__c getparticipant(String sId){
        System.debug('Id'+sId);
        Session_Participant__c sp = [SELECT Id, Name,buildertek__Participant_Name__r.FirstName,buildertek__Participant_Name__r.lastName,
                                     buildertek__Participant_Name__r.Phone,buildertek__Participant_Name__r.Title,buildertek__Participant_Name__r.Email,
                                    buildertek__Course_Session_Scheduling__c,buildertek__Is_Participant_Attending__c
                                 FROM buildertek__Session_Participant__c where id=:sId and buildertek__Is_Participant_Attending__c!=null  limit 1]; 
        system.debug('sp---------'+sp);
        return sp;
    }    
    @AuraEnabled 
    
     public static void savesessionobj( id ssId, string tss,String lst,String FstNme,String Phon,String Title,String Email,String Cit,String Stre,String Stat,String Coun,String Pc,String CmpNme){
     Session_Participant__c sp = [SELECT Id, Name,buildertek__Participant_Company__r.Name,
                                                      buildertek__Participant_Name__r.FirstName,buildertek__Participant_Name__r.lastName,
                                                      buildertek__Participant_Name__r.Phone,buildertek__Participant_Name__r.Title,
                                                      buildertek__Participant_Name__r.Email,buildertek__Participant_Name__r.MailingAddress,
                                                      buildertek__Participant_Name__r.MailingCity,buildertek__Participant_Name__r.MailingStreet,
                                                      buildertek__Participant_Name__r.MailingPostalCode,buildertek__Participant_Name__r.MailingCountry,
                                                      buildertek__Participant_Name__r.MailingState,
                                                      buildertek__Course_Session_Scheduling__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Date_Time__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Date__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Facilitator__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Time_NEW__c,buildertek__Course_Session_Scheduling__r.buildertek__Session_Time__c,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Duration__c,buildertek__Course_Session_Scheduling__r.buildertek__Course_Name__r.Name,
                                                      buildertek__Course_Session_Scheduling__r.buildertek__Session_Facilitator__r.Name
                                                      FROM buildertek__Session_Participant__c where id=:ssId limit 1];
                                                      
        buildertek__Training_Settings__c TrainingData = [Select id,name,buildertek__Contact_Info__c,buildertek__Course_Completed_Email_Template__c,buildertek__Registration_Completed_Email_Template__c,buildertek__Registration_Email_Template__c from buildertek__Training_Settings__c];
        
        system.debug('TrainingData -----@@@@---'+TrainingData.buildertek__Registration_Completed_Email_Template__c);
        string tempName = TrainingData.buildertek__Registration_Completed_Email_Template__c;
        system.debug('tempName ----@@@@--'+tempName);
        Id tempId= null;
        tempId = [Select id,name from EmailTemplate where name =: tempName].Id;
        system.debug('tempId----@@@@-----'+tempId); 
                                                     
                                                      
        Date dToday = sp.buildertek__Course_Session_Scheduling__r.buildertek__Session_Date__c;
        system.debug('dToday------'+dToday);
        String dateStr = dToday.year() + '/' + dToday.month() + '/' + dToday.day();
        System.debug('>>>>' + dateStr);                                               
        Session_Participant__c sc= new Session_Participant__c();
        sc.id=ssid;
        if(tss=='Y'){
           sc.Is_Participant_Attending__c='Yes';       
        }
        else{
            sc.Is_Participant_Attending__c='No';
        }
        system.debug('Updated value'+ssid);
        system.debug('Updated value'+tss);
         
        try{
            update sc ;   
            if(tss=='Y'){
            system.debug(tss);
//create instance of Interview
//Flow.Interview.Test_Email_From_Flow stage = new Flow.Interview.Test_Email_From_Flow(new Map<String, Object>());

//Invoke start method
//stage.start();
                string result = buildertek.ParticipantResponseClass.sendEmialToParticipants(ssid,'Registration Completed');
            }
        }catch(Exception e){
            
        }
        
        
        Session_Participant__c spid = [Select id,name,buildertek__Participant_Name__r.Id from buildertek__Session_Participant__c where id =:ssId];
        Contact cons = [Select id,name,LastName from Contact where id=:spid.buildertek__Participant_Name__r.Id];
        
        Contact con = new Contact();
        con.Id = cons.Id;
        con.LastName = lst;
        Con.FirstName = FstNme;
        Con.Phone = Phon;
        Con.Title = Title;
        Con.Email = Email;
        Con.MailingCity = Cit;
        Con.MailingStreet = Stre;
        Con.MailingState = Stat;
        Con.MailingCountry = Coun;
        Con.MailingPostalCode = Pc;
        update con ;
            
        Session_Participant__c spAcc = [Select id,name,buildertek__Participant_Company__r.Id from buildertek__Session_Participant__c where id =:ssId];
        if(spAcc.buildertek__Participant_Company__r.Id == null){
            if(CmpNme!=null && CmpNme!=''){
                  Account acc1 = new Account();
                  acc1.Name = CmpNme;
                  insert acc1;
                  Session_Participant__c SPC = new Session_Participant__c();
                  SPC .id=ssid;
                  SPC.buildertek__Participant_Company__c = acc1.Id;
                  update SPC;                
            }
                  
        }else{
              Account ac = [Select id,name from Account where id=:spAcc.buildertek__Participant_Company__r.Id];
              Account acc = new Account();
              acc.Id = ac.Id;
              acc.Name = CmpNme;
              update acc;
        }
    }
    
    
    public static String sendEmialToParticipants(String participantId, string EmailTemplate){
    string message='';
    System.debug('Participant Id *********** '+participantId+'***'+EmailTemplate);
    if(participantId!=null){
        Set<Id> csIds=new Set<Id>();
        Set<Id> cId=new Set<Id>();
        Set<Id> userId=new Set<Id>();
        Set<Id> participantIds=new Set<Id>();
        List<Session_Participant__c> spList=[SELECT Id,Participant_Name__c,Participant_Name__r.Email,Participant_Name__r.Name,
            Course_Session_Scheduling__c,Course_Session_Scheduling__r.Name,Course_Session_Scheduling__r.Session_Date__c,
            Course_Session_Scheduling__r.Session_Time__c,Course_Session_Scheduling__r.Session_Time_NEW__c,
            Course_Session_Scheduling__r.Session_Duration__c,Course_Session_Scheduling__r.Session_Facilitator__c from Session_Participant__c where id =: participantId];
        System.debug('Participants List'+spList.size());
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
        system.debug('Template--->'+Template);

        if(spList.size()>0){           
                            
            try{
                for(Session_Participant__c sessionparticipants:spList){
                        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
                    System.debug('Participants List'+sessionparticipants.Participant_Name__r.Email);
                    if(sessionparticipants.Participant_Name__r.Email!=null){
                        Messaging.SingleEmailMessage email = new        Messaging.SingleEmailMessage();
                        email.setTargetObjectId(sessionparticipants.Participant_Name__c); 
                        system.debug(sessionparticipants.Participant_Name__c);
                        email.setSaveAsActivity(false); 
                        EmailTemplate emailTemplaterec = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name =:Template];
                        system.debug('emailTemplaterec-->'+emailTemplaterec);
                        email.setTemplateID(emailTemplaterec.Id); 
                        system.debug(sessionparticipants.Id);
                        email.setWhatId(sessionparticipants.Id); //This is important for the merge fields in template to work
                        system.debug(sessionparticipants.Id); 
                        email.setSaveAsActivity(true);                       
                        email.toAddresses = new String[] { sessionparticipants.Participant_Name__r.Email};
                        Messaging.SingleEmailMessage[] emailsList = new List<Messaging.SingleEmailMessage> {email};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsList);

                        if (results[0].success) 
                        {
                            message = 'success';
                            System.debug('The email was sent successfully.');
                        } else {
                            message = 'fail';

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
    
    
    
    @auraEnabled
    public static string getAttachmentData(){
        buildertek__Admin_Interface_Node_Configuration__c checkobj = [select id,Name from buildertek__Admin_Interface_Node_Configuration__c where Name = 'Training Settings'];
        Attachment Att = [select id,Name from attachment where parentId =: checkobj.id];
        return Att.id;
    }
    @auraEnabled
    public static buildertek__Training_Settings__c getTrainingSettings(){
        buildertek__Training_Settings__c TrainingSettings = new buildertek__Training_Settings__c ();
        TrainingSettings =[Select id,name,buildertek__Course_Completed_Email_Template__c,buildertek__Contact_Info__c,buildertek__Registration_Completed_Email_Template__c,buildertek__Registration_Email_Template__c from buildertek__Training_Settings__c Where Name = 'Training Settings'];
        return TrainingSettings;
        
        
    }
}