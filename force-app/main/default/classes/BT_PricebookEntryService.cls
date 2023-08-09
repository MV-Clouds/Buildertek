/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_PricebookEntryService {

    public List<PricebookEntry> getPricebookEntryByPBId(Id pricebook2Id, String orderBy){
        return BT_PriceBookEntrySelector.getPricebookEntryByPBId(pricebook2Id, orderBy);
    }
    
    public List<PricebookEntry> getPricebookEntryByPBIdPBFamily(Id pricebook2Id, String orderBy,String PBFamily){
        String queryString ='Select Id, Product2.Id, Product2.ProductCode, '
            + 'Product2.Family, Product2.Name, Product2.Description, UnitPrice from PricebookEntry ';
        queryString = queryString + ' where Pricebook2Id =: pricebook2Id ';
        if(PBFamily != null && PBFamily != ''){
			queryString = queryString + 'AND Product2.Family =:PBFamily';            
        }
        queryString = queryString + ' order by Product2.Name ASC limit 2000 ';
        system.debug('queryString -----------> '+queryString);
        list<PricebookEntry> pricebooklst;
        pricebooklst = database.query(queryString); 
        return pricebooklst;
    }
    
    public List<PricebookEntry> getPricebookEntryByFilter(Id pricebook2Id, String filterInfoStr){
        List<PricebookEntry> pricebookEntries 
            = new List<PricebookEntry>();
        BT_ProductService productService = new BT_ProductService();
        
        BT_FilterCondition filterCondition =  BT_FilterCondition.create(filterInfoStr);
        
        String condition = filterCondition.generateConditions();
        String orderBy = filterCondition.orderBy;
        if(orderBy != null && orderBy != ''){
            orderBy = ' Order By Product2.'+ orderBy.trim();
        }
        if(orderBy == null){
            orderBy = '';
        }
        
        if(filterCondition.isForSearch){
            List<Id> productIdList = new BT_Products(productService.searchProductsByCriteria(
                    pricebook2Id, condition, filterCondition.keyword)).getRecordIds();        
            pricebookEntries = BT_PriceBookEntrySelector.getPricebookEntryByPBANDProId(pricebook2Id, productIdList, orderBy);    
        }else{
            pricebookEntries = BT_PriceBookEntrySelector.getPricebookEntryByCondition(pricebook2Id, condition, orderBy);                            
        }
        
        return pricebookEntries;
    }
}