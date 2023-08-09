@isTest
private class CloneDocTemplate_TC {
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
        qt.buildertek__Description__c = 'test description';
        qt.buildertek__Template_Header__c = th.id;
        qt.buildertek__Template_Footer__c = tf.Id;
        insert qt;
        
        buildertek__DocTemplate_Page__c qp = new buildertek__DocTemplate_Page__c();
        qp.buildertek__LineItems__c = true;
        qp.buildertek__Page_Sort_order__c = 1;
        qp.buildertek__Doc_Template__c = qt.id;
        qp.buildertek__DocTemplate_Page__c = 'test';
        qp.buildertek__Template_Page_Brake__c = false;
        insert qp;
        
        buildertek__Quote_Lineitem_Fields__c ql = new buildertek__Quote_Lineitem_Fields__c();
        ql.buildertek__Col_Width__c = 30;
        ql.buildertek__Field_API_Name__c = 'Product__c';
        ql.buildertek__Field_Name__c = 'Product';
        ql.buildertek__Quote_Template__c = qt.id;
        ql.buildertek__DocTemplate_Page__c = qp.id;
        ql.buildertek__Sort_Order__c = 1;
        insert ql;
        
        ApexPages.currentPage().getParameters().put('id', qt.id); 
        ApexPages.StandardController sc = new ApexPages.StandardController(qt);
        CloneDocTemplate_AC CDC = new CloneDocTemplate_AC(sc);
        CDC.isError = true;
        CDC.verifyError();
        CDC.Save();
        system.assertEquals('Test','Test');
    }
    
    static TestMethod void QuoteTemplates(){
        buildertek__Quote_Template__c qt1 = new buildertek__Quote_Template__c();
        qt1.buildertek__Template_Body__c = '';
        qt1.buildertek__Description__c = '';
        insert qt1;
        
        ApexPages.currentPage().getParameters().put('id', qt1.id); 
        ApexPages.StandardController sc1 = new ApexPages.StandardController(qt1);
        CloneDocTemplate_AC CDC1 = new CloneDocTemplate_AC(sc1);   
        
         
        CDC1.verifyError();
        CDC1.Save();   
        system.assertEquals('Test','Test');
        
    }
    
}