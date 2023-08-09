public class BudgetAddLines {
     Public String recordId{ get; set; }
    
    Private ApexPages.StandardController controller;
    
    Public BudgetAddLines(){
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }
    @AuraEnabled
    public static String getRecords(String parentRecordId, String fieldNameJson,Integer pageNumber, Integer pageSize){
        
        List<sObject> lstResult = new List<sObject>();
        String result = '[]';
        try{
            if(String.isNotBlank(parentRecordId)){
                Integer offset = (pageNumber - 1) * pageSize;
                List<String> fieldNames = (List<String>)JSON.deserialize(fieldNameJson, List<String>.class);
                Set<String> setFieldNames = new Set<String>();
                String query = 'SELECT ' + String.join(fieldNames, ',')+' FROM buildertek__Budget_Item__c';
                query += ' WHERE buildertek__Budget__c = : parentRecordId ORDER BY Name ASC NULLS LAST';
                query += ' LIMIT : pageSize OFFSET : offset';
                for (sObject s : Database.query(query)){
                    lstResult.add(s);
                }
                if (lstResult.size() > 0){
                    result = JSON.serialize(lstResult);
                    return result;
                }
            }
        } catch (Exception e){
            System.debug('Error' + e.getMessage());
        }
        return null;
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
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst = [SELECT family
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }
    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
    }
    
    

}