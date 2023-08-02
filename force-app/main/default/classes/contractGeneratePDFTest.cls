@isTest
private class contractGeneratePDFTest {

	private static testMethod void test() {
	    List<Contact> conList = new List<Contact>();
	    Contact con = new Contact();
	    con.LastName = 'Test';
	    con.Email = 'test@test.com';
	    conList.add(con);
	    insert conList;
	    
	    buildertek__Template_Header__c th = new buildertek__Template_Header__c();
        th.buildertek__Description__c = 'test';
        th.buildertek__Template_Header__c = 'test';
        insert th;
        buildertek__Template_Footer__c tf = new buildertek__Template_Footer__c();
        tf.buildertek__Description__c = 'test';
        tf.buildertek__Template_Footer__c = 'test';
        insert tf;
        buildertek__Quote_Template__c qt = new buildertek__Quote_Template__c();
        qt.buildertek__Template_Body__c = 'Test';
        qt.buildertek__Template_Format__c = 'Quote';
        qt.buildertek__Template_Header__c = th.id;
        qt.buildertek__Template_Footer__c = tf.Id;
        insert qt;
	    
	    buildertek__Contract__c contractToInsert = new buildertek__Contract__c();
	    contractToInsert.Name = 'Test Contract';
	    insert contractToInsert;
	    
	    Attachment att = new Attachment();
	    att.Name = 'Test Name';
	    att.ParentId = contractToInsert.Id;
	    att.Body = blob.valueOf('Test Body');
	    insert att;
	    
        ApexPages.StandardController sc = new ApexPages.StandardController(contractToInsert);
        contractGeneratePDF pdf = new contractGeneratePDF(sc);
        pdf.userValue();
        pdf.contactValue();
        pdf.selectedid = qt.Id;
        pdf.CreatePDF();
        pdf.SendPDF();
        System.assert(true);
	}

}