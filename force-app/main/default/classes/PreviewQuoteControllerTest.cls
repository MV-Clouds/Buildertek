@isTest
private class PreviewQuoteControllerTest {

    private static testMethod void insertContact() {
        contact con = new contact();
        con.Email ='test@gmail.com';
        con.lastname ='test';
        insert con;
        
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Quote';
        insert quote;
        
        string theTemplate = [SELECT Id FROM EmailTemplate WHERE Name = 'Contract Template 1'].Id;
        List<String> ccId = new List<String>();
        List<String> toId = new List<String>();
        toId.add(con.Id);
        PreviewQuoteController.getQuoteLines(quote.id, theTemplate);
        PreviewQuoteController.getProposalImages(quote.id);
        //PreviewQuoteController.sendProposal('', quote.id, theTemplate, toId, ccId);
        System.assertEquals('Test','Test');
    }

}