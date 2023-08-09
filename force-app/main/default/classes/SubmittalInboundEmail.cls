global with sharing class SubmittalInboundEmail implements Messaging.InboundEmailHandler{
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope){
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		system.debug('fromAddress --> ' + email.fromAddress);
		String replyTo = email.replyTo;
		String[] toAddresses = email.toAddresses;
		String fromAddress = email.fromAddress;
		String[] ccAddresses = email.ccAddresses;
		String fromname = email.fromname;
		String emailSubject = email.Subject;
		String htmlBody = email.htmlBody;
		String plainTextBody = email.plainTextBody;
		String inReplyTo = email.inReplyTo;
		String messageId = email.messageId;
		String[] references = email.references;
		String fromId;
		try{
			fromId = [Select Id
			          from Contact
			          where Email = :fromAddress
			          LIMIT 1].Id;
		} catch (exception ex){

		}

		if (emailSubject.indexOf('[ref') != -1){
			if (emailSubject.indexOf('[ref:') != -1){
				String relatedToId = emailSubject.split('ref:')[1];
				system.debug('---relatedToId---' + relatedToId);
				relatedToId = relatedToId.split(']')[0].trim();

				String objectAPI = Id.valueOf(relatedToId).getSObjectType().getDescribe().getName();
				String queryString;

				try{
					if (objectAPI.toLowerCase() == 'account'){
						String submittalQuery = 'Select Id, Name From ' + objectAPI + ' where id =:relatedToId';
						sObject sObj;
						sObj = Database.query(submittalQuery);

						if (email.textAttachments != null){
							// Save attachments, if any
							list<Attachment> attachmentlistrecs = new list<Attachment>();
							for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = tAttachment.fileName;
								attachment.Body = Blob.valueOf(tAttachment.body);
								attachment.ParentId = relatedToId;
								attachmentlistrecs.add(attachment);
							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attachmentlistrecs;
							}
						}
						if (email.binaryAttachments != null){
							list<Attachment> attachmentlist = new list<Attachment>();
							for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = bAttachment.fileName;
								attachment.Body = bAttachment.body;
								attachment.ParentId = relatedToId;
								attachmentlist.add(attachment);
							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attachmentlist;
							}
						}
					}
				} catch (Exception e){
					System.debug('Error::'+e.getMessage());
					System.debug('Error::'+e.getLineNumber());
				}
				if (objectAPI.toLowerCase() == 'buildertek__rfq_to_vendor__c'){
					RFQ_to_vendor__c rfqtovendor;
					if (Schema.sObjectType.RFQ_to_vendor__c.fields.Id.isAccessible() && Schema.sObjectType.RFQ_to_vendor__c.fields.Rfq__c.isAccessible()){
						rfqtovendor = [Select Id, Rfq__c
						               from RFQ_to_vendor__c
						               where Id = :relatedToId];
					}
					String rfqId = rfqtovendor.Rfq__c;
					queryString = 'Select Id, OwnerId, Owner.email from buildertek__RFQ__c where id =: rfqId';
				} else{
					queryString = 'Select Id, OwnerId, Owner.email from ' + objectAPI + ' where id =:relatedToId';
				}

				sObject obj;
				/*    if(Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()&&
				 Schema.sObjectType.buildertek__RFQ__c.fields.OwnerId.isAccessible() ){*/
				obj = database.query(queryString);
				/*}*/
				EmailMessage EmailMsg = new EmailMessage();
				EmailMsg.FromName = fromname;
				EmailMsg.FromAddress = fromAddress;
				//EmailMsg.HasAttachment = false;
				//EmailMsg.Headers
				EmailMsg.HtmlBody = htmlBody;
				EmailMsg.Incoming = true;
				//EmailMsg.MessageDate = system.today();
				//EmailMsg.MessageSize
				EmailMsg.Status = '2'; //'0' = New '1' = Read '2' = Replied '3' = Sent '4' = Forwarded
				EmailMsg.relatedToId = (Id)obj.Id;
				EmailMsg.TextBody = plainTextBody;
				//EmailMsg.ToAddress = toAddresses != null?toAddresses[0]:null;
				EmailMsg.ToAddress = (String)obj.getSObject('Owner').get('Email');
				//EmailMsg.CcAddress = ccAddresses != null ? ccAddresses[0] : null;
				EmailMsg.Subject = emailSubject;
				if (Schema.sObjectType.EmailMessage.isCreateable() && Schema.sObjectType.EmailMessage.fields.FromName.isCreateable() && Schema.sObjectType.EmailMessage.fields.FromAddress.isCreateable() && Schema.sObjectType.EmailMessage.fields.HtmlBody.isCreateable() && Schema.sObjectType.EmailMessage.fields.Incoming.isCreateable() && Schema.sObjectType.EmailMessage.fields.Status.isCreateable() && Schema.sObjectType.EmailMessage.fields.relatedToId.isCreateable() && Schema.sObjectType.EmailMessage.fields.TextBody.isCreateable() && Schema.sObjectType.EmailMessage.fields.ToAddress.isCreateable() && Schema.sObjectType.EmailMessage.fields.CcAddress.isCreateable() && Schema.sObjectType.EmailMessage.fields.Subject.isCreateable()){
					insert EmailMsg;
				}

				if (fromId != null){

					// Add Email Message Relation for id of the sender
					List<EmailMessageRelation> emrs = new List<EmailMessageRelation>();
					EmailMessageRelation emr = new EmailMessageRelation();
					emr.emailMessageId = EmailMsg.id;
					emr.relationId = fromId; // user id / contact Id of the sender
					emr.relationType = 'FromAddress';
					emr.relationAddress = FromAddress;
					emrs.add(emr);


					emr = new EmailMessageRelation();
					emr.emailMessageId = EmailMsg.id;
					emr.relationId = (Id)obj.get('OwnerId'); // user id / contact Id of the sender
					emr.relationType = 'ToAddress';
					emr.relationAddress = (String)obj.getSObject('Owner').get('Email');
					emrs.add(emr);
					if (Schema.sObjectType.EmailMessageRelation.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.emailMessageId.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.relationAddress.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.relationId.isCreateable() && Schema.sObjectType.EmailMessageRelation.fields.relationType.isCreateable()){
						insert emrs;
					}
				}

				List<Attachment> attachmetns = new List<Attachment>();
				if (email != null && email.binaryAttachments != null){
					for (Messaging.InboundEmail.BinaryAttachment bAttachment : email.binaryAttachments){

						Attachment att = new Attachment();
						att.Name = bAttachment.filename;
						att.body = bAttachment.body;
						att.parentId = EmailMsg.Id;

						attachmetns.add(att);
					}
					if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
						insert attachmetns;
					}
				}

				try{
					if (objectAPI.toLowerCase() == 'buildertek__change_order__c'){
						system.debug('--->buildertek__change_order__c');
						system.debug(plainTextBody.split('\n')[0]);
						String status = plainTextBody.split('\n')[0];
						system.debug('--->buildertek__change_order__c' + status.toLowerCase());
						if (status.toLowerCase() == 'approved' || status.toLowerCase() == 'approve' || status.toLowerCase() == 'accepted' || status.toLowerCase() == 'accepte'){
							change_order__c co = new change_Order__c();
							co.id = relatedToId;
							co.status__c = 'Approved';
							co.buildertek__Date_Approved__c = system.today();
							if (Schema.sObjectType.change_order__c.isUpdateable() && Schema.sObjectType.change_order__c.fields.Id.isUpdateable() && Schema.sObjectType.change_order__c.fields.status__c.isUpdateable() && Schema.sObjectType.change_order__c.fields.buildertek__Date_Approved__c.isUpdateable()){
								update co;
							}
						} else if (status.toLowerCase() == 'rejected' || status.toLowerCase() == 'reject'){

							change_order__c co = new change_Order__c();
							co.id = relatedToId;
							co.status__c = 'Rejected';
							if (Schema.sObjectType.change_order__c.isUpdateable() && Schema.sObjectType.change_order__c.fields.Id.isUpdateable() && Schema.sObjectType.change_order__c.fields.status__c.isUpdateable()){
								update co;
							}
						}
					}


					if (objectAPI.toLowerCase() == 'buildertek__rfq_to_vendor__c'){
						system.debug('--->buildertek__rfq_to_vendor__c');
						system.debug(plainTextBody.split('\n')[0]);
						String status = plainTextBody.split('\n')[0];

						if (status.toLowerCase() == 'accepted'){
							buildertek__rfq_to_vendor__c rfqToVendor = new buildertek__rfq_to_vendor__c();
							rfqToVendor.id = relatedToId;
							rfqToVendor.status__c = 'Accepted';
							if (Schema.sObjectType.buildertek__rfq_to_vendor__c.isUpdateable() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.status__c.isUpdateable()){
								update rfqToVendor;
							}

						} else if (status.toLowerCase() == 'canceled' || status.toLowerCase() == 'reject'){

							buildertek__rfq_to_vendor__c rfqToVendor = new buildertek__rfq_to_vendor__c();
							rfqToVendor.id = relatedToId;
							rfqToVendor.status__c = 'Canceled';
							if (Schema.sObjectType.buildertek__rfq_to_vendor__c.isUpdateable() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__rfq_to_vendor__c.fields.status__c.isUpdateable()){
								update rfqToVendor;
							}
						}
					}
				} catch (exception ex){
					system.debug('----fail---');
				}


				try{
					if (objectAPI.toLowerCase() == 'buildertek__submittal__c'){
						String submittalQuery = 'Select Id, Name, buildertek__Status__c, buildertek__Responsible_Contact__c,buildertek__Responsible_Contact__r.Email from ' + objectAPI + ' where id =:relatedToId';
						sObject sObj;
						/* if(Schema.sObjectType.buildertek__submittal__c.fields.Id.isAccessible() &&
						 Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Status__c.isAccessible()
						 && Schema.sObjectType.buildertek__submittal__c.fields.Name.isAccessible()
						 && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Responsible_Contact__c.isAccessible()
						 && Schema.sObjectType.Contact.fields.Email.isAccessible()){*/
						sObj = database.query(submittalQuery);
						/*}*/
						system.debug('sObj --> ' + sObj);

						buildertek__submittal__c submittal = new buildertek__submittal__c();
						submittal.Id = relatedToId;
						submittal.buildertek__Status__c = 'Answered';
						submittal.buildertek__Received_Date__c = system.today();
						if (Schema.sObjectType.buildertek__submittal__c.isUpdateable() && Schema.sObjectType.buildertek__submittal__c.fields.Id.isUpdateable() && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Status__c.isUpdateable() && Schema.sObjectType.buildertek__submittal__c.fields.buildertek__Received_Date__c.isUpdateable()){
							update submittal;
						}

						if (email.textAttachments != null){
							// Save attachments, if any
							list<Attachment> attachmentlistrecs = new list<Attachment>();
							for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = tAttachment.fileName;
								attachment.Body = Blob.valueOf(tAttachment.body);
								attachment.ParentId = sObj.Id;
								attachmentlistrecs.add(attachment);
							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attachmentlistrecs;
							}
						}
						if (email.binaryAttachments != null){
							list<Attachment> attachmentlist = new list<Attachment>();
							for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = bAttachment.fileName;
								attachment.Body = bAttachment.body;
								attachment.ParentId = sObj.Id;
								attachmentlist.add(attachment);
							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attachmentlist;
							}
						}
					}
				} catch (Exception exp){

				}

				


				try{
					if (objectAPI.toLowerCase() == 'buildertek__Punch_List__c'){
						String punchListQuery = 'Select Id, Name, buildertek__Vendor_Contact__c,buildertek__Vendor_Contact__r.Email from ' + objectAPI + ' where id =:relatedToId';
						sObject punchListObj;
						/*if(Schema.sObjectType.buildertek__Punch_List__c.fields.Id.isAccessible() &&
						 Schema.sObjectType.buildertek__Punch_List__c.fields.buildertek__Vendor_Contact__c.isAccessible()
						 && Schema.sObjectType.buildertek__Punch_List__c.fields.Name.isAccessible()

						 && Schema.sObjectType.Contact.fields.Email.isAccessible()){*/
						punchListObj = database.query(punchListQuery);
						/*}*/
						system.debug('punchListObj --> ' + punchListObj);

						if (email.textAttachments != null){
							// Save attachments, if any
							list<Attachment> attlistrecs = new list<Attachment>();
							for (Messaging.Inboundemail.TextAttachment tAttachment : email.textAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = tAttachment.fileName;
								attachment.Body = Blob.valueOf(tAttachment.body);
								attachment.ParentId = punchListObj.Id;
								attlistrecs.add(attachment);

							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attlistrecs;
							}
						}
						if (email.binaryAttachments != null){
							list<Attachment> attlist = new list<Attachment>();
							for (Messaging.Inboundemail.BinaryAttachment bAttachment : email.binaryAttachments){
								Attachment attachment = new Attachment();
								attachment.Name = bAttachment.fileName;
								attachment.Body = bAttachment.body;
								attachment.ParentId = punchListObj.Id;
								attlist.add(attachment);

							}
							if (Schema.sObjectType.Attachment.fields.Body.isCreateable() && Schema.sObjectType.Attachment.fields.ParentID.isCreateable() && Schema.sObjectType.Attachment.fields.Name.isCreateable()){
								insert attlist;
							}
						}
					}
				} catch (Exception exp){

				}
				result.success = true;
			}

		}

		return result;
	}
}