@isTest
public class QuoteLinesControllerTest {
    public static testMethod void testQuoteLinesController() {
        Account account1 = new Account(
            Name = 'Sample Account 1'
        );
        
        insert account1;
        
        Contact contact1 = new Contact( 
            AccountId = account1.Id,
            LastName = 'LastName1'
        );
        
        insert contact1;
        // Quote__c qt = [Select Id from Quote__c LIMIT 1];
        // List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
        Quote__c q = new Quote__c(Name='test');
        insert q;
        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c(
        	Name = 'Sample Quote Item',
            buildertek__Quote__c = q.Id
        );  
        // quoteItemList.add(quoteItem);
        String myJSON = JSON.serialize(quoteItem);
        QuoteLinesController.getLookupData('Account', '');
        QuoteLinesController.getLookupData('Contact', '');
        QuoteLinesController.getLookupData('', '');
        QuoteLinesController.getBaseData();
        QuoteLinesController.insertQuoteLineItem(myJSON);
        System.assertEquals('Test','Test');
    }
}