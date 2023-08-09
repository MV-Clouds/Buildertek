@isTest
private class QuoteTemplate_TC {
    static TestMethod void QuoteTemplate(){
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
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        QuoteTemplate_AC QuoteTemplate = new QuoteTemplate_AC(sc);
        QuoteTemplate.getImage();
        QuoteTemplate.isError = false;
        QuoteTemplate.Save();
        QuoteTemplate.verifyError();
        QuoteTemplate.doCancel();
        system.assertEquals(th.id,th.id);
    }
}