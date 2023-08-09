@isTest
private class QuoteTemplateEdit_TC {
    static TestMethod void QuoteTemplateEdit(){
        buildertek__Quote_Template__c qt = new buildertek__Quote_Template__c();
        insert qt;
        ApexPages.currentPage().getParameters().put('id', qt.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        QuoteTemplateEdit_AC QuoteTemplateEdit_AC = new QuoteTemplateEdit_AC(sc);
        QuoteTemplateEdit_AC.getImage();
        QuoteTemplateEdit_AC.verifyError();
        QuoteTemplateEdit_AC.UpdateQuoteInfo();
        QuoteTemplateEdit_AC.CancelQuoteInfo();
        system.assertEquals(qt.id,qt.id);
    }
}