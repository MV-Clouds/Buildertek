public with sharing class CreateNewContractFromProject{
	@AuraEnabled
	public static string getContractTemplate(String recordId){
		List<buildertek__Contract__c> contractList = [Select Id, Name, buildertek__Project__c
		                                              FROM buildertek__Contract__c
		                                              WHERE buildertek__Project__c = :recordId
		                                              ORDER By CreatedDate ASC
		                                              LIMIT 1];
		if (contractList.size() > 0){
			String contractId = contractList[0].Id;
			string templateBody = '';
			string templateBody1 = '';
			string templateBody2 = '';
			Contact con;
			if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
				con = [select Id, Email
				       from Contact
				       where email != null
				       order by CreatedDate DESC
				       limit 1];
			}
			SavePoint sp = Database.setSavePoint();
			list<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
			list<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
			List<String> templateList = new List<String>();
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			string theTemplate;
			if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
				theTemplate = [SELECT Id
				               FROM EmailTemplate
				               WHERE DeveloperName = :'Contract_Template_2'].Id;
			}
			email.setTemplateId(theTemplate);
			email.setWhatId(contractId);
			email.setTargetObjectId(con.Id);
			email.setSaveAsActivity(true);
			email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
			msgList.add(email);

			Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
			Database.rollback(sp);
			for (Messaging.SingleEmailMessage emailNew : msgList){
				templateBody = emailNew.getHTMLBody();
			}
			return templateBody;
		}
		return null;
	}
}