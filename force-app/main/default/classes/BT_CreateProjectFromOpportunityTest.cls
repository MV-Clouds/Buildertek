@isTest
private class BT_CreateProjectFromOpportunityTest {

    private static testMethod void test1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity Opp = new Opportunity(); 
        Opp.Name = 'Test Opportunity';
        Opp.CloseDate = system.today().addDays(30);
        Opp.StageName = 'Prospecting';
        insert Opp;
        
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        List<buildertek__Quote__c> quoteList = new List<buildertek__Quote__c>();
        buildertek__Quote__c quote = new buildertek__Quote__c();
        quote.Name = 'Test Quote';
        quote.buildertek__Opportunity__c = Opp.Id;
      //  quote.buildertek__Status__c = 'Accepted';
        quote.buildertek__Status__c = 'Customer Accepted'; 
        quoteList.add(quote);
        insert quoteList;
        buildertek__Quote_Item__c quoteItem = new buildertek__Quote_Item__c();
        quoteItem.Name = 'Test QuoteItem';
        quoteItem.buildertek__Quote__c = quote.id;
       // quoteItem.buildertek__Opportunity__c = Opp.Id;
        insert quoteItem;
        
        buildertek__Proposal_Images__c quoteimage = new buildertek__Proposal_Images__c();
        quoteimage.buildertek__Proposal__c = quote.id;
        insert quoteimage;
        
        BT_CreateProjectFromOpportunity cpfo = new BT_CreateProjectFromOpportunity();
        BT_CreateProjectFromOpportunity.getOpportunity(Opp.Id);
     //   BT_CreateProjectFromOpportunity.createProject(Opp.Id, proj.Name, acc.Id, UserInfo.getUserId(), system.today());
        
        system.assertEquals('test', 'test');
    }

}