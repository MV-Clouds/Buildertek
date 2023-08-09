public class AccountQualiicationController {
    
    @AuraEnabled
    public static String getPreQualStage(String recordId) {
        List<Account> acc = [select id,name,buildertek__Qualification_Stage__c from Account where id =:recordId];
        return acc[0].buildertek__Qualification_Stage__c;
    }
    
    
    
    
    @AuraEnabled  
    public static String ChangeAccountStatus(String recordId) {
        Account accountStatus = [select Id, buildertek__Qualification_Stage__c from Account where Id =: recordId];
        system.debug(accountStatus );
        accountStatus.buildertek__Qualification_Stage__c = 'Qualified';
        
        
        
        update accountStatus;
        system.debug(accountStatus );
        return 'Success';  
    }  
    @AuraEnabled  
    public static String ChangeAccountStatustoOld(String recordId,string oldstatus) {
        Account accountStatus = [select Id, buildertek__Qualification_Stage__c from Account where Id =: recordId];
        system.debug(accountStatus );
        
        if(oldstatus != null && oldstatus != ''){
            accountStatus.buildertek__Qualification_Stage__c = oldstatus;
            update accountStatus;
        }
        
        system.debug(accountStatus );
        return 'Success';  
    }  
    
    
    
    
    /* File Upload code */
    
    @AuraEnabled
    public static Id saveFile(Id parentId, String fileName, String base64Data, String contentType, String fileId) {
        // check if fileId id ''(Always blank in first chunk), then call the saveTheFile method,
        //  which is save the check data and return the attachemnt Id after insert,
        //  next time (in else) we are call the appentTOFile() method
        //   for update the attachment with remains chunks
        if (fileId == '') {
            fileId = saveTheFile(parentId, fileName, base64Data, contentType);
        } else {
            appendToFile(fileId, base64Data);
        }
        
        return Id.valueOf(fileId);
    }
    
    public static Id saveTheFile(Id parentId, String fileName, String base64Data, String contentType) {
        system.debug(parentId);
        system.debug(fileName);
        system.debug(base64Data);
        system.debug(contentType);
        List<Account> lstAcc=[SELECT Id,Name FROM Account WHERE id =:parentId];        
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
        ContentVersion conVer = new ContentVersion();
        conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
        conVer.PathOnClient = fileName; // The files name, extension is very important here which will help the file in preview.
        conVer.Title = fileName+'-Qualification'; // Display name of the files
        conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
        insert conVer;    //Insert ContentVersion
        system.debug(conVer.Id);
        system.debug('******************'+parentId);
        
        Id conDoc = [SELECT ContentDocumentId
                     FROM ContentVersion
                     WHERE Id = :conVer.Id].ContentDocumentId;
        system.debug(conDoc);
        ContentDocumentLink conDocLink = New ContentDocumentLink();
        conDocLink.LinkedEntityId = parentId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
        conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
        conDocLink.shareType = 'I';
        insert conDocLink;
        return conDocLink.Id;
        
        
        
        
        
        /*base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');

Attachment oAttachment = new Attachment();
oAttachment.parentId = parentId;

oAttachment.Body = EncodingUtil.base64Decode(base64Data);
oAttachment.Name = fileName;
oAttachment.ContentType = contentType;

insert oAttachment;        
return oAttachment.Id;*/
    }
    
    private static void appendToFile(Id fileId, String base64Data) {
        base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');        
        Attachment a = [
            SELECT Id, Body
            FROM Attachment
            WHERE Id = : fileId
        ];
        
        String existingBody = EncodingUtil.base64Encode(a.Body);        
        a.Body = EncodingUtil.base64Decode(existingBody + base64Data);        
        update a;
    }
    
    public class Innerclass{
        @AuraEnabled public string fileName;
        @AuraEnabled public string fileContent;
    }
    @AuraEnabled
    public static void sendEmail(String recordId,string filedata){
        
        List<Innerclass> inn;
        if(filedata != null && filedata != '' && filedata != '[]'){
            system.debug('filedata'+filedata);
            inn = (List<Innerclass>)JSON.deserialize((filedata),List<Innerclass>.Class);
            system.debug(inn);
            system.debug(inn[0].fileName);
            system.debug(inn[0].fileContent);
        }
        
        
        buildertek__MSA_Settings__c msaSettings = [Select Id, buildertek__Site_URL__c,
                                                   buildertek__MSA_PDF_Template__c,
                                                   buildertek__MSA_Template__c,buildertek__Send_MSA_Template_Name__c
                                                   from buildertek__MSA_Settings__c
                                                   WHERE Name = 'MSA Settings' LIMIT 1];
        list<Account> accountlist = [select id,Name,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c from Account where id =:recordId];
        // List<Contact> contacts = [SELECT Id,Email, AccountId,Account.buildertek__MSA_Additional_Email__c FROM Contact WHERE AccountId IN: accountIds];
        List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE id =: accountlist[0].buildertek__Pre_Qual_Contact__c];
        List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:msaSettings.buildertek__Send_MSA_Template_Name__c];
        string body ='';
        if(template.size()>0){
            body= template[0].htmlvalue;
        }
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
        buildertek__MSA_Settings__c sitesUrl = [SELECT Id, buildertek__Site_URL__c FROM buildertek__MSA_Settings__c LIMIT 1];
        string link ='<a href="'+sitesUrl.buildertek__Site_URL__c+'/'+msaSettings.buildertek__MSA_Template__c+'?id='+accountlist[0].Id+'&isresend=false">Click here to open the Web Form</a>';
        string emailSubject;
        if(body.Contains('{!URL}')){
            body = body.replace('{!URL}',link);
        }
        if(template.size()>0){
            emailSubject = template[0].Subject;
        }
        List<String> toAddresses = new List<String>();
        //system.debug(contactsList[0].Email);
        system.debug(accountlist[0].buildertek__MSA_Additional_Email__c);
        if(contactsList.size() > 0 && contactsList[0].Email != null){
            system.debug('1');
            toAddresses.add(contactsList[0].Email);
        }else if(accountlist[0].buildertek__MSA_Additional_Email__c != null){
            system.debug('2');
            toAddresses.add(accountlist[0].buildertek__MSA_Additional_Email__c);
            system.debug('!!!'+toAddresses);
        }
        system.debug(toAddresses);
        system.debug(toAddresses.isEmpty());
        system.debug(toAddresses.size());
        if(toAddresses.size() > 0){
            system.debug('hi');
            
            
            
            
            
            for(account acc : accountlist){
                //toAddresses = new String[] {acc.buildertek__MSA_Additional_Email__c};
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddresses);
                //string emailSubject = 'PreQualified Email';
                email.setSubject(emailSubject);
                //String body = '<html><body><p><span>Congratulations, you have been pre-qualified. You will be receiving additional instructions shortly on next steps.  Please fill out our MSA form.  If you have any questions please let us know.';
                //body += '</span><br/><span><a href="'+msaSettings.buildertek__Site_URL__c+'/'+msaSettings.buildertek__MSA_Template__c+'?id='+Acc.Id+'">Click here to open the Web Form</a>';
                //body += '</span></p></body></html>'; 
                email.setHtmlBody(body);
                if(filedata != null && filedata != '' && filedata != '[]'){
                    List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                    
                    
                    
                    for(Innerclass i:inn){
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(i.fileName);
                        //efa.setBody(EncodingUtil.Base64Encode(Blob.valueOf(inn[0].fileContent)));
                        efa.setBody(EncodingUtil.base64Decode(i.fileContent));
                        fileAttachments.add(efa);
                        email.setFileAttachments(fileAttachments);
                    }
                    
                }
                
                mails.add(email);   
            }
            string addresses= '';
            string CCaddresses= '';
            Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
            if(results.size() > 0 ){
                if (results[0].isSuccess()) {
                    List<Account> accountsList = [SELECT Id, buildertek__Qualification_Date__c,buildertek__Qualification_Stage__c FROM Account WHERE Id =:recordId];
                    for(Account acc : accountsList){
                        acc.buildertek__Qualification_Date__c = system.now();
                        acc.buildertek__Qualification_Stage__c = 'MSA Sent';    
                    }
                    update accountsList;
                    integer i = 0;
                    for(String Str : toAddresses){
                        addresses += Str;
                        if(toAddresses.size() > i){
                            addresses += ';';
                        }
                        i++;
                    }
                    EmailMessage caseEmailMessage = new EmailMessage();
                    caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                    caseEmailMessage.ToAddress = addresses;
                    caseEmailMessage.FromName = UserInfo.getUserName();
                    caseEmailMessage.CcAddress = CCaddresses;
                    caseEmailMessage.Subject = emailSubject;
                    caseEmailMessage.HtmlBody = body;
                    caseEmailMessage.Incoming= False;
                    caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                    caseEmailMessage.MessageDate = system.now();
                    caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                    system.debug('Content length ---------> '+body.length());
                    caseEmailMessage.status = '5';
                    caseEmailMessage.RelatedToId = accountlist[0].id;
                    caseEmailMessage.buildertek__Subject__c = emailSubject;
                    
                    insert caseEmailMessage;
                }
            }
        }else{
            //accountlist[0].Name.addError('Error added to Name on trigger');
        }
    }
    
}