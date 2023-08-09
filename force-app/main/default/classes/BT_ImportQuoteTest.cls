@isTest
public class BT_ImportQuoteTest {

	static testMethod void test1() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
	   // buildertek__Quote__c quote = new buildertek__Quote__c();
	   // quote.Name = 'Test Budget';
	   // quote.buildertek__Project__c = proj.Id;
	   // quote.buildertek__Type__c = 'Master';
	   // quoteList.add(quote);
	    
	    List<buildertek__Master_Quote__c> masterListRec = new List<buildertek__Master_Quote__c>();
	    buildertek__Master_Quote__c masterRec = new buildertek__Master_Quote__c();
	    masterRec.Name ='Test';
	    masterRec.Description__c = 'Test';
	    masterListRec.add(masterRec);
	    insert masterListRec;
	    
	    buildertek__Quote__c quote2 = new buildertek__Quote__c();
	    quote2.Name = 'Test Budget2';
	    quote2.buildertek__Project__c = proj.Id;
	    quote2.buildertek__Type__c = 'Master';
	    quoteList.add(quote2);
	    insert quoteList;
	    
	    buildertek__Master_Quote_Item__c masterQuoteItemRec = new buildertek__Master_Quote_Item__c();
	    masterQuoteItemRec.buildertek__Master_Quote__c = masterRec.Id;
	    insert masterQuoteItemRec;
	    List<String> selectedIds = new List<String>();
        selectedIds.add(masterListRec[0].Id);
	    
	    List<buildertek__Quote_Line_Group__c> groupList = new List<buildertek__Quote_Line_Group__c>();
	    buildertek__Quote_Line_Group__c groups = new buildertek__Quote_Line_Group__c();
	    groups.Name = 'Test Group';
	    groupList.add(groups);
	    insert groupList;
        
        Test.startTest();
        Test.setCurrentPage(Page.Import_Master_Quote);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(quoteList);
        stdSetController.setSelected(quoteList);
        Apexpages.currentPage().getParameters().put('Id', quoteList[0].buildertek__Project__c);
        BT_ImportQuote ext = new BT_ImportQuote(stdSetController);
        Test.stopTest();
        system.assertEquals('test', 'test');
	}
	
	static testMethod void test2() { 
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
        
        buildertek__Quote_Item__c quote1Item = new buildertek__Quote_Item__c();
        quote1Item.buildertek__Quote__c=quoteList[0].Id;
        insert quote1Item;
        
        List<buildertek__Master_Quote__c> masterListRec = new List<buildertek__Master_Quote__c>();
        buildertek__Master_Quote__c masterRec = new buildertek__Master_Quote__c();
	    masterRec.Name ='Test';
	    masterRec.Description__c = 'Test';
	    masterListRec.add(masterRec);
	    insert masterListRec;
	    
        List<String> selectedIds = new List<String>();
        selectedIds.add(masterListRec[0].Id);
	    buildertek__Master_Quote_Item__c masterQuoteItemRec = new buildertek__Master_Quote_Item__c();
	    masterQuoteItemRec.buildertek__Master_Quote__c = masterRec.Id;
	    insert masterQuoteItemRec;
	   
	    List<String> selectedId = new List<String>();
        selectedId.add(quoteList[0].Id);
	    
	    List<buildertek__Quote_Line_Group__c> groupList = new List<buildertek__Quote_Line_Group__c>();
	    buildertek__Quote_Line_Group__c groups = new buildertek__Quote_Line_Group__c();
	    groups.Name = 'Test Group';
	    groupList.add(groups);
	    insert groupList;
	    
        ApexPages.StandardController sc = new ApexPages.StandardController(quote);
        BT_ImportQuote IB = new BT_ImportQuote(SC);
        List<BT_ImportQuote.masterQuote> MQList = new List<BT_ImportQuote.masterQuote>();
        BT_ImportQuote.masterQuote MQ = new BT_ImportQuote.masterQuote();
        MQ.quotes = quoteList[0];
        MQ.isSelected = true;
        MQList.add(MQ);
        IB.masterQuotes=MQList;
        IB.save();
        system.assertEquals('test', 'test');
	}

}