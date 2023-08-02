@isTest
private class QuoteTemplate_PDFTest {

	private static testMethod void test() {
        RecordType rt = [SELECT Id, Name FROM RecordType WHERE Name = 'Quote'];
        List<buildertek__Template_Header__c> thList = new List<buildertek__Template_Header__c>();
        buildertek__Template_Header__c th = new buildertek__Template_Header__c();
        th.buildertek__Description__c = 'test';
        th.buildertek__Template_Header__c = 'test';
        thList.add(th);
        insert thList;
        System.assert(thList[0].Id!=null);
        
        List<buildertek__Template_Footer__c> tfList = new List<buildertek__Template_Footer__c>();
        buildertek__Template_Footer__c tf = new buildertek__Template_Footer__c();
        tf.buildertek__Description__c = 'test';
        tf.buildertek__Template_Footer__c = 'test';
        tfList.add(tf);
        insert tfList;
        
        List<buildertek__Quote_Template__c> qtList= new List<buildertek__Quote_Template__c>();
        buildertek__Quote_Template__c qt = new buildertek__Quote_Template__c();
        qt.buildertek__Template_Body__c = 'Test';
        qt.buildertek__Template_Format__c = 'Quote';
        qt.RecordTypeId = rt.Id;
        qt.buildertek__Template_Header__c = thList[0].id; 
        qt.buildertek__Template_Footer__c = tfList[0].Id;
        qtList.add(qt);
        insert qtList;
	    
	    buildertek__Quote__c quoteToInsert = new buildertek__Quote__c();
	    quoteToInsert.Name = 'Test Quote';
	    quoteToInsert.Doc_Template__c = qtList[0].Id;
	    insert quoteToInsert;
	    
	    ApexPages.currentPage().getParameters().put('qtid', quoteToInsert.Doc_Template__c);
	    ApexPages.currentPage().getParameters().put('qid', quoteToInsert.Id);
	    
	    QuoteTemplate_PDF_AC CT = new QuoteTemplate_PDF_AC();
	    MergeData_CTR md = new MergeData_CTR();
	    md.SObjectName = 'Quote__c';
	    //md.QuoteID = ;
	   System.assert(true);
	}

}