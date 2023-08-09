/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_ProductSelector {
    public static List<List<SObject>> searchProductsByCriteria(Id priceBookId, String condition, String keyword){
        if(condition != null && condition != ''){
            condition = 'where '+ condition;
        }
        String queryString = 'Find : keyword IN ALL FIELDS RETURNING Product2 (Id  '+condition+') WITH PricebookId =: priceBookId';
        System.debug('################The Search String is #########: ' + queryString);
        System.debug('################The keyword is #########: ' + keyword);
        return search.query(String.escapeSingleQuotes(queryString));    
    }
    
    public static List<Product2> queryProductsByCriteria(Id priceBookId, String condition){
        String queryCondition = '';
        if(condition != null && condition != ''){
            queryCondition = queryCondition + ' where  ' + condition + ' WITH pricebookId =: priceBookId';
        }
        String queryString = 'Select Id from Product2 ' + queryCondition;
         List<Product2> prdlst ;
        /* if(Schema.sObjectType.Product2.fields.Id.isAccessible()&&
             Schema.sObjectType.Product2.fields.ProductCode.isAccessible() ){*/
         prdlst = database.query(String.escapeSingleQuotes(queryString));
    /*}*/
        return prdlst;
    }
}