public with sharing class BT_CreateNewBill {
    
    
      /**********************************************************************************************************************
       Purpose: This method is used to create a link between Bill Line Item and Budget Item             
       Parameters: List<buildertek__Account_Payable_Item__c> Billlineitems
       Returns: NA
       Throws [Exceptions]: 
   **********************************************************************************************************************/
    public static void createbilllineitemToBudgetItemLink(List<buildertek__Account_Payable_Item__c> Billlineitems){
        
       /* List<buildertek__InvoiceLine_Item_To_Budget_Item_Link__c> billlineItemToBudgetItemLinks = new List<buildertek__InvoiceLine_Item_To_Budget_Item_Link__c>();
        
        for(buildertek__Account_Payable_Item__c billitem: Billlineitems){
            
            if(billitem.buildertek__Budget_Line__c != null) {
                
                    buildertek__InvoiceLine_Item_To_Budget_Item_Link__c billitemToBudgetItemLink = new buildertek__InvoiceLine_Item_To_Budget_Item_Link__c();
                    billitemToBudgetItemLink.buildertek__Invoice_Line__c = billitem.Id;
                    billitemToBudgetItemLink.buildertek__Budget_Line__c = billitem.buildertek__Budget_Line__c;
                    billlineItemToBudgetItemLinks.add(billitemToBudgetItemLink);
                }
            
        }
        
        if(!billlineItemToBudgetItemLinks.isEmpty()){
            insert billlineItemToBudgetItemLinks;
            system.debug('billlineItemToBudgetItemLinks-----'+billlineItemToBudgetItemLinks);
        }*/
    }
    
    
    /**********************************************************************************************************************
       Purpose: This method is used to roll up Bill(Accountpayable) Line item amount to Budget item            
       Parameters: set<Id> InvoiceiItemIds
       Returns: NA
       Throws [Exceptions]: 
   **********************************************************************************************************************/
    public static void RollUpBillLineItemAmount(set<Id> InvoiceLineItemIds){
       /* List<buildertek__InvoiceLine_Item_To_Budget_Item_Link__c> billitemToBudgetItemLinks = new List<buildertek__InvoiceLine_Item_To_Budget_Item_Link__c>();
        for(buildertek__InvoiceLine_Item_To_Budget_Item_Link__c billitemToBudgetLink: [Select Id, Auto_Roll_Up__c from buildertek__InvoiceLine_Item_To_Budget_Item_Link__c Where buildertek__Invoice_Line__c IN:InvoiceLineItemIds]) {
           
                billitemToBudgetLink.Auto_Roll_Up__c = true;
                billitemToBudgetItemLinks.add(billitemToBudgetLink);
            
        }
        
        if(!billitemToBudgetItemLinks.isEmpty()) {
            
        update billitemToBudgetItemLinks;
             
        }*/
    }
    
   
    
     @AuraEnabled
    public static ResponseBase createBill(buildertek__Account_Payable__c billJson,string budgetlienId, string BilllineitemsJson){
        system.debug('billJson ----------> '+billJson);
        system.debug('BilllineitemsJson ----------> '+BilllineitemsJson);
        ResponseBase res = new ResponseBase();
        try{
            //billJson.buildertek__Vendor__r = null;
            buildertek__Project__c project;
            
                project= [SELECT Id, Name, buildertek__Customer__c FROM buildertek__Project__c WHERE Id =: billJson.buildertek__Project__c];
            
            /*system.debug('project -------> '+project);
            if(project.buildertek__Customer__c != null){
                billJson.buildertek__Customer_Account__c =  project.buildertek__Customer__c;               
            }*/
            
            insert billJson;
    			
            system.debug('coRec ---------> '+billJson);
            
            List<buildertek__Account_Payable_Item__c> billlineItemList = new List<buildertek__Account_Payable_Item__c>();
            List<buildertek__Account_Payable_Item__c> Billlineitems = new List<buildertek__Account_Payable_Item__c>();
            List<BilllineitemsClass> BilllineitemsList = (List<BilllineitemsClass>)System.JSON.deserialize(BilllineitemsJson, List<BilllineitemsClass>.class);
            system.debug('BilllineitemsList ------------> '+BilllineitemsList);
            SET<ID> productIdSet = new SET<ID>();
            for(BilllineitemsClass wrapper : BilllineitemsList){
                billlineItemList.add(wrapper.billlineItem);
                productIdSet.add(wrapper.billlineItem.buildertek__Product__c);
            }
            
            List<Product2> productList ;
            
                productList= [SELECT Id, Name from Product2 where Id IN: productIdSet];
            
            Map<String, String> productNameMap = new Map<String, String>();
            for(Product2 prod : productList){
                productNameMap.put(prod.Id, prod.Name);        
            }
            
            for(buildertek__Account_Payable_Item__c billlineItem: billlineItemList){
                /*if(productNameMap.containskey(billlineItem.buildertek__Product__c)){
                    billlineItem.buildertek__Item_Name__c = productNameMap.get(billlineItem.buildertek__Product__c);    
                }else{
                 billlineItem.buildertek__Item_Name__c = billJson.Name;   
                }*/
                billlineItem.buildertek__Account_Payable__c = billJson.Id;
                billlineItem.buildertek__Budget_Line__c = budgetlienId;
                Billlineitems.add(billlineItem);
            }
            
                    insert Billlineitems;
        			
            system.debug('Billlineitems ---------> '+Billlineitems);
            res.isSuccess = true;
            res.strMessage = 'Success';
            res.strRecordId = billJson.Id;
            return res;
            
        }catch(Exception ex){
            //throw new AuraHandledException(ex.getMessage());
            system.debug('Message --------> '+ex.getMessage());
            res.isSuccess = false;
            res.strMessage = ex.getMessage();
            res.strRecordId = '';
            return res;
        }
        
    }
     @AuraEnabled
    public static List<BilllineitemsClass> getProduct(String Billlineitems){
        system.debug('billlineItem -----------> '+Billlineitems);
        List<buildertek__Account_Payable_Item__c> BilllineitemList = (List<buildertek__Account_Payable_Item__c>)JSON.deserialize(Billlineitems, List<buildertek__Account_Payable_Item__c>.class);
        system.debug('BilllineitemList -----------> '+BilllineitemList);
        List<BilllineitemsClass> BilllineitemsClassList = new List<BilllineitemsClass>();
        Integer count = 0;
        for(buildertek__Account_Payable_Item__c billline : BilllineitemList){
            BilllineitemsClass BilllineitemsClass = new BilllineitemsClass(billline, true, count);
            count++;
            BilllineitemsClassList.add(BilllineitemsClass);
        }
        
        return BilllineitemsClassList;
    }
    
    @AuraEnabled
    public static List<BilllineitemsClass> addProductsToList(String Billlineitems, buildertek__Account_Payable_Item__c billlineItem, Integer count) { 
        system.debug('billlineItem -----------> '+Billlineitems);
        system.debug('billlineItem -----------> '+billlineItem);
        system.debug('count ---------> '+count);
        List<BilllineitemsClass> BilllineitemList = (List<BilllineitemsClass>)JSON.deserialize(Billlineitems, List<BilllineitemsClass>.class);
        system.debug('BilllineitemList -----------> '+BilllineitemList);
        
        BilllineitemList.add(new BilllineitemsClass(billlineItem, false, count));
        return BilllineitemList;
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }
    
    public class BilllineitemsClass{
        @AuraEnabled public buildertek__Account_Payable_Item__c billlineItem { get; set; }
        @AuraEnabled public Boolean isProduct { get; set; }
        @AuraEnabled public Integer rowIndex { get; set; }
        public BilllineitemsClass(buildertek__Account_Payable_Item__c billlineItem, Boolean isProduct, Integer rowIndex){
            this.billlineItem = billlineItem;
            this.isProduct = isProduct;
            this.rowIndex = rowIndex;
        }
    }
}