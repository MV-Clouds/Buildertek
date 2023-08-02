/**
 *  @author Pratap Kumar
 *  @date 2 October 2018
 *  @description Helper class to create budget
 */
public with sharing class BudgetPurchaseOrderCreateHelper {
	/**
	 *  @description Helper methods to create Budget
	 */
	 public static List<buildertek__Budget__c> createBudgetFromPurchaseOrder(List<Id> listPurchaseIds) {
		Integer intIndex = 0;
		Map<Integer, buildertek__Budget__c> mapBudgetIndex = new Map<Integer, buildertek__Budget__c>();
		Map<Integer, List<buildertek__Budget_Item__c>> mapBudgetLinesIndex = new Map<Integer, List<buildertek__Budget_Item__c>>();
		for(buildertek__Purchase_Order__c currPurchase : getPurchaseWithLines(listPurchaseIds)) {
			mapBudgetIndex.put(
				intIndex,
				new buildertek__Budget__c(
					Name = currPurchase.Name,
					buildertek__Project__c = currPurchase.buildertek__Project__c
				)
			);
			
			mapBudgetLinesIndex.put(intIndex, new List<buildertek__Budget_Item__c>());
			
			for(buildertek__Purchase_Order_Item__c currPurchaseLine : currPurchase.buildertek__Purchase_Order_Items__r) {
				mapBudgetLinesIndex.get(intIndex).add(new buildertek__Budget_Item__c(
					Name = currPurchaseLine.Name,
					buildertek__Product__c = currPurchaseLine.buildertek__Product__c,
					buildertek__Item_Name__c = currPurchaseLine.buildertek__Item_Name__c,
					buildertek__Cost_Code__c = currPurchaseLine.buildertek__Cost_Code__c,
					buildertek__Quantity__c = currPurchaseLine.buildertek__Quantity__c,
					buildertek__Unit_Price__c = currPurchaseLine.buildertek__Unit_Price__c
				));
			}
			
			intIndex++;
		}
		
		if(!mapBudgetIndex.isEmpty()) {
			List<buildertek__Budget_Item__c> listBudgetItems = new List<buildertek__Budget_Item__c>();
							
	   if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isCreateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable()) {
			insert mapBudgetIndex.values();
            }
			
			for(Integer currIndex : mapBudgetIndex.keySet()) {
				for(buildertek__Budget_Item__c currBudgetItem : mapBudgetLinesIndex.get(currIndex)) {
				    system.debug('listBudgetItems *** '+ mapBudgetIndex.get(currIndex).Id);
				    if(Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable()){
    					currBudgetItem.buildertek__Budget__c = mapBudgetIndex.get(currIndex).Id;
    					listBudgetItems.add(currBudgetItem);
				    }
				}
			}
			
			system.debug('listBudgetItems *** '+ listBudgetItems.size() );
			if(!listBudgetItems.isEmpty()) {
			    if(Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isCreateable() 
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable() 
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable()
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Product__c.isCreateable()
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Cost_Code__c.isCreateable()
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Item_Name__c.isCreateable()
            && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable()){
				insert listBudgetItems;
            }
			}
		}
		return mapBudgetIndex.values();
	}
	/**
     *  @description Get all purchase Order and associated Purchase Order Line Items on Purechase Order Id's
     */
    public static List<buildertek__Purchase_Order__c> getPurchaseWithLines(List<Id> listPurchaseIds) {
        List<buildertek__Purchase_Order__c> purchaseorderlist ;
         if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Period__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Change_Order__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Completion__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Contractor_Resource__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Auto_Number__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Amount__c.isAccessible()&&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() &&
    		
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__CO_Amount__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Crew_Date__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Date_Approved__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Date_Created__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Delivery_Date__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Location__c.isAccessible()  &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Ship_To_Address__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Sub_Contract__c.isAccessible()&&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Tax__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Type__c.isAccessible() &&
    		
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Id.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Description__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Item_Name__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Expense_GL_Account__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Liability_GL_Account__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__RFQ_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    		
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Lot__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Ordered_Date__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Tax__c.isAccessible() ){
    		    
        purchaseorderlist= [SELECT Id, Name, buildertek__Period__c, buildertek__Budget__c, buildertek__Change_Order__c, 
    					buildertek__CO_Amount__c, buildertek__Completion__c, buildertek__Vendor__c, buildertek__Contractor_Resource__c, 
    					buildertek__Crew_Date__c, buildertek__Date_Approved__c, buildertek__Date_Created__c, buildertek__Delivery_Date__c, buildertek__Location__c, 
    					buildertek__Auto_Number__c, buildertek__PO_Amount__c, buildertek__PO_Total__c, 
    					buildertek__Project__c, buildertek__RFQ__c, buildertek__Ship_To_Address__c, buildertek__Status__c,
    					buildertek__Sub_Contract__c,buildertek__Tax__c,buildertek__Type__c,
    					
    					(SELECT Id, Name, buildertek__Budget_Item__c, buildertek__Cost_Code__c, buildertek__Description__c, buildertek__Expense_GL_Account__c, 
    					buildertek__Item_Name__c, buildertek__Liability_GL_Account__c, buildertek__Lot__c, buildertek__Ordered_Date__c, 
    					buildertek__Product__c, buildertek__Purchase_Order__c,buildertek__Quantity__c,buildertek__RFQ_Item__c,
    					buildertek__Tax__c,buildertek__Total_Amount_Tax__c,buildertek__Total_Price__c,
    					buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Items__r)
    			FROM buildertek__Purchase_Order__c
    			WHERE Id IN : listPurchaseIds];		
    }
    	return purchaseorderlist;
    }
}