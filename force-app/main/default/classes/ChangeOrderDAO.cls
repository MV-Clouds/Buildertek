/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date: 19/09/2017
 */
public with sharing class ChangeOrderDAO{
    
    
    
    @AuraEnabled 
    public static InnerClass getUser(){
        Boolean currencyEnable = UserInfo.isMultiCurrencyOrganization();
        String portalCode = '';
        string userName = userInfo.getUserId();
        InnerClass inn = new InnerClass();
         list<Network> netRec = [SELECT Id,Status FROM Network where Status = 'Live'];
        
        if(netRec.size() > 0){
            string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';  
            list<User> userRec= Database.query(strQry);
            if(userRec.size() > 0){
                portalCode = userRec[0].get('isPortalEnabled').toString();
            }
            inn.userRecord = userRec[0];
        }else{
          inn.userRecord = null;  
        }
       
        
        system.debug('postel code'+ portalCode);
        
        
        inn.isCurrencyEnabled = currencyEnable;
        return  inn ;
    }
    public class InnerClass{
        @AuraEnabled
        public User userRecord {get;set;}
        @AuraEnabled
        public Boolean isCurrencyEnabled {get;set;}
        
    } 
    
    
    /**********************************************************************************************************************
     Purpose: This method is used to create a link between CO Item and Budget Item
     Parameters: List<Change_Order_Item__c> changeOrderItems
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static void createChangeOrderItemToBudgetItemLink(List<Change_Order_Item__c> changeOrderItems){

        List<CO_Item_To_Budget_Item_Link__c> COItemToBudgeetItemLinks = new List<CO_Item_To_Budget_Item_Link__c>();

        for (Change_Order_Item__c COItem : changeOrderItems){
 
            if (COItem.Budget_Item__c != null){
                if (Schema.sObjectType.CO_Item_To_Budget_Item_Link__c.fields.CO_Item__c.isCreateable() && Schema.sObjectType.CO_Item_To_Budget_Item_Link__c.fields.Budget_Item__c.isCreateable()){
                    CO_Item_To_Budget_Item_Link__c COItemToBudgeetItemLink = new CO_Item_To_Budget_Item_Link__c();
                    COItemToBudgeetItemLink.CO_Item__c = COItem.Id;
                    COItemToBudgeetItemLink.Budget_Item__c = COItem.Budget_Item__c;
                    COItemToBudgeetItemLinks.add(COItemToBudgeetItemLink);
                }
            }
        }

        if (!COItemToBudgeetItemLinks.isEmpty()){
            insert COItemToBudgeetItemLinks;
            system.debug('COItemToBudgeetItemLinks-----' + COItemToBudgeetItemLinks);
        }
    }

    /**********************************************************************************************************************
     Purpose: This method is used to roll up CO item amount to Budget item
     Parameters: set<Id> purchaseOrderItemIds
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static void RollUpChangeOrderItemAmount(set<Id> changeOrderItemIds){
        List<CO_Item_To_Budget_Item_Link__c> coItemToBudgetItemLinks = new List<CO_Item_To_Budget_Item_Link__c>();
        for (CO_Item_To_Budget_Item_Link__c coItemToBudgetLink : [Select Id, Auto_Roll_Up__c
                                                                  from CO_Item_To_Budget_Item_Link__c
                                                                  Where CO_Item__c IN :changeOrderItemIds]){

            coItemToBudgetLink.Auto_Roll_Up__c = true;
            coItemToBudgetItemLinks.add(coItemToBudgetLink);

        }

        if (!coItemToBudgetItemLinks.isEmpty()){

            update coItemToBudgetItemLinks;

        }
    }

    public static void RollUpChangeOrderAmount(set<Id> changeOrderIds){
        Map<Id, Change_Order_Item__c> changeOrderItems = new Map<Id, Change_Order_Item__c>([Select Id
                                                                                            from Change_Order_Item__c
                                                                                            Where Change_Order__c IN :changeOrderIds]);
        RollUpChangeOrderItemAmount(changeOrderItems.KeySet());
    }

    /**********************************************************************************************************************
     Purpose: This method is used to create a CO for selected itmes
     Parameters: Change_Order__c co, string coItemsJson
     Returns: string "Success"
     Throws [Exceptions]:
     **********************************************************************************************************************/
    @AuraEnabled
    public static ResponseBase createCO(Change_Order__c coJson, string coItemsJson, string budgetlineid){
        system.debug('coJson ----------> ' + coJson);
        system.debug('coItemsJson ----------> ' + coItemsJson);
        ResponseBase res = new ResponseBase();
        try{
            //coJson.buildertek__Vendor__r = null;
            if(coJson.buildertek__Project__c!= null){
                buildertek__Project__c project = [SELECT Id, Name, buildertek__Customer__c FROM buildertek__Project__c WHERE Id = :coJson.buildertek__Project__c];
                if (project.buildertek__Customer__c != null){
                    coJson.buildertek__Customer_Account__c = project.buildertek__Customer__c;
                }
                
            }


            Id CustomerRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            Id VendorRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
            
            if (coJson.RecordTypeId==CustomerRecordTypeId){
                coJson.buildertek__Type__c = 'Customer';
            }
            if (coJson.RecordTypeId==VendorRecordTypeId){
                coJson.buildertek__Type__c = 'Vendor'; 
            }
            
            insert coJson;

            system.debug('coRec ---------> ' + coJson);

            List<buildertek__Change_Order_Item__c> changeOrderItemList = new List<buildertek__Change_Order_Item__c>();
            List<buildertek__Change_Order_Item__c> coItems = new List<buildertek__Change_Order_Item__c>();
            List<COLineItemsClass> COItemsList = (List<COLineItemsClass>)System.JSON.deserialize(coItemsJson, List<COLineItemsClass>.class);
            system.debug('COItemsList ------------> ' + COItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for (COLineItemsClass wrapper : COItemsList){
                changeOrderItemList.add(wrapper.changeOrderItem);
                productIdSet.add(wrapper.changeOrderItem.buildertek__Product__c);
            }

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

            for (Change_Order_Item__c coItem : changeOrderItemList){
                if (productNameMap.containskey(coItem.buildertek__Product__c)){
                    // coItem.Name = productNameMap.get(coItem.buildertek__Product__c);
                    if (productNameMap.get(coItem.buildertek__Product__c).length() > 80) {
                        string subStr = productNameMap.get(coItem.buildertek__Product__c).subString(0,76);
                        coItem.Name = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
                    } else {
                        coItem.Name = productNameMap.get(coItem.buildertek__Product__c);
                    }
                } else{
                    // coItem.Name = coJson.Name;
                    if (coJson.Name.length() > 80) {
                        string subStr = coJson.Name.subString(0,76);
                        coItem.Name = subStr.subString(0, subStr.lastIndexOf(' ')) + '...';
                    } else {
                        coItem.Name = coJson.Name;
                    }
                }
                coItem.Change_Order__c = coJson.Id;
                if (coItem.buildertek__Budget_Item__c == null){
                    coItem.buildertek__Budget_Item__c = budgetlineid;
                }
                coItems.add(coItem);
            }

            insert coItems;

            system.debug('coItems ---------> ' + coItems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = coJson.Id;
            return res;

        } catch (Exception ex){
            //throw new AuraHandledException(ex.getMessage());
            system.debug('Message --------> ' + ex.getMessage());
            system.debug('Message --------> ' + ex.getLineNumber());

            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
    }

    /**********************************************************************************************************************
     Purpose: This method is used to Create CO from Awarded RFQ
     Parameters: List<RFQ__c> rfq, Map<Id, Contract__c> usde to link subcontract with PO
     Returns: NA
     Throws [Exceptions]:
     **********************************************************************************************************************/
    public static string createCOFromRFQ(Map<Id, RFQ__c> rfqs, Map<Id, Contract__c> rfqToSubContract){

        Map<Id, Change_Order__c> rfqToChangeOrders = new map<Id, Change_Order__c>();
        for (RFQ__c rfq : rfqs.values()){
            Change_Order__c co = new Change_Order__c();
            co.Name = rfq.Name;
            co.RFQ__c = rfq.id;
            co.Budget__c = rfq.budget__c;
            //po.vendor__c = rfq.vendor__r.Vendor__c;
            co.Project__c = rfq.Project__c;
            co.buildertek__Customer_Account__c = rfq.vendor__r.buildertek__Vendor__c;
            //if(rfqToSubContract.containsKey(rfq.id)) po.Sub_Contract__c = rfqToSubContract.get(rfq.id).id;

            rfqToChangeOrders.put(rfq.id, co);
        }
        if (Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Change_Order__c.fields.RFQ__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order__c.fields.Budget__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order__c.fields.Project__c.isCreateable() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isCreateable()){
            insert rfqToChangeOrders.values();
        }

        List<Change_Order_Item__c> coItems = new List<Change_Order_Item__c>();
        for (RFQ__c rfq : rfqs.values()){
            for (RFQ_Item__c rfqItem : rfq.RFQ_Items__r){

                Change_Order_Item__c coItem = new Change_Order_Item__c();

                fillCOItemFromRFQItem(coItem, rfqItem);

                coItem.Change_Order__c = rfqToChangeOrders.get(rfq.Id).Id;
                coItems.add(coItem);
            }
        }


        ChangeOrderTriggerHandler.blnSkipChangeOrderUpdateTrigger = true;
        if (Schema.sObjectType.Change_Order_Item__c.fields.Change_Order__c.isCreateable()){
            insert coItems;
        }
        ChangeOrderTriggerHandler.blnSkipChangeOrderUpdateTrigger = false;


        return rfqToChangeOrders.values()[0].Id;
    }

    // FILL CO ITME DETAILS FROM RFQ ITME
    public static void fillCOItemFromRFQItem(Change_Order_Item__c coItem, RFQ_Item__c rfqItem){
        coItem.Name = rfqItem.Name;
        coItem.Description__c = rfqItem.Description__c;
        coItem.Cost_Code__c = rfqItem.Cost_Code__c;
        coItem.Item_Name__c = rfqItem.Name;
        coItem.Quantity__c = rfqItem.Quantity__c;
        coItem.Unit_Price__c = rfqItem.Unit_Price__c;
        coItem.Budget_Item__c = rfqItem.Budget_Item__c;
        coItem.RFQ_Item__c = rfqItem.Id;
        coItem.Product__c = rfqItem.Product__c;
    }

    @AuraEnabled
    public static PricebookEntry getProductPricevalue(string productId){
        System.debug('########pricebook' + productId);
        productId = productId.replace('"', '');
        productId = productId.replace('[', '');
        productId = productId.replace(']', '');
        System.debug('########pricebook' + productId);
        list<PricebookEntry> pList;

        pList = [select id, UnitPrice, buildertek__Unit_Cost__c, buildertek__Markup__c, Product2Id, Product2.Name
                 from PricebookEntry
                 where product2Id = :productId];
        if (pList.size() > 0){
            return pList[0];
        }
        

        system.debug('====pList' + pList);
        return null;
    }

    @AuraEnabled
    public static ResponseBase createARFromCO(String coId){
        ResponseBase response = new ResponseBase();

        try{

            buildertek__Change_Order__c co;
            if (Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Period__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Tax_Rate__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Status__c.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Vendor__c.isAccessible()){
                co = [Select Id, Name, buildertek__Customer_Account__c, buildertek__Description__c, buildertek__Period__c, buildertek__Tax_Rate__c, buildertek__Project__c, buildertek__Status__c, buildertek__Vendor__c
                      from buildertek__change_order__c
                      where Id = :coId];
            }
            Billings__c AR = new Billings__c();
            if (Schema.sObjectType.Billings__c.fields.Name.isCreateable() && Schema.sObjectType.Billings__c.fields.Change_Order__c.isCreateable() && Schema.sObjectType.Billings__c.fields.Customer_Account__c.isCreateable() && Schema.sObjectType.Billings__c.fields.Project__c.isCreateable() && Schema.sObjectType.Billings__c.fields.Tax_Rate__c.isCreateable()){

                AR.Name = co.Name;
                AR.Change_Order__c = co.Id;
                AR.Customer_Account__c = co.Customer_Account__c;
                AR.Project__c = co.Project__c;
                AR.Tax_Rate__c = co.Tax_Rate__c;

            }
            insert AR;

            List<Billable_Lines__c> arLines = new List<Billable_Lines__c>();

            for (Change_Order_Item__c coItem : [Select Id, Name, Cost_Code__c, Description__c, Item_Name__c, Tax_Rate__c, Product__c, Quantity__c, Unit_Price__c, buildertek__Unit_Sales_Price__c, SubTotal__c
                                                from change_Order_Item__c
                                                where Change_Order__c = :co.Id]){
                system.debug('Unit Sale Price ---------> ' + coItem.Unit_Sales_Price__c);
                if (Schema.sObjectType.Billable_Lines__c.fields.Billings__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Change_Order_Line__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Cost_Code__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Description__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Product__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Line_Title__c.isCreateable() && Schema.sObjectType.Billable_Lines__c.fields.Tax_Rate__c.isCreateable()){
                    Billable_Lines__c arItem = new Billable_Lines__c();
                    arItem.Billings__c = AR.Id;
                    arItem.Change_Order_Line__c = coItem.id;
                    arItem.Line_Title__c = coItem.Item_Name__c;
                    arItem.Cost_Code__c = coItem.Cost_Code__c;
                    arItem.Description__c = coItem.Name;
                    arItem.Product__c = coItem.Product__c;
                    arItem.Unit_Price__c = coItem.Unit_Sales_Price__c;
                    arItem.Quantity__c = coItem.Quantity__c;
                    arItem.Tax_Rate__c = coItem.Tax_Rate__c;
                    arLines.add(arItem);
                }
            }

            insert arLines;
            response.strMessage = 'Success';
            response.strRecordId = AR.Id;
            return response;

        } catch (Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static List<COLineItemsClass> getProduct(String coItems){
        system.debug('coItem -----------> ' + coItems);
        List<buildertek__Change_Order_Item__c> changeOrderList = (List<buildertek__Change_Order_Item__c>)JSON.deserialize(coItems, List<buildertek__Change_Order_Item__c>.class);
        system.debug('changeOrderList -----------> ' + changeOrderList);
        List<COLineItemsClass> COItemsClassList = new List<COLineItemsClass>();
        Integer count = 0;
        for (buildertek__Change_Order_Item__c CO : changeOrderList){
            COLineItemsClass COItemsClass = new COLineItemsClass(CO, true, count);
            count++;
            COItemsClassList.add(COItemsClass);
        }

        return COItemsClassList;
    }

    @AuraEnabled
    public static List<COLineItemsClass> addProductsToList(String COItems, buildertek__Change_Order_Item__c COItem, Integer count){
        system.debug('coItem -----------> ' + COItems);
        system.debug('COItem -----------> ' + COItem);
        system.debug('count ---------> ' + count);
        List<COLineItemsClass> changeOrderList = (List<COLineItemsClass>)JSON.deserialize(coItems, List<COLineItemsClass>.class);
        system.debug('changeOrderList -----------> ' + changeOrderList);

        changeOrderList.add(new COLineItemsClass(COItem, false, count));
        return changeOrderList;
    }

    @AuraEnabled
    public static string getpricebook(string BudgetId){
        system.debug('budgetId-------->'+BudgetId);
        list<buildertek__Change_Order__c> ChangeOrder;
        
        if (Schema.sObjectType.buildertek__Change_Order__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            ChangeOrder = [select id, buildertek__Project__r.buildertek__Price_Book__c
                       from buildertek__Change_Order__c
                       where id = :BudgetId];
        
        }
        system.debug('changeOrder--------->'+ChangeOrder);
       
        if (ChangeOrder.size() > 0){
            return ChangeOrder[0].buildertek__Project__r.buildertek__Price_Book__c;
            system.debug('return-------->'+ChangeOrder[0].buildertek__Project__r.buildertek__Price_Book__c);
        }
        return null;
    }

    @AuraEnabled
    public static buildertek__Change_Order_Item__c saveCOItem(String COLines, String COId){
        buildertek__Change_Order_Item__c COItemToInsert = (buildertek__Change_Order_Item__c)JSON.deserialize(COLines, buildertek__Change_Order_Item__c.class);
        COItemToInsert.buildertek__Change_Order__c = COId;
        if (COItemToInsert.Name.length() > 79){
            COItemToInsert.buildertek__Description__c = COItemToInsert.Name;
            COItemToInsert.Name = COItemToInsert.Name.left(78);

        }
        insert COItemToInsert;

        return COItemToInsert;
    }

    @AuraEnabled
     //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();

        list<pricebook2> PriceList;
        if (Schema.sObjectType.pricebook2.fields.Id.isAccessible() && Schema.sObjectType.pricebook2.fields.Name.isAccessible()){
            PriceList = [select Id, Name
                         from pricebook2
                         WHERE Name != null ORDER BY Name ASC];
        }
        for (pricebook2 p : PriceList){
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id);
        }
        return options;
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
        List<AggregateResult> productfamlylst = [SELECT family
                                                 FROM Product2
                                                 where (Id IN :ProdIds AND family != null)
                                                 group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if (productfamlylst.size() > 0){
            for (AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->' + pfwrapperlst);
        }
        return pfwrapperlst;
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

    public class COLineItemsClass{
        @AuraEnabled
        public buildertek__Change_Order_Item__c changeOrderItem{ get; set; }

        @AuraEnabled
        public Boolean isProduct{ get; set; }

        @AuraEnabled
        public Integer rowIndex{ get; set; }

        public COLineItemsClass(buildertek__Change_Order_Item__c changeOrderItem, Boolean isProduct, Integer rowIndex){
            this.changeOrderItem = changeOrderItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }
    @AuraEnabled
    //get Account Industry Picklist Values
    public static Map<String, String> getselectOptions(){
        Map<String, String> options = new Map<String, String>();
        //get Account Industry Field Describe
        Schema.DescribeFieldResult fieldResult = buildertek__Change_Order__c.buildertek__Status__c.getDescribe();
        //get Account Industry Picklist Values
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p : pList){
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    
    @AuraEnabled
    //get Change Order Record Types Values
    public static Map<String, String> getCORecordTypes(){
        Map<String, String> options = new Map<String, String>();        
        string CustomerRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        string VendorRecordTypeId = Schema.SObjectType.buildertek__Change_Order__c.getRecordTypeInfosByName().get('Vendor').getRecordTypeId();
        options.put(CustomerRecordTypeId, 'Customer');
        options.put(VendorRecordTypeId, 'Vendor');
        return options;
    }
    
    @AuraEnabled
    public static String getFieldSet(){
        String result = '';
        List<String> pickListValuesList = new List<String>();
        try{
            SObjectType objToken = Schema.getGlobalDescribe().get('buildertek__Change_Order_Item__c');
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey('buildertek__ChangeOrderLineFields')){
                for (Schema.FieldSetMember f : FsMap.get('buildertek__ChangeOrderLineFields').getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' + f.getLabel()+'",';
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown('buildertek__Change_Order_Item__c', String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;
                }
            }

        } catch (Exception e){
            result += e.getLineNumber()+' : ' + e.getMessage();
            System.debug('Error::' + e.getMessage());
            System.debug('Error At Line::' + e.getLineNumber());
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
    public static Boolean checkCustomSettings(){
        Boolean getConfigSetting;
        //* default value is always set to false in custom settings;
        try {
            List<buildertek__BT_CO_Lines_From_Product__c> coSettingList = new List<buildertek__BT_CO_Lines_From_Product__c>();
            coSettingList = [SELECT Id,buildertek__CO_Lines_Using_Product__c FROM buildertek__BT_CO_Lines_From_Product__c];
            if (coSettingList.size() > 0) {
                getConfigSetting = coSettingList[0].buildertek__CO_Lines_Using_Product__c;
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
            getConfigSetting = null;
        }
        return getConfigSetting;
    }
}