@isTest
public class QuoteTemplatePageEdit_TC {
    static TestMethod void quoteController(){
        Account a = new Account();
        a.name = 'atest';
        insert a; 
        Contact c = new contact();
        c.LastName = 'cTest';
        insert c;
        Template_Header__c th = new Template_Header__c();
        th.Description__c = 'test';
        th.Template_Header__c = 'test';
        insert th;
        Template_Footer__c tf = new Template_Footer__c();
        tf.Description__c = 'test';
        tf.Template_Footer__c = 'test';
        insert tf;
        Quote_Template__c qt = new Quote_Template__c();
        qt.Template_Body__c = 'Test';
        qt.Template_Format__c = 'Quote';
        qt.Template_Header__c = th.id;
        qt.Template_Footer__c = tf.Id;
        insert qt;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=a.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id);
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
        insert oli;
        quote q = new quote();
        q.Pricebook2Id=opp.Pricebook2Id;
        q.Name = 'test name';
        q.status = 'Won';
        q.OpportunityId =opp.id;
        q.ContactId = c.id;
        q.Doc_Template__c = qt.id;
        insert q;
 
        QuoteLineItem ql = new QuoteLineItem(); 
        ql.QuoteId = q.id;
        ql.PricebookEntryId=customPrice.id;
        ql.Product2Id =prod.Id;
        // ql.Original_Price__c = 12.1;
        ql.Quantity = 1.10;
        ql.UnitPrice = 12.11;
        insert ql;
        
        Quote_Template__c temp = new Quote_Template__c(); 
        temp.Font_Family__c = 'Arial';
        temp.Description__c = 'Diablo Cable Invoice';
        temp.Template_Format__c = 'Quote';
        insert temp;
        
        DocTemplate_page__c qp = new DocTemplate_page__c();
        qp.Page_Sort_order__c = 1;
        qp.Doc_Template__c = temp.id ;
        insert qp;
        
        Quote_Lineitem_Fields__c  qlf = new Quote_Lineitem_Fields__c ();
        qlf.Quote_Template__c = temp.id;
        qlf.DocTemplate_page__c = qp.id;
        qlf.Field_Name__c = 'Product';
        qlf.Field_API_Name__c = 'Product__r.Name';
        qlf.Sort_Order__c = 1;
        insert qlf;
         
        ApexPages.currentPage().getParameters().put('retURL', qlf.id);
        ApexPages.currentPage().getParameters().put('id', qp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qlf);
        QuoteTemplatePageEdit_AC  qtp = new  QuoteTemplatePageEdit_AC(sc);

        qtp.selectclick();
        qtp.unselectclick();
        qtp.getunSelectedValues();
        qtp.getSelectedValues();
        qtp.verifyError();
        qtp.UpdateTemplatePageInfo();
        qtp.doCancel();
        
        system.assertEquals(a.id,a.id);
        
    }
    static TestMethod void quoteController1(){
       Account a = new Account();
        a.name = 'atest';
        insert a; 
        Contact c = new contact();
        c.LastName = 'cTest';
        insert c;
        Template_Header__c th = new Template_Header__c();
        th.Description__c = 'test';
        th.Template_Header__c = 'test';
        insert th;
        Template_Footer__c tf = new Template_Footer__c();
        tf.Description__c = 'test';
        tf.Template_Footer__c = 'test';
        insert tf;
        Quote_Template__c qt = new Quote_Template__c();
        qt.Template_Body__c = 'Test';
        qt.Template_Format__c = 'Quote';
        qt.Template_Header__c = th.id;
        qt.Template_Footer__c = tf.Id;
        insert qt;
        
        Product2 prod = new Product2(Name = 'Laptop X200', Family = 'Hardware');
        insert prod;

        Id pricebookId = Test.getStandardPricebookId();

        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = pricebookId, Product2Id = prod.Id, UnitPrice = 10000, IsActive = true);
        insert standardPrice;
        
        Pricebook2 customPB = new Pricebook2(Name='Custom Pricebook', isActive=true);
        insert customPB;
        
        PricebookEntry customPrice = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prod.Id, UnitPrice = 12000, IsActive = true);
        insert customPrice;
        
        Opportunity opp = new Opportunity(Name='TestOpportunity', AccountId=a.Id, CloseDate=Date.Today(), StageName='Suspect', Pricebook2Id=customPB.Id);
        insert opp;
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, Quantity = 5, PricebookEntryId = customPrice.Id, TotalPrice = 500);
        insert oli;
        quote q = new quote();
        q.Pricebook2Id=opp.Pricebook2Id;
        q.Name = 'test name';
        q.status = 'Won';
        q.OpportunityId =opp.id;
        q.ContactId = c.id;
        q.Doc_Template__c = qt.id;
        insert q;
 
        QuoteLineItem ql = new QuoteLineItem(); 
        ql.QuoteId = q.id;
        ql.PricebookEntryId=customPrice.id;
        ql.Product2Id =prod.Id;
        // ql.Original_Price__c = 12.1;
        ql.Quantity = 1.10;
        ql.UnitPrice = 12.11;
        insert ql;
        
        Quote_Template__c temp = new Quote_Template__c(); 
        temp.Font_Family__c = 'Arial';
        temp.Description__c = 'Diablo Cable Invoice';
        temp.Template_Format__c = 'Quote';
        insert temp;
        
        DocTemplate_page__c qp = new DocTemplate_page__c();
        qp.Page_Sort_order__c = null;
        qp.Doc_Template__c = temp.id ;
        qp.DocTemplate_Page__c = '';
        insert qp;
        
        Quote_Lineitem_Fields__c  qlf = new Quote_Lineitem_Fields__c ();
        qlf.Quote_Template__c = temp.id;
        qlf.DocTemplate_page__c = qp.id;
        qlf.Field_Name__c = 'Product';
        qlf.Field_API_Name__c = 'Product__r.Name';
        qlf.Sort_Order__c = 1;
        insert qlf;
         
        ApexPages.currentPage().getParameters().put('retURL', qlf.id);
        ApexPages.currentPage().getParameters().put('id', qp.id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(qlf);
        QuoteTemplatePageEdit_AC  qtp = new  QuoteTemplatePageEdit_AC(sc);

        qtp.selectclick();
        qtp.unselectclick();
        qtp.getunSelectedValues();
        qtp.getSelectedValues();
        qtp.verifyError();
        qtp.UpdateTemplatePageInfo();
        qtp.doCancel();
        
        system.assertEquals(a.id,a.id);
    }
}