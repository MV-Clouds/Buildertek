public with sharing class MasterBudgetItemDAO {
    
public static void setDefaultGrouping(List<buildertek__Master_Budget_Line__c> masterBudgetItems){
        set<Id> budgetIds = new set<Id>();
		SET<Id> groupIds = new SET<Id>();
		map<String, String> budgetIdByGroupId = new map<String, String>();
		// get all quote Ids
		for(buildertek__Master_Budget_Line__c bItem : masterBudgetItems){
			budgetIds.add(bItem.buildertek__Master_Budget__c);
			if(bItem.buildertek__Group__c != null){
			    groupIds.add(bItem.buildertek__Group__c);
			    budgetIdByGroupId.put(bItem.Id, bItem.buildertek__Group__c);
			}
		}
		
		if(!groupIds.isEmpty()){
		    for(buildertek__Master_Budget_Line__c bItem : masterBudgetItems){
    			bItem.buildertek__Group__c = budgetIdByGroupId.get(bItem.Id);
    		}    
		}else{
		      List<buildertek__Budget_Line_Group__c> btGroup;
		     if(Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Id.isAccessible()
		        && Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isAccessible()){
		      btGroup = [SELECT Id FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping'];
		     }
		    if(btGroup.size() > 0){
		        for(buildertek__Master_Budget_Line__c bItem : masterBudgetItems){
        			bItem.buildertek__Group__c = btGroup[0].Id;
        		}         
		    }else{
		        buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
		        if (Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isCreateable()) {
		            budgetGroup.Name = 'No Grouping';     
		        
		        insert budgetGroup;
		        }
		        for(buildertek__Master_Budget_Line__c bItem : masterBudgetItems){
        			bItem.buildertek__Group__c = budgetGroup.Id;
        		} 
		    }
		    
		    
		}
    }
    
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
    public static buildertek__Master_Budget_Line__c saveMBItem(String MBLines, String MBId){
        buildertek__Master_Budget_Line__c MBItemToInsert = (buildertek__Master_Budget_Line__c)JSON.deserialize(MBLines, buildertek__Master_Budget_Line__c.class);
        
         MBItemToInsert.buildertek__Master_Budget__c = MBId;
     
        insert MBItemToInsert;    
        
        return MBItemToInsert;     
    }
    
}