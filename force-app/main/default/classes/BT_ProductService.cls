/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_ProductService {
    public List<Product2> searchProductsByCriteria(Id pricebookId, String condition, String keyword){
        List<Product2> records = new List<Product2>();
        List<List<SObject>> results = BT_ProductSelector.searchProductsByCriteria(pricebookId, condition, keyword);
        if(!results.isEmpty()){
            records = results.get(0);
        }
        
        return records;
    }
}