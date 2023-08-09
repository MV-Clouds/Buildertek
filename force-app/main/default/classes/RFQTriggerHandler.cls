/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  06-Oct-2017
*/
public with sharing class RFQTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipRFQUpdateTrigger = false;

    public static Boolean blnSkipemaileTrigger = false;
    public static Boolean skipDeleteQuoteLine = false;

    private boolean m_isExecuting = false;
    private integer BatchSize = 0;

    public RFQTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }

    public void OnBeforeInsert(RFQ__c[] newRFQ){

        Id rfiDefaultUser = null;
        List<buildertek__RFI_Settings__c> rfiSettingsList = [Select Id,Name,
                                                             buildertek__Using_Communities__c,
                                                             buildertek__Using_Email__c,
                                                             buildertek__New_RFI_Notification_Template__c,
                                                             buildertek__Vendor_Notification_Template__c,
                                                             buildertek__Recipient_Notification_Template__c,
                                                             buildertek__RFI_Default_Owner__c
                                                             from buildertek__RFI_Settings__c
                                                             WHERE Name = :'RFI Settings'];
        system.debug('rfiSettingsList-------'+rfiSettingsList);
        if(rfiSettingsList.size() > 0){
            list<User> userslist = [Select Id, UserName, Isactive from User Where UserName =:rfiSettingsList[0].buildertek__RFI_Default_Owner__c ];
            if(userslist.size()>0){
                rfiDefaultUser = userslist[0].Id;
            }
        }

        for (RFQ__c rec : newRFQ){
            if(rec.buildertek__RFI_Owner__c==null){
                if(rfiDefaultUser!=null){
                    rec.buildertek__RFI_Owner__c =rfiDefaultUser;
                }
            }
        }

        List<buildertek__RFQ__c> rfqList;
        /* if(Schema.sObjectType.buildertek__RFQ__c.fields.id.isAccessible()
&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Auto_Number1__c.isAccessible()
&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()){*/
        rfqList = [Select Id, buildertek__Auto_Number1__c from buildertek__RFQ__c
                   where buildertek__Project__c =:newRFQ[0].Project__c
                   ORDER BY CREATEDDATE DESC  LIMIT 1];
        system.debug('rfqList -------> '+rfqList);

        // }
        if(!Test.isRunningTest()){
            BT_Utils.genrateAutoNumber(rfqList, newRFQ, 'Auto_Number1__c');
        }

    }

    public void OnBeforeUpdate(RFQ__c[] oldRFQ, RFQ__c[] updatedRFQ, Map<ID, RFQ__c> RFQMap){
    }

    public void OnBeforeDelete(RFQ__c[] RFQToDelete, Map<ID, RFQ__c> RFQMap){
        for(buildertek__RFQ__c rfq : RFQToDelete){
            //if(rfq.buildertek__Status__c == 'Awarded' || rfq.buildertek__Status__c == 'Accepted' || rfq.buildertek__Status__c == 'Request Sent'){
            if(rfq.buildertek__Status__c == 'Awarded'){
                rfq.adderror('You cannot delete this RFQ because it has already been ' +rfq.buildertek__Status__c+ ' to the Vendor');
            }else if(rfq.buildertek__Status__c == 'Accepted'){
                rfq.adderror('You cannot delete this RFQ because it has already been '+rfq.buildertek__Status__c+ ' by the Vendor');
            }else if(rfq.buildertek__Status__c == 'Request Sent'){
                rfq.adderror('You cannot delete this RFQ because the request has been sent to the Vendor');
            }

            //}
        }
    }

    public void OnAfterInsert(RFQ__c[] newRFQ, Map<ID, RFQ__c> newRFQMap){

        List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        Set<Id> rfqIdSet = new Set<Id>();
        for (buildertek__RFQ__c rfq : newRFQMap.values()){

            rfqIdSet.add(rfq.Id);
            if(rfq.buildertek__Added_to_Quote__c != null){
                System.debug('buildertek__Added_to_Quote__c' + rfq.buildertek__Added_to_Quote__c);
                buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
                quoteItem.Name=rfq.Name;
                quoteItem.buildertek__Item_Name__c=rfq.Name;
                quoteItem.buildertek__RFQ__c=rfq.Id;
                quoteItem.buildertek__Quote__c=rfq.buildertek__Added_to_Quote__c;
                quoteItem.buildertek__Quantity__c=1;
                quoteItem.buildertek__Unit_Cost__c=rfq.buildertek__Vendor_Quote__c;
                quoteItemList.add(quoteItem);
            }
        }
        if (!quoteItemList.isEmpty()) {
            insert quoteItemList;
            List<buildertek__RFQ_Item__c> rfqItemList = [Select Id , Name , buildertek__Quote_Item__c , buildertek__RFQ_Package__c FROM buildertek__RFQ_Item__c where buildertek__RFQ_Package__c=:rfqIdSet];

            for(buildertek__RFQ_Item__c rfqItem : rfqItemList){
                for(buildertek__Quote_Item__c quoteItem : quoteItemList){

                    if (rfqItem.buildertek__RFQ_Package__c == quoteItem.buildertek__RFQ__c) {
                        rfqItem.buildertek__Quote_Item__c = quoteItem.Id;
                        break;
                    }
                }
            }

            update rfqItemList;
        }








    }

    public void OnAfterUpdate(RFQ__c[] oldRFQ, RFQ__c[] updatedRFQ, Map<ID, RFQ__c> RFQMap, Map<Id, RFQ__c> oldRFQMap){
        system.debug('testcall---');
        // Skip the trigger because when we update the RFQ Items from Vendor Item
        // rollup summry will calculate the total and fier the trigger again to prevent that skip the RFQ trigger
        blnSkipRFQUpdateTrigger = true;

        // build the set of ID of RFQ which get Status Accepted
        Set<Id> RfqstatusId = new Set<Id>();
        SET<Id> RfqvendrId = new SET<Id>();
        Set<Id> RfqitemId = new Set<Id>();
        Set<Id> RfqvendoritemsId = new Set<Id>();
        Set<Id> rfqIdSet = new Set<Id>();
        Set<Id> oldQuoteLineIds = new Set<Id>();

        List<buildertek__RFQ_Item__c> rfqItemListToInsert = new List<buildertek__RFQ_Item__c>();
        List<buildertek__Quote_Item__c> quoteLineList = new List<buildertek__Quote_Item__c>();
        for(buildertek__RFQ__c rf: updatedRFQ){
            rfqIdSet.add(rf.Id);

            buildertek__RFQ__c oldRFqrec = oldRFQMap.get(rf.Id);
            if(rf.buildertek__Status__c == 'Accepted'  && rf.buildertek__Status__c != oldRFqrec.buildertek__Status__c){
                RfqstatusId.add(rf.Id);
            }

            if(oldRFqrec.buildertek__Added_to_Quote__c != rf.buildertek__Added_to_Quote__c && rf.buildertek__Added_to_Quote__c!= null && oldRFqrec.buildertek__Added_to_Quote__c == null){
                buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
                quoteItem.Name=rf.Name;
                quoteItem.buildertek__Item_Name__c=rf.Name;
                quoteItem.buildertek__RFQ__c=rf.Id;
                quoteItem.buildertek__Quote__c=rf.buildertek__Added_to_Quote__c;
                quoteItem.buildertek__Quantity__c=1;
                quoteItem.buildertek__Unit_Cost__c=rf.buildertek__Vendor_Quote__c;
                quoteLineList.add(quoteItem);
            }else if(oldRFqrec.buildertek__Added_to_Quote__c != rf.buildertek__Added_to_Quote__c && rf.buildertek__Added_to_Quote__c!= null && oldRFqrec.buildertek__Added_to_Quote__c != null){
                oldQuoteLineIds.add(oldRFqrec.buildertek__Added_to_Quote__c);

                buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
                quoteItem.Name=rf.Name;
                quoteItem.buildertek__Item_Name__c=rf.Name;
                quoteItem.buildertek__RFQ__c=rf.Id;
                quoteItem.buildertek__Quote__c=rf.buildertek__Added_to_Quote__c;
                quoteItem.buildertek__Quantity__c=1;
                quoteItem.buildertek__Unit_Cost__c=rf.buildertek__Vendor_Quote__c;
                quoteLineList.add(quoteItem);
            }else if(oldRFqrec.buildertek__Added_to_Quote__c != rf.buildertek__Added_to_Quote__c && rf.buildertek__Added_to_Quote__c== null && oldRFqrec.buildertek__Added_to_Quote__c != null){
                oldQuoteLineIds.add(oldRFqrec.buildertek__Added_to_Quote__c);
            }
        }
        if(quoteLineList.size() > 0){
            insert quoteLineList;
            List<buildertek__RFQ_Item__c> rfqItemList = [Select Id , Name , buildertek__Quote_Item__c , buildertek__RFQ_Package__c FROM buildertek__RFQ_Item__c where buildertek__RFQ_Package__c=:rfqIdSet];

            if (!skipDeleteQuoteLine) {
                List<buildertek__Quote_Item__c> oldQuoteItemList= [Select Id , Name , buildertek__Quote__c , (Select Id , Name , buildertek__Quote_Item__c , buildertek__RFQ_Package__c FROM buildertek__RFQ_Items__r where buildertek__RFQ_Package__c=:rfqIdSet) , buildertek__RFQ__c From buildertek__Quote_Item__c WHERE buildertek__Quote__c=:oldQuoteLineIds AND buildertek__RFQ__c=:rfqIdSet];
                delete oldQuoteItemList;
            }


            for(buildertek__RFQ_Item__c rfqItem : rfqItemList){
                for(buildertek__Quote_Item__c quoteItem : quoteLineList){
                    if (rfqItem.buildertek__RFQ_Package__c == quoteItem.buildertek__RFQ__c) {
                        rfqItem.buildertek__Quote_Item__c = quoteItem.Id;
                        break;
                    }
                }
            }

            update rfqItemList;

        }

        if(oldQuoteLineIds.size() > 0 && quoteLineList.size() ==0 && !skipDeleteQuoteLine){
            List<buildertek__Quote_Item__c> oldQuoteItemList= [Select Id , Name , buildertek__Quote__c , (Select Id , Name , buildertek__Quote_Item__c , buildertek__RFQ_Package__c FROM buildertek__RFQ_Items__r where buildertek__RFQ_Package__c=:rfqIdSet) , buildertek__RFQ__c From buildertek__Quote_Item__c WHERE buildertek__Quote__c=:oldQuoteLineIds AND buildertek__RFQ__c=:rfqIdSet];
            delete oldQuoteItemList;
        }



        // List<buildertek__RFQ__c> rfqrec;
        /* if(Schema.sObjectType.buildertek__RFQ__c.fields.id.isAccessible()
        && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible()
        && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()){*/
                // rfqrec = [select Id,Name,buildertek__Status__c from buildertek__RFQ__c where Id =:RfqstatusId];
        // }
        List<RFQ_To_Vendor__c> rfqVendorList;
        /* if(Schema.sObjectType.RFQ_To_Vendor__c.fields.id.isAccessible()
        && Schema.sObjectType.RFQ_To_Vendor__c.fields.Send_Invitation__c.isAccessible()
        && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__Status__c.isAccessible()
        && Schema.sObjectType.RFQ_To_Vendor__c.fields.buildertek__RFQ__c.isAccessible()){*/
        rfqVendorList = [select Id,Send_Invitation__c,Status__c, buildertek__RFQ__c from RFQ_To_Vendor__c where buildertek__RFQ__c IN: RfqstatusId AND Status__c='Accepted'];
        // }



        if(rfqVendorList.size()>0){
            for(RFQ_To_Vendor__c rfqVendor : rfqVendorList){
                RfqvendrId.add(rfqVendor.Id);
            }

            Map<string,string> rfqPrlMap = new Map<string,String>();

            SET<Id> VendorRqIds = new SET<Id>();

            //   Code To Create Rfq Lines As Pricing request Lines When Rfq Is Accepted  --  Start


            //  List<buildertek__RFQ__c> RFQRecordList = [select id, Name, buildertek__Pricing_Request_Line__c from buildertek__RFQ__c where Id IN : RfqstatusId];


            //    List<buildertek__RFQ_Item__c> RfqLines = [select Id, Name, buildertek__RFQ_Package__c, buildertek__Description__c,buildertek__Product__c, buildertek__Vendor__c, buildertek__Total_Price__c from buildertek__RFQ_Item__c where buildertek__RFQ_Package__c IN: RfqstatusId];


            /*     List<buildertek__RFQ_To_Vendor__c> VendorRFQRecordList = [select id, Name,buildertek__RFQ__c,buildertek__Status__c, buildertek__RFQ__r.buildertek__Pricing_Request_Line__c from buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c IN : RfqstatusId AND buildertek__Status__c = 'Accepted'];


            for(buildertek__RFQ_To_Vendor__c rf : VendorRFQRecordList){
            VendorRqIds.add(rf.Id);
            }

            system.debug('VendorRqIds->'+VendorRqIds);
            List<buildertek__RFQ_Vendor_Item__c> VendorRfqLines = [select Id, Name, buildertek__Vendor__c,buildertek__Vendor__r.buildertek__Vendor__c, buildertek__Vendor__r.buildertek__RFQ__c,buildertek__Vendor__r.buildertek__RFQ__r.buildertek__Pricing_Request_Line__c, buildertek__Description__c, buildertek__Vendor_Name__c, buildertek__Total_Price__c from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c IN: VendorRqIds];



            for(buildertek__RFQ_To_Vendor__c rf : VendorRFQRecordList){
            rfqPrlMap.put(rf.buildertek__RFQ__c,rf.buildertek__RFQ__r.buildertek__Pricing_Request_Line__c);
            }



            list<buildertek__Pricing_Request_Line_Details__c> PRLDetailsRecList = new list<buildertek__Pricing_Request_Line_Details__c> ();


            for(buildertek__RFQ_Vendor_Item__c rfq : VendorRfqLines){

            if(rfq.buildertek__Vendor__r.buildertek__RFQ__r.buildertek__Pricing_Request_Line__c != null){
            buildertek__Pricing_Request_Line_Details__c prld = new buildertek__Pricing_Request_Line_Details__c();

            prld.buildertek__Cost__c = rfq.buildertek__Total_Price__c;
            prld.buildertek__Description__c = rfq.buildertek__Description__c;
            prld.buildertek__Vendor__c = rfq.buildertek__Vendor__r.buildertek__Vendor__c;

            prld.buildertek__Pricing_Request_Line__c  = rfqPrlMap.get(rfq.buildertek__Vendor__r.buildertek__RFQ__c);


            PRLDetailsRecList.add(prld);
            }

            }


            if(!PRLDetailsRecList.isEmpty()){
            insert PRLDetailsRecList;
            }

            */

                        //  Code To Create Rfq Lines As Pricing request Lines When Rfq Is Accepted  --  END


                        /* if(RfqvendrId.size()>0){
            Map<Id, RFQ__c> awardedRFQ = new Map<Id, RFQ__c>();
            String statusString = 'Accepted';
            String query = 'Select Vendor__r.Vendor__c,Vendor__r.Status__c, '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c');
            query = query + ', (Select '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' From RFQ_Items__r)';
            query = query + ' From RFQ__c where Vendor__c IN:RfqvendrId and Status__c=\'Accepted\' ';
            //   query =query +  ' and Status__c=\'Awarded\' ';
            // query =query +  ' and Status__c=\'Accepted\' ';
            // query =query +  ' and Status__c=:statusString ';
            system.debug(DataBase.Query(query));
            for(RFQ__c rfq:DataBase.Query(query)){
            system.debug(rfq.buildertek__Status__c);
            awardedRFQ.put(rfq.Id, rfq);

            //awardedRFQ.put(rfq.Id, rfq);
            }

            if(awardedRFQ.size()>0){
            // Create Contract
            Map<Id, Contract__c> rfqToSubContract = ContractDAO.createSubContractFromRFQ(awardedRFQ);

            system.debug(rfqToSubContract);
            //Create PO
            PurchaseOrderDAO.createPOFromRFQ(awardedRFQ, rfqToSubContract);

            }

            }*/


            list<buildertek__RFQ_Vendor_Item__c> Rfqvendoritemlist;
            /*if(Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.id.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.Name.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor__c.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Quantity__c.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Unit_Price__c.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Vendor_Note__c.isAccessible()
                && Schema.sObjectType.buildertek__RFQ_Vendor_Item__c.fields.buildertek__Description__c.isAccessible()
                && Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()){*/
            Rfqvendoritemlist  = [select Id,Name,buildertek__Vendor__c,
                                  buildertek__Vendor__r.buildertek__RFQ__c,buildertek__Vendor__r.buildertek__Vendor__r.ID,
                                  buildertek__Quantity__c,
                                  buildertek__Unit_Price__c,
                                  buildertek__Vendor_Note__c,
                                  buildertek__Description__c,buildertek__RFQ_Item__c,buildertek__RFQ_Item__r.buildertek__Product__c
                                  from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__c =:RfqvendrId];
            // }
            list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                        buildertek__Update_Price_Book__c
                                                                                                        from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                        WHERE Name=:'RFQ Configuration' and buildertek__Update_Price_Book__c !=false limit 1];
            if(adminInterfaceNodeConfigurations.size()>0){
                /*           if(adminInterfaceNodeConfigurations[0].buildertek__Update_Price_Book__c == true){
                    list<id> productid = new list<id>();
                    list<id> prodid = new list<id>();
                    list<Product2> produlist = new list<Product2>();
                    list<Product2> productlist = [select id,Name,buildertek__Vendor__c from Product2];
                    list<Pricebook2> pricebooklist = [select id,Name from Pricebook2 where Name = 'Standard Price Book'];
                    for(Product2 productRec : productlist){
                    for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                    if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null && vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID == productRec.buildertek__Vendor__c){
                    productid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                    }else if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null &&
                    vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID != productRec.buildertek__Vendor__c){
                    prodid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                    }
                    }
                    }

                    list<Product2> prodlist = [select id,Name,Description,buildertek__Finish__c,buildertek__Color__c,buildertek__Type__c,ProductCode,
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
                    productRec.buildertek__Color__c = oldprodRec.buildertek__Color__c;
                    productRec.buildertek__Finish__c = oldprodRec.buildertek__Finish__c;
                    produlist.add(productRec);
                    system.debug('productRec'+productRec);
                    duplicateProductMap.put(rfqProductItemMap.get(oldprodRec.Id).buildertek__RFQ_Item__r.buildertek__Product__c,key);
                    //duplicateProductMap.put(rfqProductItemMap.get(key).buildertek__RFQ_Item__r.buildertek__Product__c,rfqProductItemMap.get(key).buildertek__RFQ_Item__r.buildertek__Product__c);
                    }
                    }
                    }

                    /*for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                    if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null && vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID != oldprodRec.buildertek__Vendor__c){
                    Product2 productRec = new Product2();
                    productRec.Name = oldprodRec.Name;
                    productRec.buildertek__Vendor__c = vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID;
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
                    productRec.buildertek__Color__c = oldprodRec.buildertek__Color__c;
                    productRec.buildertek__Finish__c = oldprodRec.buildertek__Finish__c;
                    produlist.add(productRec);
                    }
                    }*/
                                    /*              }
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
                    for(buildertek__RFQ_Vendor_Item__c rfqvendorRec :Rfqvendoritemlist){
                    for(PricebookEntry pricebookentry: pricebookentrylist){
                    if(duplicatePriceBookEntry.get(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c) == null){
                    if(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c != null && rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c == pricebookentry.Product2Id){
                    pricebookentry.buildertek__Unit_Cost__c = rfqvendorRec.buildertek__Unit_Price__c;
                    pricebooketyList.add(pricebookentry);
                    }
                    duplicatePriceBookEntry.put(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c,rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c);
                    }

                    }
                    }
                    if(pricebooketyList.size()>0){
                    update pricebooketyList;
                    }

                    /* list<id> productid = new list<id>();
                    list<Product2> productlist = new list<Product2>();
                    list<Pricebook2> pricebooklist = [select id,Name from Pricebook2 where Name = 'Standard Price Book'];
                    for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                    if(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c != null){
                    productid.add(vendorItem.buildertek__RFQ_Item__r.buildertek__Product__c);
                    }else if(vendorItem.buildertek__RFQ_Item__c == null){
                    Product2 productRec = new Product2();
                    productRec.Name = vendorItem.Name;
                    productRec.buildertek__Vendor__c = vendorItem.buildertek__Vendor__r.buildertek__Vendor__r.ID;
                    productRec.Description = vendorItem.Name;
                    productlist.add(productRec);
                    }
                    }
                    if(productlist.size()>0){
                    insert productlist;
                    }
                    list<PricebookEntry> pbelist = new list<PricebookEntry>();
                    for(Product2 prod : productlist){
                    for(buildertek__RFQ_Vendor_Item__c rfqvendorRec : Rfqvendoritemlist){
                    if(rfqvendorRec.buildertek__RFQ_Item__c == null){
                    PricebookEntry pbeRec = new PricebookEntry();
                    pbeRec.buildertek__Unit_Cost__c = rfqvendorRec.buildertek__Unit_Price__c;
                    pbeRec.Pricebook2Id = pricebooklist[0].Id;
                    pbeRec.Product2Id = prod.id;
                    pbeRec.UnitPrice = 100;
                    pbelist.add(pbeRec);
                    }
                    }
                    }
                    if(pbelist.size()>0){
                    insert pbelist;
                    }

                    /* list<id> productid = new list<id>();
                    list<buildertek__RFQ_Item__c> rfqitemlist = [select id,Name,buildertek__Product__c from buildertek__RFQ_Item__c where id IN: RfqitemId ];
                    for(buildertek__RFQ_Item__c rfqitem : rfqitemlist){
                    if(rfqitem.buildertek__Product__c != null){
                    productid.add(rfqitem.buildertek__Product__c);
                    }
                    }
                    list<Product2> productlist = [select id,Name from Product2 where ID IN:productid];*/
                                    /*   List<PricebookEntry> pricebooketyList = new List<PricebookEntry>();
                    list<PricebookEntry>  pricebookentrylist = [select id,Name,buildertek__Unit_Cost__c,Product2Id,Pricebook2Id from PricebookEntry where Product2Id IN:productid AND Pricebook2Id IN: pricebooklist];
                    system.debug('pricebookentrylist-->'+pricebookentrylist);
                    for(buildertek__RFQ_Vendor_Item__c rfqvendorRec : Rfqvendoritemlist){
                    system.debug('$$$$$');
                    for(PricebookEntry pricebookentry: pricebookentrylist){
                    system.debug('^^^^^^');
                    if(rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c != null && rfqvendorRec.buildertek__RFQ_Item__r.buildertek__Product__c == pricebookentry.Product2Id){
                    system.debug('&&&&&');
                    pricebookentry.buildertek__Unit_Cost__c = rfqvendorRec.buildertek__Unit_Price__c;
                    pricebooketyList.add(pricebookentry);
                    }
                    }
                    }
                    if(pricebooketyList.size()>0){
                    update pricebooketyList;
                    }*/
                //    }
            }
            for(RFQ__c rf: updatedRFQ){
                for(buildertek__RFQ_Vendor_Item__c vendorItem :Rfqvendoritemlist){
                    if(vendorItem.buildertek__Vendor__r.buildertek__RFQ__c == rf.Id && vendorItem.buildertek__RFQ_Item__c == null){
                        buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
                        rfqItem.Name = vendorItem.Name;
                        rfqItem.buildertek__RFQ_Package__c = vendorItem.buildertek__Vendor__r.buildertek__RFQ__c;
                        rfqItem.buildertek__Quantity__c = vendorItem.buildertek__Quantity__c;
                        rfqItem.buildertek__Unit_Price__c = vendorItem.buildertek__Unit_Price__c;
                        rfqItem.buildertek__Notes_Details__c = vendorItem.buildertek__Vendor_Note__c;
                        rfqItem.buildertek__Description__c = vendorItem.buildertek__Description__c;
                        rfqItemListToInsert.add(rfqItem);
                    }
                }
            }


            //if(Schema.sObjectType.buildertek__RFQ_Item__c.isCreateable()
            //  && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isCreateable()
            //  && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isCreateable()
            //  && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isCreateable()
            //  && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isCreateable()
            // && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Notes_Details__c.isCreateable()
            //  && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Description__c.isCreateable()){
            RFQItemTriggerHandler.blnSkipRFQItemUpdateTrigger = true;
            insert rfqItemListToInsert;
            RFQItemTriggerHandler.blnSkipRFQItemUpdateTrigger = false;
            //  }
            system.debug(rfqItemListToInsert.size()+'rfqItemListToInsert-----'+rfqItemListToInsert);
        }


        // build the set of ID of RFQ which get Awarded
        // we need to create sub contract / purchase order for Awarded RFQs
        Set<Id> awardedRFQIds = new Set<Id>();

        // build the set of ID of RFQ which get approved
        // we need to create purchase order for approved RFQs
        Set<Id> awardedVendorIds = new Set<Id>();

        for(RFQ__c old : oldRFQ){
            system.debug('RFQMap.get(old.Id).Status__c'+RFQMap.get(old.Id).Status__c);
            if(RFQMap.get(old.Id).Vendor__c != null && BT_UTILS.hasStringFieldValueChanged(RFQMap.get(old.Id), old, 'Status__c') && RFQMap.get(old.Id).Status__c == 'Awarded'){
                awardedRFQIds.Add(old.Id);
                awardedVendorIds.add(RFQMap.get(old.Id).Vendor__c);
            }
        }
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                    buildertek__Create_PO_On_Vendor_Acceptance__c,buildertek__Update_the_Opp_Amount__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name=:'RFQ Configuration' and buildertek__Create_PO_On_Vendor_Acceptance__c !=false limit 1];

        Set<Id> acceptedRFQIds = new Set<Id>();
        for(RFQ__c old : oldRFQ){
            system.debug('RFQMap.get(old.Id).Status__c'+RFQMap.get(old.Id).Status__c);
            if(RFQMap.get(old.Id).Vendor__c != null && BT_UTILS.hasStringFieldValueChanged(RFQMap.get(old.Id), old, 'Status__c') && RFQMap.get(old.Id).Status__c == 'Accepted'){
                acceptedRFQIds.Add(old.Id);
            }
        }

        if(!acceptedRFQIds.isEmpty()){
            Map<Id, RFQ__c> awardedRFQ = new Map<Id, RFQ__c>();

            String query = 'Select Vendor__r.Vendor__c,Vendor__r.Status__c, '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c');
            query = query + ', (Select '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' From RFQ_Items__r)';
            query = query + ' From RFQ__c where Id IN:acceptedRFQIds';

            for(RFQ__c rfq:DataBase.Query(string.escapeSingleQuotes(query))){
                if(rfq.Vendor__r.Status__c=='Accepted'){
                    awardedRFQ.put(rfq.Id, rfq);
                }
            }

            if(awardedRFQ.size()>0){
                // Create Contract
                Map<Id, Contract__c> rfqToSubContract = ContractDAO.createSubContractFromRFQ(awardedRFQ);
                System.debug('rfqToSubContract above heh2'+rfqToSubContract);
                if(adminInterfaceNodeConfigurations.size()>0 ){
                    if(adminInterfaceNodeConfigurations[0].buildertek__Create_PO_On_Vendor_Acceptance__c == true){
                        //Create PO
                        PurchaseOrderDAO.createPOFromRFQ(awardedRFQ, rfqToSubContract);
                    }
                }

            }
        }


        if(!awardedRFQIds.isEmpty()) {

            // POpulate RFQ Item from warded vendor to RFQ Package
            if(!awardedVendorIds.isEmpty()) {
                RFQDAO.populateRFQItemFromAwardedRFQVendorItem(awardedVendorIds);
            }

            Map<Id, RFQ__c> awardedRFQ = new Map<Id, RFQ__c>();

            String query = 'Select Vendor__r.Vendor__c,Vendor__r.Status__c, '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c');
            query = query + ', (Select '+BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' From RFQ_Items__r)';
            query = query + ' From RFQ__c where Id IN:awardedRFQIds';

            for(RFQ__c rfq:DataBase.Query(string.escapeSingleQuotes(query))){
                if(rfq.Vendor__r.Status__c=='Accepted'){
                    awardedRFQ.put(rfq.Id, rfq);
                }
            }

            if(awardedRFQ.size()>0){
                // Create Contract
                Map<Id, Contract__c> rfqToSubContract = ContractDAO.createSubContractFromRFQ(awardedRFQ);
                System.debug('rfqToSubContract heh1'+rfqToSubContract);

                //Create PO
                PurchaseOrderDAO.createPOFromRFQ(awardedRFQ, rfqToSubContract);

            }
            // Create CO - Commented it ou on 12/29/2019.  We should not create a CO on an Awarded RFQ.
            //ChangeOrderDAO.createCOFromRFQ(awardedRFQ, rfqToSubContract);

        }
        blnSkipRFQUpdateTrigger = false;
    }


    public void OnAfterDelete(RFQ__c[] oldRFQ){

    }
    public void OnAfterUpdateforrejectedvendors(buildertek__RFQ__c[] oldRFQ, buildertek__RFQ__c[] updatedRFQ, Map<ID, buildertek__RFQ__c> RFQMap, Map<Id, buildertek__RFQ__c> oldRFQMap){

        list<Id> RfqstatusId = new list<Id>();
        for(buildertek__RFQ__c rf: updatedRFQ){
            buildertek__RFQ__c oldRFqrec = oldRFQMap.get(rf.Id);
            if(rf.buildertek__Status__c == 'Accepted'  && rf.buildertek__Status__c != oldRFqrec.buildertek__Status__c){
                RfqstatusId.add(rf.Id);
            }
        }
        string theTemplate;
        list<OrgWideEmailAddress> owea = new list<OrgWideEmailAddress>();
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,buildertek__Email_Address__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name = :'Email Configuration'];
        if (adminInterfaceNodeConfigurations.size() > 0){
            owea = [select Id from OrgWideEmailAddress where Address =: adminInterfaceNodeConfigurations[0].buildertek__Email_Address__c];
        }


        RFQTriggerHandler.blnSkipemaileTrigger = false;
        theTemplate = [SELECT Id FROM EmailTemplate WHERE Name  = : 'RFQ To Vendor Rejected Email' LIMIT 1].id;
        List<Messaging.SingleEmailMessage> messageList = new List<Messaging.SingleEmailMessage>();
        List<RFQ_To_Vendor__c> updaterfqVendorList = new List<RFQ_To_Vendor__c>();
        List<RFQ_To_Vendor__c> rfqVendorList;
        rfqVendorList = [select Id,buildertek__Send_Invitation__c,buildertek__Status__c,buildertek__Contact__c,buildertek__Contact__r.Email,
                         buildertek__RFQ__c,buildertek__RFQ__r.buildertek__Vendor__c from
                         buildertek__RFQ_To_Vendor__c where buildertek__RFQ__c IN: RfqstatusId And buildertek__Status__c != 'Accepted'];
        if(rfqVendorList.size () > 0){
            for(RFQ_To_Vendor__c vendorRec: rfqVendorList){
            if(vendorRec.buildertek__RFQ__r.buildertek__Vendor__c != null /*&& vendorRec.buildertek__RFQ__r.buildertek__Vendor__c != vendorRec.id*/){
                // vendorRec.buildertek__Status__c = 'Rejected';
                updaterfqVendorList.add(vendorRec);
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                string toemailadd = vendorRec.buildertek__Contact__r.Email;
                message.toAddresses = new String[] { toemailadd};
                    system.debug('&&&'+toemailadd);
                if ( owea.size() > 0 ) {
                    message.setOrgWideEmailAddressId(owea.get(0).Id);
                }
                message.setTemplateID(theTemplate);
                message.setSaveAsActivity(false);
                message.setWhatId(vendorRec.Id);
                message.setTargetObjectId(vendorRec.buildertek__Contact__c);
                messageList.add(message);
            }
        }
        // if(updaterfqVendorList.size()>0){
        //  update updaterfqVendorList;
        // }
        if(messageList.size()>0){
             RFQTriggerHandler.blnSkipemaileTrigger = false;
                 Messaging.sendEmail(messageList);
                RFQTriggerHandler.blnSkipemaileTrigger = true;

        }
        }
        RFQTriggerHandler.blnSkipemaileTrigger = true;


    }

    public void OnAfterUpdateforAward(buildertek__RFQ__c[] oldRFQ){
        List<Id> rfqIds = new  List<Id>();
        for(buildertek__RFQ__c rfq : oldRFQ){
            if(rfq.buildertek__Status__c == 'Accepted'){
                rfqIds.add(rfq.Id);
            }
        }
        System.debug('RFQ Ids : '+rfqIds);
        List<buildertek__RFQ_Item__c> rfqLines;
        List<buildertek__RFQ_To_Vendor__c> vendorRFQ = new List<buildertek__RFQ_To_Vendor__c>();
        Set<Id> vendorIds = new Set<Id>();
        Set<Id> RFQID = new Set<Id>();
        Map<Id,Id> vendorRFQIdmap = new Map<Id,Id>();
        if(rfqIds.size() > 0){

            Map<string,buildertek__RFQ_Vendor_Item__c> vendorItemMap = new Map<string,buildertek__RFQ_Vendor_Item__c>([select Id, buildertek__RFQ_Item__c,buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Vendor__r.buildertek__Status__c from buildertek__RFQ_Vendor_Item__c where buildertek__Vendor__r.buildertek__Status__c = 'Accepted']);
            System.debug('Vendor RFQ :------> '+ vendorItemMap.keySet());
            for(buildertek__RFQ_Vendor_Item__c e : vendorItemMap.values()){
                RFQID.add(e.buildertek__RFQ_Item__c);
            }
            System.debug('Vendorhi :------> '+ RFQID);
            // rfqLines = [select buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Pricing_Request_Line_Detail__c,buildertek__RFQ_Package__c,(select id,buildertek__Vendor__c from RFQ_Vendor_Items__r) from buildertek__RFQ_Item__c where buildertek__RFQ_Package__c IN :rfqIds AND buildertek__Pricing_Request_Line_Detail__c != null];
            rfqLines = [select Id,buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Pricing_Request_Line_Detail__c,buildertek__RFQ_Package__c, (select Id,buildertek__Vendor__r.buildertek__Status__c,buildertek__Unit_Price__c,buildertek__Quantity__c from buildertek__RFQ_Vendor_Items__r) from buildertek__RFQ_Item__c where (buildertek__RFQ_Package__c IN :rfqIds AND buildertek__Pricing_Request_Line_Detail__c != NULL AND ID IN :RFQID)];

            for(buildertek__RFQ_Item__c rfq : rfqLines){
                for(buildertek__RFQ_Vendor_Item__c b : rfq.RFQ_Vendor_Items__r){
                    vendorIds.add( b.buildertek__Vendor__c);
                }

            }
            vendorRFQ = [select Id,buildertek__Vendor__c from buildertek__RFQ_To_Vendor__c where Id IN :vendorIds];
            if(vendorRFQ.size() > 0){
                for(buildertek__RFQ_To_Vendor__c c : vendorRFQ){
                    vendorRFQIdmap.put(c.Id,c.buildertek__Vendor__c);
                }
            }
            System.debug('rfqlines ----------> '+rfqLines);
            Map<buildertek__RFQ_Item__c,buildertek__Pricing_Request_Line_Details__c> mapList = new Map<buildertek__RFQ_Item__c,buildertek__Pricing_Request_Line_Details__c>();
            System.debug('ok');
            for(buildertek__RFQ_Item__c rfqline : rfqLines){
                mapList.put(rfqline,[select buildertek__Quantity__c,buildertek__Cost__c from buildertek__Pricing_Request_Line_Details__c where id =: rfqline.buildertek__Pricing_Request_Line_Detail__c]);
            }
            System.debug('ok');
            List<buildertek__Pricing_Request_Line_Details__c> prldList = new  List<buildertek__Pricing_Request_Line_Details__c>();
            System.debug('ok ------>'+mapList.keySet());
            for(buildertek__RFQ_Item__c rfq : mapList.keySet()){
                System.debug('Vendor RFQ : '+rfq.RFQ_Vendor_Items__r);
                for(buildertek__RFQ_Vendor_Item__c b : rfq.RFQ_Vendor_Items__r){
                    if(b.buildertek__Vendor__r.buildertek__Status__c == 'Accepted'){
                        buildertek__Pricing_Request_Line_Details__c a = new buildertek__Pricing_Request_Line_Details__c();
                        a.Id = mapList.get(rfq).Id;


                        a.buildertek__RFQ_Lines__c = rfq.Id;
                        a.buildertek__RFQ__c = rfq.buildertek__RFQ_Package__c;
                        a.buildertek__Cost__c = b.buildertek__Unit_Price__c;
                        a.buildertek__Quantity__c =  b.buildertek__Quantity__c;
                        a.buildertek__Vendor__c = vendorRFQIdmap.get(b.buildertek__Vendor__c);
                        a.buildertek__RFQ_Vendor_Line__c = b.Id;
                        a.buildertek__Vendor_RFQ__c = b.buildertek__Vendor__c;
                        System.debug('Record : ---> '+a);
                        prldList.add(a);
                        break;
                    }

                }

            }

            if(prldList.size() > 0){
                System.debug('Yes');
                update prldList;
                System.debug('updated successfully ');
                System.debug('updated successfully ------------------------------------------>'+prldList);
            }

        }
    }

    public void onAfterUpdateTheBudget(List<buildertek__RFQ__c> rfqRecords, Map<Id, buildertek__RFQ__c> oldRFQMap){
        Map<Id,buildertek__RFQ__c> rfqList = new Map<Id,buildertek__RFQ__c>(rfqRecords);
        Map<Id,buildertek__RFQ_Item__c> BudgetIds = new Map<Id,buildertek__RFQ_Item__c>();
        Map<Id,Id> IdsMap = new Map<Id,Id>();
        Set<Id> rfqLinesIds = new  Set<Id>();
        List<buildertek__Budget_Item__c> updateBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__RFQ_Item__c rfqLinesRecords : [select Id,buildertek__Quantity__c,buildertek__Unit_Price__c,buildertek__Budget_Item__c from buildertek__RFQ_Item__c where buildertek__RFQ_Package__c IN : rfqList.keySet() and (buildertek__Budget_Item__c != null and buildertek__RFQ_Package__r.buildertek__Status__c = 'Accepted')]){
            BudgetIds.put(rfqLinesRecords.buildertek__Budget_Item__c,rfqLinesRecords);
            rfqLinesIds.add(rfqLinesRecords.Id);
            IdsMap.put(rfqLinesRecords.Id,rfqLinesRecords.buildertek__Budget_Item__c);
        }
        for(buildertek__Budget_Item__c budgetItem : [select Id,Name,buildertek__Quantity__c,buildertek__Unit_Price__c from buildertek__Budget_Item__c where Id IN : BudgetIds.keySet()]){

            budgetItem.buildertek__Quantity__c = BudgetIds.get(budgetItem.Id).buildertek__Quantity__c;
            budgetItem.buildertek__Unit_Price__c = BudgetIds.get(budgetItem.Id).buildertek__Unit_Price__c;
            updateBudgetItems.add(budgetItem);
        }
        if(!updateBudgetItems.isEmpty()){
            update updateBudgetItems;
        }

        if(!rfqLinesIds.isEmpty()){
            List<buildertek__Purchase_Order_Item__c> updatePOlist = new List<buildertek__Purchase_Order_Item__c>();
            List<buildertek__Purchase_Order_Item__c> poLines = [select Id,buildertek__Budget_Item__c,buildertek__RFQ_Item__c from buildertek__Purchase_Order_Item__c where buildertek__RFQ_Item__c IN : rfqLinesIds];
            for(buildertek__Purchase_Order_Item__c poLine : poLines){
                poLine.buildertek__Budget_Item__c = IdsMap.get(poLine.buildertek__RFQ_Item__c);
                updatePOlist.add(poLine);
            }

            if(!updatePOlist.isEmpty()){
                update updatePOlist;
            }
        }

        Set<Id> RfqIds = new Set<Id>();
        for(buildertek__RFQ__c rf: rfqRecords){
            buildertek__RFQ__c oldRFqrec = oldRFQMap.get(rf.Id);
            if(rf.buildertek__Status__c == 'Awarded'  && rf.buildertek__Status__c != oldRFqrec.buildertek__Status__c){
                RfqIds.add(rf.Id);
            }
        }

        if (RfqIds.size() > 0) {
            // For Ticket BUIL-2857
            List<buildertek__RFQ_Item__c> rfqLineList = [SELECT Id, Name, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Pricing_Request_Line_Detail__c, buildertek__RFQ_Package__r.buildertek__Vendor_Quote__c FROM buildertek__RFQ_Item__c WHERE buildertek__RFQ_Package__c IN: RfqIds];
            Set<Id> prldIds = new Set<Id>();
            for (buildertek__RFQ_Item__c rfqLine : rfqLineList) {
                if (rfqLine.buildertek__Pricing_Request_Line_Detail__c != null) {
                    prldIds.add(rfqLine.buildertek__Pricing_Request_Line_Detail__c);
                }
            }

            List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Pricing_Request_Line_Detail__c, buildertek__Cost__c FROM buildertek__Question__c WHERE buildertek__Pricing_Request_Line_Detail__c IN: prldIds];
            for (buildertek__Question__c option : optionList) {
                for (buildertek__RFQ_Item__c rfqLine : rfqLineList) {
                    if (option.buildertek__Pricing_Request_Line_Detail__c == rfqLine.buildertek__Pricing_Request_Line_Detail__c) {
                        option.buildertek__Quantity__c = rfqLine.buildertek__Quantity__c;
                        option.buildertek__Cost__c = rfqLine.buildertek__Unit_Price__c;
                    }
                }
            }
            update optionList;

            // For Ticket BUIL-2856
            List<buildertek__Question__c> newOptionList=[SELECT Id, Name, buildertek__Cost__c, buildertek__Manufacturer__c, buildertek__RFQ_Line__r.buildertek__Unit_Price__c, buildertek__RFQ_Line__r.buildertek__Quantity__c, buildertek__RFQ_Line__r.buildertek__Vendor__c FROM buildertek__Question__c WHERE buildertek__RFQ_Line__r.buildertek__RFQ_Package__c IN: RfqIds];
            for(buildertek__Question__c opt: newOptionList){
                opt.buildertek__Quantity__c = opt.buildertek__RFQ_Line__r.buildertek__Quantity__c;
                opt.buildertek__Cost__c = opt.buildertek__RFQ_Line__r.buildertek__Unit_Price__c;
                opt.buildertek__Manufacturer__c = opt.buildertek__RFQ_Line__r.buildertek__Vendor__c;
            }
            update newOptionList;
        }

    }

}