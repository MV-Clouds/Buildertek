public class OverrideNewQuoteLineItemController {
    
        @AuraEnabled 
    public static string getpricebook(string quotid){
        list<buildertek__Quote__c> Quoterec = [select id,
                                        buildertek__Project__r.buildertek__Price_Book__c 
                                        from buildertek__Quote__c 
                                        where id =: quotid ];
            
        if(Quoterec.size() > 0){ 
            return Quoterec[0].buildertek__Project__r.buildertek__Price_Book__c ;
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
        return options;
    } 
    
      @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook'+productId);
    
        
        
        list<PricebookEntry> pList;
        
             pList= [select id,UnitPrice,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c from PricebookEntry where 
            product2Id =: productId and
            isActive = true and 
            pricebook2Id IN (select id from Pricebook2 Where isActive =true)];
             
        system.debug('====pList'+pList);
        return pList;
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
    public static buildertek__Quote_Item__c saveQuotelineItem(String QuoteLines, String QuoteId){
        buildertek__Quote_Item__c QuoteitemToInsert = (buildertek__Quote_Item__c)JSON.deserialize(QuoteLines, buildertek__Quote_Item__c.class);
            QuoteitemToInsert.buildertek__Quote__c = QuoteId;
        if( QuoteitemToInsert.Name.length() > 79){
            QuoteitemToInsert.buildertek__Description__c = QuoteitemToInsert.Name;
            QuoteitemToInsert.Name = QuoteitemToInsert.Name.left(78);
            
         }
        
      /*  if(QuoteitemToInsert.buildertek__Product__c !=null){ 
           product2  prdctrec =[SELECT id,
                                       Name,
                                       buildertek__Cost_Code__c FROM product2 where Id=:QuoteitemToInsert.buildertek__Product__c];
            QuoteitemToInsert.buildertek__Cost_Code__c = prdctrec.buildertek__Cost_Code__c;
        }*/
           
            insert QuoteitemToInsert;    
            
        return QuoteitemToInsert;     
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

    @AuraEnabled
    public static string saveRecord(String data, String productid){
        buildertek__Quote_Item__c QuoteToInsert = (buildertek__Quote_Item__c)JSON.deserialize(data, buildertek__Quote_Item__c.class);
        //convert the string to Id
        if(QuoteToInsert.Name.length() > 79){
            QuoteToInsert.buildertek__Description__c = QuoteToInsert.Name;
            QuoteToInsert.Name = QuoteToInsert.Name.left(78);
        }
        Id prodId = Id.valueOf(productid);
        QuoteToInsert.buildertek__Product__c = prodId;

        System.debug('QuoteToInsert ==? '+QuoteToInsert);
        System.debug('prod ==>'+QuoteToInsert.buildertek__Product__c);
        insert QuoteToInsert;
        return QuoteToInsert.ID;
    }
    

}