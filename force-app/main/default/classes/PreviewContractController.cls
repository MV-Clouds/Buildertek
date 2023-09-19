public with sharing class PreviewContractController{
	public String templateBody{ get; set; }

	public String finalTemplateBody{ get; set; }

	public buildertek__Contract__c contract{
		get;

		set;
	}

	public List<buildertek__Contract_Item__c> contractLinesList{ get; set; }

	public String recId{ get; set; }

	public PreviewContractController(){
	}

	@AuraEnabled
	public Static List<EmailTemplate> getTemplates(String recordId){
		List<EmailTemplate> emailtemp;
		if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Emailtemplate.fields.folderId.isAccessible() && Schema.sObjectType.folder.fields.Name.isAccessible()){
			emailtemp = [Select Id, Name, folder.name
			             from Emailtemplate
			             where folder.name = 'BT Contract'and Name !=:'Contract Template 1'];
		}
		return emailtemp;
	}

	public void ContractMethod(){
		Contact con;
		if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
			con = [select id, Email
			       from Contact
			       where email != null
			       order by createddate desc
			       limit 1];
		}
		String[] toaddres;
		toaddres = new String[]{con.email};
		Savepoint sp = Database.setSavepoint();
		list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		string theTemplate;
		if (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
			theTemplate = [SELECT Id
			               FROM EmailTemplate
			               WHERE Name = 'Contract Template 1'].Id;
		}
		email.setTemplateId(theTemplate);
		email.setWhatId(recId);
		email.setTargetObjectId(con.Id);
		email.setSaveAsActivity(false);
		email.setToAddresses(toaddres);
		msgList.add(email);
		Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
		System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
		Database.rollback(sp);


		for (Messaging.SingleEmailMessage emailNew : msgList){
			templateBody = emailNew.getHTMLBody();
		}
		//System.debug('Email Results isSuccess = ' +  templateBody);
	}

	@AuraEnabled
	public static string getContractLines(String recordId, String templateId){
		string templateBody = '';
		string templateBody1 = '';
		string templateBody2 = '';
		Contact con;
		if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
			con = [select id, Email
			       from Contact
			       where email != null
			       order by createddate desc
			       limit 1];
		}
		String[] toaddres;
		toaddres = new String[]{con.email};
		// toaddres = new String[]{'info@buildertek.com'};
		System.debug('toaddres '+toaddres);
		Savepoint sp = Database.setSavepoint();
		list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
		list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
		List<String> templateList = new List<String>();
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		string theTemplate;
		if (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
			theTemplate = [SELECT Id
			               FROM EmailTemplate
			               WHERE Id = :templateId].Id;
		}
		email.setTemplateId(theTemplate);
		email.setWhatId(recordId);
		email.setTargetObjectId(con.Id);
		email.setSaveAsActivity(false);
		email.setToAddresses(toaddres);
		msgList.add(email);

		Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
		System.debug('Email Results isSuccess = ' + r[0].IsSuccess());
		Database.rollback(sp);
		for (Messaging.SingleEmailMessage emailNew : msgList){
			templateBody1 = emailNew.getHTMLBody();
		}


		Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();
		string theTemplate1 = '';
		if (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
			theTemplate1 = [SELECT Id
			                FROM EmailTemplate
			                WHERE Name = 'BT Contract Proposal Images'].Id;
		}
		email1.setTemplateId(theTemplate1);
		email1.setWhatId(recordId);
		email1.setTargetObjectId(con.Id);
		email1.setSaveAsActivity(false);
		email1.setToAddresses(toaddres);
		msgList1.add(email1);
		Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
		System.debug('Email Results isSuccess = ' + r1[0].IsSuccess());
		Database.rollback(sp);
		for (Messaging.SingleEmailMessage emailNew1 : msgList1){
			templateBody2 = emailNew1.getHTMLBody();
		}
		system.debug('templateBody 2 ----------> ' + templateBody2);
		templateBody = templateBody1 + templateBody2;
		system.debug('Final templateBody ----------> ' + templateBody);
		return templateBody;
	}

	@AuraEnabled
	public static List<buildertek__Proposal_Images__c> getProposalImages(String recordId){
		List<buildertek__Proposal_Images__c> proposalImagesList;
		if (Schema.sObjectType.buildertek__Proposal_Images__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Image__c.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Contract__c.isAccessible()){
			proposalImagesList = [SELECT Id, buildertek__Image__c, buildertek__Contract__c, buildertek__Description__c
			                      FROM buildertek__Proposal_Images__c
			                      WHERE buildertek__Contract__c = :recordId];
		}

		return proposalImagesList;
	}

	@AuraEnabled
	public static String sendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc){
		try{
			string fileid = '';
			String body = '';
			String subject = '';
			list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c
			                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
			                                                                                            WHERE Name = :'Create Contract on Quote Acceptance' and buildertek__Email_Subject__c != null
			                                                                                            limit 1];
			if (adminInterfaceNodeConfigurations.size() > 0){
				subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
			} else{
				subject = 'Contract';
			}
			/* buildertek__Contract__c contract;
			 if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
			 Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
			 Schema.sObjectType.contact.fields.Email.isAccessible() ){
			 contract = [SELECT Id, buildertek__Primary_Contact__r.Email FROM buildertek__Contract__c WHERE Id =: recordId];
			 }*/
			List<String> strTO = new List<String>();
			List<string> strCC = new List<string>();
			SET<Id> contactIdSet = new SET<Id>();
			List<Contact> conList = new List<Contact>();
			if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){
				conList = [Select Id, email
				           from Contact
				           where Id IN :to and Email != null];
			}
			system.debug('conList -------> ' + conList);
			for (Contact con : conList){
				strTO.add(con.email);
			}
			List<Contact> ccConList = new List<Contact>();
			if (cc.size() > 0){

				if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
					ccConList = [Select Id, email
					             from Contact
					             where Id IN :cc and Email != null];
				}
			}
			if (ccConList.size() > 0){
				for (Contact con : ccConList){
					strCC.add(con.email);
				}
			}
			
			// strTO.add(contract.buildertek__Primary_Contact__r.Email);
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(strTO);
            if (conList.size() > 0){
                mail.setTargetObjectId(conList[0].Id);
                mail.setSaveAsActivity(true);
                mail.setWhatId(recordId);
            }
            if (strCC != null && strCC.size() > 0){
				system.debug('strCC -------> ' + strCC);
				mail.setCcAddresses(strCC);
			}
			EmailServicesAddress eServices;
			if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
				eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
				             FROM EmailServicesAddress
				             where LocalPart = 'projects'];
			}
			List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
			string SiteUrl;
			if (confirmationurl.size() > 0){
				SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
			}
			string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
			body += 'Hi <br/><br/> ';
			body += '</br> Please &nbsp;';
			body += '<a href=' + SiteUrl + 'buildertek__ConfirmationPage?Id=' + recordId + '&templateId=' + templateId + '>Click here</a>';
			body += '&nbsp;to confirm your contract details.';
			mail.setReplyTo(fromAddress);
			subject = subject + '[ref:' + recordId + ']';
			mail.setSubject(subject);
			mail.setHTMLBody(body);
			List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
			efa.setFileName('Contract.pdf');
			efa.setBody(setAttachmentBody(recordId, templateId, fileid));
			fileAttachments.add(efa);
			mail.setFileAttachments(fileAttachments);
			mails.add(mail);
			Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
			/*if(results.size() > 0){
			 string Toaddresses= '';
			 integer i = 0;
			 for(String Str : strTO){
			 Toaddresses += Str;
			 i++;
			 if(i < strTO.size()){
			 Toaddresses += ';';
			 }

			 }
			 }*/
			if (results.size() > 0){
				if (results[0].isSuccess()){
					string Toaddresses = '';
					string CCaddresses = '';
					integer i = 0;
					for (String Str : strTO){
						Toaddresses += Str;
						if (strTO.size() > i){
							Toaddresses += ';';
						}
						i++;
					}
					for (String Str : strCC){
						CCaddresses += Str;
						if (strCC.size() > i){
							CCaddresses += ';';
						}
						i++;

					}
					system.debug('CCaddresses ----------> ' + CCaddresses);
					EmailMessage caseEmailMessage = new EmailMessage();
					caseEmailMessage.fromAddress = UserInfo.getUserEmail();
					caseEmailMessage.ToAddress = Toaddresses;
					caseEmailMessage.FromName = UserInfo.getUserName();
					caseEmailMessage.CcAddress = CCaddresses;
					caseEmailMessage.Subject = subject;
					caseEmailMessage.HtmlBody = body;
					caseEmailMessage.Incoming = False;
					caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
					caseEmailMessage.MessageDate = system.now();
					caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
					system.debug('Content length ---------> ' + body.length());
					caseEmailMessage.status = '5';
					caseEmailMessage.RelatedToId = recordId;
					caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;

					insert caseEmailMessage;

					EmailMessageRelation emr = new EmailMessageRelation();
					emr.emailMessageId = caseEmailMessage.id;
					emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
					emr.relationType = 'FromAddress';
					emr.relationAddress = caseEmailMessage.fromAddress;
					insert emr;

				}
			}
			String message = 'Success';
			buildertek__Contract__c contract;

			contract = [SELECT Id, buildertek__Status__c, buildertek__Signed_Contract_Date__c, buildertek__Customer_Accepted_Date__c
			            FROM buildertek__Contract__c
			            WHERE Id = :recordId];
			if (contract != null){
				//contract.buildertek__Signed_Contract_Date__c = system.today();
				contract.buildertek__Status__c = 'Out for Signature';
				update contract;
			}
			return message;
		} catch (Exception exp){
			String message = exp.getMessage();
			return message;
		}
	}

	private static Blob setAttachmentBody(String recordId, String templateId, string fileid){
		pagereference pdf;
		pdf = Page.buildertek__BT_GenerateQuotePDF;
		pdf.getParameters().put('recordId', recordId);
		pdf.getParameters().put('templateId', templateId);
		pdf.getParameters().put('fileId', fileId);
		pdf.setRedirect(true);

		Blob blobbody = !Test.isRunningTest() ? pdf.getContent() : Blob.ValueOf('dummy text');
		return blobbody;
	}

	/* To Save the Signature in Files */
	@AuraEnabled
	public static string saveSign(String recId, String base64Data, String contentType, string signName){
		system.debug('base64Data-------------' + base64Data);
		string conversn;
		if (base64Data.length() > 1696 || Test.isRunningTest()){
			base64Data = EncodingUtil.urlDecode(base64Data, 'UTF-8');
			ContentVersion conVer = new ContentVersion();
			conVer.ContentLocation = 'S'; // to use S specify this document is in Salesforce, to use E for external files
			conVer.PathOnClient = 'SignatureName.png'; // The files name, extension is very important here which will help the file in preview.
			conVer.Title = signName; // Display name of the files
			conVer.VersionData = EncodingUtil.base64Decode(base64Data); // converting your binary string to Blog
			insert conVer;    //Insert ContentVersion
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
			buildertek__Contract__c contract;

			contract = [SELECT Id, buildertek__Signed_Contract_Date__c, buildertek__Customer_Accepted_Date__c
			            FROM buildertek__Contract__c
			            WHERE Id = :recId];
			if (contract != null){
				contract.buildertek__Signed_Contract_Date__c = system.today();
				update contract;
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

	@AuraEnabled
	public static String acceptandsendProposal(String htmlBody, String recordId, String templateId, List<String> to, List<String> cc, string Emailsubject, string fileid){
		try{
			String body = '';
			String subject = '';
			list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id, buildertek__Quote_Configuration__c, buildertek__Email_Subject__c
			                                                                                            from buildertek__Admin_Interface_Node_Configuration__c
			                                                                                            WHERE Name = :'Create Contract on Quote Acceptance' and buildertek__Email_Subject__c != null
			                                                                                            limit 1];
			if (adminInterfaceNodeConfigurations.size() > 0){
				subject = adminInterfaceNodeConfigurations[0].buildertek__Email_Subject__c;
			} else{
				subject = 'Contract';
			}
			/* buildertek__Contract__c contract;
			 if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
			 Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Primary_Contact__c.isAccessible() &&
			 Schema.sObjectType.contact.fields.Email.isAccessible() ){
			 contract = [SELECT Id, buildertek__Primary_Contact__r.Email FROM buildertek__Contract__c WHERE Id =: recordId];
			 }*/
			List<String> strTO = new List<String>();
			List<string> strCC = new List<string>();
			SET<Id> contactIdSet = new SET<Id>();
			List<Contact> conList = new List<Contact>();
			if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){
				conList = [Select Id, email
				           from Contact
				           where Id IN :to and Email != null];
			}
			system.debug('conList -------> ' + conList);
			for (Contact con : conList){
				strTO.add(con.email);
			}
			
			List<Contact> ccConList = new List<Contact>();
			if (cc.size() > 0){

				if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
					ccConList = [Select Id, email
					             from Contact
					             where Id IN :cc and Email != null];
				}
			}
			if (ccConList.size() > 0){
				for (Contact con : ccConList){
					strCC.add(con.email);
				}
			}
			// strTO.add(contract.buildertek__Primary_Contact__r.Email);
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setToAddresses(strTO);
            if (conList.size() > 0){
				mail.setTargetObjectId(conList[0].Id);
				mail.setSaveAsActivity(true);
				mail.setWhatId(recordId);
			}
			if (strCC != null && strCC.size() > 0){
				system.debug('strCC -------> ' + strCC);
				mail.setCcAddresses(strCC);
			}
			EmailServicesAddress eServices;
			if (Schema.sObjectType.EmailServicesAddress.fields.Id.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.AuthorizedSenders.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.EmailDomainName.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.LocalPart.isAccessible() && Schema.sObjectType.EmailServicesAddress.fields.IsActive.isAccessible()){
				eServices = [SELECT Id, AuthorizedSenders, EmailDomainName, IsActive, LocalPart
				             FROM EmailServicesAddress
				             where LocalPart = 'projects'];
			}
			List<buildertek__ConfirmationPageSiteURL__c> confirmationurl = buildertek__ConfirmationPageSiteURL__c.getall().values();
			string SiteUrl;
			if (confirmationurl.size() > 0){
				SiteUrl = confirmationurl[0].buildertek__SiteURL__c;
			}
			string fromAddress = eServices.LocalPart + '@' + eServices.EmailDomainName;
			body += 'Hi <br/><br/> ';
			body += '</br> Please &nbsp;';
			body += '<a href=' + SiteUrl + 'buildertek__ConfirmationPage?Id=' + recordId + '&templateId=' + templateId + '>Click here</a>';
			body += '&nbsp;to confirm your contract details.';
			mail.setReplyTo(fromAddress);
			subject = subject + '[ref:' + recordId + ']';
			mail.setSubject(subject);
			mail.setHTMLBody(body);
			List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
			Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
			efa.setFileName('Contract.pdf');
			efa.setBody(setAttachmentBody(recordId, templateId, fileid));
			fileAttachments.add(efa);
			mail.setFileAttachments(fileAttachments);
			mails.add(mail);
			Messaging.SendEmailResult[] results = Messaging.sendEmail(mails);
			/* if(results.size() > 0){
			 string Toaddresses= '';
			 integer i = 0;
			 for(String Str : strTO){
			 Toaddresses += Str;
			 i++;
			 if(i < strTO.size()){
			 Toaddresses += ';';
			 }

			 }
			 } */
			if (results.size() > 0){
				if (results[0].isSuccess()){
					string Toaddresses = '';
					string CCaddresses = '';
					integer i = 0;
					for (String Str : strTO){
						Toaddresses += Str;
						if (strTO.size() > i){
							Toaddresses += ';';
						}
						i++;
					}
					for (String Str : strCC){
						CCaddresses += Str;
						if (strCC.size() > i){
							CCaddresses += ';';
						}
						i++;

					}
					system.debug('CCaddresses ----------> ' + CCaddresses);
					EmailMessage caseEmailMessage = new EmailMessage();
					caseEmailMessage.fromAddress = UserInfo.getUserEmail();
					caseEmailMessage.ToAddress = Toaddresses;
					caseEmailMessage.FromName = UserInfo.getUserName();
					caseEmailMessage.CcAddress = CCaddresses;
					caseEmailMessage.Subject = subject;
					caseEmailMessage.HtmlBody = body;
					caseEmailMessage.Incoming = False;
					caseEmailMessage.buildertek__Is_Incoming_Email__c = false;
					caseEmailMessage.MessageDate = system.now();
					caseEmailMessage.TextBody = body.replaceAll('<br/>', '\n');
					system.debug('Content length ---------> ' + body.length());
					caseEmailMessage.status = '5';
					caseEmailMessage.RelatedToId = recordId;
					caseEmailMessage.buildertek__Subject__c = 'Re: ' + subject;

					insert caseEmailMessage;


					EmailMessageRelation emr = new EmailMessageRelation();
					emr.emailMessageId = caseEmailMessage.id;
					emr.relationId = UserInfo.getUserId(); // user id / contact Id of the sender
					emr.relationType = 'FromAddress';
					emr.relationAddress = caseEmailMessage.fromAddress;
					insert emr;

				}
			}
			String message = 'Success';
			buildertek__Contract__c contract;

			contract = [SELECT Id, buildertek__Status__c, buildertek__Signed_Contract_Date__c, buildertek__Customer_Accepted_Date__c
			            FROM buildertek__Contract__c
			            WHERE Id = :recordId];
			if (contract != null){
				contract.buildertek__Signed_Contract_Date__c = system.today();
				contract.buildertek__Status__c = 'Out for Signature';
				update contract;
			}
			return message;
		} catch (Exception exp){
			String message = exp.getMessage();
			return message;
		}
	}
}