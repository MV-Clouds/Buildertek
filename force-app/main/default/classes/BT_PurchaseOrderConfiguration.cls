public class BT_PurchaseOrderConfiguration{
	public Boolean sendVendorLienReleaseOnApproval{ get; set; }

	public Boolean sendEmailOnApproval{ get; set; }
    public Boolean CreateInvoiceApproval{ get; set; }

	//public buildertek__Admin_Interface_Node_Configuration__c adminterface {get;set;}
	public string emailsubject{ get; set; }
	public string CreatePO{ get; set; }


	public BT_PurchaseOrderConfiguration(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Send_Vendor_Lien_Release_On_Approval__c, buildertek__Create_PO__c,
                                                                                              buildertek__Send_PO_On_Approval__c, buildertek__Email_Subject__c,buildertek__Create_Invoice_on_Approval__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Purchase Order Configuration'];
		sendVendorLienReleaseOnApproval = adminInterfaceNodeConfigurations.buildertek__Send_Vendor_Lien_Release_On_Approval__c;
		sendEmailOnApproval = adminInterfaceNodeConfigurations.buildertek__Send_PO_On_Approval__c;
		emailsubject = adminInterfaceNodeConfigurations.buildertek__Email_Subject__c;
        CreateInvoiceApproval = adminInterfaceNodeConfigurations.buildertek__Create_Invoice_on_Approval__c;

        CreatePO = adminInterfaceNodeConfigurations.buildertek__Create_PO__c;


		
	}

	public void onCreateChangeOrderonOverage(){
		buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, buildertek__Send_Vendor_Lien_Release_On_Approval__c,buildertek__Create_PO__c,
                                                                                              buildertek__Send_PO_On_Approval__c, buildertek__Email_Subject__c,buildertek__Create_Invoice_on_Approval__c
		                                                                                      from buildertek__Admin_Interface_Node_Configuration__c
		                                                                                      WHERE Name = :'Purchase Order Configuration'];
		adminInterfaceNodeConfigurations.buildertek__Send_Vendor_Lien_Release_On_Approval__c = sendVendorLienReleaseOnApproval;
		adminInterfaceNodeConfigurations.buildertek__Send_PO_On_Approval__c = sendEmailOnApproval;
		adminInterfaceNodeConfigurations.buildertek__Email_Subject__c = emailsubject;
        adminInterfaceNodeConfigurations.buildertek__Create_Invoice_on_Approval__c = CreateInvoiceApproval;
        adminInterfaceNodeConfigurations.buildertek__Create_PO__c = CreatePO;

		update adminInterfaceNodeConfigurations;
		ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM, 'Updated Successfully'));
	}
}