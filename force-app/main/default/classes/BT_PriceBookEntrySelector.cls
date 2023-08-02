/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_PriceBookEntrySelector {
    public static List<PricebookEntry> getPricebookEntryByPBId(Id pricebook2Id, String orderBy){
        String queryString ='Select Id, Product2.Id, Product2.ProductCode, '
                              + 'Product2.Family, Product2.Name, Product2.Description, UnitPrice from PricebookEntry ';
        queryString = queryString + ' where Pricebook2Id =: pricebook2Id order by Product2.Name ASC limit 2000 ';
        system.debug('queryString -----------> '+queryString);
        list<PricebookEntry> pricebooklst;
        /*if(Schema.sObjectType.PricebookEntry.fields.id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.Name.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Pricebook2Id.isAccessible() 
              && Schema.sObjectType.Product2.fields.Name.isAccessible()
            && Schema.sObjectType.Product2.fields.ProductCode.isAccessible()
             && Schema.sObjectType.Product2.fields.Description.isAccessible()
              && Schema.sObjectType.Product2.fields.Family.isAccessible()
               && Schema.sObjectType.Product2.fields.Id.isAccessible()){*/
          pricebooklst = database.query(queryString);
           /*}*/
        return pricebooklst;
    }
    
    public static List<PricebookEntry> getPricebookEntryByCondition(Id pricebook2Id, String condition,  String orderBy){
        String queryString ='Select Id, Product2.Id, Product2.ProductCode, '
                              + 'Product2.Family, Product2.Name, Product2.Description, UnitPrice from PricebookEntry ';
        queryString = queryString + ' where Pricebook2Id =: pricebook2Id ';
        if(condition != null && condition != ''){
          queryString = queryString + '  and ( ' + condition + ' )' ;
        }
        
        queryString = queryString + ' ' + orderBy + ' limit 2000';
        System.debug('###############The query String is #############' + queryString);
         list<PricebookEntry> pricebooklst;
    /*    if(Schema.sObjectType.PricebookEntry.fields.id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.Name.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Pricebook2Id.isAccessible() 
              && Schema.sObjectType.Product2.fields.Name.isAccessible()
            && Schema.sObjectType.Product2.fields.ProductCode.isAccessible()
             && Schema.sObjectType.Product2.fields.Description.isAccessible()
              && Schema.sObjectType.Product2.fields.Family.isAccessible()
               && Schema.sObjectType.Product2.fields.Id.isAccessible()){*/
               pricebooklst = Database.query(queryString);
              /* }*/
        return pricebooklst; 
    }
    
    public static List<PricebookEntry> getPricebookEntryByPBANDProId(Id pricebook2Id, List<Id> productIds, String orderBy){
        String queryString ='Select Id, Product2.Id, Product2.ProductCode, '
                              + 'Product2.Family, Product2.Name, Product2.Description, UnitPrice from PricebookEntry ';
        queryString = queryString + ' where Pricebook2Id =: pricebook2Id  and product2Id in: productIds '+ orderBy + ' limit 2000';
        list<PricebookEntry> pricebooklst;
       /* if(Schema.sObjectType.PricebookEntry.fields.id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.Name.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible()
            && Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible()
             && Schema.sObjectType.PricebookEntry.fields.Pricebook2Id.isAccessible() 
              && Schema.sObjectType.Product2.fields.Name.isAccessible()
            && Schema.sObjectType.Product2.fields.ProductCode.isAccessible()
             && Schema.sObjectType.Product2.fields.Description.isAccessible()
              && Schema.sObjectType.Product2.fields.Family.isAccessible()
               && Schema.sObjectType.Product2.fields.Id.isAccessible()){*/
               pricebooklst = database.query(queryString);
               /*}*/
        return pricebooklst;
    }
}