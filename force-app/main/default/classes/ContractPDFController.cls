public without sharing class ContractPDFController{
	public String emailBody{ get; set; }

	public String recordId{ get; set; }

	public string templateBody{ get; set; }

	public Contact con{ get; set; }

	public ContractPDFController(){
		recordId = ApexPages.currentPage().getParameters().get('id');
		List<Messaging.SingleEmailMessage> msgList = new List<Messaging.SingleEmailMessage>();
		List<Messaging.SingleEmailMessage> msgList1 = new List<Messaging.SingleEmailMessage>();
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
		if (Schema.sObjectType.EmailTemplate.fields.id.isAccessible()){
			templateId = [SELECT Id
			               FROM EmailTemplate
			               WHERE DeveloperName = :'Contract_Template_2'].Id;
		}
		email.setTemplateId(templateId);
		email.setWhatId(recordId);
		email.setTargetObjectId(con.Id);
		msgList.add(email);

		Messaging.SendEmailResult[] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[]{email});
		for (Messaging.SingleEmailMessage emailNew : msgList){
			templateBody = emailNew.getHTMLBody();
		}
	}
}