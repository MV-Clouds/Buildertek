public without sharing class ContractViewPDFController{
	public String emailBody{ get; set; }

	public Id recordId{ get; set; }

	public Id contractId{ get; set; }

	public List<buildertek__Contract__c> contractRecords{ get; set; }

	public string templateBody{ get; set; }

	public Contact con{ get; set; }

	public ContractViewPDFController(){
		if (ApexPages.currentPage().getParameters().get('id') != null){
			recordId = ApexPages.currentPage().getParameters().get('id');
		}
		if (String.isNotBlank(recordId)){
			contractRecords = [Select Id
			                   FROM buildertek__Contract__c
			                   WHERE buildertek__Project__c = :recordId
			                   ORDER BY CreatedDate DESC
			                   LIMIT 1];
		}
		if (contractRecords.size() > 0){
			contractId = contractRecords[0].Id;
			List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
			List<String> templateList = new List<String>();
			Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
			if (Schema.sObjectType.Contact.fields.Id.isAccessible() && Schema.sObjectType.Contact.fields.Name.isAccessible() && Schema.sObjectType.Contact.fields.email.isAccessible()){
				con = [SELECT Id, Email
				       FROM Contact
				       WHERE Email != null
				       Order By CreatedDate DESC
				       LIMIT 1];
			}
			String templateId;
			if (contractId.getSObjectType().getDescribe().getName() == 'buildertek__Contract__c'){
				if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
					templateId = [SELECT Id
					              FROM EmailTemplate
					              WHERE DeveloperName = :'Contract_Template_2'].Id;
				}
			}
			email.setTemplateId(templateId);
			email.setWhatId(contractId);
			email.setTargetObjectId(con.Id);
			email.setToAddresses(new List<String>{'noreplay@buildertek.com'});
			msgList.add(email);

			Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
			for (Messaging.SingleEmailMessage emailNew : msgList){
				templateBody = emailNew.getHTMLBody();
			}
		}
	}
}