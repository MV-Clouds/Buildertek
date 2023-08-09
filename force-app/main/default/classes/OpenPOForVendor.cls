public with sharing class OpenPOForVendor{
    
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
	@AuraEnabled
	public static Map<String, String> openPO(String recordId){
		Map<String, String> finalMap = new Map<String, String>();
		try{
			if (String.isNotBlank(recordId)){
				List<buildertek__Purchase_Order__c> purchaseOrders = [Select Id, Name, buildertek__Vendor__c, buildertek__PO_Amount__c, buildertek__Date_Created__c, buildertek__Vendor__r.Name, buildertek__Status__c, (SELECT Id, buildertek__Item_Name__c, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Received__c, buildertek__BackOrdered__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, buildertek__Description__c
				                                                                                                                                                                                                         FROM buildertek__Purchase_Order_Items__r)
				                                                      From buildertek__Purchase_Order__c
				                                                      WHERE buildertek__Vendor__c = :recordId AND buildertek__Status__c = :'Open'];
				if (purchaseOrders.size() > 0){
					finalMap.put('itemReceipt', '');
					finalMap.put('purchaseOrderMap', JSON.serialize(purchaseOrders));
					return finalMap;
				}
			}
		} catch (Exception e){
            //throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static string createItem(String recordId, String purchaseOrderList){
		try{
			if (String.isNotBlank(recordId)){
				List<buildertek__Item_Receipt__c> itemReceipts = (List<buildertek__Item_Receipt__c>)System.JSON.deserialize(purchaseOrderList, List<buildertek__Item_Receipt__c>.class);
				insert itemReceipts;
			}
		} catch (Exception e){
			System.debug('ERror ::'+e.getMessage());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}

	@AuraEnabled
	public static string createReceiptItem(String receiptObj, String POList){
		try{
			if (String.isNotBlank(receiptObj)){
				buildertek__Item_Receipt__c receiptObjs = (buildertek__Item_Receipt__c)System.JSON.deserialize(receiptObj, buildertek__Item_Receipt__c.class);
				insert receiptObjs;

				if (String.isNotBlank(POList) && POList.length() > 2){
					List<buildertek__Item_Receipt_Line__c> itemReceiptLines = (List<buildertek__Item_Receipt_Line__c>)System.JSON.deserialize(POList, List<buildertek__Item_Receipt_Line__c>.class);
					for (buildertek__Item_Receipt_Line__c itemReceiptLine : itemReceiptLines){
						itemReceiptLine.buildertek__Item_Receipt__c = receiptObjs.Id;
					}
					insert itemReceiptLines;
				}
				return receiptObjs.Id;
			}
		} catch (Exception e){
			System.debug('Error::' + e.getMessage()+'::' + e.getLineNumber());
			//throw new AuraHandledException(e.getMessage());
		}
		return null;
	}
}