@isTest
private class ImportProductsOnRfqLinesTest {
    @TestSetup
    static void makeData(){
        Account acc= new Account();
        acc.Name='test';
        insert acc;

        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.Name = 'Testing';
        insert rfq;          
        
       

        buildertek__Category__c category = new buildertek__Category__c();
        category.Name  = 'Plumbing';
        insert category;

        Product2 product = new Product2();
        product.Name = 'Testing record , test class name Import Products On RFQ lines Test, Apex class Import Products On RFQ lines';
        product.Family  = 'Framing';
        product.buildertek__Vendor__c=acc.Id;
        product.buildertek__Category__c=category.Id;

        insert product;


        Id priceBookId = Test.getStandardPricebookId();


        PriceBookEntry pbEntry = new PriceBookEntry();
        pbEntry.product2Id = product.Id;
        pbEntry.UnitPrice = 10;
        pbEntry.PriceBook2Id = priceBookId;
        pbEntry.IsActive = true;
        insert pbEntry;
        
    }

    @isTest
    private static void testMethod1() {
        Id priceBookId = Test.getStandardPricebookId();

        buildertek__RFQ__c rfq=[Select Id , Name from  buildertek__RFQ__c LIMIT 1];
        Product2 product=[Select Id , Name From Product2 LIMIT 1];
        List<String> productIds= new List<String>();
        productIds.add(product.Id);
        Test.startTest();
        ImportProductsOnRfqLines.getTradeTypes(rfq.Id);
        ImportProductsOnRfqLines.getprodlist();
        ImportProductsOnRfqLines.productfamilyList('Product2' , priceBookId);
        ImportProductsOnRfqLines.pricebookList(rfq.Id);
        ImportProductsOnRfqLines.getProducts(rfq.Id ,'' , '' ,'' , '' ,'' ,'' ,'test');
        ImportProductsOnRfqLines.addProductToRfq(productIds, rfq.Id );
        ImportProductsOnRfqLines.addProductToPO(productIds, rfq.Id );


        Test.stopTest();

        
    }

    @isTest
    private static void testMethod2() {
        Id priceBookId = Test.getStandardPricebookId();
        buildertek__RFQ__c rfq=[Select Id , Name from  buildertek__RFQ__c LIMIT 1];
        Test.startTest();
        ImportProductsOnRfqLines.getProducts(rfq.Id ,'test' , 'test' ,'test' , 'test' ,'test' ,'tset' ,'test');
        Test.stopTest();

        
    }
   
}