public class SendEMailController {
    
public void updateRFQ(){
	system.debug('HIi');  
	OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'mounica.amudala@diligentforcelabs.com'];
	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	
  //  Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	String[] toAddresses = new String[] {'harika.chunduri@diligentforcelabs.com'}; 
	if ( owea.size() > 0 ) {
		mail.setOrgWideEmailAddressId(owea.get(0).Id);
	}
	mail.setToAddresses(toAddresses);
	mail.setSubject('New Case Created : ');
	mail.setPlainTextBody('Your Case: '  +' has been created.');
	mail.setHtmlBody('Your case:<b> </b>has been created.<p>'+
     'To view your case <a href=https://mydomainname.my.salesforce.com/>click here.</a>');
     mail.SetSaveAsActivity(true);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	system.debug('Send EMail'); 
}


}