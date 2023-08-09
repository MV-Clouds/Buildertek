public class PackageLineOverrideController {

   
public static void setDefaultGrouping(List<buildertek__Budget_Item__c> BudgetItems){
        set<Id> budgetIds = new set<Id>();
		SET<Id> groupIds = new SET<Id>();
		map<String, String> budgetIdByGroupId = new map<String, String>();
		// get all quote Ids
		for(buildertek__Budget_Item__c bItem : BudgetItems){
			budgetIds.add(bItem.buildertek__Budget__c);
			if(bItem.buildertek__Group__c != null){
			    groupIds.add(bItem.buildertek__Group__c);
			    budgetIdByGroupId.put(bItem.Id, bItem.buildertek__Group__c);
			}
		}
		
		if(!groupIds.isEmpty()){
		    for(buildertek__Budget_Item__c bItem : BudgetItems){
    			bItem.buildertek__Group__c = budgetIdByGroupId.get(bItem.Id);
    		}    
		}else{
		      List<buildertek__Budget_Line_Group__c> btGroup;
		     if(Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Id.isAccessible()
		        && Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isAccessible()){
		      btGroup = [SELECT Id FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping'];
		     }
		    if(btGroup.size() > 0){
		        for(buildertek__Budget_Item__c bItem : BudgetItems){
        			bItem.buildertek__Group__c = btGroup[0].Id;
        		}         
		    }else{
		        buildertek__Budget_Line_Group__c budgetGroup = new buildertek__Budget_Line_Group__c();
		        if (Schema.sObjectType.buildertek__Budget_Line_Group__c.fields.Name.isCreateable()) {
		            budgetGroup.Name = 'No Grouping';     
		        
		        insert budgetGroup;
		        }
		        for(buildertek__Budget_Item__c bItem : BudgetItems){
        			bItem.buildertek__Group__c = budgetGroup.Id;
        		} 
		    }
		    
		    
		}
    }
    @AuraEnabled
    public static String getobjectName(Id recordId){
        String sObjName = recordId.getSObjectType().getDescribe().getName();  
        return sObjName;
    }
    
    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook'+productId);
        list<PricebookEntry> pList;
        
            pList = [select id,UnitPrice,buildertek__Unit_Cost__c,buildertek__Markup__c from PricebookEntry where 
            product2Id =: productId and
            isActive = true and 
            pricebook2Id IN (select id from Pricebook2 Where isActive =true)];
            
        system.debug('====pList'+pList);
        return pList;
    }    
        @AuraEnabled 
    public static string getpricebook(string budgetid){
        list<buildertek__Package__c> budgetrec = [select id,
                                        buildertek__Project__r.buildertek__Price_Book__c 
                                        from buildertek__Package__c 
                                        where id =: budgetid ];
            
        if(budgetrec.size() > 0){ 
            return budgetrec[0].buildertek__Project__r.buildertek__Price_Book__c ;
        }
        return null;
    }
 @AuraEnabled //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        
        list<pricebook2> PriceList;
        
            PriceList = [select Id,Name from pricebook2 WHERE Name!=null];
        
        for (pricebook2 p: PriceList) {
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id); 
        }
        return options;
    } 
    
     @AuraEnabled public list<productfamilyClass> pfwrapperlst {get;set;}
     //get product family Values
    @AuraEnabled 
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName,string parentId) {
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List < sObject > returnList = new List < sObject > ();
       
        list<string> ProdIds = new list<string>();
        if(ObjectName == 'Product2' && parentId != null){
            
             list<pricebookEntry> PElist;
             
             PElist = [select id,Product2Id from pricebookEntry where pricebook2Id =: parentId];
           
            for(pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
         }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
         List<AggregateResult> productfamlylst =[SELECT family FROM Product2  where (Id IN :ProdIds AND family != null) group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if(productfamlylst.size() > 0 ){
            for(AggregateResult agg : productfamlylst){
                 productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
                }
            system.debug('pfwrapperlst---->'+pfwrapperlst);
        }
         return pfwrapperlst;
    }
 public class productfamilyClass{
         @AuraEnabled public string productfamilyvalues {get;set;}
     }    
    
    @AuraEnabled
    public static buildertek__Package_Line__c saveMBItem(String MBLines, String MBId){
        buildertek__Package_Line__c MBItemToInsert = (buildertek__Package_Line__c)JSON.deserialize(MBLines, buildertek__Package_Line__c.class);
       // system.debug('MBId---->'+MBItemToInsert.buildertek__Item_Name__c);
       // system.debug('checknamelength----'+MBItemToInsert.buildertek__Item_Name__c.length());
       // if(MBItemToInsert.buildertek__Item_Name__c != null){
          // if( MBItemToInsert.buildertek__Item_Name__c.length() > 79){
           // MBItemToInsert.buildertek__Description__c = MBItemToInsert.buildertek__Item_Name__c;
          //  MBItemToInsert.buildertek__Item_Name__c = MBItemToInsert.buildertek__Item_Name__c.left(250);
          //  MBItemToInsert.Name = MBItemToInsert.buildertek__Item_Name__c.left(79);
        // } 
      //  }else{
           // MBItemToInsert.buildertek__Description__c = '';
           // MBItemToInsert.buildertek__Item_Name__c = '';
           // MBItemToInsert.Name = '';
      //  }
        
        MBItemToInsert.buildertek__Package_Name__c = MBId;
     
        insert MBItemToInsert;    
        
        return MBItemToInsert;     
    }
    @AuraEnabled
     public static Map<String, String> getIndustry(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Package_Line__c.buildertek__Location__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
     @AuraEnabled
     public static Map<String, String> getUOM(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Package_Line__c.buildertek__UOM__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    
}