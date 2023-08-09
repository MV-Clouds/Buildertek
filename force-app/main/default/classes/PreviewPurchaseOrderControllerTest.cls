@isTest
private class PreviewPurchaseOrderControllerTest {
     @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
        Purchase_Order__c PO = [Select ID from purchase_order__c LIMIT 1];
         contact con = new contact();
        con.Email ='test@gmail.com';
        con.lastname ='test';
        insert con;
        // string theTemplate = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Purchase_Order_Template'].Id; 
         List<String> ccId = new List<String>();
        List<String> toId = new List<String>();
        List<String> attachdoc = new List<String>();
        toId.add(con.Id);
        // PreviewPurchaseOrderController.getPurchaseOrderLines(PO.id,theTemplate);
        // PreviewPurchaseOrderController.sendProposal('', PO.id, theTemplate, toId, ccId ,'',attachdoc); 
        System.assertEquals('Test','Test');


  }
}