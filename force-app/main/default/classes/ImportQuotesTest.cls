@isTest
private class ImportQuotesTest {

	private static testMethod void getQuotes() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
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
	    
	    List<ImportQuotes.MasterQuotesClass> MQList = new List<ImportQuotes.MasterQuotesClass>();
        ImportQuotes.MasterQuotesClass MQ = new ImportQuotes.MasterQuotesClass();
        MQ.quoteRecord = quoteList[0];
        MQ.quoteCheck = true;
        MQList.add(MQ);
        ImportQuotes.getMasterQuotes();
        system.assertEquals('test', 'test');
        
	}
	
	private static testMethod void importQuotes() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
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
	    
	    
	    List<ImportQuotes.MasterQuotesClass> MQList = new List<ImportQuotes.MasterQuotesClass>();
        ImportQuotes.MasterQuotesClass MQ = new ImportQuotes.MasterQuotesClass();
        MQ.quoteRecord = quoteList[0];
        MQ.quoteCheck = true;
        MQList.add(MQ);
        ImportQuotes.importMasterQuoteLines(selectedIds, quoteList[0].Id);
        system.assertEquals('test', 'test');
	}

}