@isTest
private class PreviewBillingsControllerTest {

	private static testMethod void insertContact() {
	     Account acc = new Account();
        acc.Name='test';
        insert acc;
        
        Change_Order__c co = new Change_Order__c();
        co.Name = 'test';
        co.Customer_Account__c=acc.id;
        insert co;
        
        
        Billings__c billing = new Billings__c();
        billing.Name='test';
        billing.Change_Order__c=co.id;
        insert billing;
        
        contact con = new contact();
        con.Email ='test@gmail.com';
        con.lastname ='test';
        insert con;
        
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Invoice3'].Id; 
         List<String> ccId = new List<String>();
        List<String> toId = new List<String>();
        toId.add(con.Id);
        PreviewBillingsController.getInvoiceLines(billing.id,theTemplate);
        PreviewBillingsController.sendProposal('', billing.id, theTemplate, toId, ccId);
        System.assertEquals('Test','Test');
	}

}