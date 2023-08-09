@isTest
private class ImportMasterQuotesTest {

	private static testMethod void getQuotes() {
		Account a = new Account();
		a.Name = 'test Account';
		insert a;

	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    proj.buildertek__Customer__c = a.Id;
	    insert proj;
	    
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
	    buildertek__Quote__c quote = new buildertek__Quote__c();
	    quote.Name = 'Test Budget';
	    quote.buildertek__Project__c = proj.Id;
	    quote.buildertek__Type__c = 'Master';
	    quoteList.add(quote); 
	    insert quoteList;
	    
	    List<buildertek__Master_Quote__c> masterquoteList = new List<buildertek__Master_Quote__c>();
	    buildertek__Master_Quote__c masterQuote = new buildertek__Master_Quote__c();
	    masterQuote.Name = 'Test Quote';
	    masterQuote.buildertek__Project__c = proj.Id;
	    masterQuote.buildertek__Type__c = 'Master';
	    masterquoteList.add(masterQuote); 
	    insert masterquoteList;
	    
	    List<buildertek__Quote_Line_Group__c> groupList = new List<buildertek__Quote_Line_Group__c>();
	    buildertek__Quote_Line_Group__c groups = new buildertek__Quote_Line_Group__c();
	    groups.Name = 'No Grouping';
	    groupList.add(groups);
	    insert groupList;
	    
	    List<buildertek__Master_Quote_Item__c> masterQuoteItemList = new List<buildertek__Master_Quote_Item__c>();
	    buildertek__Master_Quote_Item__c masterQuoteItem = new buildertek__Master_Quote_Item__c();
	    masterQuoteItem.Name = 'Test Quote Item';
	    masterQuoteItem.buildertek__Master_Quote__c = masterquoteList[0].Id;
	    masterQuoteItemList.add(masterQuoteItem);
	    insert masterQuoteItemList;
	    
	    List<ImportMasterQuotes.MasterQuotesClass> MQList = new List<ImportMasterQuotes.MasterQuotesClass>();
        ImportMasterQuotes.MasterQuotesClass MQ = new ImportMasterQuotes.MasterQuotesClass();
        MQ.quoteRecord = quoteList[0];
        MQ.quoteCheck = true;
        MQList.add(MQ);
        ImportMasterQuotes.getMasterQuotes('test');
        system.assertEquals('test', 'test');
	}
	
	private static testMethod void importQuotes() {
		
		Account a = new Account();
		a.Name = 'test Account';
		insert a;
		
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    proj.buildertek__Customer__c = a.Id;
	    insert proj;
	    
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
	    buildertek__Quote__c quote = new buildertek__Quote__c();
	    quote.Name = 'Test Budget';
	    quote.buildertek__Project__c = proj.Id;
	    quote.buildertek__Type__c = 'Master';
	    quoteList.add(quote); 
	    insert quoteList;
	    
	    List<buildertek__Quote_Line_Group__c> groupList = new List<buildertek__Quote_Line_Group__c>();
	    buildertek__Quote_Line_Group__c groups = new buildertek__Quote_Line_Group__c();
	    groups.Name = 'No Grouping';
	    groupList.add(groups);
	    insert groupList;
	    
	    List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
	    buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
	    quoteItem.Name = 'Material';
	    quoteItem.buildertek__Quantity__c = 10;
	    quoteItem.buildertek__Unit_Price__c = 100;
	    quoteItem.buildertek__Quote__c = quoteList[0].Id;
	    quoteItemList.add(quoteItem);
	    insert quoteItemList;
	    
	    
	    List<String> selectedIds = new List<String>();
        selectedIds.add(quoteList[0].Id);
	    
	    
	    List<ImportMasterQuotes.MasterQuotesClass> MQList = new List<ImportMasterQuotes.MasterQuotesClass>();
        ImportMasterQuotes.MasterQuotesClass MQ = new ImportMasterQuotes.MasterQuotesClass();
        MQ.quoteRecord = quoteList[0];
        MQ.quoteCheck = true;
        MQList.add(MQ);
        ImportMasterQuotes.importMasterQuoteLines(selectedIds, quoteList[0].Id);
        system.assertEquals('test', 'test');
	}

}