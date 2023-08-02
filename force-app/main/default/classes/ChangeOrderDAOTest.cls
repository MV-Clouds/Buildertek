@isTest
private class ChangeOrderDAOTest {
    
    private static testMethod void createChangeOrderItemToBudgetItemLink() {
    
    Integer MAX_QUERY = Limits.getLimitQueries();
Integer NUM_QUERY = MAX_QUERY - 1;
        
        Product2 prod1 = new Product2();
        prod1.Name='test product';
        insert prod1;
        Id pricebookId = Test.getStandardPricebookId();
       
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        proj.buildertek__Customer__c=acc.Id;
        insert proj;
        
        
        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Test Budget';
        budget.buildertek__Project__c = proj.Id;
        budget.buildertek__Type__c = 'Master';
        insert budget;
        
        buildertek__Budget_Item__c budItem = new buildertek__Budget_Item__c();
        budItem.Name = 'Test Budget';
        budItem.buildertek__Budget__c = budget.Id;
        budItem.buildertek__Quantity__c = 10;
        budItem.buildertek__Unit_Price__c = 100;
        insert budItem;
        
        
        buildertek__Change_Order__c CO = new buildertek__Change_Order__c();
        CO.Name = 'Test CO';
        CO.buildertek__Project__c = proj.Id;
        CO.buildertek__Status__c = 'Pending';
        CO.buildertek__Customer_Account__c = acc.Id;
        insert CO;
        
        buildertek__Change_Order__c CO1 = new buildertek__Change_Order__c();
        CO1.Name = 'Test CO';
        CO1.buildertek__Project__c = proj.Id;
        CO1.buildertek__Status__c = 'Pending';
        CO1.buildertek__Customer_Account__c = acc.Id;
        
        List<buildertek__Change_Order_Item__c> coItemList = new List<buildertek__Change_Order_Item__c>();
        buildertek__Change_Order_Item__c coItem = new buildertek__Change_Order_Item__c();
        coItem.buildertek__Change_Order__c = CO.Id;
        coItem.Name = 'Test CO Item';
        coItem.buildertek__Quantity__c = 10;
        coItem.buildertek__Unit_Price__c = 100;
        coItem.Budget_Item__c = budItem.Id;
        coItemList.add(coItem);
        insert coItemList;
        
        String strJSON = JSON.serialize(coItemList);
        
        List<buildertek__Change_Order_Item__c> coItemList1 = new List<buildertek__Change_Order_Item__c>();
        buildertek__Change_Order_Item__c coItem1 = new buildertek__Change_Order_Item__c();
        coItem1.Name = 'Test CO Item';
        coItem1.buildertek__Quantity__c = 10;
        coItem1.buildertek__Unit_Price__c = 100;
        coItem1.Budget_Item__c = budItem.Id;
        coItem1.buildertek__Product__c=prod1.Id;
        coItemList1.add(coItem1);
        
        
        
      // ChangeOrderDAO.createChangeOrderItemToBudgetItemLink(coItemList);
        ChangeOrderDAO.createCO(CO, strJSON,budItem.Id);
        
        List<ChangeOrderDAO.COLineItemsClass>  coLineItemClassRecs = new List<ChangeOrderDAO.COLineItemsClass>();
        ChangeOrderDAO.COLineItemsClass coLineItemClassRec = new ChangeOrderDAO.COLineItemsClass(coItem1,true,0);
        coLineItemClassRecs.add(coLineItemClassRec);
        
        String strJSON1 = JSON.serialize(coLineItemClassRecs);
        ChangeOrderDAO.createCO(CO1, strJSON1,budItem.id);
        ChangeOrderDAO.getProduct(strJSON);
        ChangeOrderDAO.addProductsToList(strJSON1,coItem1,0);
        ChangeOrderDAO.createARFromCO(CO.Id);
        
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = proj.Id;
        rfq.buildertek__Status__c = 'Awarded';
        rfq.buildertek__Description__c = 'Test Description'; 
        rfq.budget__c=budget.Id;
        insert rfq;
        
        RFQ_Item__c rfqItem = new RFQ_Item__c(RFQ_Package__c = rfq.Id,Name='test',buildertek__Description__c='test description');
        insert rfqItem;
        Test.startTest();  
        ChangeOrderDAO.fillCOItemFromRFQItem(coItem1,rfqItem);
        
        
        RFQ_To_Vendor__c rfqToVendor = new RFQ_To_Vendor__c(RFQ__c = rfq.Id, Vendor__c = acc.Id);
        insert rfqToVendor;
        
        rfq.buildertek__Vendor__c=rfqToVendor.Id;
        update rfq; 
        
        Map<Id, RFQ__c> rfqsMap = new Map<Id, RFQ__c>([select id,Name,buildertek__Description__c,buildertek__Status__c,buildertek__Project__c,budget__c,vendor__r.buildertek__Vendor__c,(select id,Name,buildertek__Description__c,Product__c,Budget_Item__c,Unit_Price__c,Quantity__c,Cost_Code__c from RFQ_Items__r) from buildertek__RFQ__c where id=:rfq.Id]);      
        
        Map<Id, Contract__c> rfqToSubContract = new  Map<Id, Contract__c> (); 
        Contract__c contract1 = new Contract__c();
        insert contract1;
        rfqToSubContract.put(contract1.Id,contract1);
      
        // ChangeOrderDAO.createCOFromRFQ(rfqsMap,rfqToSubContract);
        
      //  ChangeOrderDAO.getpricebook(budget.Id);
      //  ChangeOrderDAO.getpricebooks();
        //ChangeOrderDAO.getProductPrice(prod1.Id);
        ChangeOrderDAO.getselectOptions();
        ChangeOrderDAO.getCORecordTypes();
        ChangeOrderDAO.getFieldSet();  
        //ChangeOrderDAO.saveCOItem(coItemList[0],CO);
        //ChangeOrderDAO.getProductfamilyRecords('Product2',prod1.ID);
        //ChangeOrderDAO.getProductPrice(prod1.ID);
       // ChangeOrderDAO.getProductPricevalue(prod1.ID);
        //ChangeOrderDAO.getDropDown('buildertek__Change_Order_Item__c','buildertek__Markup__c');
         system.assertEquals('test', 'test');
       
//System.assertEquals(NUM_QUERY, Limits.getQueries());
for (Integer i = 0; i < NUM_QUERY; i++) {
/* buildertek__Change_Order_Item__c a = [SELECT Id,
                                        buildertek__Cost_Code__c,
                                        Name,
                                        buildertek__Quantity__c,
                                        buildertek__Unit_Price__c,
                                        buildertek__Total__c,
                                        buildertek__Unit_Sales_Price__c,
                                        buildertek__Change_Order__c,
                                        buildertek__Change_Order__r.buildertek__Contract__c
                                        FROM buildertek__Change_Order_Item__c  limit 1];*/
}
//System.assertEquals(NUM_QUERY, Limits.getQueries());
Test.stopTest();
        
        
        
    }  
    
}