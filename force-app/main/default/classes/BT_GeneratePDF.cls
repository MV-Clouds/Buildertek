/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  10-Sep-2018createPDF
 */
public without sharing class BT_GeneratePDF{
	public string recordID;
	public string templateName;

	public string fileid{ get; set; }

	public transient string strBody{ get; set; }

	public string filerecid{ get; set; }

	public String imageURL{ get; set; }

	public Date CustomerAcceptedDate{ get; set; }

	public BT_GeneratePDF(){
	}

	public void createPDF(){

		string vendorID;
		// Pick a dummy Contact
		if (vendorID == null){
			Contact c;
			if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Email.isAccessible()){
				c = [select id, Email
				     from Contact
				     where email<>null
				     limit 1];
			}
			vendorID = c.id;
		}

        recordID = apexpages.currentPage().getParameters().get('recordId');
		string templateName = apexpages.currentPage().getParameters().get('templateName');
		string templateId = apexpages.currentPage().getParameters().get('templateId');
		String objectAPIName = '';
		string keyPrefix = recordID.substring(0, 3);

        for (Schema.SObjectType obj : Schema.getGlobalDescribe().Values()){
			String prefix = obj.getDescribe().getKeyPrefix();
			if (prefix == keyPrefix){
				objectAPIName = obj.getDescribe().getName();
				system.debug('objectAPIName --------> ' + objectAPIName);
				break;
			}
		}

        if (objectAPIName.contains('buildertek__Change_Order__c')){
			filerecid = apexpages.currentPage().getParameters().get('fileId');
			system.debug('filerecid --------> ' + filerecid);
			if (filerecid != null){
				buildertek__Change_Order__c corec = [select id, Name, buildertek__Status__c, buildertek__Date_Approved__c
				                                     from buildertek__Change_Order__c
				                                     where Id = :recordID
				                                     limit 1];
				CustomerAcceptedDate = system.today();
			}
		}

		if (objectAPIName.contains('buildertek__Purchase_Order__c')){
			filerecid = apexpages.currentPage().getParameters().get('fileId');
			system.debug('filerecid --------> ' + filerecid);
			if (filerecid != null){
				buildertek__Purchase_Order__c porec = [select id, Name, buildertek__Status__c, buildertek__Date_Approved__c, buildertek__Date_Confirmed__c
				                                       from buildertek__Purchase_Order__c
				                                       where Id = :recordID
				                                       limit 1];
				CustomerAcceptedDate = system.today();
			}
		}

		// Construct the list of emails we want to send
		string templateBody = '';
		string templateBody1 = '';
		string templateBody2 = '';
		List<Messaging.SingleEmailMessage> lstMsgs = new List<Messaging.SingleEmailMessage>();
		List<Messaging.SingleEmailMessage> lstMsgs1 = new List<Messaging.SingleEmailMessage>();
		List<String> templateList = new List<String>();
		Savepoint sp = Database.setSavepoint();
		Messaging.SingleEmailMessage msg = new Messaging.SingleEmailMessage();
		string theTemplate = [SELECT Id
		                      FROM EmailTemplate
		                      WHERE Id = :templateId].Id;
		msg.setTemplateId(theTemplate);
		msg.setWhatId(recordID);
		msg.setTargetObjectId(ID.valueOf(vendorID));
		msg.setToAddresses(new List<String>{'noreplay@buildertek.com'});
		lstMsgs.add(msg);
        System.debug('recordID::'+ recordID);
        System.debug('vendorID::'+ vendorID);

		// Send the emails in a transaction, then roll it back
		Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{msg});
		// Messaging.sendEmail(lstMsgs);
		Database.rollback(sp);
		// For each SingleEmailMessage that was just populated by the sendEmail() method, copy its
		// contents to a new SingleEmailMessage. Then send those new messages.
		for (Messaging.SingleEmailMessage emailNew : lstMsgs){
			templateBody1 = emailNew.getHTMLBody();
		}
		system.debug('templateBody1 ---------> ' + templateBody1);
		Messaging.SingleEmailMessage email1 = new Messaging.SingleEmailMessage();

		string theTemplate1 = '';
		EmailTemplate etemp;
		if (objectAPIName.contains('Contract')){
			if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
				etemp = [SELECT Id
				         FROM EmailTemplate
				         WHERE Name = 'BT Contract Proposal Images'];
			}
			theTemplate1 = etemp.Id;
		} else{
			if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
				etemp = [SELECT Id
				         FROM EmailTemplate
				         WHERE Name = 'BT Proposal Images'];
			}
			theTemplate1 = etemp.Id;
		}
		email1.setTemplateId(theTemplate1);
		email1.setWhatId(recordId);
		email1.setTargetObjectId(vendorID);
		email1.setSaveAsActivity(false);
		email1.setToAddresses(new List<String>{'noreplay@buildertek.com'});
		lstMsgs1.add(email1);
		Messaging.SendEmailResult[] r1 = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email1});
		System.debug('Email Results isSuccess = ' + r1[0].IsSuccess());
		Database.rollback(sp);
		for (Messaging.SingleEmailMessage emailNew1 : lstMsgs1){
			templateBody2 = emailNew1.getHTMLBody();
		}
		system.debug('templateBody 2 ----------> ' + templateBody2);
		templateBody = templateBody1 + templateBody2;
		system.debug('Final templateBody ----------> ' + templateBody);
		strBody = templateBody;
		system.debug('strBody -----> ' + strBody);
		// string Body = lstMsgs[0].getHTMLBody();
		//if(strBody == null)strBody = lstMsgs[0].getPlainTextBody();
		//strBody = templateBody1;
		try{
			document doc;
			doc = [SELECT ID
			       from Document
			       where DeveloperName = 'Company_Logo'
			       limit 1];
			string imageid = doc.id;
			imageid = imageid.substring(0, 15);
			strBody = strBody.replace('###############', imageid);
		} catch (exception ex){

		}
	}
}