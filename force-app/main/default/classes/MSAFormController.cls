public without sharing class MSAFormController {
    @AuraEnabled
    public static ResponseClass getMSASettings(string RecordId,string iscontractor){
        
        ResponseClass RC = new ResponseClass();
        try{
            buildertek__MSA_Settings__c msaSettings = new buildertek__MSA_Settings__c();
            List<buildertek__MSA_Settings__c> msaSettingsList = [Select Id, 
                                                                 buildertek__City__c,
                                                                 buildertek__Company_Full_Name__c,
                                                                 buildertek__Company_Name__c,
                                                                 buildertek__Fax__c,
                                                                 buildertek__MSA_Template__c,
                                                                 buildertek__Phone__c,
                                                                 buildertek__State__c,
                                                                 buildertek__Street__c,
                                                                 buildertek__Website__c,
                                                                 buildertek__Zipcode__c,
                                                                 buildertek__MSA_PDF_Template__c
                                                                 from buildertek__MSA_Settings__c
                                                                 WHERE Name = :'MSA Settings'];
            system.debug('^^msaSettingsList'+msaSettingsList);
            
            /* Account acc = [select id,buildertek__Pre_Qual_Contact__c from Account where id =:RecordId];
contact con;
if(acc.buildertek__Pre_Qual_Contact__c != null){
con = [select id,name,MailingAddress,Phone,Fax from contact where id =:acc.buildertek__Pre_Qual_Contact__c];
}*/
            string converId;
            if(iscontractor == 'YES'){
                List<string> contentdocIds = new List<string>();
                system.debug('RecordId'+RecordId);
                List<ContentDocumentLink> conlink = [select id,ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:RecordId];
                system.debug('^^conlink'+conlink);
                if(conlink.size()>0){
                    for(ContentDocumentLink con:conlink){
                        contentdocIds.add(con.ContentDocumentId);
                    }
                }
                
                system.debug('contentdocIds'+contentdocIds);
                List<ContentVersion> conversion = new List<ContentVersion>();
                
                
                if(contentdocIds.size()>0){
                    conversion = [select id,title,VersionData from ContentVersion where title = 'CompanySignature' AND ContentDocumentId IN:contentdocIds order by CreatedDate desc];
                }
                system.debug(conversion);
                
                if(conversion.size()>0){
                    converId = conversion[0].Id;
                }else{
                    converId = '';
                }
            } 
            Account acc = [select id,
                           name,Phone,fax,buildertek__City__c,buildertek__State__c,buildertek__ZipCode__c,buildertek__Federal_Tax_ID__c,buildertek__Contractor_License__c,buildertek__Office_Address__c,buildertek__Pre_Qual_Contact__c,buildertek__Sub_Contract_By__c,buildertek__Sub_Contract_Printed_Name__c,
                           buildertek__Sub_Contractor_Vendor_Name__c,buildertek__Contractor_Signed_date__c,buildertek__Agreement_Month__c,buildertek__Agreement_Day__c
                           from account 
                           where id=:RecordId];
            contact con; 
            
            if(acc.buildertek__Pre_Qual_Contact__c != null){
                con = [select id,name,Account.name from contact where id =:acc.buildertek__Pre_Qual_Contact__c];
            }
            
            
            
            
            if(msaSettingsList.size() > 0){
                msaSettings = msaSettingsList[0];   
            } 
            RC.msaSettings =  msaSettings;
            RC.accountdata =  acc;
            RC.contactdata = con;
            RC.currentdate = System.today();
            RC.contentVersionID = converId ;
            RC.status = 'Success';
            return RC;    
        }catch(Exception exp){
            system.debug(exp.getMessage());
            RC.status = 'Error';
            RC.message = exp.getMessage();
            return RC;
        }
        
        
    }  
    @AuraEnabled
    public static void UpdateAccount(string recId,string Name,string Phone,string Fax,string City,string State,string Zip,string Federal,string Contractor,string Address,string subContractorBy,string subContractorprintedName,string subContractorVendorName,string day,string month,string isContractor){
        // if(recId != null){
        system.debug(recId);
        Account acc = new Account();
        acc.id = recId;
        acc.Name = Name;
        acc.Phone = Phone;
        acc.Fax = Fax;
        acc.buildertek__City__c = City;
        acc.buildertek__State__c = State;
        acc.buildertek__ZipCode__c = Zip;
        acc.buildertek__Federal_Tax_ID__c = Federal;
        acc.buildertek__Contractor_License__c = Contractor;
        acc.buildertek__Office_Address__c = Address;
        acc.buildertek__Sub_Contract_By__c = subContractorBy;
        acc.buildertek__Sub_Contract_Printed_Name__c = subContractorprintedName;
        acc.buildertek__Sub_Contractor_Vendor_Name__c = subContractorVendorName;
        if(isContractor == 'YES'){
            acc.buildertek__Contractor_Signed_date__c = System.today(); 
        }
        
        acc.buildertek__Agreement_Day__c = day;
        acc.buildertek__Agreement_Month__c = month;
        update acc;
        system.debug('@@@@@@'+acc);
        // }  
        
    }
    
    
    
    @AuraEnabled
    public static string saveSign(String recId, String base64Data, String contentType, string signName, String contractorSignbase64Data,boolean iscontractor){
        system.debug('base64Data-------------' + base64Data);
        system.debug('iscontractor'+iscontractor);
        system.debug('contractorSignbase64Data'+contractorSignbase64Data);
        system.debug('base64Data'+base64Data);
        string conversn;
        if (base64Data.length() > 1696 || contractorSignbase64Data.length() > 1696 || Test.isRunningTest()){
            if(iscontractor == true){
                contractorSignbase64Data = EncodingUtil.urlDecode(contractorSignbase64Data, 'UTF-8');
            }else{
                base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
            }
            
            ContentVersion conVer = new ContentVersion();
            conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
            if(iscontractor == true){
                conVer.PathOnClient = 'ContractorSignatureName.png';
            }else{
                conVer.PathOnClient = 'CompanySignature.png'; // The files name, extension is very important here which will help the file in preview.
            }
            conVer.Title = signName; // Display name of the files
            if(iscontractor == true){
                conVer.VersionData = EncodingUtil.base64Decode(contractorSignbase64Data);
            }else{
                conVer.VersionData = EncodingUtil.base64Decode(base64Data);
            }
            // converting your binary string to Blog
            insert conVer;    //Insert ContentVersion
            system.debug('conVer'+conVer);
            system.debug('*******conVer*******' + conVer);
            // First get the Content Document Id from ContentVersion Object
            Id conDoc = [SELECT ContentDocumentId
                         FROM ContentVersion
                         WHERE Id = :conVer.Id].ContentDocumentId;
            //create ContentDocumentLink  record
            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = recId; // Specify RECORD ID here i.e Any Object ID (Standard Object/Custom Object)
            conDocLink.ContentDocumentId = conDoc;  //ContentDocumentId Id from ContentVersion
            conDocLink.shareType = 'I';
            insert conDocLink;
            system.debug('conDocLink---' + conDocLink.id);
            
            list<buildertek__Quote__c> quoterec;
            
            quoterec = [select id, Name, buildertek__Status__c, buildertek__Date_Sent_To_Customer__c, buildertek__Date_Accepted_by_Customer__c
                        from buildertek__Quote__c
                        where Id = :recId
                        limit 1];
            
            if (quoterec.size() > 0){
                
                quoterec[0].buildertek__Status__c = 'Customer Accepted';
                
                quoterec[0].buildertek__Date_Accepted_by_Customer__c = system.now();
                
                update quoterec;
                system.debug(quoterec + 'quoterec---' + quoterec[0].buildertek__Date_Accepted_by_Customer__c);
            }
            
            conversn = [SELECT Id, VersionData
                        FROM ContentVersion
                        WHERE ContentDocumentId = :conDoc AND IsLatest = true].Id;
            //system.debug('conversn[0].Id ='+conversn[0].Id);
            return conversn;
        } else{
            String message = 'NoImage';
            return message;
        }
    }
    
    @auraEnabled
    public static String getJSonString(string jsonData,string AccountId,string FileId,String isContractor,string isresendMSA)
    {
        try{
            system.debug(jsonData);
            system.debug('FileId'+FileId);
            system.debug(isresendMSA);
            /* string contractor='';
if(iscontractor == true){
contractor = 'true';
}else{
contractor = 'false';
}*/
            Account acc = [SELECT Id, Name, buildertek__Contract_Signed__c,buildertek__Contractor_Signed_datetime__c,buildertek__Sub_Contractor_Signed_Date__c,Owner.Email, buildertek__Qualification_Stage__c FROM Account WHERE Id =: AccountId];
            acc.buildertek__Contract_Signed__c = system.today();
            
            acc.buildertek__Is_ResendMSA__c = true;
            if(iscontractor == 'YES' ){
                acc.buildertek__Is_Contract_Signed__c = true;
                acc.buildertek__Contractor_Signed_datetime__c = system.now();
            }else if(iscontractor == 'NO'){
                acc.buildertek__Sub_Contractor_Signed_Date__c = system.now();
            }
            
            acc.buildertek__Qualification_Stage__c = 'MSA Signed';
            //update acc;
            buildertek__MSA_Settings__c msaSettings = [Select Id, 
                                                       buildertek__MSA_PDF_Template__c,
                                                       buildertek__MSA_Template__c,
                                                       buildertek__MSA_Email__c,buildertek__MSA_Sign_Template_Name__c,
                                                       buildertek__MSA_Sign_Contractor_Template_Name__c
                                                       from buildertek__MSA_Settings__c
                                                       WHERE Name = :'MSA Settings' LIMIT 1];
            List<EmailTemplate> template = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:msaSettings.buildertek__MSA_Sign_Template_Name__c];  
            string emailSubject;
            string body ='';
            if(template.size()>0){
                emailSubject= template[0].Subject;
                body = template[0].htmlvalue;
            }  
            if(body.contains('{!Account.Link}')){
                string urls = String.valueof(URL.getOrgDomainUrl()).replace('Url:[delegate=','').replace(']','');
                body = body.replace('{!Account.Name}',acc.Name);
                body = body.replace('{!Account.Link}',urls +'/'+ acc.Id);
            } 
            List<ContentVersion> conver;
            List<string> condocIdList = new List<string>();
            system.debug('%%%%'+isContractor);
            if(isContractor == 'YES'){
                List<ContentDocumentLink> css = [select id,ContentDocumentId,LinkedEntityId from ContentDocumentLink where LinkedEntityId=:AccountId];
                for(ContentDocumentLink con:css){
                    condocIdList.add(con.ContentDocumentId);
                }
                system.debug(condocIdList);
                system.debug('###'+css);
                if(condocIdList.size()>0){
                    conver = [SELECT Id,title, VersionData,ContentDocumentId FROM ContentVersion where title='CompanySignature' And ContentDocumentId IN:condocIdList  order by CreatedDate desc];
                }
            }                                              
            system.debug('###'+conver);
            PageReference pagePdf = new PageReference('/apex/'+msaSettings.buildertek__MSA_PDF_Template__c);
            pagePdf.getParameters().put('contentdata', jsonData);
            pagePdf.getParameters().put('iscontractor',string.valueof(iscontractor));
            if(iscontractor == 'YES' ){
                pagePdf.getParameters().put('FileId', conver[0].Id);
                pagePdf.getParameters().put('contractorFileId',FileId);
            }else{
                pagePdf.getParameters().put('FileId', FileId);
            }
            blob pdfPageBlob = !Test.isRunningTest() ? pagePdf.getContentAsPDF() : Blob.ValueOf('dummy text01'); 
            system.debug('#################'+pdfPageBlob);
            
            if(!Test.isRunningTest()){
                MSAFormBoxController.saveFileInBox(pdfPageBlob,AccountId,iscontractor,isresendMSA);
            }
            if(iscontractor == 'YES' ){
                ContentVersion changeLogFile = new ContentVersion(FirstPublishLocationId = AccountId, 
                                                                  Description = 'Fully Executed MSA',
                                                                  PathOnClient = 'Fully Executed MSA.pdf',
                                                                  Title = 'Fully Executed MSA.pdf',
                                                                  VersionData = pdfPageBlob
                                                                 );
                insert changeLogFile;
            }else if(iscontractor == 'NO'){
                ContentVersion changeLogFile = new ContentVersion(FirstPublishLocationId = AccountId, 
                                                                  Description = 'Vendor Signed MSA',
                                                                  PathOnClient = 'Vendor Signed MSA.pdf',
                                                                  Title = 'Vendor Signed MSA.pdf',
                                                                  VersionData = pdfPageBlob
                                                                 );
                insert changeLogFile;
                
            }
            
            update acc;
            if(iscontractor == 'YES'){
                system.debug(accountId);
                string name = '';
                Organization org = [SELECT Id,Name from Organization limit 1];
                buildertek__MSA_Settings__c sitesUrl = [SELECT Id,buildertek__Submit_MSA_template_Name__c FROM buildertek__MSA_Settings__c LIMIT 1];
                List<Account> act = [SELECT Id,buildertek__MSA_Additional_Email__c,buildertek__Pre_Qual_Contact__c FROM Account WHERE id =: AccountId ];
                List<Contact> contactsList = [SELECT Id, Name, Email FROM Contact WHERE id =: act[0].buildertek__Pre_Qual_Contact__c];
                List<EmailTemplate> temp = [SELECT Id, Name, Subject, Body,htmlvalue FROM EmailTemplate  WHERE Name =:sitesUrl.buildertek__Submit_MSA_template_Name__c];
                List<String> toAddresses = new List<String>();
                if(contactsList.size() > 0){
                    name = contactsList[0].Name;
                    toAddresses.add(contactsList[0].Email);
                }else{
                    name = act[0].buildertek__MSA_Additional_Email__c;
                    toAddresses.add(act[0].buildertek__MSA_Additional_Email__c);
                }
                
                
                string emailSub;
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                email.setToAddresses(toAddresses);
                if(temp.size()>0){
                    emailSub = temp[0].Subject;
                }
                
                email.setSubject(emailSub);
                email.setSaveAsActivity(true);
                //String body = '<html><body><p><span>Hi '+Name+',</span><br/><br/>';
                // body += '<span> Congratulations! You have completed the pre-qualification process.Please keep the attached document for your records.we look forward to doing bussiness with you and your team.<br/><br/></span></p></body></html>';
                string body2 = '';
                if(!temp.isEmpty()){
                    body2 = temp[0].htmlvalue;
                }
                if(body2.contains('{!Contact.Name}')){
                    body2 = body2.replace('{!Contact.Name}',name);
                }
                email.setHtmlBody(body2);
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName('Fully Executed MSA.pdf');
                efa.setBody(setAttachmentBody(jsonData,fileId,msaSettings,isContractor,conver[0].Id));
                fileAttachments.add(efa);
                
                email.setFileAttachments(fileAttachments);
                mails.add(email);
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                if(results.size() > 0){
                    if (results[0].isSuccess()) {
                        Account ac = [SELECT Id, buildertek__Qualification_Stage__c FROM Account WHERE Id =: accountId];
                        ac.buildertek__Qualification_Stage__c = 'Fully Executed';
                        ac.buildertek__Fully_Executed_Date__c = system.now();
                        update ac;
                        
                        string addresses= '';
                        string CCaddresses= '';
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
                        caseEmailMessage.RelatedToId = accountId;
                        caseEmailMessage.buildertek__Subject__c = emailSubject;
                        
                        insert caseEmailMessage;
                        
                        
                        
                        
                    }    
                }
                
            }else if(iscontractor == 'NO'){
                
                List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                String[] toAddress = new string[]{acc.Owner.Email};
                    email.setToAddresses(toAddress);
                email.setSaveAsActivity(true);
                //string emailSubject = 'Qualified Email';
                email.setSubject(emailSubject);
                //String body = '<html><body><p><span>'+ acc.Name +' has just been qualified and the MSA has been signed';
                //body += '</span></p></body></html>';
                email.setHtmlBody(body);
                List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                efa.setFileName('Vendor Signed MSA.pdf');
                system.debug('fileId'+fileId);
                efa.setBody(setAttachmentBody(jsonData,fileId,msaSettings,isContractor));
                fileAttachments.add(efa);
                email.setFileAttachments(fileAttachments);
                mails.add(email); 
                
                // EmailTemplate emailtemp = [select id,HtmlValue,Subject from EmailTemplate where DeveloperName = 'MSA_Form_Template'];
                EmailTemplate emailtemplate = [select id,HtmlValue,Subject from EmailTemplate where Name =:msaSettings.buildertek__MSA_Sign_Contractor_Template_Name__c];
                string emailbody = emailtemplate.HtmlValue;
                string subject = emailtemplate.Subject;
                
                Messaging.SingleEmailMessage emails = new Messaging.SingleEmailMessage();
                String[] toAddresss = new string[]{msaSettings.buildertek__MSA_Email__c};
                    emails.setToAddresses(toAddresss);
                string qualifiedemailSubject = 'New Qualified Email';
                emails.setSubject(subject);
                emails.setSaveAsActivity(true);
                //String emailbody = '<html>  <body>      <p>         <span>              Contractor have been singed. please see attached link           </span>                         <br/>           <span>              {!Account.Link}         </span>     </p>    </body></html>';
                string urls = String.valueof(URL.getOrgDomainUrl()).replace('Url:[delegate=','').replace(']','');
                emailbody = emailbody.replace('{!Account.Link}',urls +'/'+ acc.Id);
                emails.setHtmlBody(emailbody);
                List<Messaging.Emailfileattachment> listfileAttachments = new List<Messaging.Emailfileattachment>();
                Messaging.Emailfileattachment efas = new Messaging.Emailfileattachment();
                efas.setFileName('MSAForm.pdf');
                efas.setBody(setAttachmentBody(jsonData,fileId,msaSettings,isContractor));
                listfileAttachments.add(efas);
                emails.setFileAttachments(listfileAttachments);
                mails.add(emails);   
                
                Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
                system.debug('results **'+ results);
                if(results.size() > 0){
                    if (results[0].isSuccess()) {
                        string addressString= '';
                        integer i = 0;
                        for(String Str : toAddress){
                            addressString += Str;
                            if(toAddress.size() > i){
                                addressString += ';';
                            }
                            i++;
                        }
                        EmailMessage caseEmailMessage = new EmailMessage();
                        caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                        caseEmailMessage.ToAddress = addressString;
                        caseEmailMessage.FromName = UserInfo.getUserName();
                        //caseEmailMessage.CcAddress = CCaddresses;
                        caseEmailMessage.Subject = emailSubject;
                        caseEmailMessage.HtmlBody = body;
                        caseEmailMessage.Incoming= False;
                        caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                        caseEmailMessage.MessageDate = system.now();
                        caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                        system.debug('Content length ---------> '+body.length());
                        caseEmailMessage.status = '5';
                        caseEmailMessage.RelatedToId = AccountId;
                        caseEmailMessage.buildertek__Subject__c = emailSubject;
                        
                        insert caseEmailMessage;
                    }
                    if(results[1].isSuccess()){
                        string addressString= '';
                        integer i = 0;
                        for(String Str : toAddresss){
                            addressString += Str;
                            if(toAddresss.size() > i){
                                addressString += ';';
                            }
                            i++;
                        }
                        EmailMessage caseEmailMessage = new EmailMessage();
                        // caseEmailMessage.fromAddress= UserInfo.getUserEmail();
                        caseEmailMessage.ToAddress = addressString;
                        caseEmailMessage.FromName = UserInfo.getUserName();
                        //caseEmailMessage.CcAddress = CCaddresses;
                        caseEmailMessage.Subject = subject;
                        caseEmailMessage.HtmlBody = emailbody;
                        caseEmailMessage.Incoming= False;
                        caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
                        caseEmailMessage.MessageDate = system.now();
                        caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
                        system.debug('Content length ---------> '+body.length());
                        caseEmailMessage.status = '5';
                        caseEmailMessage.RelatedToId = AccountId;
                        caseEmailMessage.buildertek__Subject__c = subject;
                        insert caseEmailMessage;
                    }
                    
                    
                    
                }
            }
            return 'success';
        }catch(Exception e) {
            return e.getMessage();
            
        }
    }
    
    private static Blob setAttachmentBody( String jsonData, String FileId, buildertek__MSA_Settings__c msaSettings,string isContractor){
        PageReference pdf = new PageReference('/apex/'+msaSettings.buildertek__MSA_PDF_Template__c);
        pdf.getParameters().put('contentdata', jsonData);
        pdf.getParameters().put('FileId', FileId); 
        pdf.getParameters().put('iscontractor',string.valueof(iscontractor));      
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
    }
    
    private static Blob setAttachmentBody( String jsonData, String FileId, buildertek__MSA_Settings__c msaSettings,string isContractor,string contverid){
        PageReference pdf = new PageReference('/apex/'+msaSettings.buildertek__MSA_PDF_Template__c);
        pdf.getParameters().put('contentdata', jsonData);
        pdf.getParameters().put('iscontractor',string.valueof(iscontractor));
        if(iscontractor == 'YES'){
            pdf.getParameters().put('FileId', contverid);
            pdf.getParameters().put('contractorFileId',FileId);
        }else{
            pdf.getParameters().put('FileId', FileId);
        }
        
        pdf.setRedirect(true);
        
        Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
        return blobbody;
        
    }
    
    @AuraEnabled
    public static ResponseClass getErrorMsg(){
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter value'));
        return null;
    }
    
    public class ResponseClass{
        @AuraEnabled public buildertek__MSA_Settings__c msaSettings;
        @AuraEnabled public Account accountdata;
        @AuraEnabled public Contact contactdata;
        @AuraEnabled public Date currentdate;
        @AuraEnabled public String status;
        @AuraEnabled public String contentVersionID;
        @AuraEnabled public String message;
    }
}