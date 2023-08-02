trigger InsertPartnerAccountsForOpportunity on OpportunityContactRole (After insert) {
    InsertPartnerAccountsForOppHandler handler = new InsertPartnerAccountsForOppHandler();
    handler.InsertPartnerAccount(Trigger.new);
    
}