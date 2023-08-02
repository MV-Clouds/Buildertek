/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date: 15/09/2017
*/

public without sharing class ContractDAO {
    
    
    
    /*Method to used to set default grouping in Contr
act item*/
    public static void setDefaultGrouping(List<Contract_Item__c> contractItems){
        set<Id> contractIds = new set<Id>();
        SET<Id> groupIds = new SET<Id>();
        map<String, String> contractIdByGroupId = new map<String, String>();
        // get all quote Ids
        for(Contract_Item__c item : contractItems){
            contractIds.add(item.Contract__c);
            if(item.buildertek__Contract_Item_Group__c != null){
                groupIds.add(item.buildertek__Contract_Item_Group__c);
                contractIdByGroupId.put(item.Id, item.Contract_Item_Group__c);
            }
        }
        
        if(!groupIds.isEmpty()){
            for(Contract_Item__c item : contractItems){
                item.Contract_Item_Group__c = contractIdByGroupId.get(item.Id);
            }    
        }else{
             List<Quote_Line_Group__c> ctGroup ;
            if(Schema.sObjectType.Quote_Line_Group__c.fields.Id.isAccessible()&&
            Schema.sObjectType.Quote_Line_Group__c.fields.Name.isAccessible()){
             ctGroup = [SELECT Id FROM Quote_Line_Group__c WHERE Name = 'No Grouping'];
           }
            if(ctGroup.size() > 0){
                for(Contract_Item__c item : contractItems){
                    item.Contract_Item_Group__c = ctGroup[0].Id;
                }         
            }else{
                Quote_Line_Group__c contractGroup = new Quote_Line_Group__c();
                if (Schema.sObjectType.Quote_Line_Group__c.fields.Name.isCreateable()) {
                    contractGroup.Name = 'No Grouping';    
                }
                insert contractGroup;
                for(Contract_Item__c item : contractItems){
                    item.Contract_Item_Group__c = contractGroup.Id;
                } 
            }
            
            
        }
        
        
        // create new group for quote
//      if(!newContractWithoutGroup.isEmpty()){
//          Contract_Line_Group__c conGroup = [SELECT Id FROM Contract_Line_Group__c WHERE Name = 'No Grouping'];
//          /*contractIdByGroupId = new map<Id,Contract_Line_Group__c>();
//          for(Id contractId: newContractWithoutGroup){
//              Contract_Line_Group__c defaultGroup = new Contract_Line_Group__c();
//              defaultGroup.Name = 'No Grouping';
//              defaultGroup.Contract__c = contractId;
//              contractIdByGroupId.put(contractId, defaultGroup);
//          }
            
//          insert contractIdByGroupId.values();
//          */
//          for(Contract_Item__c bItem:contractItems){
//              if(contractIdByGroupId.containsKey(bItem.Contract__c)){
//                  bItem.Contract_Line_Group__c = conGroup.Id;
//              }
//          }
//      }
    }
    
    /* Create Prime Contrct from Accepted Quotes */
    Public Static List<Contract__c> QuoteToContract(Set<Id> acceptedQuoteIds){
        
        Map<Id, Quote__c> QuoteItemByContract = New Map<Id, Quote__c>([Select Id, Description__c, Name, Project__c, 
                                                                       (Select Id, Name, Description__c, Item_Name__c, Quantity__c, Unit_Price__c from Quote_Items__r) 
                                                                       from Quote__c Where Id IN:acceptedQuoteIds]);
        
        
        // CREATE PRIME CONTRACT
        Map<Id, Contract__c> QuoteIdByContract = New Map<Id, Contract__c>();
        
        for(Quote__c Quote :QuoteItemByContract.Values()){
            
            Contract__c Contract = new Contract__c();
            Contract.Name = Quote.Name;
            Contract.Project__c = Quote.Project__c;
            Contract.Description__c = Quote.Description__c;
			Contract.Status__c='Accepted';            
            QuoteIdByContract.put(Quote.Id, Contract);
        }
        if(Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Status__c.isCreateable()){
            
            insert QuoteIdByContract.Values();    
        }
        
        
        
        // CREATE PRIME CONTRACT ITMES
        List<Contract_Item__c> ContractItems = New List<Contract_Item__c>();
        for(Quote__c Quote :QuoteItemByContract.Values()){
            for(Quote_Item__c QuoteItem : Quote.Quote_Items__r){
                if(Schema.sObjectType.Contract_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Description__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Item_Name__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Quantity__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Contract__c.isCreateable()){
                    Contract_Item__c ContractItem = New Contract_Item__c();
                    ContractItem.Name = QuoteItem.Name;
                    ContractItem.Description__c = QuoteItem.Description__c;
                    ContractItem.Item_Name__c = QuoteItem.Item_Name__c;
                    ContractItem.Quantity__c = QuoteItem.Quantity__c;
                    ContractItem.Unit_Price__c = QuoteItem.Unit_Price__c;
                    ContractItem.Contract__c = QuoteIdByContract.get(Quote.Id).Id;
                    
                    ContractItems.Add(ContractItem);
                }
            }
        }
        
        // Skip the trigger because when we Insert the Items 
        // rollup summry will calculate the total and fier the trigger again to prevent that skip the contract trigger
        ContractTriggerHandler.blnSkipContractUpdateTrigger = true;
        insert ContractItems;
        ContractTriggerHandler.blnSkipContractUpdateTrigger = false;
        
        return QuoteIdByContract.Values();
    }
    
    
    Public Static List<Contract__c> createContract(Set<Id> acceptedQuoteIds){
        
        Map<Id, Quote__c> QuoteItemByContract = New Map<Id, Quote__c>([Select Id, Description__c, Name, Project__c, Create_Contract_on_Quote_Acceptance__c ,
                                                                       (Select Id, Name, Description__c, Item_Name__c, Quantity__c, Unit_Price__c from Quote_Items__r) 
                                                                       from Quote__c Where Id IN:acceptedQuoteIds]);
        
        
        // CREATE PRIME CONTRACT
        Map<Id, Contract__c> QuoteIdByContract = New Map<Id, Contract__c>();
        
        for(Quote__c Quote :QuoteItemByContract.Values()){
            
            Contract__c Contract = new Contract__c();
            Contract.Name = Quote.Name;
            Contract.Project__c = Quote.Project__c;
            Contract.Description__c = Quote.Description__c;
			Contract.Status__c='Accepted';            
            QuoteIdByContract.put(Quote.Id, Contract);
        }
        if(Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Status__c.isCreateable()){
            
            insert QuoteIdByContract.Values();    
        }
        
        
        
        // CREATE PRIME CONTRACT ITMES
        List<Contract_Item__c> ContractItems = New List<Contract_Item__c>();
        for(Quote__c Quote :QuoteItemByContract.Values()){
            for(Quote_Item__c QuoteItem : Quote.Quote_Items__r){
                if(Schema.sObjectType.Contract_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Description__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Item_Name__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Quantity__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Contract__c.isCreateable()){
                    Contract_Item__c ContractItem = New Contract_Item__c();
                    ContractItem.Name = QuoteItem.Name;
                    ContractItem.Description__c = QuoteItem.Description__c;
                    ContractItem.Item_Name__c = QuoteItem.Item_Name__c;
                    ContractItem.Quantity__c = QuoteItem.Quantity__c;
                    ContractItem.Unit_Price__c = QuoteItem.Unit_Price__c;
                    ContractItem.Contract__c = QuoteIdByContract.get(Quote.Id).Id;
                    
                    ContractItems.Add(ContractItem);
                }
            }
        }
        
        // Skip the trigger because when we Insert the Items 
        // rollup summry will calculate the total and fier the trigger again to prevent that skip the contract trigger
        ContractTriggerHandler.blnSkipContractUpdateTrigger = true;
        insert ContractItems;
        ContractTriggerHandler.blnSkipContractUpdateTrigger = false;
        
        return QuoteIdByContract.Values();
    }
    Public Static List<buildertek__Budget__c> QuoteToBudget(Set<Id> acceptedQuoteIds){
        Map<Id, buildertek__Quote__c> QuoteItemByBudget = New Map<Id, buildertek__Quote__c>([Select Id, buildertek__Description__c, Name, buildertek__Project__c, 
                                                                        (Select Id, Name, buildertek__Description__c, buildertek__Item_Name__c, buildertek__Quantity__c, buildertek__Unit_Price__c from Quote_Items__r) 
                                                                        from buildertek__Quote__c Where Id IN:acceptedQuoteIds]);
        Map<Id, buildertek__Budget__c> QuoteIdByBudget = New Map<Id, buildertek__Budget__c>();
        for(buildertek__Quote__c Quote :QuoteItemByBudget.Values()){
            buildertek__Budget__c budget = new buildertek__Budget__c();
            budget.Name = Quote.Name;
            budget.buildertek__Project__c = Quote.buildertek__Project__c;
            QuoteIdByBudget.put(Quote.Id, budget);
        }
        if(Schema.sObjectType.buildertek__Budget__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isCreateable()){
            insert QuoteIdByBudget.Values();    
        }
        List<buildertek__Budget_Item__c> BudgetItems = New List<buildertek__Budget_Item__c>();
        for(buildertek__Quote__c Quote :QuoteItemByBudget.Values()){
            for(buildertek__Quote_Item__c QuoteItem : Quote.buildertek__Quote_Items__r){
                if(Schema.sObjectType.buildertek__Budget_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Description__c.isCreateable()
                    && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Item_Name__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Quantity__c.isCreateable()
                    && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Budget_Item__c.fields.buildertek__Budget__c.isCreateable()){
                    buildertek__Budget_Item__c BudgetItem = New buildertek__Budget_Item__c();
                    BudgetItem.Name = QuoteItem.Name;
                    BudgetItem.buildertek__Description__c = QuoteItem.buildertek__Description__c;
                    BudgetItem.buildertek__Item_Name__c = QuoteItem.buildertek__Item_Name__c;
                    BudgetItem.buildertek__Quantity__c = QuoteItem.buildertek__Quantity__c;
                    BudgetItem.buildertek__Unit_Price__c = QuoteItem.buildertek__Unit_Price__c;
                    BudgetItem.buildertek__Budget__c = QuoteIdByBudget.get(Quote.Id).Id;
                    BudgetItems.Add(BudgetItem);
                }
            }
        }
        //ContractTriggerHandler.blnSkipContractUpdateTrigger = true;
        insert BudgetItems;
        // ContractTriggerHandler.blnSkipContractUpdateTrigger = false;
        return QuoteIdByBudget.Values();
    }
    
    
    // Create Sub Contract from RFQ
    Public Static Map<Id, Contract__c> createSubContractFromRFQ(Map<Id, RFQ__c> rfqs){
        
        Id subContractRecordType = BT_Utils.getRecordTypeId('Contract__c', 'Sub Contract');
        
        Map<Id, Contract__c> rfqToSubContract = new Map<Id, Contract__c>();
        
        //CREATE SUB CONTRACT
        for(RFQ__c rfq: rfqs.Values()) {
            Contract__c contract = new Contract__c();
            contract.Name = rfq.Name;
            Contract.Vendor__c = rfq.Vendor__r.Vendor__c;
            Contract.Description__c = rfq.Description__c;
            contract.Budget__c = rfq.Budget__c;
            contract.rfq__c = rfq.id;
            contract.Project__c = rfq.Project__c;
            contract.Status__c='Accepted';
            contract.Signed_Contract_Date__c = System.today();
            contract.RecordTypeId = subContractRecordType;
            contract.buildertek__Contract_Start_Date__c = System.today();
            contract.buildertek__Contract_End_Date__c = System.today()+364;
            contract.buildertek__Contract_In_Terms__c = '12';
            rfqToSubContract.put(rfq.Id, contract);
        }
        if(Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Vendor__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Budget__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.rfq__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Status__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.Signed_Contract_Date__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Start_Date__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_End_Date__c.isCreateable()
            && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_In_Terms__c.isCreateable()){
            
            insert rfqToSubContract.values();    
        }
        
        
        
        
        // CREATE SUB CONTRACT ITEMS 
        List<Contract_Item__c> contractItems = new List<Contract_Item__c>();
        system.debug('RFQList --------> '+rfqs.values());
        for(RFQ__c rfq: rfqs.values()){
            system.debug('RFQItemList --------> '+rfq.RFQ_Items__r);
            for(RFQ_Item__c rfqITem: rfq.RFQ_Items__r){
                Contract_Item__c contractItem = new Contract_Item__c();
                fillContractItemFromRFQItem(contractItem, rfqItem);
                 if(Schema.sObjectType.Contract_Item__c.fields.Contract__c.isCreateable()){
                    contractItem.Contract__c = rfqToSubContract.get(rfq.Id).Id;
                    contractItems.add(contractItem);
                 }
            }
        }
        system.debug('contractItems ---------> '+contractItems);
        // Skip the trigger because when we Insert the Items 
        // rollup summry will calculate the total and fier the trigger again to prevent that skip the contract trigger
        ContractTriggerHandler.blnSkipContractUpdateTrigger = true;
        insert ContractItems;
        ContractTriggerHandler.blnSkipContractUpdateTrigger = false;
        
        return rfqToSubContract;
    }
    
    // FILL CONTRACT ITME DETAILS FROM RFQ ITME
    public static void fillContractItemFromRFQItem(Contract_Item__c contractItem, RFQ_Item__c rfqItem){
        contractItem.Name = rfqItem.Name;
        contractItem.Description__c = rfqItem.Description__c;
        contractItem.Cost_Code__c = rfqItem.Cost_Code__c;
        contractItem.Item_Name__c = rfqItem.Name;
        contractItem.Quantity__c = rfqItem.Quantity__c;
        contractItem.Unit_Price__c = rfqItem.Unit_Price__c;
        contractItem.Budget_Item__c = rfqItem.Budget_Item__c;
    } 
    
    
    
    
    
    /**********************************************************************************************************************
Purpose: This method is used to create a Sub Contract for selected itmes            
Parameters: Contract__c subContract, string subContractItemsJson
Returns: string "Success"
Throws [Exceptions]: 
**********************************************************************************************************************/
    @AuraEnabled
    public static Contract__c createSubContract(string subContractJson, string subContractItemsJson){
        
        try{
            // List<Contract__c> subContractList = new List<Contract__c>();
            Contract__c subContractRec = new Contract__c();
            Id subContractRecordType = BT_Utils.getRecordTypeId('Contract__c', 'Sub Contract');
            if(Schema.sObjectType.Contract__c.fields.RecordTypeID.isCreateable() && Schema.sObjectType.Contract__c.fields.Signed_Contract_Date__c.isCreateable()){
            subContractRec.RecordTypeID = subContractRecordType;
            subContractRec.Signed_Contract_Date__c = System.today();
            subContractRec = (Contract__c)System.JSON.deserialize(subContractJson, Contract__c.class); 
            // subContractList.add(subContract);
            }
            insert subContractRec;
            
            List<Contract_Item__c> subContractItems = new List<Contract_Item__c>();
            for(Contract_Item__c contractItem: (List<Contract_Item__c>)System.JSON.deserialize(subContractItemsJson, List<Contract_Item__c>.class)){
                contractItem.Contract__c = subContractRec.Id;
                subContractItems.add(contractItem);
            }
            system.debug(subContractItems+'subContractItems-------<');
            
            if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Contract__c.isCreateable()){
                insert subContractItems;
            }
            
            return subContractRec;
            
        }catch(Exception ex){
            //throw new AuraHandledException(ex.getMessage());
        }  
        
        return null;
    }
    
    @AuraEnabled
    public static ResponseBase createSubContractFromBudget(buildertek__Contract__c contractJson, string contractItemsJson){
        ResponseBase res = new ResponseBase();
        try{
            RecordType RT;
            if(Schema.sObjectType.RecordType.fields.Id.isAccessible()&&
            Schema.sObjectType.RecordType.fields.Name.isAccessible()&&
            Schema.sObjectType.RecordType.fields.sObjectType.isAccessible()  ){
            RT= [SELECT Id FROM RecordType WHERE sObjectType='buildertek__Contract__c' AND Name='Sub Contract'];
            }
            contractJson.buildertek__Vendor__r = null;
            contractJson.RecordTypeID = RT.Id;
            if(Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeID.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isCreateable()){

            insert contractJson; 
            }
            system.debug('contractJson ---------> '+contractJson);
            
            List<buildertek__Contract_Item__c> contractItemList = new List<buildertek__Contract_Item__c>();
            List<buildertek__Contract_Item__c> contractItems = new List<buildertek__Contract_Item__c>();
            List<ContractLineItemsClass> COItemsList = (List<ContractLineItemsClass>)System.JSON.deserialize(contractItemsJson, List<ContractLineItemsClass>.class);
            system.debug('COItemsList ------------> '+COItemsList);
            SET<ID> productIdSet = new SET<ID>();
            for(ContractLineItemsClass wrapper : COItemsList){
                contractItemList.add(wrapper.contractItem);
                productIdSet.add(wrapper.contractItem.buildertek__Product__c);
            }
            
            List<Product2> productList;
            if(Schema.sObjectType.Product2.fields.Id.isAccessible()&&
                Schema.sObjectType.Product2.fields.Name.isAccessible()){
                productList= [SELECT Id, Name from Product2 where Id IN: productIdSet];
            }
            Map<String, String> productNameMap = new Map<String, String>();
            for(Product2 prod : productList){
                productNameMap.put(prod.Id, prod.Name);        
            }
            
            for(buildertek__Contract_Item__c coItem : contractItemList){
                coItem.Name = productNameMap.get(coItem.buildertek__Product__c);
                coItem.buildertek__Contract__c = contractJson.Id;
                contractItems.add(coItem);
            }
            if(Schema.sObjectType.Contract_Item__c.fields.Name.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Description__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Item_Name__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.Quantity__c.isCreateable()
                    && Schema.sObjectType.Contract_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.Contract_Item__c.fields.buildertek__Contract__c.isCreateable()){
                    insert contractItems;
                }
            system.debug('contractItems ---------> '+contractItems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = contractJson.Id;
            return res;
            
        }catch(Exception ex){
            system.debug('Message --------> '+ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
    }
    
    @AuraEnabled
    public static List<EmailTemplate> getContractTemplates(){
        return BT_Email_Utils.getTemplates('BT Contract');
    }
    
    @AuraEnabled
    public static List<buildertek__Contract_Item__c> GetContractLines(string contractId)
    {
     List<buildertek__Contract_Item__c> contractitemslst ;   
        if(Schema.sObjectType.buildertek__Contract_Item__c.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Product__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Cost_Codes__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible() ){
        contractitemslst= [Select Id, buildertek__Product__r.Name, Name, buildertek__Cost_Code__r.Name, buildertek__Quantity__c, 
                buildertek__Unit_Price__c, buildertek__Total_Price__c From buildertek__Contract_Item__c];
    	}
    	return contractitemslst;
    }
    
    public static List<Schema.FieldSetMember> getFields() 
    {
        return SObjectType.buildertek__Contract_Item__c.FieldSets.buildertek__Contract_Line_Field_Set.getFields();
    }
    
    @AuraEnabled
    public static Map<string, List<ContractLineWrapper>> GetGroupedContractLines(string contractId){
       return null;
    }
    
    public class ContractLineWrapper {
        @AuraEnabled public string ProductName;
        @AuraEnabled public string ContractItem;
        @AuraEnabled public string CostCode;
        @AuraEnabled public decimal Qunatity;
        @AuraEnabled public decimal UnitPrice;
        @AuraEnabled public decimal TotalPrice;
        @AuraEnabled public string Id;
    }
    
    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook'+productId);
        list<PricebookEntry> pList = new list<PricebookEntry>();
         
            pList=[select id,UnitPrice,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c from PricebookEntry where 
               product2Id =: productId and
               isActive = true and 
               pricebook2Id IN (select id from Pricebook2 Where isActive =true)];
            
        system.debug('====pList'+pList);
        return pList;
    }
    
    @AuraEnabled public list<productfamilyClass> pfwrapperlst {get;set;}
     //get product family Values
    @AuraEnabled 
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName,string parentId) {
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List < sObject > returnList = new List < sObject > ();
       
        list<string> ProdIds = new list<string>();
        if(ObjectName == 'Product2' && parentId != null){
            
             list<pricebookEntry> PElist;
             
             PElist = [select id,Product2Id from pricebookEntry where pricebook2Id =: parentId];
           
            for(pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
         }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
         List<AggregateResult> productfamlylst =[SELECT family FROM Product2  where (Id IN :ProdIds AND family != null) group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if(productfamlylst.size() > 0 ){
            for(AggregateResult agg : productfamlylst){
                 productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
                }
            system.debug('pfwrapperlst---->'+pfwrapperlst);
        }
         return pfwrapperlst;
    }
 public class productfamilyClass{
         @AuraEnabled public string productfamilyvalues {get;set;}
     }    
    
     @AuraEnabled
    public static buildertek__Contract_Item__c savecontractlineItemrec(String Colines, String contractId){
        buildertek__Contract_Item__c Coitemstoinsert = (buildertek__Contract_Item__c)JSON.deserialize(Colines, buildertek__Contract_Item__c.class);
            Coitemstoinsert.buildertek__Contract__c = contractId;
        if( Coitemstoinsert.Name.length() > 79){
            Coitemstoinsert.buildertek__Description__c = Coitemstoinsert.Name;
            Coitemstoinsert.Name = Coitemstoinsert.Name.left(78);
            
         }
        if(Coitemstoinsert.buildertek__Contract_Item_Group__c == null){
             List<buildertek__Quote_Line_Group__c> contractGroup ;
               
                    contractGroup= [select Id, Name from buildertek__Quote_Line_Group__c where Name = 'No Grouping'];
                    
            if(contractGroup.size() > 0){
                Coitemstoinsert.buildertek__Contract_Item_Group__c = contractGroup[0].Id;     
            }else{
                buildertek__Quote_Line_Group__c conGroup = new buildertek__Quote_Line_Group__c();
               
                    conGroup.Name = 'No Grouping';    
                
                insert conGroup;
                Coitemstoinsert.buildertek__Contract_Item_Group__c = conGroup.Id;
            }
            
        }  
      
           
            insert Coitemstoinsert;    
            
        return Coitemstoinsert;     
    }
    @AuraEnabled
    public static buildertek__Contract_Item__c saveContractLineItem(String contractRecord){
       
        buildertek__Contract_Item__c contractRec = new buildertek__Contract_Item__c();
        contractRec = (buildertek__Contract_Item__c)System.JSON.deserialize(contractRecord, buildertek__Contract_Item__c.class);

        if(contractRec.buildertek__Contract_Item_Group__c == null){
             List<buildertek__Quote_Line_Group__c> contractGroup ;
                if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                    contractGroup= [select Id, Name from buildertek__Quote_Line_Group__c where Name = 'No Grouping'];
                    }
            if(contractGroup.size() > 0){
                contractRec.buildertek__Contract_Item_Group__c = contractGroup[0].Id;     
            }else{
                buildertek__Quote_Line_Group__c conGroup = new buildertek__Quote_Line_Group__c();
                if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                    conGroup.Name = 'No Grouping';    
                }
                insert conGroup;
                contractRec.buildertek__Contract_Item_Group__c = conGroup.Id;
            }
            
        }  
        
        buildertek__Contract_Item__c contractLineToInsert = new buildertek__Contract_Item__c();
        contractLineToInsert.buildertek__Product__c = contractRec.buildertek__Product__c;
        contractLineToInsert.Name = contractRec.Name;
        contractLineToInsert.buildertek__Contract__c = contractRec.buildertek__Contract__c; 
        contractLineToInsert.buildertek__Contract_Item_Group__c = contractRec.buildertek__Contract_Item_Group__c;
        contractLineToInsert.buildertek__Unit_Price__c = contractRec.buildertek__Unit_Price__c;
        contractLineToInsert.buildertek__Quantity__c = contractRec.buildertek__Quantity__c;
        contractLineToInsert.buildertek__Cost_Code__c = contractRec.buildertek__Cost_Code__c;
        contractLineToInsert.buildertek__Discount__c = contractRec.buildertek__Discount__c;
         
               insert contractLineToInsert;
    			
        return contractLineToInsert;
    }
    
    @AuraEnabled
    public static void deleteContractLineItem(string contractRecord){
        system.debug('---delete id'+contractRecord);
        if(Schema.sObjectType.buildertek__Contract__c.fields.id.isAccessible()
            && buildertek__Contract__c.sObjectType.getDescribe().isDeletable()){
            buildertek__Contract__c contract = [select Id from buildertek__Contract__c where Id =: contractRecord];
            delete contract;
        }    
    }   
    
    
    
     
    @AuraEnabled
    public static Object retrieveGroups(string contractId, Decimal pageNumber, Integer recordToDisply){
        
        Integer pageSize = recordToDisply;
        Integer offset = ((Integer)pageNumber - 1) * pageSize;
        
        contractDetails Detail = new contractDetails();
        Detail.groups = getQuoteGroupDetails(contractId, null, recordToDisply, offset);
        Detail.columns = BT_Lightning_Utils.getFieldSetForDataTable('buildertek__Contract_Item__c','buildertek__Contract_Line_Field_Set');
    
        List<String> groupIds = new List<String>();
        List<String> allFields = new List<String>();
        List<String> fieldsList = new List<String>();
        String fieldsType = '[';
        List<String> fieldsTypeList = new List<String>();
        for(buildertek__Quote_Line_Group__c grp : Detail.groups){
            groupIds.add(grp.Id);        
        }
        for(BT_Lightning_Utils.dataTableFields dtFields : Detail.columns){
            allFields.add(dtFields.fieldName);
            if(dtFields.type == 'currency'){
                fieldsList.add(dtFields.fieldName);    
            }
            fieldsType += '{"fieldName": "'+dtFields.fieldName+'","fieldType": "'+dtFields.type+'","isEditable":'+dtFields.editable+'},';
        }
        allFields.add('Id');
        allFields.add('buildertek__Contract_Item_Group__c');
        fieldsType += '{"fieldName": "buildertek__Contract_Item_Group__c","fieldType": "Reference","isEditable": false},';
        fieldsType += '{"fieldName": "Id","fieldType": "","isEditable": false}]';
        system.debug('fieldsType ------------> '+fieldsType);
        system.debug('allFields ------------> '+allFields);
        system.debug('groupIds ------------> '+groupIds);
        List<wrapperClass> wrapperList = new List<wrapperClass>();
        wrapperList = groupValues(contractId, fieldsList, allFields, groupIds, recordToDisply, offset);
        TargetTable tarTable = new TargetTable();
        //List<FieldClass> fieldClassList = (List<FieldClass>)System.JSON.deserialize(fieldsType, List<FieldClass>.class);
        tarTable = getQuoteItemData(contractId, allFields, fieldsType, recordToDisply, offset);
        FinalWrapperClass wrap = new FinalWrapperClass();
        wrap.tarTable = tarTable;
        wrap.wrapperList = wrapperList;
        wrap.columns = Detail.columns;
        wrap.groups = Detail.groups;
         wrap.pageSize = pageSize;
        wrap.page = (Integer) pageNumber;
        wrap.total = [SELECT count() FROM buildertek__Contract_Item__c WHERE buildertek__Contract__c =: contractId];
        return wrap;
    }
    
    
    
    @AuraEnabled
    public static Quote_Line_Group__c updateLineFromDataTable(String items, String groupId, String contractId){
        if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isUpdateable()&&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isUpdateable()){
        update (List<Contract_Item__c>)System.JSON.deserialize(Items, List<Contract_Item__c>.class);
    		}
        return getQuoteGroupDetails(contractId, groupId, 50, 0)[0];
    }
    
    
    public static List<Quote_Line_Group__c> getQuoteGroupDetails(String contractId, String groupId, Decimal recordToDisply, Integer offset){
        // Add selected field in soql from field set
        String objectName = 'buildertek__Contract_Item__c';
        //String filterConditions = ' AND buildertek__Contract__c =:contractId'; 
        String fieldSetAPI = 'buildertek__Contract_Line_Field_Set';
        String soql = 'SELECT Id, Name ';
        soql = soql + ', Contract_Item_Group__c, Description__c, Product__c ';
        
        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList = BT_Utils.getFieldSetMembers(fieldSetAPI,objectName);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList)
        {
            if(!soql.contains(fieldSetMemberObj.getFieldPath().replace(namespacePrefix,''))){
                soql = soql+ ',' + fieldSetMemberObj.getFieldPath();
            }
            
            if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE') {
                if (!fieldSetMemberObj.getFieldPath().Contains('__c')) {
                    soql = soql+ ',' + fieldSetMemberObj.getFieldPath().replace('Id','.Name');
                } else {
                    soql = soql+ ',' + fieldSetMemberObj.getFieldPath().replace('__c','__r.Name');
                }
            }
        }
        soql = soql + ' FROM buildertek__Contract_Item__c';
        
        soql = soql + ' WHERE buildertek__Contract__c =: contractId ORDER BY Contract_Item_Group__r.Name ASC limit '+recordToDisply+' OFFSET '+offset;
        
        List<buildertek__Contract_Item__c> contractItemList;
        /*if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
        contractItemList = Database.query(soql);
				/*}*/
        system.debug('contractItemList ------------> '+contractItemList);
        
        SET<Id> groupIdSet = new SET<Id>();
        for(buildertek__Contract_Item__c contractItem : contractItemList){
            groupIdSet.add(contractItem.buildertek__Contract_Item_Group__c);        
        }
        
        List<Quote_Line_Group__c> budgetGroup;
        /*String query = 'SELECT Id, Name ';
        query = query + ', Contract_Item_Group__c, Description__c, Product__c ';
        
        String namespacePrefix1 = BT_Utils.getNamespacePrefix();
        List<Schema.FieldSetMember> fieldSetMemberList1 = BT_Utils.getFieldSetMembers(fieldSetAPI,objectName);
        system.debug('fieldSetMemberList -----> '+fieldSetMemberList1);
        for(Schema.FieldSetMember fieldSetMemberObj : fieldSetMemberList1)
        {
            
            if(!query.contains(fieldSetMemberObj.getFieldPath())){
                 system.debug('fieldSetMemberObj ********' + fieldSetMemberObj.getFieldPath());
                query = query+ ',' + fieldSetMemberObj.getFieldPath();
            }
            
            if (String.ValueOf(fieldSetMemberObj.getType()).toUpperCase() == 'REFERENCE') {
                if (!fieldSetMemberObj.getFieldPath().Contains('__c')) {
                    query = query+ ',' + fieldSetMemberObj.getFieldPath().replace('Id','.Name');
                } else {
                    query = query+ ',' + fieldSetMemberObj.getFieldPath().replace('__c','__r.Name');
                }
            }
        }
        query = query + ' FROM Contract_Lines__r';
        if(contractId != null) {
            query = query + ' WHERE Id != null AND buildertek__Contract__c =: contractId ORDER BY Name limit '+recordToDisply+' OFFSET '+offset;    
        }else {
            query = query + ' WHERE Id != null ORDER BY Name ASC';   
        }*/
        
        if(groupId != null){
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
           Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
            budgetGroup = Database.query('Select Id, Name from buildertek__Quote_Line_Group__c where Id =: groupId  ORDER BY Name ASC');  
           }
        }else{
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
           Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
            budgetGroup = Database.query('Select Id, Name from buildertek__Quote_Line_Group__c where Id IN: groupIdSet ORDER BY Name ASC');  
           }
        }
        
        /*if(contractId != null)
        budgetGroup = Database.query('Select Id, Name,('+soql+') from contract_line_group__c where contract__c =: contractId ORDER BY Sort_id__c, Name ASC');
        
        else if(groupId != null)
        budgetGroup = Database.query('Select Id, Name,('+soql+') from contract_line_group__c where Id =: groupId ORDER BY Sort_id__c, Name ASC');*/
        
        return budgetGroup;    
    }
    
    
    
    
    @AuraEnabled
    public static List<fieldSet> getFieldSet(String fieldSetName, String objectName){
        String namespacePrefix = BT_Utils.getNamespacePrefix();
        List<fieldSet> fieldSet = new List<fieldSet>();
        Schema.DescribeFieldResult describeFieldResult;
        
        List<Schema.FieldSetMember> fieldSetMembers = BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+fieldSetName, namespacePrefix+objectName);
        Map<String, Schema.SObjectField> sobjectFieldsByName = Schema.getGlobalDescribe().get(namespacePrefix+objectName).getDescribe().fields.getMap();
        
        if (!fieldSetMembers.isEmpty()) {
            for(Schema.FieldSetMember fieldSetMember : fieldSetMembers){
                describeFieldResult = sobjectFieldsByName.get(fieldSetMember.getFieldPath()).getDescribe();
                fieldSet.Add(new fieldSet(fieldSetMember.getLabel(), fieldSetMember.getFieldPath(),
                                             describeFieldResult.isHtmlFormatted(),fieldSetMember.getRequired()));
            }
        }
        
        return fieldSet;
    }
    
    
    
    @AuraEnabled
    public static void updateGroupsOrder(List<Quote_Line_Group__c> groups){
        try{
             DMLManager.updateAsUser(groups);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static void deleteGroups(List<Quote_Line_Group__c> groups){
        try{
             DMLManager.deleteAsUser(groups);
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }
    
    @AuraEnabled
    public static Quote_Line_Group__c deleteItem(List<buildertek__Contract_Item__c> Items, String groupId, String contractId){
        try{
             DMLManager.deleteAsUser(Items);
             return getQuoteGroupDetails(contractId, groupId, 50, 0)[0];
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
        return null;
    }
    
    
    @AuraEnabled
    public static string createContractItem(String contractItemsJSON){
        /*try{
            insert (List<Contract_Item__c>)System.JSON.deserialize(contractItemsJSON, List<Contract_Item__c>.class);
            return 'Success';
        }catch(Exception ex){
            throw new AuraHandledException(ex.getMessage());
        }
        return null;*/
        system.debug('budgetItemsJSON -------> '+contractItemsJSON);
        try{
            List<String> groupIds = new List<String>();
            map<String, String> budgetIdByGroupId = new map<String, String>();
            set<Id> newQuoteWithoutGroup = new set<Id>();
            List<buildertek__Contract_Item__c> contractItemsToInsert = (List<buildertek__Contract_Item__c>)System.JSON.deserialize(contractItemsJSON, List<buildertek__Contract_Item__c>.class);
            //insert (List<buildertek__Budget_Item__c>)System.JSON.deserialize(quoteItemsJSON, List<buildertek__Budget_Item__c>.class);
            system.debug('contractItemsToInsert ----------> '+contractItemsToInsert);
            for(buildertek__Contract_Item__c conItem : contractItemsToInsert){
                system.debug('conItem.buildertek__Contract_Item_Group__c --------> '+conItem.buildertek__Contract_Item_Group__c);
                if(conItem.buildertek__Contract_Item_Group__c != null){
                    groupIds.add(conItem.buildertek__Contract_Item_Group__c);  
                    budgetIdByGroupId.put(conItem.Id, conItem.buildertek__Contract_Item_Group__c);
                }     
            }
            system.debug('Is Empty ----------> '+groupIds.isEmpty());
            if(!groupIds.isEmpty()){
                system.debug('Not Empty ----------> '+groupIds);
                for(buildertek__Contract_Item__c contractItem : contractItemsToInsert){
                    contractItem.buildertek__Contract_Item_Group__c = budgetIdByGroupId.get(contractItem.Id);
                }    
            }else{
                List<buildertek__Quote_Line_Group__c> contractGroup ;
                if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
                    Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                    contractGroup= [SELECT Id FROM buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];
                    }
                system.debug('contractGroup ----------> '+contractGroup);
                if(contractGroup.size() > 0){
                    for(buildertek__Contract_Item__c cItem : contractItemsToInsert){
                        cItem.buildertek__Contract_Item_Group__c = contractGroup[0].Id;
                    }         
                }else{
                    buildertek__Quote_Line_Group__c conGroup = new buildertek__Quote_Line_Group__c();
                    if (Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()) {
                        conGroup.Name = 'No Grouping';    
                    }
                    insert conGroup;
                    system.debug('conGroup ----------> '+conGroup);
                    for(buildertek__Contract_Item__c cItem : contractItemsToInsert){
                        cItem.buildertek__Contract_Item_Group__c = conGroup.Id;
                        contractItemsToInsert.add(cItem);
                    } 
                }
            }
             if (Schema.sObjectType.buildertek__Contract_Item__c.isCreateable() && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isCreateable()) {
            insert contractItemsToInsert;
             }
            return 'Success';
        }catch(Exception ex){
            return ex.getMessage();
        }
        return null;
        
    }
    
    @AuraEnabled
    public static buildertek__contract_Item__c getcontractItem(string contractLineRecord){
       buildertek__Contract_Item__c contractItem;
        if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Product__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Cost_Codes__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Cost_Codes__c.fields.buildertek__Cost_Code_Name__c.isAccessible() ){
    			    
    			    
               contractItem = [select Id, Name,buildertek__Product__r.Name,buildertek__Product__c,buildertek__contract__c, buildertek__Cost_Code__c,buildertek__Cost_Code__r.Name, buildertek__Contract_Item_Group__c, buildertek__Contract_Item_Group__r.Name,
                                buildertek__Cost_Code__r.buildertek__Cost_Code_Name__c,buildertek__Unit_Price__c, buildertek__Quantity__c from buildertek__contract_Item__c where Id =: contractLineRecord];
    	
    			}
        return contractItem;
    }
    
    /*@AuraEnabled
    public static string getselectOptions(sObject contractObject, string contractField) {
        system.debug('contractObject --->' + contractObject);
        system.debug('contractField --->' + contractField);
        Schema.sObjectType objType = contractObject.getSObjectType();
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        list < Schema.PicklistEntry > values =
        fieldMap.get(contractField).getDescribe().getPickListValues();
        
        list<contractClass> allcontractOptions = new list<contractClass>();
        integer i=1;
        for (Schema.PicklistEntry a: values) {
            contractClass allcontractOption = new contractClass(); 
            allcontractOption.Id = a.getLabel();
            allcontractOption.values = a.getValue();
            allcontractOptions.add(allcontractOption);
            i++;
        }
        String Allcontractvalues = json.serialize(allcontractOptions);
        system.debug('allOpts ---->' + allcontractOptions);
        //allOpts.sort();
        return Allcontractvalues;
    }*/
    
    @AuraEnabled
    public static void updatecontractLineItem(buildertek__contract_Item__c contractLineRecord){
        System.debug('---contract Line Items'+contractLineRecord);
        system.debug('Created contractLineRecord: ' + contractLineRecord);
        
         buildertek__Quote_Line_Group__c contractGroup;
         if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() ){
        contractGroup = [select Id, Name from buildertek__Quote_Line_Group__c where Id =: contractLineRecord.buildertek__Contract_Item_Group__c];
        }
        system.debug('Group Name ----> '+contractGroup.Name);
        buildertek__Quote_Line_Group__c newContractGroup = new buildertek__Quote_Line_Group__c();
        if(contractGroup != null){
            system.debug('Group Name 123 ----> '+contractGroup.Name); 
            newContractGroup.Id = contractGroup.Id;
            newContractGroup.Name = contractGroup.Name;
            //newContractGroup.buildertek__Contract__c = contractLineRecord.buildertek__Contract__c;
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.isUpdateable()&&
            Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isUpdateable() &&
    		Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isUpdateable()){ 
            update newContractGroup;
    		}
        }else{
            newContractGroup.Name = contractGroup.Name;
            //newContractGroup.buildertek__Contract__c = contractLineRecord.buildertek__Contract__c;
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.isCreateable()&&
    		Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){ 
            insert newContractGroup;
    		}
        }
        
        buildertek__contract_Item__c contractLineToInsert = new buildertek__contract_Item__c();
        contractLineToInsert.Id = contractLineRecord.Id;
        contractLineToInsert.buildertek__Product__c = contractLineRecord.buildertek__Product__c;
        contractLineToInsert.Name = contractLineRecord.Name;
        contractLineToInsert.buildertek__Contract_Item_Group__c = contractLineRecord.buildertek__Contract_Item_Group__c;
        contractLineToInsert.buildertek__Unit_Price__c = contractLineRecord.buildertek__Unit_Price__c;
        contractLineToInsert.buildertek__Quantity__c = contractLineRecord.buildertek__Quantity__c;
       // contractLineToInsert.buildertek__UOM__c  = contractLineRecord.buildertek__UOM__c;
        contractLineToInsert.buildertek__Cost_Code__c  = contractLineRecord.buildertek__Cost_Code__c;
        system.debug('Created contractLineRecord: ' + contractLineToInsert);
      if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isUpdateable()){
            update contractLineToInsert;
    	}
    }
    
     public Class contractClass{
        @AuraEnabled public String Id{get;set;}
        @AuraEnabled public String values{get;set;}
    }
    
    public class contractDetails{
       
        @AuraEnabled
        public List<Quote_Line_Group__c> groups {get;set;}
        
        @AuraEnabled
        public List<String> headerFields {get;set;}
        
        @AuraEnabled
        public List<BT_Lightning_Utils.dataTableFields> columns {get;set;}
        
        public contractDetails(){
            groups = new List<Quote_Line_Group__c>();
            headerFields = new List<String>();
            columns = new List<BT_Lightning_Utils.dataTableFields>();
        }
    }
    
    public class fieldSet {
        @AuraEnabled
        public String fieldLabel {get;set;}
        @AuraEnabled       
        public String fieldName {get;set;}
        @AuraEnabled
        public Boolean isRequired {get;set;}
        @AuraEnabled
        public Boolean isHtmlFormatted {get;set;}
        
        public fieldSet(String fieldLabel, String fieldName, Boolean isHtmlFormatted, Boolean isRequired){
            this.fieldLabel = fieldLabel;
            this.fieldName = fieldName; 
            this.isHtmlFormatted = isHtmlFormatted;
            this.isRequired = isRequired;
        }
    }
    
    @AuraEnabled
    public static buildertek__Contract_Item__c deleteQuoteItem(String quoteId){
        buildertek__Contract_Item__c contractItem;
        if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible() ){
                 contractItem = [SELECT Id, Name FROM buildertek__Contract_Item__c WHERE Id =: quoteId];
        }
        if(buildertek__Contract_Item__c.sObjectType.getDescribe().isDeletable()){
            delete contractItem;
        }
            return contractItem;
    }
    
    @AuraEnabled
    public static void deleteSelectedItems(List<String> recordIds){
        list<buildertek__Contract_Item__c> contractItemLists;
        if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible() ){
                contractItemLists= [select id from buildertek__Contract_Item__c where id IN: recordIds];
         }
          if(buildertek__Contract_Item__c.sObjectType.getDescribe().isDeletable()){
            delete contractItemLists; 
          }
    }
    
    @AuraEnabled
    public static List<wrapperClass> groupValues(String recordId, list<String> currencyFields, List<String> allFields, List<String> groupIds, Decimal recordToDisply, Integer offset){
        Map<string,string> mapForLabel = new Map<string,string>();
        Map<string,string> mapForFieldType = new Map<string,string>();
        Map<String, Schema.SObjectType> gd = Schema.getGlobalDescribe(); 
        Schema.SObjectType ctype = gd.get('buildertek__Contract_Item__c');
        Map<String, Schema.SobjectField> fmap = ctype.getDescribe().fields.getMap(); 
        system.debug('FieldsName '+fmap.keySet());
        for(String fieldName: fmap.keySet()) { 
            mapForLabel.put(fieldName,fmap.get(fieldName).getDescribe().getLabel()); 
            mapForFieldType.put(fieldName,string.valueof(fmap.get(fieldName).getDescribe().getType())); 
        }
        List<buildertek__Contract_Item__c> contractItemList = new List<buildertek__Contract_Item__c>();
        list<AggregateResult> childObjGroup = new list<AggregateResult>();
        string myqueries = '';
        String myquery = '';
        String aggregateFields = '';
        String queryFields = '';
        integer i=1;
        for(string sumOfFields : currencyFields){
            queryFields += ', '+ sumOfFields.trim();       
        }
        myquery = 'select buildertek__Contract_Item_Group__c '+ queryFields + ' from buildertek__Contract_Item__c where buildertek__Contract__c =: recordId Order by buildertek__Contract_Item_Group__r.Name, Name ASC limit '+recordToDisply+' OFFSET '+offset;
        system.debug('myquery -----------> '+myquery);
     /*if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
        contractItemList = database.query(myquery);
			/*	}*/
        system.debug('contractItemList -----------> '+contractItemList.size());
        for(string sumOfFields : currencyFields){
            aggregateFields += ', SUM('+sumOfFields.trim()+') total'+i;
            i++;
        }
        myqueries = 'select buildertek__Contract_Item_Group__c '+ aggregateFields + ' from buildertek__Contract_Item__c where Id IN: contractItemList Group By buildertek__Contract_Item_Group__c';
        system.debug('myqueries Results '+myqueries);
        /*if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
        childObjGroup = database.query(myqueries);
				/*}*/
        system.debug('childObjGroup ---------> '+childObjGroup.size()); 
        system.debug('childObjGroup Results '+childObjGroup);
        string Childs = 'select Id, Name from buildertek__Quote_Line_Group__c where id IN: groupIds order by Name ASC';
        list<buildertek__Quote_Line_Group__c> childObjGroups;
        /*if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible() &&
           Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){*/
       childObjGroups = database.query(Childs);
    /*}*/
        Map<string, string> GroupNameMap = new Map<String, string>();
        for(buildertek__Quote_Line_Group__c  Grps : childObjGroups){
            GroupNameMap.put((String)Grps.get('Id'),(String)Grps.get('Name'));
        }
        system.debug('GroupNameMap ------------> '+GroupNameMap);
        
        Map<String, Boolean> fieldTypeMap = new Map<String, Boolean>();
        for(string sumOfFields : currencyFields){
            fieldTypeMap.put(sumOfFields, true);
        }
        system.debug('fieldTypeMap ----------> '+fieldTypeMap);
        List<wrapperClass> wrapperClassList = new List<wrapperClass>();         
        for(AggregateResult  objAgr: childObjGroup){
            integer j=1;
            integer child = 1;
            for(string sumOfFields : allFields){
                if(child >=2){ 
                    system.debug('Result --------> '+fieldTypeMap.get(sumOfFields));
                    if(fieldTypeMap.get(sumOfFields) == true){
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Contract_Item_Group__c')), (Decimal)objAgr.get('total'+j), string.valueOf(mapForFieldType.get(sumOfFields.toLowercase().replace(' ',''))), sumOfFields)); 
                        j++;
                    }else{
                        wrapperClassList.add(new wrapperClass(GroupNameMap.get((String)objAgr.get('buildertek__Contract_Item_Group__c')), null, 'false', sumOfFields));
                    }
                    
                }
                child++;
            }
        } 
        system.debug('wrapperClassList ----------> '+wrapperClassList);
        return wrapperClassList;
    }
    
    @AuraEnabled
    public static TargetTable getQuoteItemData(String recordId, List<String> fieldsList, String fieldString, Decimal recordToDisply, Integer offset){
        List<FieldClass> fieldClassList = (List<FieldClass>)System.JSON.deserialize(fieldString, List<FieldClass>.class);
        system.debug('fieldClassList ------------> '+fieldClassList);
        system.debug('fieldsList --------> '+fieldsList);
        TargetTable TargetTable_inst = new TargetTable();
        List<EachRecord> allListOfRecords = new List<EachRecord>();
        String aggregateFields = '';
        String objectName = 'buildertek__Contract_Item__c';
        String listType = 'List<' + objectName + '>';
        String EachRecordType =  ''+objectName+'';
        System.debug('listType'+listType);
        System.debug('EachRecordType'+EachRecordType);
        SObject IndividualMember = (SObject)Type.forName(EachRecordType).newInstance();
        for(string sumOfFields : fieldsList){
            if(sumOfFields != null){
                aggregateFields += ', '+sumOfFields;    
            }
        }
        system.debug('aggregateFields --------> '+aggregateFields);
        String myqueries = '';
        myqueries = 'select buildertek__Contract__c '+ aggregateFields + ' from buildertek__Contract_Item__c where buildertek__Contract__c =: recordId ORDER BY buildertek__Contract_Item_Group__r.Name, Name ASC limit '+recordToDisply+' OFFSET '+offset; 
        List<SObject> ListOfRecords;
   /* if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
       ListOfRecords = Database.query(myqueries);
    /*}*/
        system.debug('ListOfRecords ----------> '+ListOfRecords.size());
        Integer count = 0;
        for(Integer i=0;i<ListOfRecords.size();i++){
            IndividualMember = ListOfRecords[i];
            EachRecord Each_record_nested_List_Of_Fields = new EachRecord();
            List<object> temp = new List<object>();
            List<RecordsList> recList = new List<RecordsList>();
            for(FieldClass field : fieldClassList){
                if(field.fieldName == 'id'){
                    Each_record_nested_List_Of_Fields.recordId=(Id)IndividualMember.get(field.fieldName);
                }else{
                    if(field.fieldName != null && field.fieldName !='buildertek__Contract_Item_Group__c' && field.fieldName != 'Name'){
                        if(field.fieldType == 'currency'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName)==null)?'$0.00':'$'+IndividualMember.get(field.fieldName), field.fieldName, (IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName), field.fieldType));
                            temp.add((IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName));    
                        }else if(field.fieldType == 'string'){
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName)==null)?'0.00%':IndividualMember.get(field.fieldName)+'%', field.fieldName, (IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName), field.fieldType));
                            temp.add((IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName));     
                        }else{
                            recList.add(new RecordsList(field.isEditable, (IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName)+'', field.fieldName, (IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName), field.fieldType));
                            temp.add((IndividualMember.get(field.fieldName)==null)?'':IndividualMember.get(field.fieldName)); 
                        }
                            
                    }
                }
                if(field.fieldName =='buildertek__Contract_Item_Group__c'){
                    Each_record_nested_List_Of_Fields.groupId = (Id)IndividualMember.get(field.fieldName);    
                }
                if(field.fieldName == 'Name'){
                    Each_record_nested_List_Of_Fields.recordName = (String)IndividualMember.get(field.fieldName);
                }
            }
            System.debug('i -----------> '+i+'-'+temp);
            //recList.recordValue=temp;
            Each_record_nested_List_Of_Fields.recordValue=temp;
            Each_record_nested_List_Of_Fields.recordList = recList;
            Each_record_nested_List_Of_Fields.recordCount = count;
            allListOfRecords.add(Each_record_nested_List_Of_Fields);
            count++;
        }
        TargetTable_inst.records=ListOfRecords;
        TargetTable_inst.ListOfEachRecord=allListOfRecords;
        return TargetTable_inst;
    }
    
    @AuraEnabled
    public static List<buildertek__Contract_Item__c> prepareString(String contractString){
        List<buildertek__Contract_Item__c> contractItemsToInsert = (List<buildertek__Contract_Item__c>)System.JSON.deserialize(contractString, List<buildertek__Contract_Item__c>.class);
        system.debug('contractItemsToInsert ----------> '+contractItemsToInsert);
        //update budgetItemsToInsert;
        return contractItemsToInsert;
    }
    
    @AuraEnabled
    public static void saveUpdatedValues(List<buildertek__Contract_Item__c> contractItemList){
        Map<String, buildertek__Contract_Item__c> contractItemIdMap = new Map<String, buildertek__Contract_Item__c>();
        system.debug('contractItemList -----------> '+contractItemList);
        contractItemIdMap.putAll(contractItemList); 
        
        system.debug('contractItemIdMap key ----------> '+contractItemIdMap.keyset());
        system.debug('contractItemIdMap ----------> '+contractItemIdMap);
        system.debug('contractItemIdMap ----------> '+contractItemIdMap.values());
        if(Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isUpdateable() ){
                update contractItemIdMap.values();
    	}
    }
    
    @AuraEnabled //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        list<pricebook2> PriceList = [select Id,Name from pricebook2 ORDER BY Name ASC];
        for (pricebook2 p: PriceList) {
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id); 
        }
        return options;
    } 
      /* mass Functionality start*/

    @AuraEnabled
    public static void massUpdateContractLineItem(string contractLineRecords){ 
        System.debug('quoteLineRecords ::'+contractLineRecords);
        List<buildertek__Contract_Item__c> ContractRecs = new List<buildertek__Contract_Item__c>();
        ContractRecs =(List<buildertek__Contract_Item__c>)System.JSON.deserialize(contractLineRecords, List<buildertek__Contract_Item__c>.class);
        if(ContractRecs.size()>0){
          if(Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isUpdateable() &&
    		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isUpdateable()){
                update ContractRecs;
    			}
            System.debug('contractRecs '+ContractRecs);
        }

    }
    
     @AuraEnabled
    public static void duplicateContractLineItem(List<string> contractLineRecords){
        List<String> contractLineItemRecs=contractLineRecords;
        
        String query ='';
        String SobjectApiName = 'buildertek__Contract_Item__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(SobjectApiName).getDescribe().fields.getMap();
        
        String strFields = '';
        
        for(String fieldName : fieldMap.keyset() )
        {
            if(strFields == null || strFields == '')
            {
                strFields = fieldName;
            }else{
                strFields = strFields + ',' + fieldName;
            }
        }
        
        query = 'select ' + strFields + ' from ' + SobjectApiName + ' where id in :contractLineItemRecs';
        
       List<buildertek__Contract_Item__c> lstRecs;
       /*if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__contract__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Total_Price__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Line_Group__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
				Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Reason_for_Change__c.isAccessible()){*/
                lstRecs =  Database.query(query);
			/*}*/
       List<buildertek__Contract_Item__c> lstRecsClone= lstRecs.deepClone(); 
        if(lstRecsClone.size()>0){
            if(Schema.sObjectType.buildertek__Contract_Item__c.isCreateable()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isCreateable()&&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isCreateable() &&
        		Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isCreateable()){ 
                insert lstRecsClone;
    		}
        } 
     }
    
    
    /* mass Functionality end*/

 @AuraEnabled 
    public static string getpricebook(string ContractId){
        list<buildertek__Contract__c> Contractlist; 
          if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isAccessible() &&
			Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()  ){
                                        Contractlist= [  select id,
                                                        buildertek__Project__r.buildertek__Price_Book__c 
                                                        from buildertek__Contract__c 
                                                        where id =: ContractId ];
			}
        if(Contractlist.size() > 0){
            return Contractlist[0].buildertek__Project__r.buildertek__Price_Book__c ;
        }
        return null;
    }   
    
    public class FieldClass{
        @AuraEnabled public String fieldName; //Record Id used for Firing Events
        @AuraEnabled public String fieldType;
        @AuraEnabled public Boolean isEditable; 
    }
    
    public class RecordsList{
        @AuraEnabled public Boolean isEditable;
        @AuraEnabled public String recordValue;
        @AuraEnabled public String fieldName;
        @AuraEnabled public Object originalValue;
        @AuraEnabled public String fieldType;
        public RecordsList(Boolean isEditable, String recordValue, String fieldName, Object originalValue, String fieldType){
            this.isEditable = isEditable;
            this.recordValue = recordValue;
            this.fieldName = fieldName;
            this.originalValue = originalValue;
            this.fieldType = fieldType;
        }
    }
    
    public class EachRecord{
        @AuraEnabled public Integer recordCount;
        @AuraEnabled public List<RecordsList> recordList;
        @AuraEnabled public List<object> recordValue;  //Record
        @AuraEnabled public Id recordId; //Record Id used for Firing Events
        @AuraEnabled public String recordName;
        @AuraEnabled public Id groupId;
    }
    public class TargetTable{
        @AuraEnabled public List <sObject> records; //actual list of records
        @AuraEnabled public List <EachRecord> ListOfEachRecord;//all data will be saved as array of array values
        
    }
    
    public class wrapperClass {
        @AuraEnabled public String groupName { get; set; }
        @AuraEnabled public Decimal totalValue { get; set; }
        @AuraEnabled public String fieldType { get; set; }
        @AuraEnabled public String fieldLabel { get; set; }
        public wrapperClass(String groupName, Decimal totalValue, String fieldType, String fieldLabel){
            this.groupName = groupName;
            this.totalValue = totalValue;
            this.fieldType = fieldType;
            this.fieldLabel = fieldLabel;
        }
    }
    
     public class finalWrapperClass{
        @AuraEnabled public TargetTable tarTable;
        @AuraEnabled public List<wrapperClass> wrapperList;
        @AuraEnabled public List<BT_Lightning_Utils.dataTableFields> columns;
        @AuraEnabled public List<Quote_Line_Group__c> groups {get;set;}
        @AuraEnabled public Integer pageSize {get;set;}
        @AuraEnabled public Integer page {get;set;}
        @AuraEnabled public Integer total {get;set;}
    }
    
    @AuraEnabled
    public static List<ContractLineItemsClass> getProduct(String poItems){
        system.debug('poItems -----------> '+poItems);
        List<buildertek__Contract_Item__c> contractItemList = (List<buildertek__Contract_Item__c>)JSON.deserialize(poItems, List<buildertek__Contract_Item__c>.class);
        system.debug('contractItemList -----------> '+contractItemList);
        List<ContractLineItemsClass> ContractItemsClassList = new List<ContractLineItemsClass>();
        Integer count = 0;
        for(buildertek__Contract_Item__c CO : contractItemList){
            ContractLineItemsClass COItemsClass = new ContractLineItemsClass(CO, true, count);
            count++;
            ContractItemsClassList.add(COItemsClass);
        }
        
        return ContractItemsClassList;
    }
    
    @AuraEnabled
    public static List<ContractLineItemsClass> addProductsToList(String POItems, buildertek__Contract_Item__c POItem, Integer count) { 
        system.debug('POItems -----------> '+POItems);
        system.debug('POItem -----------> '+POItem);
        system.debug('count ---------> '+count); 
        List<ContractLineItemsClass> contractItemList = (List<ContractLineItemsClass>)JSON.deserialize(POItems, List<ContractLineItemsClass>.class);
        system.debug('purchaseOrderList -----------> '+contractItemList);
        
        contractItemList.add(new ContractLineItemsClass(POItem, false, count));
        return contractItemList;
    }
    
    public class ContractLineItemsClass{
        @AuraEnabled public buildertek__Contract_Item__c contractItem { get; set; }
        @AuraEnabled public Boolean isProduct { get; set; }
        @AuraEnabled public Integer rowIndex { get; set; }
        public ContractLineItemsClass(buildertek__Contract_Item__c contractItem, Boolean isProduct, Integer rowIndex){
            this.contractItem = contractItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }
    
    
    
}