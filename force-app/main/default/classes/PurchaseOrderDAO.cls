/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date: 19/09/2017
 */
public without sharing class PurchaseOrderDAO{

    @AuraEnabled
    public static Boolean Checkifpaid(String recId){
        buildertek__Purchase_Order__c po = [SELECT Id, buildertek__Status__c FROM buildertek__Purchase_Order__c WHERE Id =: recId];
            if(po.buildertek__Status__c == 'Paid'){
                return true;
            }
            else{
                return false;
            }
     }
  
    /**********************************************************************************************************************
     Purpose: This method is used to create a link between PO Item and Budget Item
     Parameters: List<Purchase_Order_Item__c> purchaseOrderItems
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static boolean isInvoiceCreated = false;
    public static void createPurchaseOrderItemToBudgetItemLink(List<Purchase_Order_Item__c> purchaseOrderItems){

        List<PO_Item_To_Budget_Item_Link__c> POItemToBudgeetItemLinks = new List<PO_Item_To_Budget_Item_Link__c>();

        for (Purchase_Order_Item__c POItem : purchaseOrderItems){
            if (POItem.Budget_Item__c != null){
                if (Schema.sObjectType.PO_Item_To_Budget_Item_Link__c.fields.PO_Item__c.isCreateable() && Schema.sObjectType.PO_Item_To_Budget_Item_Link__c.fields.Budget_Item__c.isCreateable()){
                    PO_Item_To_Budget_Item_Link__c POItemToBudgeetItemLink = new PO_Item_To_Budget_Item_Link__c();
                    POItemToBudgeetItemLink.PO_Item__c = POItem.Id;
                    POItemToBudgeetItemLink.Budget_Item__c = POItem.Budget_Item__c;
                    POItemToBudgeetItemLinks.add(POItemToBudgeetItemLink);
                }
            }
        }

        if (!POItemToBudgeetItemLinks.isEmpty()){
            insert POItemToBudgeetItemLinks;
        }
    }

    /**********************************************************************************************************************
     Purpose: This method is used to roll up PO item amount to Budget item
     Parameters: set<Id> purchaseOrderItemIds
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static void RollUpPurchaseOrderItemAmount(set<Id> purchaseOrderItemIds){
        List<PO_Item_To_Budget_Item_Link__c> poItemToBudgetItemLinks = new List<PO_Item_To_Budget_Item_Link__c>();
        for (PO_Item_To_Budget_Item_Link__c poItemToBudgetLink : [Select Id, Auto_Roll_Up__c
                                                                  from PO_Item_To_Budget_Item_Link__c
                                                                  Where PO_Item__c IN :purchaseOrderItemIds]){

            poItemToBudgetLink.Auto_Roll_Up__c = true;
            poItemToBudgetItemLinks.add(poItemToBudgetLink);

        }

        if (!poItemToBudgetItemLinks.isEmpty())
            update poItemToBudgetItemLinks;
    }

    public static void RollUpPurchaseOrder(set<Id> purchaseOrderIds){
        Map<Id, Purchase_Order_Item__c> POItems = new Map<Id, Purchase_Order_Item__c>([Select Id
                                                                                       from Purchase_Order_Item__c
                                                                                       where Purchase_Order__c IN :purchaseOrderIds]);
        RollUpPurchaseOrderItemAmount(POItems.keyset());
    }

    /**********************************************************************************************************************
     Purpose: This method is used to Create PO from Awarded RFQ
     Parameters: List<RFQ__c> rfq, Map<Id, Contract__c> usde to link subcontract with PO
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static void createPOFromRFQ(Map<Id, RFQ__c> rfqs, Map<Id, Contract__c> rfqToSubContract){
        system.debug('test Po'+rfqs.keySet());
        Map<Id, Purchase_Order__c> rfqToPurchaseorders = new map<Id, Purchase_Order__c>();
        for (RFQ__c rfq : rfqs.values()){
            if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Sub_Contract__c.isCreateable()){
                Purchase_Order__c po = new Purchase_Order__c();
                po.Description__c = rfq.Name;
                po.RFQ__c = rfq.id;
                po.Budget__c = rfq.budget__c;
                po.buildertek__vendor__c = rfq.vendor__r.Vendor__c;
                po.Project__c = rfq.Project__c;
                po.buildertek__Status__c = 'Awarded';
                if (rfqToSubContract.containsKey(rfq.id))
                    po.Sub_Contract__c = rfqToSubContract.get(rfq.id).id;
                rfqToPurchaseorders.put(rfq.id, po);
            }
        }

        System.debug('rfqToPurchaseorders.values() '+rfqToPurchaseorders.values());
        insert rfqToPurchaseorders.values();

        List<Purchase_Order_Item__c> poItems = new List<Purchase_Order_Item__c>();
        for (RFQ__c rfq : rfqs.values()){
            system.debug( ' rfq.RFQ_Items__r'+rfq.RFQ_Items__r);
            system.debug( ' rfq.RFQ_Items__r------>'+rfq.RFQ_Items__r.size());
            for (RFQ_Item__c rfqItem : rfq.RFQ_Items__r){

                Purchase_Order_Item__c poItem = new Purchase_Order_Item__c();

                fillPOItemFromRFQItem(poItem, rfqItem);
                if (Schema.sObjectType.Purchase_Order_Item__c.fields.Purchase_Order__c.isCreateable()){
                    poItem.Purchase_Order__c = rfqToPurchaseorders.get(rfq.Id).Id;
                    poItems.add(poItem);
                }
            }
        }

        PurchaseOrderTriggerHandler.blnSkipPurchaseOrderUpdateTrigger = true;
        insert poItems;

    /*      List<buildertek__PO_Item_To_Budget_Item_Link__c> jncObj = new List<buildertek__PO_Item_To_Budget_Item_Link__c>();

        for (buildertek__Purchase_Order_Item__c poItem : [SELECT Id, Name,buildertek__Budget_Item__c FROM buildertek__Purchase_Order_Item__c where Id IN:poItems ]) {

            system.debug('poItem'+poItem);

          buildertek__PO_Item_To_Budget_Item_Link__c jncOb = new buildertek__PO_Item_To_Budget_Item_Link__c();

            jncOb.buildertek__Budget_Item__c = poItem.buildertek__Budget_Item__c;
            jncOb.buildertek__PO_Item__c = poItem.Id;
            jncObj.add(jncOb);
        }

        insert jncObj; */


        PurchaseOrderTriggerHandler.blnSkipPurchaseOrderUpdateTrigger = false;
    }

    // FILL PO ITME DETAILS FROM RFQ ITME
    public static void fillPOItemFromRFQItem(Purchase_Order_Item__c poItem, RFQ_Item__c rfqItem){
        poItem.Name = rfqItem.Name;
        poItem.Description__c = rfqItem.Description__c;
        poItem.Cost_Code__c = rfqItem.Cost_Code__c;
        poItem.Item_Name__c = rfqItem.Name;
        poItem.Quantity__c = rfqItem.Quantity__c;
        poItem.Unit_Price__c = rfqItem.Unit_Price__c;
        poItem.Budget_Item__c = rfqItem.Budget_Item__c;
        poItem.RFQ_Item__c = rfqItem.Id;
        poItem.Product__c = rfqItem.Product__c;
    }

    /**********************************************************************************************************************
     Purpose: This method is used to create a PO for selected itmes
     Parameters: Purchase_Order__c po, string poItemsJson
     Returns: string "Success"
     Throws [Exceptions]:
     **********************************************************************************************************************/
    @AuraEnabled
    public static ResponseBase createPO(Purchase_Order__c poJson, string poItemsJson, string budgetlineid){
        ResponseBase res = new ResponseBase();
        try{
            if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Auto_Number1__c.isCreateable()){
                poJson.buildertek__Vendor__r = null;
                insert poJson;
            }
            system.debug('poJson ---------> ' + poJson);

            List<buildertek__Purchase_Order_Item__c> purchaseOrderItemList = new List<buildertek__Purchase_Order_Item__c>();
            List<buildertek__Purchase_Order_Item__c> poItems = new List<buildertek__Purchase_Order_Item__c>();
            List<POLineItemsClass> POItemsList = (List<POLineItemsClass>)System.JSON.deserialize(poItemsJson, List<POLineItemsClass>.class);
            system.debug('POItemsList ------------> ' + POItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for (POLineItemsClass wrapper : POItemsList){
                purchaseOrderItemList.add(wrapper.purchaseOrderItem);
                productIdSet.add(wrapper.purchaseOrderItem.buildertek__Product__c);
            }
            system.debug('purchaseOrderItemList----->'+purchaseOrderItemList);
            List<Product2> productList;
            if (Schema.sObjectType.Product2.fields.Id.isAccessible() && Schema.sObjectType.Product2.fields.Name.isAccessible()){
                productList = [SELECT Id, Name
                               from Product2
                               where Id IN :productIdSet];
            }
            system.debug('productList----->'+productList);
            Map<String, String> productNameMap = new Map<String, String>();
            for (Product2 prod : productList){
                productNameMap.put(prod.Id, prod.Name);
            }

            for (buildertek__Purchase_Order_Item__c poItem : purchaseOrderItemList){
                if(productNameMap.get(poItem.buildertek__Product__c) != null){
                    if (productNameMap.get(poItem.buildertek__Product__c).length() > 79) {
                        poItem.Name = productNameMap.get(poItem.buildertek__Product__c).substring(0,79);
                    }
                }else{
                    poItem.Name = poItem.buildertek__Description__c;
                }
                poItem.Purchase_Order__c = poJson.Id;
                if (poItem.buildertek__Budget_Item__c == null){
                    poItem.buildertek__Budget_Item__c = budgetlineid;
                }
                poItems.add(poItem);
            }

            insert poItems;
            if(poItems.size()>0){
                List<buildertek__PO_Item_To_Budget_Item_Link__c>  budgetItemLinkRecs= new List<buildertek__PO_Item_To_Budget_Item_Link__c>();
                for(buildertek__Purchase_Order_Item__c poitemRec : poItems){
                    buildertek__PO_Item_To_Budget_Item_Link__c potobudgetRec = new buildertek__PO_Item_To_Budget_Item_Link__c();
                    potobudgetRec.buildertek__Budget_Item__c = budgetlineid;
                    potobudgetRec.buildertek__PO_Item__c = poitemRec.id;
                    system.debug('working in purchaseorderdao');
                }
            }

            system.debug('poItems ---------> ' + poItems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = poJson.Id;
            return res;

        } catch (Exception ex){
            system.debug('Message --------> ' + ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
    }

    @AuraEnabled
    public static ResponseBase createLinesForExistedPO (String poRecordID, String poItemsJson, String budgetlineid, list<string> addbudgetlineids){
        ResponseBase res = new ResponseBase();
        //try{
        List<buildertek__Purchase_Order_Item__c> purchaseOrderItemList = new List<buildertek__Purchase_Order_Item__c>();
            List<buildertek__Purchase_Order_Item__c> poItems = new List<buildertek__Purchase_Order_Item__c>();
            System.debug('poItemsJson :: ' + poItemsJson);
            List<POLineItemsClass> POItemsList = (List<POLineItemsClass>)System.JSON.deserialize(poItemsJson, List<POLineItemsClass>.class);
            system.debug('POItemsList ------------> ' + POItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for (POLineItemsClass wrapper : POItemsList){
                purchaseOrderItemList.add(wrapper.purchaseOrderItem);
                productIdSet.add(wrapper.purchaseOrderItem.buildertek__Product__c);
            }
            system.debug(productIdSet);
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
            system.debug(productNameMap);
            for (buildertek__Purchase_Order_Item__c poItem : purchaseOrderItemList){
                if(productNameMap.get(poItem.buildertek__Product__c) != null){
                   poItem.Name = productNameMap.get(poItem.buildertek__Product__c);
                }else{
                    poItem.Name = poItem.buildertek__Description__c;
                }
                poItem.Purchase_Order__c = poRecordID;
                if (poItem.buildertek__Budget_Item__c == null){
                    poItem.buildertek__Budget_Item__c = budgetlineid;
                }
                poItems.add(poItem);
                system.debug(poItem);
            }
            system.debug('poItems'+poItems);
            //insert poItems;
            list<buildertek__Budget_Item__c> BudgetItemList = [select Id, Name, buildertek__Product__c, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c
                              from buildertek__Budget_Item__c
                              where id IN :addbudgetlineids limit 1];
            Decimal approvedamount = 0;
            buildertek__Purchase_Order__c purchaseRec = [select id,Name,buildertek__Description__c,buildertek__Project__c,buildertek__Budget__c,buildertek__Budget_Line__c,
                                                         buildertek__Vendor__c,buildertek__Status__c,buildertek__PO_Total__c from buildertek__Purchase_Order__c where id =:poRecordID];
            list<buildertek__Purchase_Order_Item__c> purchaseOrderItem = [Select id,Name,buildertek__Purchase_Order__c,buildertek__Budget_Item__c from buildertek__Purchase_Order_Item__c where buildertek__Purchase_Order__c =: poRecordID order by CreatedDate limit 1];

                approvedamount = purchaseRec.buildertek__PO_Total__c;
                List<buildertek__PO_Item_To_Budget_Item_Link__c>  budgetItemLinkRecs= new List<buildertek__PO_Item_To_Budget_Item_Link__c>();
               if(purchaseOrderItem.size()>0){
                    for(buildertek__Purchase_Order_Item__c poitemRec : purchaseOrderItem){
                        for(buildertek__Budget_Item__c budgetRec : BudgetItemList){
                            buildertek__PO_Item_To_Budget_Item_Link__c potobudgetRec = new buildertek__PO_Item_To_Budget_Item_Link__c();
                            potobudgetRec.buildertek__Budget_Item__c = budgetRec.id;
                            potobudgetRec.buildertek__PO_Item__c = poitemRec.id;
                            // potobudgetRec.buildertek__Approved_PO__c = poitemRec.buildertek__Purchase_Order__r.buildertek__PO_Total__c;
                           potobudgetRec.buildertek__Approved_PO__c = approvedamount;
                            budgetItemLinkRecs.add(potobudgetRec);

                            system.debug('working in purchase order dao');
                        }
                    }
                }
                if(budgetItemLinkRecs.size()>0){
                    insert budgetItemLinkRecs;
                }
            system.debug('poItems ---------> ' + poItems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = poRecordID;
            return res;

        /*} catch (Exception ex){
            system.debug('Message --------> ' + ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }*/
    }

    @AuraEnabled
    public static string createAPFromPO(string poid){
        system.debug('poid---->' + poid);
        isInvoiceCreated = true;
        string accountPaybleId = createAP([Select Id, Name, Project__c, Vendor__c, Period__c, Tax__c, buildertek__Status__c, buildertek__Description__c
                                           from purchase_order__c
                                           where Id = :poid]);
        createAPItems([Select Id, Name, Tax__c, purchase_order__c, Item_Name__c, Description__c, Cost_Code__c, Product__c, Quantity__c, Unit_Price__c, buildertek__Quantity_Remaining__c, buildertek__Quantity_Received__c
                       from Purchase_Order_Item__c
                       where purchase_order__c = :poid]);

        return accountPaybleId;
    }

    /**********************************************************************************************************************
     Purpose: This method is used to create a AP from PO
     Parameters: List<Purchase_Order__c> pos
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static string createAP(List<Purchase_Order__c> pos){
        system.debug('Inside createAP');
        Map<Id, Account_Payable__c> PoIdbyAp = new Map<Id, Account_Payable__c>();
        Id posRecId;
        for (Purchase_Order__c po : pos){
            /* if(Schema.sObjectType.buildertek__Account_Payable__c.isCreateable()&&
             Schema.sObjectType.buildertek__Account_Payable__c.fields.buildertek__Purchase_Order__c.isCreateable()&&
             Schema.sObjectType.buildertek__Account_Payable__c.fields.buildertek__Project__c.isCreateable()&&
             Schema.sObjectType.buildertek__Account_Payable__c.fields.buildertek__Vendor__c.isCreateable()&&
             Schema.sObjectType.buildertek__Account_Payable__c.fields.buildertek__Tax__c.isCreateable()){*/

            Account_Payable__c ap = new Account_Payable__c();
            //ap.Name = po.Name;
            ap.Purchase_Order__c = po.id;
            System.debug('purchase order iD => ' + ap.Purchase_Order__c);
            ap.Project__c = po.Project__c;
            ap.Vendor__c = po.Vendor__c;

            if(po.Tax__c != null){
                ap.Tax__c = po.Tax__c;
            }
            ap.buildertek__Description__c = po.buildertek__Description__c;
            PoIdbyAp.put(po.id, ap);
            posRecId = po.id;
        }
        /* }*/
        insert PoIdbyAp.values();
        return PoIdbyAp.get(posRecId).Id;
    }

    public static void createAPItems(List<Purchase_Order_Item__c> poItems){
        system.debug('In createAPItems');
        Map<Id, Account_Payable__c> PoIdbyAp = new Map<Id, Account_Payable__c>();

        set<Id> poIds = new set<Id>();
        for (Purchase_Order_Item__c poItem : poItems){
            poIds.add(poItem.Purchase_Order__c);
        }

        for (Account_Payable__c ap : [Select Id, Purchase_Order__c
                                      from Account_Payable__c
                                      where Purchase_Order__c IN :poIds]){
            PoIdbyAp.put(ap.Purchase_Order__c, ap);
        }
        System.debug('PoIdbyAp---->' +  PoIdbyAp);

        List<buildertek__Account_Payable_Item__c> apItems = new List<buildertek__Account_Payable_Item__c>();
        for (Purchase_Order_Item__c poItem : poItems){        
            System.debug('poItem.purchaseorder--->' + PoIdbyAp.get(poItem.Purchase_Order__c));
            Account_Payable_Item__c apItem = new Account_Payable_Item__c();
            apItem.Account_Payable__c = PoIdbyAp.get(poItem.Purchase_Order__c).Id;
            apItem.Name = poItem.Name;
            apItem.Item_Title__c = poItem.Item_Name__c;
            apItem.Description__c = poItem.Description__c;
            apItem.Cost_Code__c = poItem.Cost_Code__c;
            apItem.Product__c = poItem.Product__c;
            apItem.Purchase_Order_Item__c = poItem.Id;
            apItem.Quantity__c = poItem.Quantity_Remaining__c;
            
            if(poItem.Unit_Price__c != null){
                apItem.Unit_Price__c = poItem.Unit_Price__c;
            }
            if(poItem.Tax__c != null){
                apItem.Tax__c = poItem.Tax__c;
            }
            apItems.add(apItem);
        }
        /* if(Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Id.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Account_Payable__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Name.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Item_Title__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Description__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Cost_Code__c.isCreateable()&&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Product__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Purchase_Order_Item__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Quantity__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Unit_Price__c.isCreateable() &&
         Schema.sObjectType.buildertek__Account_Payable_Item__c.fields.Tax__c.isCreateable()){
        insert apItems;*/
        /*}*/
        //system.debug('apItems--->' + apItems);
        insert apItems;
    }

    @AuraEnabled
    public static string getpricebook(string BudgetId){
        system.debug('budgetId-------->'+BudgetId);
        list<buildertek__Purchase_Order__c> purchaseOrder;
        if (Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            purchaseOrder = [select id, buildertek__Project__r.buildertek__Price_Book__c
                             from buildertek__Purchase_Order__c
                             where id = :BudgetId];
        }
        system.debug('changeOrder--------->'+purchaseOrder);
        if (purchaseOrder.size() > 0){
            return purchaseOrder[0].buildertek__Project__r.buildertek__Price_Book__c;
        }
        return null;
    }

    // @AuraEnabled
    // public static Map<String, String> getpricebooks(String recordId){
    //     Map<String, String> options = new Map<String, String>();

    //     list<pricebook2> PriceList;
    //     if (Schema.sObjectType.pricebook2.fields.Id.isAccessible() && Schema.sObjectType.pricebook2.fields.Name.isAccessible()){
    //         PriceList = [select Id, Name from pricebook2 WHERE Name != null ORDER BY Name ASC];
    //     }
    //     for (pricebook2 p : PriceList){
    //         //Put Picklist Value & Label in Map
    //         options.put(p.name, p.Id);
    //     }
    //     return options;
    // }
    public class pricebookWrapper{
        @AuraEnabled
        public List<pricebook2> priceWrapList;

        @AuraEnabled
        public pricebook2 defaultValue;
    }
    @AuraEnabled
    public static List<pricebookWrapper> getpricebooks(Id recordId){
        System.debug('****getpricebooks******');
        List<pricebookWrapper> priceWrapper = new List<pricebookWrapper>();

        pricebookWrapper priceWrap = new pricebookWrapper();
        priceWrap.defaultValue= new pricebook2();
        priceWrap.priceWrapList = new List<pricebook2>();
        List<pricebook2> PriceList = [select Id, Name from pricebook2 WHERE Name != null ORDER BY Name ASC];
        priceWrap.priceWrapList=PriceList;
        System.debug(recordId);

        if(recordId != null ){
            buildertek__Purchase_Order__c poRecord = [Select Id, Name , buildertek__Project__c , buildertek__Project__r.buildertek__Price_Book__c , buildertek__Project__r.buildertek__Price_Book__r.Name From buildertek__Purchase_Order__c  WHERE Id = :recordId];
            if(poRecord.buildertek__Project__c != null && poRecord.buildertek__Project__r.buildertek__Price_Book__c !=null){
                System.debug('Project notnull');
                pricebook2 selectedPriceList = [SELECT Id, Name FROM pricebook2 where Id=:poRecord.buildertek__Project__r.buildertek__Price_Book__c LIMIT 1];
                System.debug(selectedPriceList);

                priceWrap.defaultValue= selectedPriceList;
            }
        }
        priceWrapper.add(priceWrap);
        return priceWrapper;
    }

    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Purchase_Order_Item__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__new_Purchase_Order_Line')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__new_Purchase_Order_Line').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Purchase_Order_Item__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }

        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::'+e.getMessage());
            System.debug('Error At Line::'+e.getLineNumber());
        }
        return '[' + result + ']';
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook' + productId);


        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, buildertek__Discount__c
                 from PricebookEntry
                 where product2Id = :productId and isActive = true and pricebook2Id IN (select id
                                                                                        from Pricebook2
                                                                                        Where isActive = true)];

        system.debug('====pList' + pList);
        return pList;
    }

    @AuraEnabled
    public list<productfamilyClass> pfwrapperlst{ get; set; }

    //get product family Values
    @AuraEnabled
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName, string parentId){
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List<sObject> returnList = new List<sObject>();

        list<string> ProdIds = new list<string>();
        if (ObjectName == 'Product2' && parentId != null){

            list<pricebookEntry> PElist;

            PElist = [select id, Product2Id
                      from pricebookEntry
                      where pricebook2Id = :parentId];

            for (pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst = [SELECT toLabel(Family) familyLabel
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('familyLabel'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
    }

    @AuraEnabled
    public static PricebookEntry getProductPricevalue(string productId){
        System.debug('########pricebook' + productId);
        productId = productId.replace('"', '');
        productId = productId.replace('[', '');
        productId = productId.replace(']', '');
        System.debug('########pricebook' + productId);
        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, Product2Id, Product2.Name
                 from PricebookEntry
                 where product2Id = :productId];
        system.debug('pList'+pList);
        if (pList.size() > 0){
            return pList[0];
        }

        system.debug('====pList' + pList);
        return null;
    }

    @AuraEnabled
    public static buildertek__Purchase_Order_Item__c savePOItem(String POLines, String POId){
        buildertek__Purchase_Order_Item__c POItemToInsert = (buildertek__Purchase_Order_Item__c)JSON.deserialize(POLines, buildertek__Purchase_Order_Item__c.class);
        POItemToInsert.buildertek__Purchase_Order__c = poId;
        if (POItemToInsert.Name.length() > 79){
            POItemToInsert.buildertek__Description__c = POItemToInsert.Name;
            POItemToInsert.Name = POItemToInsert.Name.left(78);

        }
        insert POItemToInsert;

        return POItemToInsert;
    }

    @AuraEnabled
    public static List<POLineItemsClass> getProduct(String poItems){
        system.debug('poItems -----------> ' + poItems);
        List<buildertek__Purchase_Order_Item__c> purchaseOrderList = (List<buildertek__Purchase_Order_Item__c>)JSON.deserialize(poItems, List<buildertek__Purchase_Order_Item__c>.class);
        system.debug('purchaseOrderList -----------> ' + purchaseOrderList);
        List<POLineItemsClass> POItemsClassList = new List<POLineItemsClass>();
        Integer count = 0;
        for (buildertek__Purchase_Order_Item__c PO : purchaseOrderList){
            POLineItemsClass POItemsClass = new POLineItemsClass(PO, true, count);
            count++;
            POItemsClassList.add(POItemsClass);
        }

        return POItemsClassList;
    }

    @AuraEnabled
    public static List<POLineItemsClass> addProductsToList(String POItems, buildertek__Purchase_Order_Item__c POItem, Integer count){
        system.debug('POItems -----------> ' + POItems);
        system.debug('POItem -----------> ' + POItem);
        system.debug('count ---------> ' + count);
        List<POLineItemsClass> purchaseOrderList = (List<POLineItemsClass>)JSON.deserialize(POItems, List<POLineItemsClass>.class);
        system.debug('purchaseOrderList -----------> ' + purchaseOrderList);

        purchaseOrderList.add(new POLineItemsClass(POItem, false, count));
        return purchaseOrderList;
    }

    public class POLineItemsClass{
        @AuraEnabled
        public buildertek__Purchase_Order_Item__c purchaseOrderItem{ get; set; }

        @AuraEnabled
        public Boolean isProduct{ get; set; }

        @AuraEnabled
        public Integer rowIndex{ get; set; }

        public POLineItemsClass(buildertek__Purchase_Order_Item__c purchaseOrderItem, Boolean isProduct, Integer rowIndex){
            this.purchaseOrderItem = purchaseOrderItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }

    public class productfamilyClass{
        @AuraEnabled
        public string productfamilyvalues{ get; set; }
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
    //get Account Industry Picklist Values
    public static Map<String, String> getselectOptions(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Purchase_Order__c.buildertek__Status__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static Id saveData(string allData){
        buildertek__Purchase_Order_Item__c newRecord = (buildertek__Purchase_Order_Item__c) JSON.deserialize(allData, buildertek__Purchase_Order_Item__c.class);
        System.debug(allData);
        insert newRecord;
        return newRecord.Id;
    }
    // @AuraEnabled
    // public static List<Product2> getProductDetails(Id PriceBookId  , string prodFamily){
    //     List<Product2> product = [Select Id , Name , Family , (Select Id , Name , Pricebook2Id , Product2Id From PricebookEntries Where Pricebook2Id=: PriceBookId)  From Product2 where Family=: prodFamily AND Id IN (SELECT Product2Id FROM PricebookEntry)];
    //     System.debug('List<Product2>' + product);
    //     return product;
    // }
}