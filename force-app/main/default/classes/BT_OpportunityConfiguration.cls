public class BT_OpportunityConfiguration {
    public Boolean AssigntoExistingProjectonClosedWon{ get; set; }
	public Boolean SendEmailonautomaticcreationofProj{ get; set; }
	public Boolean isCreateProjectfromOpp{ get; set; }

	public BT_OpportunityConfiguration(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Assign_to_Existing_Project_on_Closed_Won__c,  buildertek__Send_Email_on_automatic_creation_of_Proj__c, buildertek__Create_Project_from_Opportunity__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Opportunity Configuration'];
		AssigntoExistingProjectonClosedWon = adminInterfaceNodeConfigurations.buildertek__Assign_to_Existing_Project_on_Closed_Won__c;
		SendEmailonautomaticcreationofProj = adminInterfaceNodeConfigurations.buildertek__Send_Email_on_automatic_creation_of_Proj__c;
		isCreateProjectfromOpp = adminInterfaceNodeConfigurations.buildertek__Create_Project_from_Opportunity__c;
	}

	public void onOpportunityOverage(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Assign_to_Existing_Project_on_Closed_Won__c, buildertek__Send_Email_on_automatic_creation_of_Proj__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Opportunity Configuration'];
		adminInterfaceNodeConfigurations.buildertek__Assign_to_Existing_Project_on_Closed_Won__c = AssigntoExistingProjectonClosedWon;
		adminInterfaceNodeConfigurations.buildertek__Send_Email_on_automatic_creation_of_Proj__c = SendEmailonautomaticcreationofProj;
		adminInterfaceNodeConfigurations.buildertek__Create_Project_from_Opportunity__c = isCreateProjectfromOpp;
		update adminInterfaceNodeConfigurations;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Updated Successfully'));
	}

}