public with sharing class PreQualController {
    
    public class ApexWrapper{
        public string NameApi{get;set;}
        public string NameLabel{get;set;}
    }
    
    @AuraEnabled
    public static String getTemplates(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Selected_Templates__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name = :'Pre Qualification Configuration'];
        system.debug(adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c);
        List<ApexWrapper> Innerlist = new List<ApexWrapper>();
        if(adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c.contains(',')){
            List<string> res = adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c.split(',');
            string apiname = '';
            string returnval = '';
            List<ApexPage> pages = [select id,NamespacePrefix,name,MasterLabel from ApexPage where name IN:res];
            List<string> namelist = new List<string>();
            
            if(pages.size() > 0){
                for(ApexPage ap:pages){
                    ApexWrapper apx = new ApexWrapper();
                    if(ap.NamespacePrefix != null){
                        apiname = ap.NamespacePrefix+'__'+ap.Name;
                        apx.NameApi = apiname;
                        apx.NameLabel = ap.MasterLabel;
                        Innerlist.add(apx);
                    }
                    else{
                        apiname = ap.name;
                        apx.NameApi = apiname;
                        apx.NameLabel = ap.MasterLabel;
                        Innerlist.add(apx);
                    }
                }
                system.debug('Innerlist-->'+Innerlist);
            }
            if(namelist.size()>0){
                for(integer i=0;i<namelist.size();i++){
                    returnval += namelist[i];
                    if(i != namelist.size()){
                        returnval += ',';
                    }
                }
                
                
            }
            system.debug(Innerlist[0]);
            
        }else{
            system.debug(adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c);
            string res = '';
            res = adminInterfaceNodeConfigurations.buildertek__Selected_Templates__c;
            if(!String.isBlank(res) && res.contains('buildertek__')){
                res= res.split('buildertek__')[1];
            }
            ApexPage ap = [select id,NamespacePrefix,name,MasterLabel from ApexPage where name =:res];
            string apiname = '';
            ApexWrapper apx = new ApexWrapper();
            if(ap.NamespacePrefix != null){
                apiname = ap.NamespacePrefix+'__'+ap.Name;
                apx.NameApi = apiname;
                apx.NameLabel = ap.MasterLabel;
                Innerlist.add(apx);
            }
            else{
                apiname = ap.name;
                apx.NameApi = apiname;
                apx.NameLabel = ap.MasterLabel;
                Innerlist.add(apx);
            }
            
            system.debug('Innerlist'+Innerlist);
            
        } 
        system.debug('Innerlist'+Innerlist);
        String serialInnerList = JSON.serialize(Innerlist);
        return serialInnerList;
    }
    
    
    
    
    @AuraEnabled
    public static ObjectClass getPrimaryContacts(String recordId){
        //List<Contact> contactsList = [SELECT Id, Name FROM Contact WHERE AccountId =: recordId AND buildertek__Primary_Contact__c = true]; 
        List<account> accountList = [select id,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c,buildertek__Qualification_Stage__c from Account where id =:recordId];
        List<contact> contactsList;
        List<contact> PrimarycontactsList = [select id,name from contact where AccountId =:recordId AND buildertek__Primary_Contact__c = true];
        if(accountList[0].buildertek__Pre_Qual_Contact__c != null){
            contactsList = [select id,name from contact where id=:accountList[0].buildertek__Pre_Qual_Contact__c];
        }
        ObjectClass obj = new ObjectClass();
        obj.conlist = contactsList;
        obj.acclist = accountList;
        obj.primary = PrimarycontactsList;
        return obj;
    }
    public class ObjectClass{
        @AuraEnabled public List<contact> conlist;
        @AuraEnabled public List<Account> acclist;
        @AuraEnabled public List<contact> primary;
        
        
    }
    @AuraEnabled
    public static contact getContact(Id conId){
        contact con = new contact();
        list<contact> conlist = [select id,Email from Contact where id=:conId];
        if(!conlist.isEmpty()){
            con = conlist[0];
        }
        return con;
        
    }
    public class Innerclass{
        @AuraEnabled public string fileName;
        @AuraEnabled public string fileContent;
    }
    @AuraEnabled
    public static StageInnerclass getPreQualStage(string recordId){
        
        List<Account> acc = [select id,name,buildertek__Qualification_Stage__c from Account where id=:recordId]; 
        buildertek__Pre_Qual_Settings__c preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c LIMIT 1];
        
        StageInnerclass stg =  new StageInnerclass();
        stg.QualificationStage = acc[0].buildertek__Qualification_Stage__c;
        stg.ismultiPreQual = preQualSettings.buildertek__Is_Multiple_PreQual__c;
        return stg;
    }
    
    public class StageInnerclass{
        @AuraEnabled public string QualificationStage;
        @AuraEnabled public Boolean ismultiPreQual;
    }
    
    
    @AuraEnabled
    public static void sendEmailToVendor(String recordId, String emailTemplateId, List<String> to, List<String> cc, List<String> emailIds,string filedata){
        system.debug(filedata);
        boolean isMultiplePrequal = false;
        string preQualId = '';
        Account act = [select id,buildertek__Box_Folder_Id__c,Name from Account where id =:recordId];
        buildertek__Pre_Qual__c prq = new buildertek__Pre_Qual__c();
        List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
        System.debug('preQualSettings>>>'+preQualSettings);
        if(preQualSettings.size()>0){
            isMultiplePrequal = preQualSettings[0].buildertek__Is_Multiple_PreQual__c;
        }else{ 
            isMultiplePrequal = false;
        }
        if(isMultiplePrequal == true){
            prq.buildertek__Account__c = recordId;
            if(to.size()>0){
                prq.buildertek__Pre_Qual_Contact__c = to[0];
            }else{
                prq.buildertek__Pre_Qual_Contact__c = null;
            }
            if(!emailIds.isEmpty()){
                prq.buildertek__MSA_Additional_Email__c = emailIds[0];
                
            }
            prq.buildertek__Qualification_Stage__c = 'Email Sent';
            prq.buildertek__Company_Name__c = act.Name; 
            insert prq;
            preQualId = prq.Id;
        }
        if(!Test.isRunningTest()){
            if(act.buildertek__Box_Folder_Id__c != ''){
                boxAPICall_handler.getboxFolderID(recordId,preQualId,isMultiplePrequal);
            }
        }
        List<Innerclass> inn;
        if(filedata != null && filedata != '' && filedata != '[]'){
            system.debug('filedata'+filedata);
            inn = (List<Innerclass>)JSON.deserialize((filedata),List<Innerclass>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            system.debug(inn[0].fileContent);
        }
        
        
        Account acc = [SELECT Id,Name,buildertek__Qualification_Stage__c,buildertek__MSA_Additional_Email__c FROM Account WHERE Id =: recordId];
        System.debug('Type of PreQual '+isMultiplePrequal);
        if(to.size()>0){
            System.debug('Type of PreQual '+isMultiplePrequal);
            acc.buildertek__Pre_Qual_Contact__c = to[0];
            if(!isMultiplePrequal){
                acc.buildertek__Qualification_Stage__c = 'Email Sent';
                System.debug('Type of PreQual '+isMultiplePrequal);
            }
            update acc;
        }else{
            acc.buildertek__Pre_Qual_Contact__c = null;
             if(!isMultiplePrequal){
                acc.buildertek__Qualification_Stage__c = 'Email Sent';
                System.debug('Type of PreQual '+isMultiplePrequal);
            }
            update acc;
            
        }
        
        if(!emailIds.isEmpty()){
            acc.buildertek__MSA_Additional_Email__c = emailIds[0];
            update acc;
        }
        
        buildertek__MSA_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c,buildertek__Pre_Qual_Template_Name__c FROM buildertek__MSA_Settings__c LIMIT 1];
        
        List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:sitesUrl.buildertek__Pre_Qual_Template_Name__c];
        //EmailTemplate invTemplate = [ SELECT Id, Name, Subject, Body FROM EmailTemplate  WHERE Name ='Pre Qual'];
        string emailsubject;
        string body = '';
        if(template.size()>0){
            body = template[0].htmlvalue;
            emailsubject = template[0].Subject;
        }
        string link = '';
        //List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
        if(preQualSettings.size() > 0){
            if(preQualSettings[0].buildertek__Is_Multiple_PreQual__c == true){
                link = '<a href="'+sitesUrl.buildertek__Site_URL__c+'/'+emailTemplateId+'?id='+preQualId+'">Click here to open the Web Form</a>';
            }else{
                link = '<a href="'+sitesUrl.buildertek__Site_URL__c+'/'+emailTemplateId+'?id='+recordId+'">Click here to open the Web Form</a>'; 
            }
            
        }
        
        
        system.debug(link);
        // if(body != '' && body != null){}
        if(body.Contains('{!URL}')){
            system.debug('true');
            if(emailTemplateId == ''){
                body = body.replace('{!URL}','');
            }else{
                body = body.replace('{!URL}',link);
            }
            
            system.debug(body);
        }
        
        //String body = '<html><body><p><span>You have been selected to fill out our Pre-Qualification form. Once you have completed this form and submitted it, we will review your qualifications and let you know next steps.';
        //body += '</span><br/><span><a href="'+sitesUrl.buildertek__Site_URL__c+'/'+emailTemplateId+'?id='+recordId+'">Click here to open the Web Form</a>';
        // body += '</span></p></body></html>';
        //String subject = 'AccountPayable'; 
        List<string> strTO = new List<string>();
        List<string> strCC = new List<string>();
        List<Contact> conList = new List<Contact>();
        if(Schema.sObjectType.Contact.fields.Id.isAccessible()
           && Schema.sObjectType.Contact.fields.email.isAccessible()){
               conList = [Select Id, email from Contact where Id IN:to and email != null];        
           }
        system.debug('conList -------> '+conList);
        for(Contact con: conList){
            strTO.add(con.email);
        }
        if(!emailIds.isEmpty()){
            //acc.buildertek__MSA_Additional_Email__c = emailIds[0];
            //update acc;
        }
        if(!conList.isEmpty()){
            //acc.buildertek__MSA_Additional_Email__c = conList[0].Email;
            //update acc;
        }
        List<Contact> ccConList = new List<Contact>(); 
        if(cc.size() > 0 && Schema.sObjectType.Contact.fields.Id.isAccessible()
           && Schema.sObjectType.Contact.fields.Email.isAccessible()){
               ccConList = [Select Id, email from Contact where Id IN:cc and Email != null];        
           }
        if(ccConList.size() > 0){
            for(Contact con: ccConList){
                strCC.add(con.email);
            }    
        }
        system.debug('emailIds&&&&&&&&'+emailIds);
        strTO.addAll(emailIds);
        system.debug('strTO---->'+strTO);
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        List<OrgWideEmailAddress> owea = new List<OrgWideEmailAddress>();
        List<buildertek__MSA_Settings__c> msaSettingsList = [Select Id,buildertek__From_Email_Address__c from buildertek__MSA_Settings__c where Name = :'MSA Settings'];
        if(msaSettingsList.size() > 0){
            owea = [select Id from OrgWideEmailAddress where Address =: msaSettingsList[0].buildertek__From_Email_Address__c]; 
        }
        Messaging.SendEmailResult[] results ;
        try {
            if(owea.size() > 0){
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                system.debug('strTO ---------> '+strTO);
                mail.setToAddresses(strTO);
                if(strCC != null && strCC.size() > 0) {
                    system.debug('strCC -------> '+strCC);
                    mail.setCcAddresses(strCC);
                }
                List<contact> con =[SELECT AccountId, Name, Email, HomePhone  FROM Contact where AccountId=:recordId];
                List<EmailTemplate> temp = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name = 'Pre Qual'];
                EmailServicesAddress eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
                string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
                mail.setReplyTo(fromAddress);
                //subject = 'Pre Qualification';
                //List<buildertek__Pre_Qual_Settings__c> preQualSettings = [SELECT Id,buildertek__Is_Multiple_PreQual__c FROM buildertek__Pre_Qual_Settings__c Where name ='PreQualSettings' LIMIT 1];
                if(preQualSettings[0].buildertek__Is_Multiple_PreQual__c){
                   mail.setSubject(template[0].Subject); 
                }else{
                   mail.setSubject('PreQualification-'+acc.Name+'-'+recordId); 
                }
                
                mail.setHTMLBody(body);
                mail.setSaveAsActivity(true);
                if(filedata != null && filedata != '' && filedata != '[]'){
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    for(Innerclass i:inn){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(i.fileName);
                        //efa.setBody(EncodingUtil.Base64Encode(Blob.valueOf(inn[0].fileContent)));
                        efa.setBody(EncodingUtil.base64Decode(i.fileContent));
                        fileAttachments.add(efa);
                        mail.setFileAttachments(fileAttachments);
                    }
                }
                mail.setOrgWideEmailAddressId(owea.get(0).Id);
                mails.add(mail);
                results = Messaging.sendEmail(mails); 
                
            }else{
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                system.debug('strTO ---------> '+strTO);
                mail.setToAddresses(strTO);
                if(strCC != null && strCC.size() > 0) {
                    system.debug('strCC -------> '+strCC);
                    mail.setCcAddresses(strCC);
                }
                List<contact> con =[SELECT AccountId, Name, Email, HomePhone  FROM Contact where AccountId=:recordId];
                List<EmailTemplate> temp = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name = 'Pre Qual'];
                EmailServicesAddress eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
                string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
                mail.setReplyTo(fromAddress);
                //subject = 'Pre Qualification'; 
               if(preQualSettings[0].buildertek__Is_Multiple_PreQual__c){
                   mail.setSubject(template[0].Subject); 
                }else{
                   mail.setSubject('PreQualification-'+acc.Name+'-'+recordId); 
                }
                mail.setHTMLBody(body);
                mail.setSaveAsActivity(true);
                if(filedata != null && filedata != '' && filedata != '[]'){
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    for(Innerclass i:inn){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(i.fileName);
                        //efa.setBody(EncodingUtil.Base64Encode(Blob.valueOf(inn[0].fileContent)));
                        efa.setBody(EncodingUtil.base64Decode(i.fileContent));
                        fileAttachments.add(efa);
                        mail.setFileAttachments(fileAttachments);
                    }
                    
                }
                mails.add(mail);
                results = Messaging.sendEmail(mails);
            }
            
        }catch(Exception e){
            system.debug('Check123'+e.getMessage());
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            system.debug('strTO ---------> '+strTO);
            mail.setToAddresses(strTO);
            if(strCC != null && strCC.size() > 0) {
                system.debug('strCC -------> '+strCC);
                mail.setCcAddresses(strCC);
            }
            List<contact> con =[SELECT AccountId, Name, Email, HomePhone  FROM Contact where AccountId=:recordId];
            List<EmailTemplate> temp = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name = 'Pre Qual'];
            EmailServicesAddress eServices =  [SELECT Id,AuthorizedSenders,EmailDomainName,IsActive,LocalPart FROM EmailServicesAddress where LocalPart = 'projects'];
            string fromAddress = eServices.LocalPart+'@'+eServices.EmailDomainName;
            mail.setReplyTo(fromAddress);
            //subject = 'Pre Qualification'; 
            if(preQualSettings[0].buildertek__Is_Multiple_PreQual__c){
                   mail.setSubject(template[0].Subject); 
                }else{
                   mail.setSubject('PreQualification-'+acc.Name+'-'+recordId); 
                }
            mail.setHTMLBody(body);
            mail.setSaveAsActivity(true);
            if(filedata != null && filedata != '' && filedata != '[]'){
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                for(Innerclass i:inn){
                    Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                    efa.setFileName(i.fileName);
                    //efa.setBody(EncodingUtil.Base64Encode(Blob.valueOf(inn[0].fileContent)));
                    efa.setBody(EncodingUtil.base64Decode(i.fileContent));
                    fileAttachments.add(efa);
                    mail.setFileAttachments(fileAttachments);
                }
            }
            mails.add(mail);
            results = Messaging.sendEmail(mails);
        }
        if(results.size() > 0){
            if (results[0].isSuccess()) {
                if(isMultiplePrequal = false){
                    acc.buildertek__Qualification_Stage__c = 'Email Sent';
                    update acc;
                }
                
                string Toaddresses= '';
                string CCaddresses= '';
                integer i = 0;
                for(String Str : strTO){
                    Toaddresses += Str;
                    if(strTO.size() > i){
                        Toaddresses += ';';
                    }
                    i++;
                }
                for(String Str : strCC){
                    CCaddresses += Str;
                    if(strCC.size() > i){
                        CCaddresses += ';';
                    }
                    i++;
                    
                }
                system.debug('CCaddresses ----------> '+CCaddresses);
                EmailMessage caseEmailMessage = new EmailMessage();
                caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                caseEmailMessage.ToAddress = Toaddresses;
                caseEmailMessage.FromName = UserInfo.getUserName();
                caseEmailMessage.CcAddress = CCaddresses;
                caseEmailMessage.Subject = emailsubject;
                caseEmailMessage.HtmlBody = body;
                caseEmailMessage.Incoming= False;
                caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                caseEmailMessage.MessageDate = system.now();
                caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                system.debug('Content length ---------> '+body.length());
                caseEmailMessage.status = '5';
                caseEmailMessage.RelatedToId = recordId;
                caseEmailMessage.buildertek__Subject__c = emailsubject;
                
                insert caseEmailMessage;
                
                EmailMessageRelation emr = new EmailMessageRelation();
                emr.emailMessageId = caseEmailMessage.id;
                emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
                emr.relationType = 'FromAddress';
                emr.relationAddress = caseEmailMessage.fromAddress;
                insert emr;
            }
        } 
    }
}