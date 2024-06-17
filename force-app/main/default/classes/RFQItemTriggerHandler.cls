/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  03-Oct-2017
*/
public with sharing class RFQItemTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipRFQItemUpdateTrigger = false;
     
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public RFQItemTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    public void OnBeforeInsert(RFQ_Item__c[] newRFQItems){
        Set<Id> rfqIds = new Set<Id>();

        for(RFQ_Item__c rfqLine : newRFQItems){
            rfqIds.add(rfqLine.buildertek__RFQ_Package__c);
        }

        Map<Id, buildertek__RFQ__c> rfqMap = new Map<Id, buildertek__RFQ__c>();
        for(buildertek__RFQ__c rfq : [SELECT Id, buildertek__Status__c, (SELECT Id FROM RFQ_Items__r) FROM buildertek__RFQ__c WHERE Id IN :rfqIds]){
            rfqMap.put(rfq.Id, rfq);
        }

        for(RFQ_Item__c rfqItem : newRFQItems){
            buildertek__RFQ__c relatedRFQ = rfqMap.get(rfqItem.buildertek__RFQ_Package__c);
            if(relatedRFQ != null && relatedRFQ.buildertek__Status__c != 'New') {
                rfqItem.addError('The RFQ has already been ' + relatedRFQ.buildertek__Status__c + '. You cannot add more lines.');
            }
        }

        RFQDAO.copyBudgetItemDetails(newRFQItems);     
        RFQDAO.copyQuoteItemDetails(newRFQItems);

        for(RFQ_Item__c item : newRFQItems){
            if(String.isBlank(item.Name)){
                item.Name = item.buildertek__Description__c;
            }
        }       
    }
     
    public void OnBeforeUpdate(RFQ_Item__c[] oldRFQItems, RFQ_Item__c[] updatedRFQItems, Map<ID, RFQ_Item__c> RFQItemsMap){
        for(RFQ_Item__c items : updatedRFQItems){
            if(items.Name == null || String.isBlank(items.Name)){
                items.Name = items.buildertek__Description__c;
            }
        }
    }
     
    public void OnBeforeDelete(RFQ_Item__c[] RFQItmesToDelete, Map<ID, RFQ_Item__c> RFQItemsMap){
        
        // We need to delete the venor items on delete of actual RFQ items
        // so in this methods we are deleting the venodr item
        RFQDAO.deleteLinkedVendorItems(RFQItemsMap);
    }
     
    public void OnAfterInsert(RFQ_Item__c[] newRFQItems, Map<ID, RFQ_Item__c> newRFQItemsMap){ 
          system.debug('testrfqitem---');
        // Link newly added RFQ item to related vendor
        // When user has added the vendors and user add the new item at that time we need to link the newly added item with vendor item
        // so in this method we are creating rfq vendor item
         
        RFQDAO.linkNewRfqItems(newRFQItemsMap);
    }
     
    public void OnAfterUpdate(RFQ_Item__c[] oldRFQItems, RFQ_Item__c[] updatedRFQItems, Map<ID, RFQ_Item__c> RFQItemsMap, Map<Id, RFQ_Item__c> oldRFQItemsMap){
        //RFQDAO.linkNewRfqItems(RFQItemsMap);
       /*    List<buildertek__Pricing_Request_Line_Details__c> prldList = new   List<buildertek__Pricing_Request_Line_Details__c>();
        for(RFQ_Item__c rfqItem : updatedRFQItems){
        System.debug('ok');
            if(rfqItem.buildertek__Pricing_Request_Line_Detail__c != null){
                buildertek__Pricing_Request_Line_Details__c prld = new buildertek__Pricing_Request_Line_Details__c();
                prld.id = rfqItem.buildertek__Pricing_Request_Line_Detail__c;
                prld.buildertek__Cost__c = rfqItem.buildertek__Unit_Price__c;
                prldList.add(prld);
            }
        }
        if(prldList.size() > 0){
            update prldList;
        }  */
        System.debug('In After Update');
        // set<Id> rfqId = new set<Id>();
        // for(RFQ_Item__c rfqItem : updatedRFQItems){
        //     if(rfqItem.buildertek__Quote_Item__c == null && oldRFQItemsMap.get(rfqItem.Id).buildertek__Quote_Item__c != rfqItem.buildertek__Quote_Item__c){
        //         rfqId.add(rfqItem.buildertek__RFQ_Package__c);
        //     }
        // }
        // List<buildertek__RFQ__c> rfqList = [select id,name, buildertek__Added_to_Quote__c from buildertek__RFQ__c where id IN : rfqId ];
        // for(buildertek__RFQ__c rfq : rfqList){
        //     if(rfq.buildertek__Added_to_Quote__c != null || rfq.buildertek__Added_to_Quote__c != '' ){
        //         rfq.buildertek__Added_to_Quote__c = null;
        //     }
        // }
        // update rfqList;
    }
    
    
    
    public void OnBeforeUpdate(RFQ_Item__c[] newRFQItems, Map<ID, RFQ_Item__c> newRFQItemsMap){
     
    }
    
    public void OnAfterDelete(RFQ_Item__c[] oldRFQItems){
     
    } 
    
  /*   public void OnAfterUpdate2(RFQ_Item__c[] rfqItems){
        Map<Id,RFQ_Item__c> mapListRecords = new  Map<Id,RFQ_Item__c>(rfqItems);   
        Map<Id,RFQ_Item__c> mapList = new  Map<Id,RFQ_Item__c>();
        for(RFQ_Item__c rfqItemRecord : [select Id,Name,buildertek__RFQ_Package__c,buildertek__RFQ_Package__r.buildertek__Status__c,buildertek__Budget_Item__c,buildertek__Quantity__c,buildertek__Unit_Price__c from RFQ_Item__c where Id IN : mapListRecords.keySet() AND buildertek__RFQ_Package__r.buildertek__Status__c = 'Accepted']){
            if(rfqItemRecord.buildertek__RFQ_Package__c != null && rfqItemRecord.buildertek__Budget_Item__c != null){
                mapList.put(rfqItemRecord.buildertek__Budget_Item__c,rfqItemRecord);
            }
        }
        List<buildertek__Budget_Item__c> listOfBudgetItemRecords = new List<buildertek__Budget_Item__c>();
        if(!mapList.keySet().isEmpty()){
            List<buildertek__Budget_Item__c> BudgetItemRecords = [select Id,Name,buildertek__Quantity__c,buildertek__Unit_Price__c from buildertek__Budget_Item__c where Id IN : mapList.keySet()];
            for(buildertek__Budget_Item__c budgetLine : BudgetItemRecords){
                budgetLine.buildertek__Quantity__c = mapList.get(budgetLine.Id).buildertek__Quantity__c;
                budgetLine.buildertek__Unit_Price__c =mapList.get(budgetLine.Id).buildertek__Unit_Price__c;
                listOfBudgetItemRecords.add(budgetLine);
            }
        }
        if(!listOfBudgetItemRecords.isEmpty()){
            update listOfBudgetItemRecords;
        }
    } */

}