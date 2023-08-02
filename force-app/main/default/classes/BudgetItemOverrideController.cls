public class BudgetItemOverrideController {
   
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
    public static list<PricebookEntry> getProductPrice(string productId , String pricebookId){

        System.debug('########ProductId'+productId);
        System.debug('########pricebook ---> '+pricebookId);
        list<PricebookEntry> pList;
        
            // pList = [select id,UnitPrice,buildertek__Unit_Cost__c,buildertek__Markup__c from PricebookEntry where 
            // product2Id =: productId and
            // isActive = true and 
            // pricebook2Id IN (select id from Pricebook2 Where isActive =true)];
            
        plist = [select id,UnitPrice,buildertek__Unit_Cost__c,buildertek__Markup__c from PricebookEntry where Product2Id =: productId and pricebook2Id =: pricebookId and isActive = true ];
        system.debug('====pList'+pList);
        return pList;
    }    
        @AuraEnabled 
    public static string getpricebook(string budgetid){
        list<buildertek__Budget__c> budgetrec = [select id,
                                        buildertek__Project__r.buildertek__Price_Book__c 
                                        from buildertek__Budget__c 
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
        
            PriceList = [select Id,Name from pricebook2 WHERE Name!=null order by Name asc];
        
        for (pricebook2 p: PriceList) {
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id); 
        }
        //System.debug('options '+options);
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
    public static buildertek__Budget_Item__c saveMBItem(String MBLines, String MBId){
        buildertek__Budget_Item__c MBItemToInsert = (buildertek__Budget_Item__c)JSON.deserialize(MBLines, buildertek__Budget_Item__c.class);
        system.debug('MBId---->'+MBItemToInsert.buildertek__Item_Name__c);
       // system.debug('checknamelength----'+MBItemToInsert.buildertek__Item_Name__c.length());
        if(MBItemToInsert.buildertek__Item_Name__c != null){
           if( MBItemToInsert.buildertek__Item_Name__c.length() > 79){
            MBItemToInsert.buildertek__Description__c = MBItemToInsert.buildertek__Item_Name__c;
            MBItemToInsert.buildertek__Item_Name__c = MBItemToInsert.buildertek__Item_Name__c.left(250);
            MBItemToInsert.Name = MBItemToInsert.buildertek__Item_Name__c.left(79);
         } 
        }else{
            MBItemToInsert.buildertek__Description__c = '';
            MBItemToInsert.buildertek__Item_Name__c = '';
            MBItemToInsert.Name = '';
        }
        
         MBItemToInsert.buildertek__Budget__c = MBId;
     
        insert MBItemToInsert;    
        
        return MBItemToInsert;     
    }

    @AuraEnabled(cacheable=true)
    public static List<BT_Lightning_Utils.FieldSetWrapper> getfield(string objectName, string fieldSetName){
        List<Schema.FieldSetMember> fieldSet = BT_UTILS.getFieldSetMembers(fieldSetName, objectName);
        //System.debug('fieldSet-->'+fieldSet);
        List<BT_Lightning_Utils.FieldSetWrapper> fMaplist = new List<BT_Lightning_Utils.FieldSetWrapper>();
        for (Schema.FieldSetMember fmem : fieldSet){
            fMaplist.add(new BT_Lightning_Utils.FieldSetWrapper(fmem.getLabel(), fmem.getFieldPath(), fmem, Schema.getGlobalDescribe().get(objectName).newSObject()));
        }
        System.debug('fMaplist-->'+fMaplist);
        return fMaplist;
    }



    @AuraEnabled
    public static String getFieldSet(String objectName, String fieldSetName){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get(objectName);
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
                        pickListValuesList = getDropDown(objectName, String.valueOf(f.getFieldPath()));
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


    // method to store multiple var types data in a map
    @AuraEnabled(cacheable=true)
    public static List<PricebookEntry> getProductComponentValues (String productId , String PriceBookName){
        List<PricebookEntry> pricebookEntries = [SELECT Id, UnitPrice,buildertek__Unit_Cost__c FROM PricebookEntry WHERE Product2Id =: productId AND IsActive = true AND Pricebook2.Name =: PriceBookName];
        return pricebookEntries;
    }

    @AuraEnabled(cacheable=true)
    public static List<Pricebook2> getPriceBookNames(){
        List<Pricebook2> PriceBookName = [SELECT Id , Name FROM Pricebook2];
        return PriceBookName;
    }     

    //* method for saving data into object
    @AuraEnabled
    public static String saveData(String productId, String allData){
        String budgetNewId;
        buildertek__Budget_Item__c budgetItem = (buildertek__Budget_Item__c) JSON.deserialize(allData, buildertek__Budget_Item__c.class);
        Id recordId = Id.valueOf(productId);
        if (budgetItem.Name.length() > 80) {
            string subStr = budgetItem.Name.subString(0,76);
            budgetItem.Name = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
        }
        budgetItem.buildertek__Product__c = recordId;
        insert budgetItem;
        budgetNewId = String.valueOf(budgetItem.Id);
        return budgetNewId;
    }
    
}