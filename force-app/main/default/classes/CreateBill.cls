public with sharing class CreateBill{
	@AuraEnabled
	public static String createBillFromReciept(String recordId){
		if (String.isNotBlank(recordId)){
			List<buildertek__Item_Receipt__c> itemReceipt = [Select Id, Name, buildertek__Bill__c, buildertek__Project__c, buildertek__Date_Received__c, buildertek__Vendor__c
			                                                 From buildertek__Item_Receipt__c
			                                                 WHERE Id = :recordId];
			if (itemReceipt.size() > 0){
				List<buildertek__Item_Receipt_Line__c> itemReceiptLines = [SELECT Id, Name, buildertek__Item_Receipt__c, buildertek__Cost__c, buildertek__Quantity__c, buildertek__Total_Amount__c, buildertek__Product__c, buildertek__PO__c, buildertek__Description__c
				                                                           FROM buildertek__Item_Receipt_Line__c
				                                                           WHERE buildertek__Item_Receipt__c = :recordId];

				//Create Bill from Item Receipt

				buildertek__Account_Payable__c accountPayable = new buildertek__Account_Payable__c();
				accountPayable.buildertek__Project__c = itemReceipt[0].buildertek__Project__c;
				accountPayable.buildertek__Vendor__c = itemReceipt[0].buildertek__Vendor__c;
				accountPayable.buildertek__Date_Received__c = itemReceipt[0].buildertek__Date_Received__c;
				accountPayable.buildertek__Purchase_Order__c = itemReceiptLines[0].buildertek__PO__c;
				insert accountPayable;

				List<buildertek__Account_Payable_Item__c> accountPayableLines = new List<buildertek__Account_Payable_Item__c>();
				//If Item Receipt Line Items exist
				if (itemReceiptLines.size() > 0){
					for (buildertek__Item_Receipt_Line__c itemReceiptLine : itemReceiptLines){
						buildertek__Account_Payable_Item__c accountPayableLine = new buildertek__Account_Payable_Item__c();
						accountPayableLine.buildertek__Account_Payable__c = accountPayable.Id;
						accountPayableLine.Name = itemReceiptLine.Name;
						accountPayableLine.buildertek__Product__c = itemReceiptLine.buildertek__Product__c;
						accountPayableLine.buildertek__Description__c = itemReceiptLine.buildertek__Description__c;
						accountPayableLine.buildertek__Quantity__c = itemReceiptLine.buildertek__Quantity__c;
						accountPayableLine.buildertek__Unit_Price__c = itemReceiptLine.buildertek__Cost__c;
						accountPayableLines.add(accountPayableLine);
					}
					insert accountPayableLines;
				}

				//Update Bill Id in Item Receipt
				if (String.isNotBlank(accountPayable.Id)){
					itemReceipt[0].buildertek__Bill__c = accountPayable.Id;
				}
				update itemReceipt[0];
			}
			return 'Success';
		}
		return null;
	}
}