public with sharing class New_WTLine_Controller {
    public New_WTLine_Controller() {

    }

    @AuraEnabled
    public static List<RecordType> getRecordType(String ObjectAPIName) {
        System.debug('ObjectAPIName: ' + ObjectAPIName);
        List<RecordType> recordTypes = [SELECT Id, Name FROM RecordType WHERE SObjectType = :ObjectAPIName];
        System.debug('recordTypes: ' + recordTypes);
        return recordTypes;
    }

    @AuraEnabled
	public static String getFieldSet(String objName, String fieldSetName){
		String result = '';
		List<String> pickListValuesList = new List<String>();
		try{
			SObjectType objToken = Schema.getGlobalDescribe().get(objName);
			Schema.DescribeSObjectResult d = objToken.getDescribe();
			Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
			if (FsMap.containsKey(fieldSetName)){
				for (Schema.FieldSetMember f : FsMap.get(fieldSetName).getFields()){
					if (result != ''){
						result += ',';
					}
					String jsonPart = '{';
					jsonPart += '"label":"' + f.getLabel()+'",';
					jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
					jsonPart += '"type":"' + (f.getType())+'",';
					jsonPart += '"name":"' + f.getFieldPath()+'"';
					if (String.valueOf(f.getType()) == 'PICKLIST'){
						pickListValuesList = getDropDown(objName, String.valueOf(f.getFieldPath()));
						jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
					}
					jsonPart += '}';
					result += jsonPart;
				}
			}

		} catch (Exception e){
			result += e.getLineNumber()+' : ' + e.getMessage();
			throw new AuraHandledException(e.getMessage());
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
    public static Id saveData(string allData){
        buildertek__Walk_Through_Line_Items__c newRecord = (buildertek__Walk_Through_Line_Items__c) JSON.deserialize(allData, buildertek__Walk_Through_Line_Items__c.class);
        insert newRecord;
        return newRecord.Id; 
    }

    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }

    @AuraEnabled
    public static List<pricebookWrapper> getPricebookList(string recordId){
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();
        
        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [SELECT Id, Name FROM pricebook2 ORDER BY Name ASC ];
        priceWrap.priceWrapList=PriceList;
        
        if(PriceList.size() > 0){
            if(recordId != null){
                buildertek__Walk_Through_List__c walkThroughList = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Walk_Through_List__c  WHERE Id = :recordId];
                if(walkThroughList.buildertek__Project__c != null && walkThroughList.buildertek__Project__r.buildertek__Price_Book__c !=null){
                    pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:walkThroughList.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                    if(selectedPriceList != null){
                        priceWrap.defaultValue= selectedPriceList;
                    }
                    else{
                        priceWrap.defaultValue = PriceList[0];
                    }
                }
                else{
                    priceWrap.defaultValue = PriceList[0];
                }
            }
        }

        priceWrapper.add(priceWrap);
        return priceWrapper;
    }

	// @AuraEnabled
    // public static List<String> getProductFamily(String pbookId){
    //     try {

    //         List<PriceBookEntry> pEntries2 = [SELECT Id,Product2Id, toLabel(Product2.Family), 
    //                                         Product2.IsActive, Pricebook2.Name  //----
    //                                         FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND Product2.Family != null AND IsActive = True 
    //                                         ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 50000];

    //         Set<String> ProductfamilySet = new Set<String>();
    //         for(PriceBookEntry PE : pEntries2){
    //             if(PE.Product2.Family != null){
    //                 ProductfamilySet.add(PE.Product2.Family);
    //             }
    //         }

    //         return new List<String>(ProductfamilySet);
            
    //     } catch (Exception e) {
    //         System.debug('Exception in getProductFamily : '+ e.getMessage());
    //         return null;
    //     }
    // }


    // get product family
    // @AuraEnabled
    // public static string getpricebook(string BudgetId){
    //     system.debug('budgetId-------->'+BudgetId);
    //     list<buildertek__Purchase_Order__c> purchaseOrder;
    //     if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
    //         purchaseOrder = [select id, buildertek__Project__r.buildertek__Price_Book__c
    //                          from buildertek__Purchase_Order__c
    //                          where id = :BudgetId];
    //     }
    //     system.debug('changeOrder--------->'+purchaseOrder);
    //     if (purchaseOrder.size() > 0){
    //         return purchaseOrder[0].buildertek__Project__r.buildertek__Price_Book__c;
    //     }
    //     return null;
    // }
  
    // public class pricebookWrapper{
    //     @AuraEnabled
    //     public List<pricebook2> priceWrapList;

    //     @AuraEnabled
    //     public pricebook2 defaultValue;
    // }

    // @AuraEnabled
    // public static List<pricebookWrapper> getpricebooks(Id recordId){
    //     System.debug('****getpricebooks******');
    //     List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();

    //     pricebookWrapper priceWrap = new pricebookWrapper();
    //     priceWrap.defaultValue= new pricebook2();
    //     priceWrap.priceWrapList = new List<pricebook2>();
    //     List<pricebook2> PriceList = [select Id, Name from pricebook2 WHERE Name != null ORDER BY Name ASC];
    //     priceWrap.priceWrapList=PriceList;
    //     System.debug(recordId);

    //     if(recordId != null ){
    //         buildertek__Purchase_Order__c poRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Purchase_Order__c  WHERE Id = :recordId];
    //         if(poRecord.buildertek__Project__c != null && poRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
    //             System.debug('Project notnull');
    //             pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:poRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
    //             System.debug(selectedPriceList);

    //             priceWrap.defaultValue= selectedPriceList;
    //         }
    //     }
    //     priceWrapper.add(priceWrap);
    //     return priceWrapper;
    // }

    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId, string pricebookId){

        list<PricebookEntry> pList;

        pList = [SELECT id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c, Product2.buildertek__Instructions__c, Product2.Description, Product2.Name
                 FROM PricebookEntry
                 where product2Id = :productId and isActive = true and pricebook2Id =: pricebookId];

        return pList;
    }

    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){

            list<pricebookEntry> PElist;

            PElist = [select id, Product2Id
                      from pricebookEntry
                      where pricebook2Id = :parentId];

            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        List<AggregateResult> productfamlylst = [SELECT toLabel(Family) familyLabel
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('familyLabel'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }

    @AuraEnabled
    public static PricebookEntry getProductPricevalue(string productId){
        productId = productId.replace('"', '');
        productId = productId.replace('[', '');
        productId = productId.replace(']', '');
        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, Product2Id, Product2.Name
                 from PricebookEntry
                 where product2Id = :productId];
        system.debug('pList'+pList);
        if (pList.size() > 0){
            return pList[0];
        }

        system.debug('====pList' + pList);
        return null;
    }


    @AuraEnabled
    public static List<productWrapper> getProductsthroughPriceBook2(string priceBookId, string productFamilyLabel, String searchProduct ) {

        String queryString = 'SELECT Id, Product2Id, Product2.buildertek__Quote_Group__c, Product2.Name, Product2.ProductCode, '
                            + 'Product2.buildertek__Vendor__r.Name, Product2.buildertek__Cost_Code__r.Name, Product2.Description, '
                            + 'toLabel(Product2.Family),Product2.buildertek__Instructions__c, Product2.IsActive, buildertek__Unit_Cost__c, buildertek__Markup__c, '
                            + 'buildertek__Discount__c, Pricebook2.Name, UnitPrice, Product2.QuantityUnitOfMeasure '
                            + 'FROM PricebookEntry WHERE Pricebook2Id = :priceBookId AND IsActive = True';
    
        if (String.isNotBlank(searchProduct)) {
            queryString += ' AND (Product2.Name LIKE :searchProduct OR Product2.ProductCode LIKE :searchProduct)';
        }
    
        if (productFamilyLabel != 'All') {
            queryString += ' AND Product2.Family = :productFamilyLabel';
        }
    
        queryString += ' ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 100';
    
        List<PriceBookEntry> pEntries = Database.query(queryString);    

        List<productWrapper> products = new List<productWrapper>();
        for (PriceBookEntry pEntry: pEntries) {
            productWrapper aProduct = new productWrapper();
            aProduct.Id = pEntry.Product2Id;
            aProduct.Vendor = pEntry.Product2.buildertek__Vendor__r.Name;
            aProduct.CostCode = pEntry.Product2.buildertek__Cost_Code__r.Name;
            aProduct.Name = pEntry.Product2.Name;
            aProduct.ProductCode = pEntry.Product2.ProductCode;
            aProduct.Description = pEntry.Product2.Description;
            aProduct.Family = pEntry.Product2.Family;
            aProduct.IsActive = pEntry.Product2.IsActive;
            aProduct.UnitPrice = pEntry.UnitPrice;            
            aProduct.Size = pEntry.Pricebook2.Name;
            aProduct.Selected = false;
            aProduct.MarkUp = pEntry.buildertek__Markup__c;
            aProduct.Discount = pEntry.buildertek__Discount__c;
            aProduct.UnitCost = pEntry.buildertek__Unit_Cost__c;
            aProduct.Phase = pEntry.Product2.buildertek__Quote_Group__c;
            aProduct.QuantityUnitOfMeasure = pEntry.Product2.QuantityUnitOfMeasure;     
            aProduct.Instructions = pEntry.Product2.buildertek__Instructions__c;     
            products.add(aProduct);
        }

        return products;
    }



    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }

    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String strRecordId;

    }
    @AuraEnabled
    public static Map<String, String> getselectOptions(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = buildertek__Purchase_Order__c.buildertek__Status__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }

    public class productWrapper{
        @AuraEnabled
        public Id Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String ProductCode;
        @AuraEnabled
        public String Description;
        @AuraEnabled
        public String Family;
        @AuraEnabled
        public Boolean IsActive;
        @AuraEnabled
        public Decimal UnitPrice;
        @AuraEnabled
        public String Size;
        @AuraEnabled
        public Boolean Selected;
        @AuraEnabled
        public Decimal UnitCost;
        @AuraEnabled
        public String Phase;
        @AuraEnabled
        public Decimal MarkUp;
        @AuraEnabled
        public Decimal Discount;
        @AuraEnabled
        public String Vendor;
        @AuraEnabled
        public String CostCode;
        @AuraEnabled
        public String QuantityUnitOfMeasure; 
        @AuraEnabled
        public String PriceBookId; 
        @AuraEnabled
        public String PriceBookName;
        @AuraEnabled
        public String PriceBookEntryId;
        @AuraEnabled 
        public List<String> ProductFamilySet;
        @AuraEnabled
        public String Instructions;
    }

    @AuraEnabled
    public static List<String> getProductFamily(String pbookId){
        try {

            List<PriceBookEntry> pEntries2 = [SELECT Id,Product2Id, toLabel(Product2.Family), 
                                            Product2.IsActive, Pricebook2.Name  //----
                                            FROM PricebookEntry WHERE Pricebook2Id=:pbookId AND Product2.Family != null AND IsActive = True 
                                            ORDER BY Product2.Family ASC NULLS LAST, Product2.Name ASC NULLS LAST LIMIT 50000];

            Set<String> ProductfamilySet = new Set<String>();
            for(PriceBookEntry PE : pEntries2){
                if(PE.Product2.Family != null){
                    ProductfamilySet.add(PE.Product2.Family);
                }
            }

            return new List<String>(ProductfamilySet);
            
        } catch (Exception e) {
            System.debug('Exception in getProductFamily : '+ e.getMessage());
            return null;
        }
    }


}