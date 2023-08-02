public class BT_OpportunityConfiguration {
    public Boolean AssigntoExistingProjectonClosedWon{ get; set; }
	public BT_OpportunityConfiguration(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Assign_to_Existing_Project_on_Closed_Won__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Opportunity Configuration'];
		AssigntoExistingProjectonClosedWon = adminInterfaceNodeConfigurations.buildertek__Assign_to_Existing_Project_on_Closed_Won__c;
	}

	public void onOpportunityOverage(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Assign_to_Existing_Project_on_Closed_Won__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Opportunity Configuration'];
		adminInterfaceNodeConfigurations.buildertek__Assign_to_Existing_Project_on_Closed_Won__c = AssigntoExistingProjectonClosedWon;
		update adminInterfaceNodeConfigurations;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Updated Successfully'));
	}

}