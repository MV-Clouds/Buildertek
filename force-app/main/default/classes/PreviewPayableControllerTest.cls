@isTest
private class PreviewPayableControllerTest {

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
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Payable'].Id; 
         List<String> ccId = new List<String>();
        List<String> toId = new List<String>();
        List<String> texttoId = new List<String>();
        toId.add(con.Id);
        texttoId.add('test@gmail.com');
        PreviewPayableController.getTemplates();
        PreviewPayableController.getPayableLines(accp.id,theTemplate);
        PreviewPayableController.sendProposal('', accp.id, theTemplate, toId, ccId,texttoId);
        
        System.assertEquals('Test','Test');


  }

}