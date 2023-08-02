/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  06-Nov-2017
Last Modified By: DILIGENT FORCE LABS
Date: 11-Mar-2020
*/
public with sharing class QuoteItemTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipQuoteItemTrigger = false;
     
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public QuoteItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(Quote_Item__c[] newQuoteItems){
        List<Quote_Item__c> qItems = new List<Quote_Item__c>();
        for(Quote_Item__c qItem: newQuoteItems) {
            System.debug('qItem.Grouping__c ----> '+qItem.Grouping__c);
            if(qItem.buildertek__Quantity__c == null ){
                qItem.buildertek__Quantity__c = 1;
            }
            if(qItem.Grouping__c == null) {
                qItems.add(qItem);
            }
        }
        
        if(!qItems.isEmpty()) QuoteDAO.setDefaultGrouping(qItems);
        QuoteDAO.setProductNameToItemName(newQuoteItems);
    }
     
    public void OnBeforeUpdate(Quote_Item__c[] oldQuoteItems, Quote_Item__c[] updatedQuoteItems, Map<ID, Quote_Item__c> QuoteItemMap){
        List<Quote_Item__c> qItems = new List<Quote_Item__c>();
        for(Quote_Item__c qItem: updatedQuoteItems) {
            if(qItem.Grouping__c == null) {
                qItems.add(qItem);
            }
        }
        
        if(!qItems.isEmpty()) QuoteDAO.setDefaultGrouping(qItems);  
        QuoteDAO.setProductNameToItemName(updatedQuoteItems);
    }
    
    public void OnBeforeUpdateQuoteLine(List<Quote_Item__c> updatedQuoteItems){
       // List<Quote_Item__c> qItems = new List<Quote_Item__c>();
      list<buildertek__Quote_Line_Group__c> quoteGroupName=[SELECT 
                                                      Id, 
                                                      Name
                                                      FROM buildertek__Quote_Line_Group__c 
                                                      where Name=:'No Grouping'];
       // if(quoteGroupName!=null){
       if(quoteGroupName.size() > 0){
        for(Quote_Item__c qItem: updatedQuoteItems) {
            if(qItem.Grouping__c == null) {
                qItem.Grouping__c=quoteGroupName[0].Id;
                //qItems.add(qItem);
            }
        }
        }
    }
     
    public void OnBeforeDelete(Quote_Item__c[] QuoteItemToDelete, Map<ID, Quote_Item__c> QuoteItemMap){
        RFQTriggerHandler.skipDeleteQuoteLine = true;
        set<id> QuoteId = new set<id>();
        for(Quote_Item__c qItem: QuoteItemToDelete) {
            QuoteId.add(qItem.buildertek__Quote__c);
        } 
        List<buildertek__RFQ__c> rfqList = [SELECT Id, buildertek__Added_to_Quote__c FROM buildertek__RFQ__c WHERE buildertek__Added_to_Quote__c IN :QuoteId];
        if(rfqList.size() > 0){
            for(buildertek__RFQ__c rfq : rfqList){
                rfq.buildertek__Added_to_Quote__c = null;
            }
            update rfqList;
        }
        RFQTriggerHandler.skipDeleteQuoteLine = false;
        
    }
     
    public void OnAfterInsert(Quote_Item__c[] newQuoteItems, Map<ID, Quote_Item__c> newQuoteItemsMap){ 
        
    }
     
    public void OnAfterUpdate(Quote_Item__c[] oldQuoteItems, Quote_Item__c[] updatedQuoteItems, Map<ID, Quote_Item__c> QuoteItemMap, Map<Id, Quote_Item__c> oldQuoteItemsMap){
        
    }
    
    public void OnBeforeUpdate(Quote_Item__c[] newQuoteItems, Map<ID, Quote_Item__c> newQuoteItemsMap){
     
    }
    
    public void OnAfterDelete(Quote_Item__c[] oldQuoteItems){
     
    }
}