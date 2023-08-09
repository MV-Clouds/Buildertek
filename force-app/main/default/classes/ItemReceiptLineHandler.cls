public with sharing class ItemReceiptLineHandler{
	public static Boolean blnSkipBilllineItemUpdateTrigger = false;
	private boolean m_isExecuting = false;
	private integer BatchSize = 0;
	public ItemReceiptLineHandler(boolean isExecuting, integer size){
		m_isExecuting = isExecuting;
		BatchSize = size;
	}

	public void OnAfterInsert(buildertek__Item_Receipt_Line__c[] newBillLineItem, Map<ID, buildertek__Item_Receipt_Line__c> newBillLineItemMap){
		Map<Id, buildertek__Item_Receipt_Line__c> purchaseOrderLineMap = new Map<Id, buildertek__Item_Receipt_Line__c>();
		for (buildertek__Item_Receipt_Line__c itemReceiptMap : newBillLineItemMap.values()){
			purchaseOrderLineMap.put(itemReceiptMap.buildertek__PO_Line__c, itemReceiptMap);
		}

		List<buildertek__Purchase_Order_Item__c> purchaseOrderLines = [Select Id, Name, buildertek__Quantity__c, buildertek__Received__c
		                                                               From buildertek__Purchase_Order_Item__c
		                                                               WHERE Id In :purchaseOrderLineMap.keySet()];
		for (buildertek__Purchase_Order_Item__c purchaseOrderLine : purchaseOrderLines){
			if (purchaseOrderLine.Id == purchaseOrderLineMap.get(purchaseOrderLine.Id).buildertek__PO_Line__c){
				purchaseOrderLine.buildertek__Received__c = purchaseOrderLineMap.get(purchaseOrderLine.Id).buildertek__Quantity__c;
			}
		}
		update purchaseOrderLines;
	}

	public void OnAfterUpdate(buildertek__Item_Receipt_Line__c[] oldItemReceipt, buildertek__Item_Receipt_Line__c[] updatedItemReceipt, Map<ID, buildertek__Item_Receipt_Line__c> newItemReceiptMap, Map<Id, buildertek__Item_Receipt_Line__c> oldItemReceiptMap){
		Map<Id, buildertek__Item_Receipt_Line__c> purchaseOrderLineMap = new Map<Id, buildertek__Item_Receipt_Line__c>();
		for (buildertek__Item_Receipt_Line__c itemReceiptMap : newItemReceiptMap.values()){
			if (itemReceiptMap.buildertek__Quantity__c != oldItemReceiptMap.get(itemReceiptMap.Id).buildertek__Quantity__c){
				purchaseOrderLineMap.put(itemReceiptMap.buildertek__PO_Line__c, itemReceiptMap);
			}
		}

		List<buildertek__Purchase_Order_Item__c> purchaseOrderLines = [Select Id, Name, buildertek__Quantity__c, buildertek__Received__c
		                                                               From buildertek__Purchase_Order_Item__c
		                                                               WHERE Id In :purchaseOrderLineMap.keySet()];
		for (buildertek__Purchase_Order_Item__c purchaseOrderLine : purchaseOrderLines){
			if (purchaseOrderLine.Id == purchaseOrderLineMap.get(purchaseOrderLine.Id).buildertek__PO_Line__c){
				purchaseOrderLine.buildertek__Received__c = purchaseOrderLineMap.get(purchaseOrderLine.Id).buildertek__Quantity__c;
			}
		}
		update purchaseOrderLines;
	}
}