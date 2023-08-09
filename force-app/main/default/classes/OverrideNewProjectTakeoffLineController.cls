public class OverrideNewProjectTakeoffLineController {
  
   

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
    public static string getpricebook(string PtoffId){
        list<buildertek__Project_Takeoff__c> projecttakeoffrec = [select id,Name,
                                        buildertek__Project__r.buildertek__Price_Book__c 
                                        from buildertek__Project_Takeoff__c 
                                        where id =: PtoffId ];
            
        if(projecttakeoffrec.size() > 0){ 
            return projecttakeoffrec[0].buildertek__Project__r.buildertek__Price_Book__c ;
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
    public static buildertek__Project_Takeoff_Lines__c savePToffline(String takeoffLines, String PtoffId){
        buildertek__Project_Takeoff_Lines__c TakeofflineToInsert = (buildertek__Project_Takeoff_Lines__c)JSON.deserialize(takeoffLines, buildertek__Project_Takeoff_Lines__c.class);
        system.debug('PtoffId---->'+PtoffId);
       // system.debug('checknamelength----'+TakeofflineToInsert.buildertek__Item_Name__c.length());
       
           // TakeofflineToInsert.buildertek__Description__c = TakeofflineToInsert.buildertek__Product__r.name;
           // TakeofflineToInsert.buildertek__Item_Name__c = TakeofflineToInsert.buildertek__Item_Name__c.left(250);
           // TakeofflineToInsert.Name = TakeofflineToInsert.buildertek__Item_Name__c.left(79);
             
         
         TakeofflineToInsert.buildertek__Project_Takeoff__c = PtoffId;
     
        insert TakeofflineToInsert;    
        
        return TakeofflineToInsert;     
    }

    @AuraEnabled
    public static string saveTakeOffLineRecords(String data){
        System.debug('In save method');

        buildertek__Project_Takeoff_Lines__c takeOffLinesToInsert = (buildertek__Project_Takeoff_Lines__c)JSON.deserialize(data, buildertek__Project_Takeoff_Lines__c.class);
       
        insert takeOffLinesToInsert;
        return takeOffLinesToInsert.ID;
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


    
}