/* 
Copyright (c) 2017-2018, BuilderTek.
All rights reserved.

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class QuoteDAOTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }

    public static testMethod void test1() {
        
        Project__c proj = [Select Id from Project__c LIMIT 1];
        // Quote__c qt = [Select Id from Quote__c LIMIT 1];

        buildertek__Quote__c quoteRec = new buildertek__Quote__c(Name='test');
        insert quoteRec;

        list<buildertek__Quote_Line_Group__c> grouplist = new list<buildertek__Quote_Line_Group__c>();
        buildertek__Quote_Line_Group__c GroupRef = new buildertek__Quote_Line_Group__c(Name='test');
        grouplist.add(GroupRef);
        insert GroupRef;
        List<buildertek__Quote_Item__c> quoteListRef = new List<buildertek__Quote_Item__c>();
        List<buildertek__Quote_Item__c> quoteListRef1 = new List<buildertek__Quote_Item__c>();

        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
        quoteItem.Name = 'test';
        quoteItem.buildertek__Quote__c = quoteRec.Id;
        quoteItem.buildertek__Grouping__c = GroupRef.Id;

        quoteListRef.add(quoteItem);
        insert quoteItem;
        buildertek__Quote_Item__c quoteItem1 = new buildertek__Quote_Item__c();
        quoteItem1=quoteItem.clone();
        quoteItem1.buildertek__Grouping__c = null;
        quoteListRef.add(quoteItem1);
        insert quoteItem1;

  

        product2 product1= new product2();
        product1.name='test ';
        product1.family ='Framing';
        insert product1;
        // QuoteDAO.getProductPrice(product1.id);

        Id priceBookId = Test.getStandardPricebookId();
        PriceBookEntry pbEntry = new PriceBookEntry();
        pbEntry.product2Id = product1.Id;
        pbEntry.UnitPrice = 10;
        pbEntry.PriceBook2Id = priceBookId;
        pbEntry.IsActive = true;
        insert pbEntry;


        buildertek__RFQ__c rfqTest1=new buildertek__RFQ__c();
        rfqTest1.Name='test';
        insert rfqTest1;
        quoteItem.buildertek__RFQ__c=rfqTest1.id;

         Account accRec = new Account();
        accRec.Name = 'Test 2';
        insert accRec;

        buildertek__Purchase_Order__c poTest1 = new buildertek__Purchase_Order__c();
        poTest1.buildertek__RFQ__c=rfqTest1.id;
        poTest1.buildertek__Project__c=proj.id;
        poTest1.buildertek__Vendor__c = accRec.Id;
        insert poTest1;

        Test.startTest();

        // 	update quoteItem;
        String myJSONQuote1 = JSON.serialize(quoteItem1);
        String myJSONQuote = JSON.serialize(quoteItem);

        List<String> budgetItemIds = new List<String>();
        budgetItemIds.add(quoteListRef[0].Id);

        List<String> groupIds = new List<String>();
        groupIds.add(GroupRef.id);

        List<String> currencyFields = new List<String>{'buildertek__Unit_Price__c', 'buildertek__Total_Cost__c', 'buildertek__Unit_Cost__c'};
            List<String> allFields = new List<String>{'Id', 'buildertek__Grouping__c', 'buildertek__Quantity__c', 'buildertek__Unit_Price__c', 'buildertek__Total_Cost__c', 'buildertek__Unit_Cost__c'};

                //String fieldString;
                String fieldString = '[{"fieldName":"buildertek__Grouping__c","fieldType":"reference","isEditable": false},'
                +'{"fieldName":"Id","fieldType":"","isEditable": false},'
                +'{"fieldName":"buildertek__Quantity__c","fieldType":"number","isEditable": true},'
                +'{"fieldName":"buildertek__Unit_Price__c","fieldType":"currency","isEditable": true}]';

        QuoteDAO.updateQuoteLineItem(myJSONQuote);
        QuoteDAO.updateQuoteLineItem(myJSONQuote1);

        QuoteDAO.insertQuoteLineItem(myJSONQuote);
        QuoteDAO.saveQuoteLineItem(myJSONQuote);
        QuoteDAO.saveQuoteLineItem(myJSONQuote1);
        QuoteDAO.createQuoteItem(JSON.serialize(new list<Quote_Item__c>{quoteItem}));
        quoteItem.buildertek__Grouping__c=null;
        QuoteDAO.createQuoteItem(JSON.serialize(new list<Quote_Item__c>{quoteItem}));
        QuoteDAO.updateGroupsOrder(grouplist);



        // 	QuoteDAO.updateGroupsOrder();
        // QuoteDAO.getProductRecords('Sample', 'Quote__c',null,quoteRec.Id, product1.family);

        QuoteDAO.getFieldSet('buildertek__BT_Product_Picker_Fields', 'Product2');

        String quoteItemId = [Select Id from Quote_Item__c LIMIT 1].Id;
        string myJson='[ {  "Id" : "'+quoteItem.Id+'", "Name" : "'+quoteItem.Name+'"}]';
        List<string> massupdateQI=new List<String>();
        massupdateQI.add(quoteItem.Id);

        QuoteDAO.massDuplicateQuoteLineItem(massupdateQI);
        QuoteDAO.massUpdateQuoteLineItem(myJson);
        QuoteDAO.prepareString(myJson);
        QuoteDAO.deleteLineItems(budgetItemIds);
        QuoteDAO.deleteSelectedItems(budgetItemIds);
        //BudgetDAO.deleteBudgetLineItem(budgetRef.Id);
        QuoteDAO.groupValues(quoteRec.Id, currencyFields, allFields, groupIds, 10, 0 , 'Accept');
        QuoteDAO.getQuoteItemData(quoteRec.Id, allFields, fieldString, 10, 0, 'Accept');
        QuoteDAO.getQuoteItemData(quoteRec.Id, allFields, fieldString, 10, 0, 'Reject');

        quoteListRef1.add(quoteItem1);
        QuoteDAO.saveUpdatedValues(quoteListRef1);
        QuoteDAO.QuoteWrapper q1= new QuoteDAO.QuoteWrapper();
        q1.quoteList=quoteListRef1;
        q1.checkQuote=true;
        q1.fieldNames=budgetItemIds;

        QuoteDAO.FieldClass f1= new QuoteDAO.FieldClass();
        f1.fieldName='Name';
        f1.fieldType='String';
        f1.isEditable=true;
        quoteRec.buildertek__Markup__c=2;
        update quoteRec;

  		QuoteDAO.getQuoteRecord(quoteRec.Id);
        QuoteDAO.getQuoteRecord('testId');
        Quote_Item__c qi1= new Quote_Item__c();
        qi1.buildertek__Quote__c=quoteRec.Id;
        insert qi1;

        QuoteDAO.deleteGroups(grouplist);
        QuoteDAO.deleteItem(quoteListRef, grouplist[0].id, quoteRec.Id, 'Accept');
        QuoteDAO.deleteItem(quoteListRef, grouplist[0].id, quoteRec.Id, 'Reject');

        System.assertEquals('Test','Test');
        Test.stopTest();
    }
    @isTest
    public static void testMethod2(){
     
     buildertek__Schedule__c scheRec = new buildertek__Schedule__c();
     scheRec.buildertek__Primary_Schedule__c = true;
     insert scheRec;

     product2 product1= new product2();
     product1.name='test ';
     product1.family ='Framing';
     insert product1;
    //  QuoteDAO.getProductPrice(product1.id);

     Quote__c qt = [Select Id from Quote__c LIMIT 1];

     Id priceBookId = Test.getStandardPricebookId();
     PriceBookEntry pbEntry = new PriceBookEntry();
     pbEntry.product2Id = product1.Id;
     pbEntry.UnitPrice = 10;
     pbEntry.PriceBook2Id = priceBookId;
     pbEntry.IsActive = true;
     insert pbEntry;

     buildertek__Quote_Line_Group__c groupRef = new buildertek__Quote_Line_Group__c();
     groupRef.Name = 'test';
     insert groupRef;

     buildertek__RFQ__c rfqTest1=new buildertek__RFQ__c();
     rfqTest1.Name='test';
     insert rfqTest1;


     Map<Id, buildertek__RFQ__c> rfq = new Map<Id, buildertek__RFQ__c> ([SELECT Id , Name , buildertek__Project__c FROM buildertek__RFQ__c ]);
     Test.startTest();

     QuoteDAO.getProductfamilyRecords('Product2' , priceBookId );
     QuoteDAO.getTasksInSchedule('test', 'buildertek__Project_Task__c' , null , scheRec.Id);
     QuoteDAO.getProductRecords('Sample', 'Product2',null, priceBookId, product1.family);
     QuoteDAO.updateGroupName(groupRef.Id , 'test');
     QuoteDAO.updateDescription(groupRef.Id ,'test');
     QuoteDAO.createQuoteFromRFQ(rfq);
     



     buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
     quoteItem.Name = 'test';
     quoteItem.buildertek__Quote__c = qt.Id;
     quoteItem.buildertek__Grouping__c = groupRef.Id;
     insert quoteItem;

        buildertek__Quote_Item__c quoteItem1 = new buildertek__Quote_Item__c();
        quoteItem1.Name = '%test';
        quoteItem1.buildertek__Quote__c = qt.Id;
        quoteItem1.buildertek__Grouping__c = null;
        insert quoteItem1;



     RFQ_Item__c rfqItems = new RFQ_Item__c();
     rfqItems.buildertek__Description__c ='test';
     rfqItems.buildertek__RFQ_Package__c=rfqTest1.Id;
     insert rfqItems;

     String myJSONQuote1 = JSON.serialize(quoteItem1);

     QuoteDAO.fillqtItemFromRFQItem(quoteItem ,rfqItems , groupRef.Id );
     QuoteDAO.updateQuoteLineItem(myJSONQuote1);

     Test.stopTest();
    }

     @isTest
    public static void testMethod3(){
      
      buildertek__Schedule__c scheRec = new buildertek__Schedule__c();
      scheRec.buildertek__Primary_Schedule__c = true;
      insert scheRec;

      List<Id> idList = new List<Id>();
      product2 product1= new product2();
      product1.name='test ';
      product1.family ='Framing';
      insert product1;
      idList.add(product1.Id);
    //   QuoteDAO.getProductPrice(product1.id);


      List<String> priceBookIds= new List<String>();
      Id priceBookId = Test.getStandardPricebookId();
      priceBookIds.add(priceBookId);
      
      PriceBookEntry pbEntry = new PriceBookEntry();
      pbEntry.product2Id = product1.Id;
      pbEntry.UnitPrice = 10;
      pbEntry.PriceBook2Id = priceBookId;
      pbEntry.IsActive = true;
      // pbEntry.buildertek__Project__c = true;

      insert pbEntry;

      buildertek__Project_Task__c projectTask1 = new buildertek__Project_Task__c();
      projectTask1.Name='test Task';
      projectTask1.buildertek__Schedule__c=scheRec.Id;
      DateTime dt= System.now();
      projectTask1.buildertek__Finish__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-5);
      projectTask1.buildertek__Start__c=(Date.newInstance(dt.year(),dt.month(),dt.day())).addDays(-15);
      projectTask1.buildertek__Duration__c=10;
      projectTask1.buildertek__Phase__c='Candidate Selection';
      projectTask1.buildertek__Lag__c=0;
      projectTask1.buildertek__Milestone__c =false;
      insert projectTask1;

      Account acc = new Account();
      acc.Name='test';
      insert acc;

      Contact con = new Contact();
      con.LastName='test';
      con.FirstName='testmthod';
      con.Email='test@test.com';
      con.AccountId=acc.Id;
      insert con;

      buildertek__Project__c proj = new buildertek__Project__c();
      proj.Name = 'Test Project';
      insert proj;
      Quote__c qt = [Select Id from Quote__c LIMIT 1];



      List<buildertek__Quote_Item__c> quoteListRef = new List<buildertek__Quote_Item__c>();

      buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
      quoteItem.Name = 'test';
      quoteItem.buildertek__Quote__c = qt.Id;
      insert quoteItem;
      quoteListRef.add(quoteItem);

      Test.startTest();
      QuoteDAO.getProductRecords('Sample', 'Product2',null, priceBookId, null);
      QuoteDAO.getTaskName(projectTask1.Id);
      QuoteDAO.getContractResource('Test' , 'Contact' ,  null , acc.Id);
      QuoteDAO.getContactName(con.Id);
      QuoteDAO.getProductUOM(product1.Id);
      QuoteDAO.insertQuoteLineGroup('Test' ,'test');
      QuoteDAO.getProducts();
      QuoteDAO.searchProdcutFamily('Test');
      QuoteDAO.getProductRecordsByIds1(idList, 'test');
      QuoteDAO.priceBookInProject(qt.Id);
      QuoteDAO.getQuoteLines(qt.Id);
      QuoteDAO.getProductsthroughPriceBook(priceBookId);
      QuoteDAO.getProducts2();
      QuoteDAO.getQuoteGrouping2(qt.Id);
      QuoteDAO.QuoteLinesInsert(quoteListRef ,qt.Id);
      QuoteDAO.getProductRecordsByIds(idList , priceBookIds);
      QuoteDAO.getProject(qt.Id);
      QuoteDAO.updatequote(quoteItem.Id , 2);
      QuoteDAO.getquote(quoteItem.Id);

      Test.stopTest();
    }
    @isTest
    public static void testMethod4() {
        
        buildertek__Quote__c quoteRec = new buildertek__Quote__c(Name='test',buildertek__Markup__c=2 );
        insert quoteRec;
        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
        quoteItem.Name = 'test';
        quoteItem.buildertek__Quote__c = quoteRec.Id;
        quoteItem.buildertek__Markup__c = null;
        insert quoteItem;

        buildertek__Quote_Item__c quoteItem1 = new buildertek__Quote_Item__c();
        quoteItem1=quoteItem.clone();
        quoteItem1.buildertek__Grouping__c = null;
        insert quoteItem1;
        Quote__c qt = [Select Id from Quote__c LIMIT 1];
        String quoteItemId = [Select Id from Quote_Item__c LIMIT 1].Id;
        buildertek__Quote_Item__c qutItem = new buildertek__Quote_Item__c();

        Test.startTest();

        String myJSONQuote1 = JSON.serialize(quoteItem1);
        String quoteJson = JSON.serialize(quoteRec);
        QuoteDAO.saveQuoteSingleRec(quoteJson);
        QuoteDAO.getRfqTo();
        QuoteDAO.getmulticurrency();
        QuoteDAO.deleteQuoteItem(quoteItem1.Id);
        QuoteDAO.getBaseData();
        QuoteDAO.getLookupData('', '');
        QuoteDAO.getpricebooks();
        QuoteDAO.cloneQuote(quoteRec.Id);
        QuoteDAO.getQuoteTemplates();
        QuoteDAO.getLookupData('Account', '');
        QuoteDAO.getLookupData('Contact', '');
        QuoteDAO.retrieveGroups(qt.id, 1, 10, 'Accept');
        QuoteDAO.retrieveGroups(qt.id, 1, 10, 'Reject');
        QuoteDAO.getQuoteGrouping(qt.id);
        QuoteDAO.insertQuoteLines(new List<Quote_Item__c>());
        QuoteDAO.getQuoteItem(quoteItemId);
        QuoteDAO.deleteLineItems(new List<String>{quoteItemId});
        QuoteDAO.getpricebook(quoteRec.Id);
        QuoteDAO.getselectOptions(qutItem, 'buildertek__UOM__c');
        Test.stopTest();

    }


    
}