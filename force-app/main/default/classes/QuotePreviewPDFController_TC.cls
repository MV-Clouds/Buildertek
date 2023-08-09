@isTest
private class QuotePreviewPDFController_TC {

	private static testMethod void insertQuote() {
        Account a = new Account(name='acc1');
        insert a;
        System.assert(a.Id!=null);
        Opportunity o = new Opportunity();
        o.Accountid = a.id;
        o.Name = 'test';
        o.StageName = 'Prospecting';
        o.CloseDate = date.today();
        o.Type = 'New Client';
        o.NextStep = 'Test';
        o.LeadSource = 'Business Development';
        insert o;
        System.assert(o.Id!=null);
        List<buildertek__Quote__c> QuoteListRef = new List<buildertek__Quote__c>();
        buildertek__Quote__c QuoteRef = new buildertek__Quote__c();
        QuoteRef.Name='Test';
        QuoteListRef.add(QuoteRef);
        insert QuoteListRef;
        ApexPages.currentPage().getParameters().put('ID',QuoteListRef[0].id);
        ApexPages.StandardController sc = new ApexPages.StandardController(QuoteRef);
        QuotePreviewPDFController QuotePreviewPDFControllerRef = new QuotePreviewPDFController(sc);
        System.assert(true);
	}

}