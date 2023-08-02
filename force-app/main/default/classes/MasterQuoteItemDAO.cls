public with sharing class MasterQuoteItemDAO {
    
    public static void setDefaultGrouping(List<buildertek__Master_Quote_Item__c> masterBudgetItems){
        set<Id> quoteIds = new set<Id>();
		SET<Id> groupIds = new SET<Id>();
		map<String, String> quoteIdByGroupId = new map<String, String>();
		// get all quote Ids
		for(buildertek__Master_Quote_Item__c qItem : masterBudgetItems){
			quoteIds.add(qItem.buildertek__Master_Quote__c);
			if(qItem.buildertek__Quote_Line_Group__c != null){
			    groupIds.add(qItem.buildertek__Quote_Line_Group__c);
			    quoteIdByGroupId.put(qItem.Id, qItem.buildertek__Quote_Line_Group__c);
			}
		}
		
		if(!groupIds.isEmpty()){
		    for(buildertek__Master_Quote_Item__c qItem : masterBudgetItems){
    			qItem.buildertek__Quote_Line_Group__c = quoteIdByGroupId.get(qItem.Id);
    		}    
		}else{
		    List<buildertek__Quote_Line_Group__c> btGroup;
		    if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()
		    && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
		     btGroup = [SELECT Id FROM buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];
		    }
		    if(btGroup.size() > 0){
		        for(buildertek__Master_Quote_Item__c qItem : masterBudgetItems){
        			qItem.buildertek__Quote_Line_Group__c = btGroup[0].Id;
        		}         
		    }else{
		        buildertek__Quote_Line_Group__c quoteGroup = new buildertek__Quote_Line_Group__c();
		        if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()) {
		            quoteGroup.Name = 'No Grouping';     
		        }
		        
		        insert quoteGroup;
		        for(buildertek__Master_Quote_Item__c qItem : masterBudgetItems){
        			qItem.buildertek__Quote_Line_Group__c = quoteGroup.Id;
        		} 
		    }
		    
		    
		}
    }
    
    //Developer : Laxman 14/07/2020
    //Override the Master QuoteLIne New Button and auto populate the product fields.
    
     @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook'+productId);
        list<PricebookEntry> pList;
        if(Schema.sObjectType.pricebookEntry.fields.Id.isAccessible()&&
             Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
             Schema.sObjectType.PricebookEntry.fields.product2Id.isAccessible() &&
             Schema.sObjectType.Pricebook2.fields.Id.isAccessible() &&
             Schema.sObjectType.Pricebook2.fields.isActive.isAccessible()){
            pList = [select id,UnitPrice from PricebookEntry where 
            product2Id =: productId and
            isActive = true and 
            pricebook2Id IN (select id from Pricebook2 Where isActive =true)];
            }
        system.debug('====pList'+pList);
        return pList;
    }    
    
    @AuraEnabled
    public static buildertek__Master_Quote_Item__c saveMQItem(String MQLines, String MQId){
        buildertek__Master_Quote_Item__c MQItemToInsert = (buildertek__Master_Quote_Item__c)JSON.deserialize(MQLines, buildertek__Master_Quote_Item__c.class);
        MQItemToInsert.Name = MQItemToInsert.buildertek__Master_Quote_Item_Name__c;
         MQItemToInsert.buildertek__Master_Quote__c = MQId;
         
        insert MQItemToInsert;    
        system.debug('MQItemToInsert---->'+MQItemToInsert);
        return MQItemToInsert;     
    }
}