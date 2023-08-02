public without sharing class NewPaymentRequestController{
	public static boolean isInvoiceCreated = false;
	public static string paymentRequestId = '';
    @AuraEnabled
	public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
	@AuraEnabled
	public static String getFieldSet(){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Payment_Request__c');
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey('buildertek__paymentRequestFromPO')){
				for (Schema.FieldSetMember f : FsMap.get('buildertek__paymentRequestFromPO').getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown('buildertek__Payment_Request__c', String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;
				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
			System.debug('Error::' + e.getMessage());
			System.debug('Error At Line::' + e.getLineNumber());
		}
		return '[' + result + ']';
	}

	@AuraEnabled
	public static List<String> getDropDown(String objName, String fieldName){
		List<String> pickListValuesList = new List<String>();
		try{
			Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult r = s.getDescribe();
			Map<String, Schema.SObjectField> fields = r.fields.getMap();
			Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
			List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
			for (Schema.PicklistEntry pickListVal : ple){
				pickListValuesList.add(pickListVal.getLabel());
			}
		} catch (Exception e){
			throw new AuraHandledException(e.getMessage());
		}
		return pickListValuesList;
	}

	
    @AuraEnabled
	public static Map<Id, String> getNames(String RecordId){
		Map<Id, String> poNames= new Map<Id, String>();

        buildertek__Purchase_Order__c purchaseRec = [select id,Name,buildertek__Vendor__c from buildertek__Purchase_Order__c where id =: RecordId];
		poNames.put(purchaseRec.buildertek__Vendor__c , 'Vendor');
        return poNames;
    }
	@AuraEnabled
    public static String saveRecord(String paymentRequestData, String poid){
        buildertek__Payment_Request__c paymentRequest = (buildertek__Payment_Request__c)JSON.deserialize(paymentRequestData, buildertek__Payment_Request__c.class);
        insert paymentRequest;
		paymentRequestId = paymentRequest.Id;
		buildertek__Payment_Request__c exist = [SELECT Id, buildertek__BT_Contractor_Invoice_PO__c, buildertek__BT_Purchase_Order__c FROM buildertek__Payment_Request__c WHERE Id = :paymentRequest.Id LIMIT 1];
		if (exist != null) {
			exist.buildertek__BT_Purchase_Order__c = poid; 
			update exist;
		}
        List<buildertek__Account_Payable__c> relatedAP = [SELECT Id, buildertek__Purchase_Order__c FROM buildertek__Account_Payable__c WHERE buildertek__Purchase_Order__c = :poid ORDER BY CreatedDate DESC LIMIT 1];
        if (relatedAP.isEmpty()) {
            createAPFromPO(poid);
        }
        else {
            exist.buildertek__BT_Contractor_Invoice_PO__c = relatedAP[0].Id; 
			update exist;
        }
        return paymentRequest.Id;
    }

	public static string createAPFromPO(string poid){
        system.debug('poid---->' + poid);
        isInvoiceCreated = true;
        string accountPaybleId = createAP([Select Id, Name, Project__c, Vendor__c, Period__c, Tax__c, buildertek__Status__c, buildertek__Description__c
                                           from purchase_order__c
                                           where Id = :poid]);
        createAPItems([Select Id, Name, Tax__c, purchase_order__c, Item_Name__c, Description__c, Cost_Code__c, Product__c, Quantity__c, Unit_Price__c
                       from Purchase_Order_Item__c
                       where purchase_order__c = :poid]);

        return accountPaybleId;
    }

	public static string createAP(List<Purchase_Order__c> pos){
        Map<Id, Account_Payable__c> PoIdbyAp = new Map<Id, Account_Payable__c>();
        Id posRecId;
        for (Purchase_Order__c po : pos){

            Account_Payable__c ap = new Account_Payable__c();
            ap.Purchase_Order__c = po.id;
            ap.Project__c = po.Project__c;
            ap.Vendor__c = po.Vendor__c;

            if(po.Tax__c != null){
                ap.Tax__c = po.Tax__c;
            }
            ap.buildertek__Description__c = po.buildertek__Description__c;
            PoIdbyAp.put(po.id, ap);
            posRecId = po.id;
        }
        insert PoIdbyAp.values();
		buildertek__Payment_Request__c exist = [SELECT Id, buildertek__BT_Contractor_Invoice_PO__c, buildertek__BT_Purchase_Order__c FROM buildertek__Payment_Request__c WHERE Id = :paymentRequestId LIMIT 1];
		if (exist != null) {
			exist.buildertek__BT_Contractor_Invoice_PO__c = PoIdbyAp.get(posRecId).Id; 
			update exist;
		}
        return PoIdbyAp.get(posRecId).Id;
    }

	public static void createAPItems(List<Purchase_Order_Item__c> poItems){
        Map<Id, Account_Payable__c> PoIdbyAp = new Map<Id, Account_Payable__c>();

        set<Id> poIds = new set<Id>();
        for (Purchase_Order_Item__c poItem : poItems){
            poIds.add(poItem.Purchase_Order__c);
        }

        for (Account_Payable__c ap : [Select Id, Purchase_Order__c
                                      from Account_Payable__c
                                      where Purchase_Order__c IN :poIds]){
            PoIdbyAp.put(ap.Purchase_Order__c, ap);
        }

        List<buildertek__Account_Payable_Item__c> apItems = new List<buildertek__Account_Payable_Item__c>();
        system.debug('poItems-----' + poItems);
        for (Purchase_Order_Item__c poItem : poItems){

            Account_Payable_Item__c apItem = new Account_Payable_Item__c();
            apItem.Account_Payable__c = PoIdbyAp.get(poItem.Purchase_Order__c).Id;
            apItem.Name = poItem.Name;
            apItem.Item_Title__c = poItem.Item_Name__c;
            apItem.Description__c = poItem.Description__c;
            apItem.Cost_Code__c = poItem.Cost_Code__c;
            apItem.Product__c = poItem.Product__c;
            apItem.Purchase_Order_Item__c = poItem.Id;
            apItem.Quantity__c = poItem.Quantity__c;
            if(poItem.Unit_Price__c != null){
                apItem.Unit_Price__c = poItem.Unit_Price__c;
            }
            if(poItem.Tax__c != null){
                apItem.Tax__c = poItem.Tax__c;
            }
            apItems.add(apItem);
        }
        insert apItems;
    }

	
  
}