@isTest
public class AddRFQToQuote_ACTest {
    public static testMethod void test1() {
        
       Project__c p = new Project__c();
       p.Name = 'test';
       insert p;
        
       Quote__c q = new Quote__c();
       q.Name='test';
       q.Project__c = p.id;
       insert q;
       
       Quote_Line_Group__c qlg = new Quote_Line_Group__c();
       qlg.Name = 'No Grouping';
       qlg.Quote__c = q.id;
       insert qlg;
       
       RFQ__c rfq = new RFQ__c();
       rfq.Name  = 'test';
       rfq.Project__c = p.id;
       insert rfq;
       
     
       AddRFQToQuote_AC.getRFQList(Id.valueOf(rfq.id));
       AddRFQToQuote_AC.fetchPurchaseOrders('Name',true,Id.valueOf(rfq.id));
       AddRFQToQuote_AC.getQuotelist(rfq.Id);
       
       AddRFQToQuote_AC.RFQWrap wrap = new AddRFQToQuote_AC.RFQWrap();
       wrap.purcheckbox = true;
       wrap.getPurchaseOrderList = rfq;
       
       String strJSON = '['+JSON.serialize(wrap)+']';
       AddRFQToQuote_AC.AddPurchaseOrders(strJSON,Id.valueOf(q.id));
       
       System.assertEquals('Test','Test');
        
    }
    
}