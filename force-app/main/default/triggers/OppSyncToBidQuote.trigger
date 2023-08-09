trigger OppSyncToBidQuote on SBQQ__Quote__c (After insert) {

    OppSyncToBidQuoteController.OppSyncToBidQuote(Trigger.New);

}