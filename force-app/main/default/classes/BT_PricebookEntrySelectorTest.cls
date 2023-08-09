/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class BT_PricebookEntrySelectorTest {

    @testSetup static void Datasetup() {
        
        BT_TestDataFactory.createProductsAndPriceBookEntries();
        
    }

    private static testMethod void getPricebookEntryByPBId_test() {
        
        Id pBEId = [Select Id,Product2.Id,Product2.ProductCode,Product2.Family,Pricebook2Id,
                    Product2.Name, Product2.Description, 
                    UnitPrice from PricebookEntry where Product2.Name = 'Test Product 0' LIMIT 1][0].Pricebook2Id;
        system.debug('Id****'+pBEId);           
        List<PricebookEntry>searchEntriesList = BT_PriceBookEntrySelector.getPricebookEntryByPBId(pBEId, 'ASC');
                system.assertEquals(searchEntriesList.size(),10);
                    
    }
    private static testMethod void getPricebookEntryByCondition_test() {
        Id pBEId = [Select Id,Product2.Id,Product2.ProductCode,Product2.Family,Pricebook2Id,
                    Product2.Name, Product2.Description, 
                    UnitPrice from PricebookEntry where Product2.Name = 'Test Product 0' LIMIT 1][0].Pricebook2Id; 
        
        string condition = '';            
        List<PricebookEntry>searchEntriesList = BT_PriceBookEntrySelector.getPricebookEntryByCondition(pBEId,condition,'Order By Name');               
        system.assertEquals(searchEntriesList.size(),10);

    }
    private static testMethod void getPricebookEntryByPBANDProId_test() {
        List<Id>Product2Ids = new List<Id>();
        for(product2 pp : [Select Id from product2 where Name Like 'Test%']) {
            Product2Ids.add(pp.Id);    
        }
        Id pb2Id = Test.getStandardPricebookId();
        List<PricebookEntry>searchEntriesList = BT_PriceBookEntrySelector.getPricebookEntryByPBANDProId(pb2Id,Product2Ids,'Order By Name');               
        system.assertEquals(searchEntriesList.size(),10);

    }    
}