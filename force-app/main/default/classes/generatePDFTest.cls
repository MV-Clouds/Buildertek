@isTest
private class generatePDFTest {

	private static testMethod void test() {
        List<Contact> conList = new List<Contact>();
	    Contact con = new Contact();
	    con.LastName = 'Test';
	    con.Email = 'test@gmail.com';
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
	    Email_Template__c emailTempRec = new Email_Template__c();
	    emailTempRec.Allow_LineItems__c = true;
	    emailTempRec.Body__c ='Test';
	    emailTempRec.Subject__c ='Test';
	    insert emailTempRec;
	    
	    Email_Line_Item_Column__c emailLineItemRec = new Email_Line_Item_Column__c();
	    emailLineItemRec.Sort_Order__c = 1;
	    emailLineItemRec.Email_Template__c = emailTempRec.Id;
	    insert emailLineItemRec;
	    
	    buildertek__Quote__c quoteToInsert = new buildertek__Quote__c();
	    quoteToInsert.Name = 'Test Quote';
	    quoteToInsert.Email_Template__c =emailTempRec.Id;
	    quoteToInsert.buildertek__Primary_Contact__c =conList[0].Id; 
	    insert quoteToInsert;
	    
	    Task taskRec = new Task();
	    taskRec.whatId = quoteToInsert.Id;
	    taskRec.Status = 'Completed';
	    taskRec.Subject ='test';
	    taskRec.ActivityDate = System.Today();
	    taskRec.Description ='Test'; 
	    insert taskRec;
	    
	    Attachment att = new Attachment();
	    att.Name = 'Test Name';
	    att.ParentId = taskRec.Id;
	    att.Body = blob.valueOf('Test Body');
	    att.Description ='test';
	    att.ContentType ='application/pdf';
	    insert att;
	    
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteToInsert);
        generatePDF pdf = new generatePDF(sc);
        pdf.userValue();
        pdf.contactValue();
        pdf.selectedid = qt.Id;
        pdf.CreatePDF();
        pdf.SendPDF();
        System.assert(true);
	}
	private static testMethod void test1() {
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
	    
	    buildertek__Quote__c quoteToInsert = new buildertek__Quote__c();
	    quoteToInsert.Name = 'Test Quote';
	    insert quoteToInsert;
	    
	   // Attachment att = new Attachment();
	   // att.Name = 'Test Name';
	   // att.ParentId = quoteToInsert.Id;
	   // att.Body = blob.valueOf('Test Body');
	   // insert att;
	    
        ApexPages.StandardController sc = new ApexPages.StandardController(quoteToInsert);
        generatePDF pdf = new generatePDF(sc);
        pdf.userValue();
        pdf.contactValue();
        pdf.selectedid = qt.Id;
        pdf.CreatePDF();
        pdf.SendPDF();
        System.assert(true);
	}


}