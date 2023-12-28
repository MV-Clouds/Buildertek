@IsTest
public with sharing class CreateQuoteFromBOMControllerTest {
    
    @IsTest
    static void testCreateQuoteWithBOMLines() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        buildertek__Project_Selection_Sheet_Takeoff__c BOM = new buildertek__Project_Selection_Sheet_Takeoff__c();
        BOM.buildertek__Name__c = 'Test BOM';
        BOM.buildertek__Project__c = proj.Id;
        insert BOM;

        product2 prod1 = new product2();
        prod1.Name = 'Product 1';
        insert prod1;

        product2 prod2 = new product2();
        prod2.Name = 'Product 2';
        insert prod2;

        Account vendor1 = new Account();
        vendor1.Name = 'Test 1';
        insert vendor1;
        
        Account vendor2 = new Account();
        vendor2.Name = 'Test 1';
        insert vendor2;

        buildertek__Build_Phase__c phase1 = new buildertek__Build_Phase__c();
        phase1.Name = 'Phase 1';
        insert phase1;

        buildertek__Build_Phase__c phase2 = new buildertek__Build_Phase__c();
        phase2.Name = 'Phase 2';
        insert phase2;

        buildertek__Quote_Line_Group__c quoteLineGroup = new buildertek__Quote_Line_Group__c();
        quoteLineGroup.Name = 'No Grouping';
        insert quoteLineGroup;

        buildertek__Select_Sheet__c BOMLine1 = new buildertek__Select_Sheet__c();
        BOMLine1.Name = 'BOM Line 1';
        BOMLine1.buildertek__Product__c = prod1.Id;
        BOMLine1.buildertek__Quantity__c = 1;
        BOMLine1.buildertek__BL_MARKUP__c = 10;
        BOMLine1.buildertek__BL_UNIT_COST__c = 100;
        BOMLine1.buildertek__Vendor__c = vendor1.Id;
        BOMLine1.buildertek__Build_Phase__c = phase1.Id;
        BOMLine1.buildertek__Selection_Sheet_Takeoff__c = BOM.Id;
        insert BOMLine1;

        buildertek__Select_Sheet__c BOMLine2 = new buildertek__Select_Sheet__c();
        BOMLine2.Name = 'BOM Line 2';
        BOMLine2.buildertek__Product__c = prod2.Id;
        BOMLine2.buildertek__Quantity__c = 2;
        BOMLine2.buildertek__BL_MARKUP__c = 20;
        BOMLine2.buildertek__BL_UNIT_COST__c = 200;
        BOMLine2.buildertek__Vendor__c = vendor2.Id;
        BOMLine2.buildertek__Build_Phase__c = phase2.Id;
        BOMLine2.buildertek__Selection_Sheet_Takeoff__c = BOM.Id;
        insert BOMLine2;

        Test.startTest();
        String quoteId = CreateQuoteFromBOMController.createQuote(BOM.Id);

        Test.stopTest();

        buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Bill_of_Material__c, buildertek__Project__c FROM buildertek__Quote__c WHERE Id = :quoteId];
        System.debug('quoteId test method: ' + quoteId);
        System.assertEquals(BOM.Id, quote.buildertek__Bill_of_Material__c);
        System.assertEquals(BOM.buildertek__Name__c, quote.Name);
        System.assertEquals(BOM.buildertek__Project__c, quote.buildertek__Project__c);

        List<buildertek__Quote_Item__c> quoteLineItems = [SELECT Id, Name, buildertek__Quote__c, buildertek__Product__c, buildertek__Quantity__c, buildertek__Markup__c, buildertek__Unit_Cost__c, buildertek__Vendor__c, buildertek__Build_Phase__c, buildertek__Grouping__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :quoteId];
        System.assertEquals(2, quoteLineItems.size());
    }

    @IsTest
    static void testCreateQuoteWithoutBOMLines() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;

        buildertek__Project_Selection_Sheet_Takeoff__c BOM = new buildertek__Project_Selection_Sheet_Takeoff__c();
        BOM.buildertek__Name__c = 'Test BOM';
        BOM.buildertek__Project__c = proj.Id;
        insert BOM;

        Test.startTest();
        String quoteId = CreateQuoteFromBOMController.createQuote(BOM.Id);
        Test.stopTest();

        buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Bill_of_Material__c, buildertek__Project__c FROM buildertek__Quote__c WHERE Id = :quoteId];
        System.assertEquals(BOM.Id, quote.buildertek__Bill_of_Material__c);
        System.assertEquals(BOM.buildertek__Name__c, quote.Name);
        System.assertEquals(BOM.buildertek__Project__c, quote.buildertek__Project__c);

        List<buildertek__Quote_Item__c> quoteLineItems = [SELECT Id FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c = :quoteId];
        System.assertEquals(0, quoteLineItems.size());
    }
}

