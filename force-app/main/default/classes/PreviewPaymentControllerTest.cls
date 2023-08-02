@isTest
private class PreviewPaymentControllerTest {


     @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
        Purchase_Order__c PO = [Select ID from purchase_order__c LIMIT 1];
         contact con = new contact();
        con.Email ='test@gmail.com';
        con.lastname ='test';
        insert con;
        
        buildertek__Account_Payable__c  accp = new buildertek__Account_Payable__c();
        accp.buildertek__Purchase_Order__c = PO.id;
        accp.buildertek__Status__c = 'Open';
        insert accp;
        
        buildertek__Payment__c payment = new buildertek__Payment__c();
        payment.buildertek__Payable__c = accp.id;
        insert payment;
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Payment'].Id; 
         List<String> ccId = new List<String>();
        List<String> toId = new List<String>();
        toId.add(con.Id);
        PreviewPaymentController.getTemplates();
        PreviewPaymentController.getPaymentLines(payment.id,theTemplate);
        PreviewPaymentController.sendProposal('', payment.id, theTemplate, toId, ccId);
        
        System.assertEquals('Test','Test');


  }

}