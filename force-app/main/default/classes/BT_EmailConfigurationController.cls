public class BT_EmailConfigurationController {

	public string emailaddress{ get; set; }

	public BT_EmailConfigurationController(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Email Configuration'];
		emailaddress = adminInterfaceNodeConfigurations.buildertek__Email_Address__c;
	}

	public void onCreateemailaddress(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Email Configuration'];
		adminInterfaceNodeConfigurations.buildertek__Email_Address__c = emailaddress;
		update adminInterfaceNodeConfigurations;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Updated Successfully'));
	}
}