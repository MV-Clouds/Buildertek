public with sharing class ServiceRequestTriggerHandler{
	//static method
	public static void sendEmailForRequestProcess(List<Service_Request__c> ltServiceRequest){
		Set<Id> projectIds = new Set<Id>();//For Address from Project.
        //query on template object
		EmailTemplate et;
		If (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
			et = [Select id
			      from EmailTemplate
			      where name = :'Service Process Notification'];
		}
		//list of emails
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (Service_Request__c request : ltServiceRequest){
            projectIds.add(request.buildertek__Project__c);
			//check for Account
			if (request.Customer_Name__c != null && request.Customer_Email__c != null){
				// Step 1: Create a new Email
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				// Step 2: Set list of people who should get the email
				List<String> sendTo = new List<String>();
				sendTo.add(request.Customer_Email__c);

				mail.setToAddresses(sendTo);
				mail.setTargetObjectId(request.Customer_Name__c);
				//set template Id
				mail.setTemplateId(et.Id);
				mail.setWhatId(request.Id);
				//add mail
				emails.add(mail);
			}
		}
        updateServiceRequestAddress(projectIds);
		//send mail
		Messaging.sendEmail(emails);
	}

	public static void sendEmailForRequestComplete(Map<Id, Service_Request__c> oldMap, List<Service_Request__c> ltServiceRequest){
		Set<Id> projectIds = new Set<Id>();//For Address from Project.
        //query on template object
		EmailTemplate et;
		If (Schema.sObjectType.EmailTemplate.fields.Id.isAccessible() && Schema.sObjectType.EmailTemplate.fields.Name.isAccessible()){
			et = [Select id
			      from EmailTemplate
			      where name = :'Service Complete Notification'];
		}
		//list of emails
		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for (Service_Request__c request : ltServiceRequest){
            projectIds.add(request.buildertek__Project__c);
			//check for Account
			if (request.Request_Status__c != oldMap.get(request.Id).Request_Status__c && request.Request_Status__c == 'Complete'){
				if (request.Customer_Name__c != null && request.Customer_Email__c != null){
					// Step 1: Create a new Email
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

					// Step 2: Set list of people who should get the email
					List<String> sendTo = new List<String>();
					sendTo.add(request.Customer_Email__c);

					mail.setToAddresses(sendTo);
					mail.setTargetObjectId(request.Customer_Name__c);
					//set template Id
					mail.setTemplateId(et.Id);
					mail.setWhatId(request.Id);
					//add mail
					emails.add(mail);
				}
			}
		}
        updateServiceRequestAddress(projectIds);
		//send mail
		Messaging.sendEmail(emails);
	}

    //Update Service request Address with Project.
	public static void updateServiceRequestAddress(Set<Id> projectIds){
		
        List<buildertek__Service_Request__c> serviceRequestList = new List<buildertek__Service_Request__c>();
		List<buildertek__Project__c> projects = [Select Id, Name, buildertek__Address__c, buildertek__City__c, buildertek__Country__c, buildertek__Zip__c, buildertek__County__c, buildertek__State__c, (SELECT Id, Name, buildertek__Address__c, buildertek__City__c, buildertek__State__c, buildertek__Country__c, buildertek__Postal_Code__c
		                                                                                                                                                                                                 FROM buildertek__Service_Requests__r)
		                                         FROM buildertek__Project__c
		                                         WHERE Id IN :projectIds];

		for (buildertek__Project__c project : projects){
            for(buildertek__Service_Request__c serviceRequest : project.buildertek__Service_Requests__r){
                serviceRequest.buildertek__Address__c = project.buildertek__Address__c;
                serviceRequest.buildertek__State__c = project.buildertek__State__c;
                serviceRequest.buildertek__City__c = project.buildertek__City__c;
                serviceRequest.buildertek__Country__c = project.buildertek__Country__c;
                serviceRequest.buildertek__Postal_Code__c = project.buildertek__Zip__c;
                serviceRequestList.add(serviceRequest);
            }
		}
        update serviceRequestList;
	}
}