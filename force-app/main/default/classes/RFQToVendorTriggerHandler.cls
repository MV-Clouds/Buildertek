/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  27-Sep-2017
*/
public without sharing class RFQToVendorTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipRFQToVendorUpdateTrigger = false;
    
    private boolean m_isExecuting = false;
    private integer BatchSize = 0; 
    
    public RFQToVendorTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size; 
    }
    
    public void OnBeforeInsert(RFQ_To_Vendor__c[] newRFQToVendors){
        
        /*################### UPDATE RFQ TO VENDOR NAME FIELD #####################################*/
        set<Id> accountIds = new set<Id>();
        for(RFQ_To_Vendor__c refqToVendor: newRFQToVendors) {
            accountIds.add(refqToVendor.vendor__c);
        }
        
        Map<Id, Account> rfqAccounts = new Map<Id, Account>([Select Id,Name,(Select Id from Contacts Where Primary_Contact__c = true) from Account where Id IN:accountIds]);
        
        for(RFQ_To_Vendor__c refqToVendor: newRFQToVendors) {
            if(String.isBlank(refqToVendor.Name) && refqToVendor.vendor__c != null) {
                refqToVendor.Name = rfqAccounts.get(refqToVendor.vendor__c).Name;
            }
            if(refqToVendor.contact__c == null && rfqAccounts.get(refqToVendor.vendor__c).contacts != null && rfqAccounts.get(refqToVendor.vendor__c).contacts.size() > 0){
                refqToVendor.Contact__c = rfqAccounts.get(refqToVendor.Vendor__c).contacts[0].Id;
            }
        }
    }
    
    
    
    public void OnBeforeUpdate(RFQ_To_Vendor__c[] oldRFQToVendors, RFQ_To_Vendor__c[] updatedRFQToVendors, Map<ID, RFQ_To_Vendor__c> RFQToVendorsMap){
        
    }
    
    public void OnBeforeDelete(RFQ_To_Vendor__c[] QuotesToDelete, Map<ID, RFQ_To_Vendor__c> RFQToVendorsMap){
        
    }
    
    public void OnAfterInsert(RFQ_To_Vendor__c[] newRFQToVendors, Map<ID, RFQ_To_Vendor__c> newRFQToVendorsMap){ 
        Map<Id,set<Id>> rfqToVendors = new Map<Id,set<Id>>();
        
        for(RFQ_To_Vendor__c refqToVendor: newRFQToVendors) {
            if(rfqToVendors.containsKey(refqToVendor.RFQ__c)) {
                rfqToVendors.get(refqToVendor.RFQ__c).add(refqToVendor.Id);
            } else {
                rfqToVendors.put(refqToVendor.RFQ__c, new set<Id>{refqToVendor.Id});
            }
        }
        system.debug('rfqToVendor-----------'+rfqToVendors);
        RFQDAO.linkRfqItems(rfqToVendors);
        
    }
    
    public void OnAfterUpdate(RFQ_To_Vendor__c[] oldRFQToVendors, RFQ_To_Vendor__c[] updatedRFQToVendors, Map<ID, RFQ_To_Vendor__c> RFQToVendorsMap, Map<Id, RFQ_To_Vendor__c> oldRFQToVendorsMap){
     
        Set<Id> vendorIdSet = new Set<Id>();
        list<id> productvendors = new list<id>();
        list<id> vendorrfqid = new list<id>();
        for(RFQ_To_Vendor__c tempVendor : updatedRFQToVendors ){
            if(tempVendor.buildertek__Status__c=='Accepted' && BT_UTILS.hasStringFieldValueChanged( tempVendor,oldRFQToVendorsMap.get(tempVendor.Id), 'buildertek__Status__c')){
                vendorIdSet.add(tempVendor.Id);
                productvendors.add(tempVendor.buildertek__Vendor__c);
            } 
            
            if(tempVendor.buildertek__Status__c =='Rejected' && BT_UTILS.hasStringFieldValueChanged( tempVendor,oldRFQToVendorsMap.get(tempVendor.Id), 'buildertek__Status__c')){
                //vendorIdSet.add(tempVendor.Id);
                //productvendors.add(tempVendor.buildertek__Vendor__c);
                system.debug('^&&****%$##$%'+tempVendor.buildertek__Status__c);
                system.debug('oldRFQToVendorsMap.get(tempVendor.Id)-->'+oldRFQToVendorsMap.get(tempVendor.Id));
               if(oldRFQToVendorsMap.get(tempVendor.Id).buildertek__Status__c != 'New' || oldRFQToVendorsMap.get(tempVendor.Id).buildertek__Status__c != 'Email Sent'){
                   system.debug('tempVendor.buildertek__RFQ__r.buildertek__Status__c'+tempVendor.buildertek__RFQ__r.buildertek__Status__c);
                   if(tempVendor.buildertek__RFQ__r.buildertek__Status__c != 'Canceled'){
                       vendorrfqid.add(tempVendor.buildertek__RFQ__c); 
                   } 
               }
            } 
        }
        list<buildertek__RFQ__c> rflist = new list<buildertek__RFQ__c>();
        list<buildertek__RFQ__c> rfqlist = [SELECT Id, Name, buildertek__Project__c, buildertek__Status__c, buildertek__Quote__c, 
            buildertek__Vendor__c, buildertek__Accepted_Date__c,buildertek__Start_Date__c, buildertek__Vendor_Rating__c, buildertek__Awarded_Date__c, buildertek__RFQ_s_Sent__c, 
            buildertek__RFQ_s_Replied_To__c, buildertek__Opportunity__c,buildertek__Type__c, buildertek__RFQ_s_Replied_Toe_Percent__c, buildertek__Reason_for_Cancelling_RFQ__c, 
            buildertek__RFQ_s_Not_Replied_To__c, buildertek__RFQ_s_Not_Replied_To_Percent__c, 
            buildertek__Sender_Email_Response__c FROM buildertek__RFQ__c where Id IN: vendorrfqid];
        for(buildertek__RFQ__c rfqRec : rfqlist){
             rfqRec.buildertek__RFQ_s_Replied_To__c -=  1;
            rflist.add(rfqRec);
        }
        update rflist;
       if(vendorIdSet.size()>0){
            Map<Id, RFQ__c> awardedRFQ = new Map<Id, RFQ__c>();
            String query = 'Select Vendor__r.Vendor__c,Vendor__r.Status__c, '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c');  
            query = query + ', (Select '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' From RFQ_Items__r)';  
            query = query + ' From RFQ__c where Vendor__c IN:vendorIdSet ';
         //   query =query +  ' and Status__c=\'Awarded\' ';
              query =query +  ' and Status__c=\'Accepted\' ';   
            // query =query +  ' and Status__c=:statusString ';             
            system.debug(DataBase.Query(query));
            for(RFQ__c rfq:DataBase.Query(query)){ 
               system.debug(rfq.buildertek__Status__c);
                    awardedRFQ.put(rfq.Id, rfq);
            }
            
            if(awardedRFQ.size()>0){
                // Create Contract
                Map<Id, Contract__c> rfqToSubContract = ContractDAO.createSubContractFromRFQ(awardedRFQ);
                
                system.debug(rfqToSubContract);
                //Create PO
                PurchaseOrderDAO.createPOFromRFQ(awardedRFQ, rfqToSubContract);
                
            }
            
        }
        if(vendorIdSet.size()>0){
            list<buildertek__RFQ_Vendor_Item__c> Rfqvendoritemlist = new list<buildertek__RFQ_Vendor_Item__c>();
        Rfqvendoritemlist  = [select Id,Name,buildertek__Vendor__c,
                                buildertek__Vendor__r.buildertek__RFQ__c,buildertek__Vendor__r.buildertek__Vendor__r.ID,
                                buildertek__Quantity__c,
                                buildertek__Unit_Price__c,
                                buildertek__Vendor_Note__c,
                                buildertek__Description__c,buildertek__RFQ_Item__c,buildertek__RFQ_Item__r.buildertek__Product__c,
                                buildertek__RFQ_Item__r.buildertek__Product__r.Name
                                from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c =:vendorIdSet];
            
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                  buildertek__Update_Price_Book__c
                                                                                                  from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                  WHERE Name=:'RFQ Configuration' and buildertek__Update_Price_Book__c !=false limit 1];
           if(adminInterfaceNodeConfigurations.size()>0){
           if(adminInterfaceNodeConfigurations[0].buildertek__Update_Price_Book__c == true){
               list<id> productid = new list<id>();
               list<id> prodid = new list<id>();
               list<Product2> produlist = new list<Product2>();
               list<Product2> productlist = [select id,Name,buildertek__Vendor__c from Product2 where buildertek__Vendor__c IN : productvendors];
               system.debug('666'+productlist);
                system.debug('77777'+productvendors);
               list<Pricebook2> pricebooklist = [select id,Name from Pricebook2 where Name = 'Standard Price Book'];
               Boolean isproduct = false;
               if(productlist.size()>0){
                   for(Product2 productRec : productlist){
                       for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                           if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null && 
                              vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID == productRec.buildertek__Vendor__c && 
                              vendorItem.buildertek__RFQ_Item__r.buildertek__Product__r.Name == productRec.Name){
                                  // productid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c); 
                                  productid.add(productRec.id); 
                                  isproduct = true;
                              }/*else if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null && 
                                       vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID != productRec.buildertek__Vendor__c &&
                                       vendorItem.buildertek__RFQ_Item__r.buildertek__Product__r.Name != productRec.Name){
                                           system.debug('hello');
                                           system.debug('hiiii');
                                           prodid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                                       }*/
                       }  
                   } 
                   if(isproduct == false){
                       for(Product2 productRec : productlist){
                           for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                               if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__r.Name != productRec.Name){
                                   prodid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                               }
                           }  
                       }
                   }
               
               }
               
                if(productlist.size() == 0 ){
                   system.debug('((((((((((((');
                   for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                       if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null){
                           prodid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                       }
                   }
               }
               
               list<Product2> prodlist = [select id,Name,Description,buildertek__Finish__c,buildertek__Color__c,buildertek__BT_COLOR__c,buildertek__Type__c,ProductCode,
                                          buildertek__Handing__c,buildertek__Lock__c,buildertek__Screen__c,buildertek__Tempered__c,
                                          buildertek__Glass__c,buildertek__Series__c,buildertek__Size__c,buildertek__Collection__c,
                                          buildertek__Selection_Category__c,buildertek__Product_Type__c,buildertek__Category__c,
                                          Family,buildertek__Manufacturer__c,buildertek__Trade_Type__c,buildertek__Vendor__c from Product2 where id IN : prodid];
               
               Map<String,buildertek__RFQ_Vendor_Item__c> rfqProductItemMap = new Map<String,buildertek__RFQ_Vendor_Item__c>();
               for(buildertek__RFQ_Vendor_Item__c item : Rfqvendoritemlist){
                   if(rfqProductItemMap.get(item.buildertek__RFQ_Item__r.buildertek__Product__c) == null){
                       rfqProductItemMap.put(item.buildertek__RFQ_Item__r.buildertek__Product__c, item);
                   }
               }
               
               system.debug(rfqProductItemMap);
               Map<String,String> duplicateProductMap = new Map<String,String>();
               for(Product2 oldprodRec: prodlist){
                   system.debug(oldprodRec);
                   for(String key : rfqProductItemMap.keySet()){
                       system.debug(rfqProductItemMap.get(key));
                       if(duplicateProductMap.get(rfqProductItemMap.get(oldprodRec.Id).buildertek__RFQ_Item__r.buildertek__Product__c) == null){
                           if(rfqProductItemMap.get(key).buildertek__RFQ_Item__r.buildertek__Product__c != null && rfqProductItemMap.get(key).buildertek__Vendor__r.buildertek__Vendor__r.ID != oldprodRec.buildertek__Vendor__c){
                               system.debug(rfqProductItemMap.get(key)+' '+oldprodRec);
                               Product2 productRec = new Product2();
                               productRec.Name = oldprodRec.Name;
                               productRec.buildertek__Vendor__c = rfqProductItemMap.get(key).buildertek__Vendor__r.buildertek__Vendor__r.ID;
                               productRec.Description = oldprodRec.Description;
                               productRec.Family = oldprodRec.Family;
                               productRec.buildertek__Manufacturer__c = oldprodRec.buildertek__Manufacturer__c;
                               //  productRec.StockKeepingUnit = oldprodRec.StockKeepingUnit;
                               productRec.ProductCode = oldprodRec.ProductCode;
                               productRec.buildertek__Trade_Type__c = oldprodRec.buildertek__Trade_Type__c;
                               productRec.buildertek__Category__c = oldprodRec.buildertek__Category__c;
                               productRec.buildertek__Product_Type__c = oldprodRec.buildertek__Product_Type__c;
                               productRec.buildertek__Collection__c = oldprodRec.buildertek__Collection__c;
                               productRec.buildertek__Selection_Category__c = oldprodRec.buildertek__Selection_Category__c;
                               productRec.buildertek__Series__c = oldprodRec.buildertek__Series__c;
                               productRec.buildertek__Size__c = oldprodRec.buildertek__Size__c;
                               productRec.buildertek__Glass__c = oldprodRec.buildertek__Glass__c;
                               productRec.buildertek__Tempered__c = oldprodRec.buildertek__Tempered__c;
                               productRec.buildertek__Screen__c = oldprodRec.buildertek__Screen__c;
                               productRec.buildertek__Lock__c = oldprodRec.buildertek__Lock__c;
                               productRec.buildertek__Handing__c = oldprodRec.buildertek__Handing__c;
                               productRec.buildertek__Type__c = oldprodRec.buildertek__Type__c;
                              // productRec.buildertek__Color__c = oldprodRec.buildertek__Color__c;
                               productRec.buildertek__BT_COLOR__c = oldprodRec.buildertek__BT_COLOR__c;
                               productRec.buildertek__Finish__c = oldprodRec.buildertek__Finish__c;
                               produlist.add(productRec);
                               system.debug('productRec'+productRec);
                               duplicateProductMap.put(rfqProductItemMap.get(oldprodRec.Id).buildertek__RFQ_Item__r.buildertek__Product__c,key);
                               //duplicateProductMap.put(rfqProductItemMap.get(key).buildertek__RFQ_Item__r.buildertek__Product__c,rfqProductItemMap.get(key).buildertek__RFQ_Item__r.buildertek__Product__c);
                           }
                       }
                   }
                   
                   
               }
               if(prodlist.size()>0){
                   insert produlist;
               }
               list<PricebookEntry> pbelist = new list<PricebookEntry>();
               list<PricebookEntry>  pricebooketrylist = [select id,Name,UnitPrice,UseStandardPrice,buildertek__PriceBook_Amounts__c,buildertek__Markup__c,buildertek__Discount__c,buildertek__Unit_Cost__c,Product2Id,Pricebook2Id from PricebookEntry where Product2Id IN:prodid AND Pricebook2Id IN: pricebooklist];
               
               Map<String,String> duplicatePriceBook = new Map<String,String>();
               
               for(Product2 prod : produlist){
                   system.debug(prod);
                   for(PricebookEntry pricebookRec : pricebooketrylist){
                       for(buildertek__RFQ_Vendor_Item__c rfqvendorRec : Rfqvendoritemlist){
                           if(duplicatePriceBook.get(prod.Id) == null){
                           //if(duplicatePriceBook.get(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c) == null){
                               if(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c != null && rfqvendorRec.buildertek__Vendor__r.buildertek__Vendor__r.ID == prod.buildertek__Vendor__c){
                                   PricebookEntry pbeRec = new PricebookEntry();
                                   pbeRec.buildertek__Unit_Cost__c = rfqvendorRec.buildertek__Unit_Price__c;
                                   pbeRec.Pricebook2Id = pricebookRec.Pricebook2Id;
                                   pbeRec.Product2Id = prod.id; 
                                   pbeRec.UnitPrice = pricebookRec.UnitPrice;
                                   pbeRec.buildertek__Discount__c = pricebookRec.buildertek__Discount__c;
                                   pbeRec.buildertek__Markup__c = pricebookRec.buildertek__Markup__c;
                                   pbeRec.buildertek__PriceBook_Amounts__c = pricebookRec.buildertek__PriceBook_Amounts__c;
                                   pbeRec.UseStandardPrice = pricebookRec.UseStandardPrice;
                                   pbelist.add(pbeRec);
                                   system.debug(pbeRec);
                                   duplicatePriceBook.put(prod.id,rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c);
                                   //duplicatePriceBook.put(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c,rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c);
                               }
                           }
                       }
                   }
               }
               if(pbelist.size()>0){
                   
                   insert pbelist;
               }
               
               List<PricebookEntry> pricebooketyList = new List<PricebookEntry>();
               list<PricebookEntry>  pricebookentrylist = [select id,Name,buildertek__Unit_Cost__c,Product2Id,Pricebook2Id from PricebookEntry where Product2Id IN:productid AND Pricebook2Id IN: pricebooklist];
               
               Map<String,String> duplicatePriceBookEntry = new Map<String,String>();
               Map<String,String> duplicatepricebooketyList = new Map<String,String>();
               for(buildertek__RFQ_Vendor_Item__c rfqvendorRec :Rfqvendoritemlist){
                   for(PricebookEntry pricebookentry: pricebookentrylist){
                       if(duplicatePriceBookEntry.get(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c) == null){
                           if(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c != null /*&& rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c == pricebookentry.Product2Id*/){
                               system.debug('unitcost'+pricebookentry.buildertek__Unit_Cost__c);
                               pricebookentry.buildertek__Unit_Cost__c = rfqvendorRec.buildertek__Unit_Price__c;
                               system.debug(pricebookentry.Id);
                               system.debug(pricebookentrylist.size());
                               if(duplicatepricebooketyList.get(pricebookentry.Id) == null){
                                   pricebooketyList.add(pricebookentry);
                                   duplicatepricebooketyList.put(pricebookentry.Id,pricebookentry.Id);
                               }
                               //pricebooketyList.add(pricebookentry);
                           }
                           duplicatePriceBookEntry.put(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c,rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c);
                       }
                       
                   }
               }  
               if(pricebooketyList.size()>=1){
                   update pricebooketyList;
                   
               }
             

       }
           }
        }
                    /*List<buildertek__RFQ__c> rfqList = new List<buildertek__RFQ__c>();
            for(RFQ_To_Vendor__c refqToVendor: updatedRFQToVendors) {
            buildertek__RFQ__c rfq = new buildertek__RFQ__c();
            rfq.Id = refqToVendor.buildertek__RFQ__c;
            if(refqToVendor.buildertek__Accepted_Date__c != null){
            rfq.buildertek__Accepted_Date__c = Date.valueOf(refqToVendor.buildertek__Accepted_Date__c);     
            }
            if(refqToVendor.buildertek__Awarded_Date__c != null){
            rfq.buildertek__Awarded_Date__c =  Date.valueOf(refqToVendor.buildertek__Awarded_Date__c);        
            }
            rfqList.add(rfq);
            }
            if(rfqList.size() > 0){
            update rfqList;    
            }*/
    }
    
    public void OnBeforeUpdate(RFQ_To_Vendor__c[] newRFQToVendors, Map<ID, RFQ_To_Vendor__c> newRFQToVendorsMap){
        
    }
    
    public void OnAfterDelete(RFQ_To_Vendor__c[] oldRFQToVendors){
        
    }
}