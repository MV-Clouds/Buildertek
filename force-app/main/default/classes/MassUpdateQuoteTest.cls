@isTest
public class MassUpdateQuoteTest{
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;

        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Quote';
        quote.buildertek__Project__c = project.Id;
        insert quote;
        
        buildertek__Quote_Item__c quoteItems = new buildertek__Quote_Item__c();
        quoteItems.Name = 'Test Quote Item';
        quoteItems.buildertek__Quote__c = quote.Id;
        insert quoteItems;
    }
 
    @isTest
    static void testMethod1(){
        List<buildertek__Quote__c> quote = [Select Id
                                          FROM buildertek__Quote__c
                                          LIMIT 1];
        List<buildertek__Quote_Item__c> quoteItem = [Select Id
                                          FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =: quote[0].Id];
        
        
        
        MassUpdateQuote updaterecord = new MassUpdateQuote();

        MassUpdateQuote.getName(quote[0].Id);
        String fieldName='[]';
        MassUpdateQuote.getFieldSet();
        MassUpdateQuote.getRecords(quote[0].Id,fieldName,1,1);
        //MassUpdateQuote.updateRecords(quote[0].Id,JSON.serialize(quoteItem), fieldName,1,1);
        MassUpdateQuote.getDropDown('buildertek__Quote_Item__c','buildertek__UOM__c');
        MassUpdateQuote.deleteQuoteItem(quote[0].Id,quoteItem[0].Id, fieldName,1,1);
    }
    
    @isTest
    static void testMethod2(){
        MassUpdateQuote.getName('');
        MassUpdateQuote.getCount('');
        MassUpdateQuote.getRecords('','[]',1,1);
        //MassUpdateQuote.updateRecords('','','[]',1,1);
        MassUpdateQuote.getDropDown('buildertek__Quote_Item__c','buildertek__UOM__c');
        MassUpdateQuote.deleteQuoteItem('','','[]',1,1);
    }
}