public with sharing class InvoiceAR {
    @AuraEnabled
    public static List<COLineItemsClass> getItem(String coItems){
        system.debug('coItem -----------> ' + coItems);
        List<buildertek__Billable_Lines__c> changeOrderList = (List<buildertek__Billable_Lines__c>)JSON.deserialize(coItems, List<buildertek__Billable_Lines__c>.class);
        system.debug('changeOrderList -----------> ' + changeOrderList);
        List<COLineItemsClass> COItemsClassList = new List<COLineItemsClass>();
        Integer count = 0;
        for (buildertek__Billable_Lines__c CO : changeOrderList){
            COLineItemsClass COItemsClass = new COLineItemsClass(CO, true, count);
            count++;
            COItemsClassList.add(COItemsClass);
        }

        return COItemsClassList;
    }

    public class COLineItemsClass{
        @AuraEnabled
        public buildertek__Billable_Lines__c changeOrderItem{ get; set; }

        @AuraEnabled
        public Boolean isProduct{ get; set; }

        @AuraEnabled
        public Integer rowIndex{ get; set; }

        public COLineItemsClass(buildertek__Billable_Lines__c changeOrderItem, Boolean isProduct, Integer rowIndex){
            this.changeOrderItem = changeOrderItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }

    @AuraEnabled
    public static List<COLineItemsClass> addProductsToList(String COItems, buildertek__Billable_Lines__c COItem, Integer count){
        system.debug('coItem -----------> ' + COItems);
        system.debug('COItem -----------> ' + COItem);
        system.debug('count ---------> ' + count);
        List<COLineItemsClass> changeOrderList = (List<COLineItemsClass>)JSON.deserialize(coItems, List<COLineItemsClass>.class);
        system.debug('changeOrderList -----------> ' + changeOrderList);

        changeOrderList.add(new COLineItemsClass(COItem, false, count));
        return changeOrderList;
    }

    @AuraEnabled
    public static ResponseBase createInvoiceAR(buildertek__Billings__c coJson, string coItemsJson, string budgetlineid,string descri){
        system.debug('coJson ----------> ' + coJson);
        system.debug('coItemsJson ----------> ' + coItemsJson);
        ResponseBase res = new ResponseBase();
        List<buildertek__Budget_Item__c> budgetid = new List<buildertek__Budget_Item__c>();
        try{
        if(budgetlineid != null || budgetlineid != ''){
         budgetid= [select id,name,buildertek__Budget__c from buildertek__Budget_Item__c where id =:budgetlineid];
        }
           coJson.buildertek__Status__c = 'Open'; 
            coJson.Name = descri;
            if(budgetid.size()>0){
            coJson.buildertek__Budget__c = budgetid[0].buildertek__Budget__c;
            }
            coJson.buildertek__Terms__c = ' Net 30';
            insert coJson;

            system.debug('coRec ---------> ' + coJson);

            List<buildertek__Billable_Lines__c> changeOrderItemList = new List<buildertek__Billable_Lines__c>();
            List<buildertek__Billable_Lines__c> coItems = new List<buildertek__Billable_Lines__c>();
            List<COLineItemsClass> COItemsList = (List<COLineItemsClass>)System.JSON.deserialize(coItemsJson, List<COLineItemsClass>.class);
            system.debug('COItemsList ------------> ' + COItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for (COLineItemsClass wrapper : COItemsList){
                changeOrderItemList.add(wrapper.changeOrderItem);
                productIdSet.add(wrapper.changeOrderItem.buildertek__Product__c);
            }

            List<Product2> productList;
            if (Schema.sObjectType.Product2.fields.Id.isAccessible() && Schema.sObjectType.Product2.fields.Name.isAccessible()){
                productList = [SELECT Id, Name
                               from Product2
                               where Id IN :productIdSet];
            }
            Map<String, String> productNameMap = new Map<String, String>();
            for (Product2 prod : productList){
                productNameMap.put(prod.Id, prod.Name);
            }

            for (buildertek__Billable_Lines__c coItem : changeOrderItemList){
                if (productNameMap.containskey(coItem.buildertek__Product__c)){
                string prodName = productNameMap.get(coItem.buildertek__Product__c);
                if(prodName.length()>80){
                   // coItem.Name = prodName.SubString(0,80);
                 }else{
                     // coItem.Name = prodName;
                  }
                    
                } else{
                    //coItem.Name = coJson.Name;
                }
                coItem.buildertek__Billings__c = coJson.Id;
                if (coItem.buildertek__Budget_Line__c == null){
                    coItem.buildertek__Budget_Line__c = budgetlineid;
                }
                coItems.add(coItem);
            }

            insert coItems;
            
            Map<string,buildertek__Billable_Lines__c> apimap = new map<string,buildertek__Billable_Lines__c>();
            List<string> budgetlistids = new List<string>();
            List<buildertek__Budget_Item__c> budgetreclist = new List<buildertek__Budget_Item__c>();
            for(buildertek__Billable_Lines__c ap :coItems){
                system.debug(ap.buildertek__Budget_Line__c);
                system.debug(ap.buildertek__Unit_Price__c);
                 system.debug(ap.buildertek__Quantity__c);
                apimap.put(ap.buildertek__Budget_Line__c,ap);
                budgetlistids.add(ap.buildertek__Budget_Line__c);
            }
            List<buildertek__Budget_Item__c> budget = new List<buildertek__Budget_Item__c>();
            if(budgetlistids.size()>0){
                 budget= [select id,buildertek__Invoice_total__c,name,buildertek__Budget__c from buildertek__Budget_Item__c where id IN:budgetlistids];
            }
            for(buildertek__Budget_Item__c b:budget){
                system.debug(b.name);
                system.debug(b.buildertek__Invoice_total__c);
                if(b.buildertek__Invoice_total__c != null){
                b.buildertek__Invoice_total__c = b.buildertek__Invoice_total__c+(apimap.get(b.id).buildertek__Quantity__c)*(apimap.get(b.id).buildertek__Unit_Price__c);
                }else{
                    b.buildertek__Invoice_total__c = 0+(apimap.get(b.id).buildertek__Quantity__c)*(apimap.get(b.id).buildertek__Unit_Price__c);
                }
            }
            if(budget.size()>0){
                update budget; 
            }
           for(buildertek__Billable_Lines__c ap :coItems){
               // ap.buildertek__Budget__c = budget[0].buildertek__Budget__c;
            }
             update coItems;

            system.debug('coItems ---------> ' + coItems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = coJson.Id;
            return res;

        } catch (Exception ex){
            system.debug('Message --------> ' + ex.getMessage());
            system.debug('%%%%'+ex.getLineNumber());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
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
    public static PricebookEntry getProductPricevalues(string productId){
        System.debug('########pricebook' + productId);
        productId = productId.replace('"', '');
        productId = productId.replace('[', '');
        productId = productId.replace(']', '');
        System.debug('########pricebook' + productId);
        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, Product2Id, Product2.Name
                 from PricebookEntry
                 where product2Id = :productId];
        if (pList.size() > 0){
            return pList[0];
        }
        

        system.debug('====pList' + pList);
        return null;
    }
}