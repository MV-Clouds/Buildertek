/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_Products {
    public List<Product2> records {private set; public get;}
    public BT_Products(List<Product2> records){
        this.records = records;
    }
    
    public List<Id> getRecordIds(){
        List<Id> recordIds = new List<Id>();
        for(Product2 record: records){
            recordIds.add(record.Id);
        }
        return recordIds;
    }
}