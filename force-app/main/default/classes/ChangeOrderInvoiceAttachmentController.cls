public class ChangeOrderInvoiceAttachmentController{
	public String parentId{ get; set; }

	public static buildertek__Change_Order__c CO{ get; set; }

	public static List<buildertek__Change_Order_Item__c> COI{ get; set; }

	public ChangeOrderInvoiceAttachmentController(){
		parentId = ApexPages.currentPage().getParameters().get('parentId');
	}

	public void attachPDF(){
		//generate and attach the PDF document
		Blob pdfBlob; //create a blob for the PDF content
		PageReference pdfPage = Page.ChangeOrderInvoice;
		pdfPage.getParameters().put('id', parentId);
		if (Test.isRunningTest()){
			pdfBlob = blob.valueOf('Unit.Test');
		} else{
			pdfBlob = pdfPage.getContent(); //generate the pdf blob
		}

		// create the new attachment
		Attachment attach = new Attachment();
		attach.Body = pdfBlob;
		attach.Name = 'Change Order Invoice' + ' ' + DateTime.now().format('dd-MM-yyyy HH:mm:ss')+'.pdf';//Name of the file
		attach.IsPrivate = false;
		attach.ParentId = parentId;
		insert attach;

		buildertek__Change_Order__c co;
		if (Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Period__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Tax_Rate__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Vendor__c.isAccessible()){
			co = [Select Id, Name, buildertek__Customer_Account__c, buildertek__Description__c, buildertek__Period__c, buildertek__Tax_Rate__c, buildertek__Project__c, buildertek__Status__c, buildertek__Vendor__c
			      from buildertek__change_order__c
			      where Id = :parentId];
		}
		buildertek__Billings__c AR = new buildertek__Billings__c();
		if (Schema.sObjectType.buildertek__Billings__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Change_Order__c.isCreateable() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Customer_Account__c.isCreateable() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Project__c.isCreateable() && Schema.sObjectType.buildertek__Billings__c.fields.buildertek__Tax_Rate__c.isCreateable()){
			AR.Name = co.Name;
			AR.Change_Order__c = co.Id;
			AR.Customer_Account__c = co.Customer_Account__c;
			AR.Project__c = co.Project__c;
			AR.Tax_Rate__c = co.Tax_Rate__c;
		}
		insert AR;

		List<buildertek__Billable_Lines__c> arLines = new List<buildertek__Billable_Lines__c>();
		for (buildertek__Change_Order_Item__c coItem : [Select Id, Name, buildertek__Cost_Code__c, buildertek__Description__c, buildertek__Item_Name__c, buildertek__Tax_Rate__c, buildertek__Product__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Unit_Sales_Price__c, buildertek__SubTotal__c
		                                                from buildertek__Change_Order_Item__c
		                                                where buildertek__Change_Order__c = :co.Id]){
			if (Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Billings__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Change_Order_Line__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Line_Title__c.isCreateable() && Schema.sObjectType.buildertek__Billable_Lines__c.fields.buildertek__Tax_Rate__c.isCreateable()){
				buildertek__Billable_Lines__c arItem = new buildertek__Billable_Lines__c();
				arItem.Billings__c = AR.Id;
				arItem.Change_Order_Line__c = coItem.id;
				arItem.Line_Title__c = coItem.buildertek__Item_Name__c;
				arItem.Cost_Code__c = coItem.buildertek__Cost_Code__c;
				arItem.Description__c = coItem.Name;
				arItem.Product__c = coItem.buildertek__Product__c;
				arItem.Unit_Price__c = coItem.buildertek__Unit_Sales_Price__c;
				arItem.Quantity__c = coItem.buildertek__Quantity__c;
				arItem.Tax_Rate__c = coItem.buildertek__Tax_Rate__c;
				arLines.add(arItem);
			}
		}
		insert arLines;
	}

	public PageReference redirectToPage(){
		//Redirect the user
		PageReference pdfPage = Page.BT_Invoice;
		pdfPage.getParameters().put('id', parentId);
		pdfPage.setRedirect(true);
		return pdfPage;
	}
}