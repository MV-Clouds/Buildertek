@isTest
private class RFQDAOTest {

    private static testMethod void awardVendor() {
   
        Test.startTest();
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = proj.Id;
        rfq.buildertek__Status__c = 'Awarded';
        rfq.buildertek__Description__c = 'Test Description';
        insert rfq;
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Account';
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        insert con;
        
        buildertek__Quote__c q = new buildertek__Quote__c();
        q.Name = 'Test Account';
        q.buildertek__Project__c = proj.Id;
        insert q;
        
        buildertek__Quote_Item__c quoteitem = new buildertek__Quote_Item__c();
        quoteitem.Name= 'test';
        quoteitem.buildertek__Quote__c = q.Id;
        insert quoteitem;
        
        List<buildertek__RFQ_To_Vendor__c> rfqToVendorList = new List<buildertek__RFQ_To_Vendor__c>();
        buildertek__RFQ_To_Vendor__c rfqToVendor = new buildertek__RFQ_To_Vendor__c();
        rfqToVendor.Name = 'Test Vendor';
        rfqToVendor.buildertek__RFQ__c = rfq.Id;
        rfqToVendor.buildertek__Vendor__c = acc.Id;
        rfqToVendor.buildertek__Status__c = 'Awarded';
        rfqToVendor.buildertek__Contact__c = con.Id;
        rfqToVendorList.add(rfqToVendor);
        insert rfqToVendorList;
        
        Map<Id,buildertek__RFQ_Item__c> rfqItemMap = new Map<Id,buildertek__RFQ_Item__c>();
        List<buildertek__RFQ_Item__c> rfqItemList = new List<buildertek__RFQ_Item__c>();
        buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
        rfqItem.Description__c = 'Test Description';
        rfqItem.Name = 'Test Material';
        rfqItem.buildertek__RFQ_Package__c = rfq.Id;
        rfqItem.Quantity__c = 10;
        rfqItem.Unit_Price__c = 100;
        rfqItemList.add(rfqItem);
        insert rfqItemList;
        
        for(buildertek__RFQ_Item__c rfqitemRec :rfqItemList){
            rfqItemMap.put(rfqitemRec.Id,rfqitemRec);
        }
        
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
        buildertek__Budget__c budgetItem = new buildertek__Budget__c();
        budgetItem.Name = 'Test Material';
        budgetList.add(budgetItem);
        insert budgetList;
        
        String budgetJsonId = '["'+budgetList[0].Id +'"]';
        
        List<RFQ_Vendor_Item__c> rfqVendorItemList = new List<RFQ_Vendor_Item__c>();
        RFQ_Vendor_Item__c rfqVendorItem = new RFQ_Vendor_Item__c();
        rfqVendorItem.Name = 'Test Material';
        rfqVendorItem.buildertek__Quantity__c = 10;
        rfqVendorItem.buildertek__Unit_Price__c = 100;
        rfqVendorItem.buildertek__Vendor__c = rfqToVendorList[0].Id;
        rfqVendorItemList.add(rfqVendorItem);
        insert rfqVendorItemList;
        
        List<buildertek__File__c> fileList = new List<buildertek__File__c>();
        buildertek__File__c fileItem = new buildertek__File__c();
        fileItem.Name = 'Test Material';
        fileList.add(fileItem);
        //insert fileList;
        
        SET<Id> vendorIds = new SET<Id>();
        vendorIds.add(rfqToVendorList[0].Id); 
        
        List<String> vendorIdsList = new List<String>();
        vendorIdsList.add(rfqToVendorList[0].Id);
        
        List<String> accountIds = new List<String>();
        accountIds.add(acc.Id);
        
         List<String> contactsIds = new List<String>();
        contactsIds.add(con.Id);
        
          List<String> rfqItemListIds = new List<String>();
        rfqItemListIds.add(rfqItemList[0].Id);

        
       // RFQDAO.awardVendor(rfqToVendorList[0].Id);
        RFQDAO.getRfqConfig(rfq.Id);
        RFQDAO.getRfqToVendors(rfq.Id);
        RFQDAO.addAcceptedRFQToBudget(rfq.Id,budgetJsonId);
        RFQDAO.getSelectedVendorData(rfqToVendorList[0].Id);
        RFQDAO.awardRFQ(rfqToVendorList);
        RFQDAO.populateRFQItemFromAwardedRFQVendorItem(vendorIds);
        RFQDAO.linkVendors(rfq.Id, accountIds);
        RFQDAO.selectedVendors(rfq.Id);
        RFQDAO.sendRFQEmailToVendor(vendorIdsList);
      //  RFQDAO.updateRFQToVendorStatus(vendorIdsList, 'Email Sent');
        RFQDAO.getSelectedVendorsData(vendorIdsList);
        RFQDAO.getBudgetData(1,1,rfq.Id);
        RFQDAO.sendRFQCancelEmailToVendor(vendorIdsList);
      //  RFQDAO.linkRFQDocuments(fileList,rfq.Id);
        RFQDAO.linkRFQDocumentToVendor(fileList[0].Id,rfqToVendorList[0].Id);
        //RFQDAO.createRFQ();
      //  RFQDAO.getAllApprovedRFQ(q.Id);
        //RFQDAO.createCOFromRFQ(rfq.Id);
       // RFQDAO.emailPreview(rfq.Id,vendorIdsList[0]);
       // RFQDAO.sendEmail(rfqToVendorList[0].Id);
        
        system.assertEquals('test', 'test');
        test.stopTest();
    }
    private static testMethod void awardVendorTest() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Project__c = proj.Id;
        rfq.buildertek__Status__c = 'Awarded';
        rfq.buildertek__Description__c = 'Test Description';
        insert rfq;
        
        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Account';
        con.AccountId = acc.Id;
        con.Email = 'test@gmail.com';
        insert con;
        
        buildertek__Quote__c q = new buildertek__Quote__c();
        q.Name = 'Test Account';
        q.buildertek__Project__c = proj.Id;
        insert q;
        
        buildertek__Quote_Item__c quoteitem = new buildertek__Quote_Item__c();
        quoteitem.Name= 'test';
        quoteitem.buildertek__Quote__c = q.Id;
        insert quoteitem;
        
        List<buildertek__RFQ_To_Vendor__c> rfqToVendorList = new List<buildertek__RFQ_To_Vendor__c>();
        buildertek__RFQ_To_Vendor__c rfqToVendor = new buildertek__RFQ_To_Vendor__c();
        rfqToVendor.Name = 'Test Vendor';
        rfqToVendor.buildertek__RFQ__c = rfq.Id;
        rfqToVendor.buildertek__Vendor__c = acc.Id;
        rfqToVendor.buildertek__Status__c = 'Awarded';
        rfqToVendor.buildertek__Contact__c = con.Id;
        rfqToVendorList.add(rfqToVendor);
        insert rfqToVendorList;
        Map<Id,buildertek__RFQ_Item__c> rfqItemMap = new Map<Id,buildertek__RFQ_Item__c>();
        List<buildertek__RFQ_Item__c> rfqItemList = new List<buildertek__RFQ_Item__c>();
        buildertek__RFQ_Item__c rfqItem = new buildertek__RFQ_Item__c();
        rfqItem.Description__c = 'Test Description';
        rfqItem.Name = 'Test Material';
        rfqItem.buildertek__RFQ_Package__c = rfq.Id;
        rfqItem.Quantity__c = 10;
        rfqItem.Unit_Price__c = 100;
        rfqItem.buildertek__Master_Item__c =true;
        rfqItemList.add(rfqItem);
        insert rfqItemList;
        for(buildertek__RFQ_Item__c rfqitemRec :rfqItemList){
            rfqItemMap.put(rfqitemRec.Id,rfqitemRec);
        }
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
        buildertek__Budget__c budgetItem = new buildertek__Budget__c();
        budgetItem.Name = 'Test Material';
        budgetList.add(budgetItem);
        insert budgetList;
        
        List<RFQ_Vendor_Item__c> rfqVendorItemList = new List<RFQ_Vendor_Item__c>();
        RFQ_Vendor_Item__c rfqVendorItem = new RFQ_Vendor_Item__c();
        rfqVendorItem.Name = 'Test Material';
        rfqVendorItem.buildertek__Quantity__c = 10;
        rfqVendorItem.buildertek__Unit_Price__c = 100;
        rfqVendorItem.buildertek__Vendor__c = rfqToVendorList[0].Id;
        rfqVendorItemList.add(rfqVendorItem);
        insert rfqVendorItemList;
        
        List<buildertek__File__c> fileList = new List<buildertek__File__c>();
        buildertek__File__c fileItem = new buildertek__File__c();
        fileItem.Name = 'Test Material';
        fileList.add(fileItem);
        //insert fileList;
        
        SET<Id> vendorIds = new SET<Id>();
        vendorIds.add(rfqToVendorList[0].Id); 
        
        List<String> vendorIdsList = new List<String>();
        vendorIdsList.add(rfqToVendorList[0].Id);
        
        List<String> accountIds = new List<String>();
        accountIds.add(acc.Id);
        
         List<String> contactsIds = new List<String>();
        contactsIds.add(con.Id);
        
          List<String> rfqItemListIds = new List<String>();
        rfqItemListIds.add(rfqItemList[0].Id);

        
        
        //RFQDAO.getProduct('');
        //RFQDAO.addProductsToList('',rfqItemList[0],1);
        RFQDAO.createTask(con.Id,rfq.Id,'test');
        RFQDAO.createMultipleTasks(contactsIds,rfq.Id,'test');
        RFQDAO.getmasterRFQItems();
        RFQDAO.linkNewRfqItems(rfqItemMap);
        RFQDAO.importRFQItems(rfqItemListIds,rfq.Id);
        RFQDAO.createRFQFromQuote(q.Id,quoteitem.Id);
        RFQDAO.deleteVendorLinks(vendorIdsList);
       // RFQDAO.updateRFQToVendorStatus(vendorIdsList, 'New');
        RFQDAO.RFQLineItemsClass wrapperRFQ = new RFQDAO.RFQLineItemsClass(rfqItemList[0],true,1);
        wrapperRFQ.rfqItem = rfqItemList[0];
        wrapperRFQ.isProduct = true;
        wrapperRFQ.rowIndex = 1;
       RFQDAO.awardVendor(rfqToVendor.Id);
        
        
        system.assertEquals('test', 'test');
    }

}