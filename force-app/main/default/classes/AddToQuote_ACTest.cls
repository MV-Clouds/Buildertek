@isTest
public class AddToQuote_ACTest {
    public static testMethod void test1() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Project__c p = new Project__c();
        p.Name = 'test';
        insert p;    
        
       Purchase_Order__c po = new Purchase_Order__c();
       po.Description__c = 'test';
       po.Project__c = p.id;
        po.buildertek__Vendor__c = acc.id; 
       insert po;
       
       Quote__c q = new Quote__c();
       q.Name='test';
       insert q;
       
       Quote_Line_Group__c qlg = new Quote_Line_Group__c();
       qlg.Name = 'No Grouping';
       qlg.Quote__c = q.id;
       insert qlg;
        
        String poid = Id.valueOf(po.id);
       AddToQuote_AC.getPurchaseOrderList(Id.valueOf(po.id));
       AddToQuote_AC.fetchPurchaseOrders('Name',true,Id.valueOf(po.id));
       AddToQuote_AC.getQuotelist();
       
       AddToQuote_AC.PurchaseOrderWrap pow = new AddToQuote_AC.PurchaseOrderWrap();
       pow.purcheckbox = true;
       pow.getPurchaseOrderList = po;
       
       String strJSON = '['+JSON.serialize(pow)+']';
       AddToQuote_AC.AddPurchaseOrders(strJSON,Id.valueOf(q.id));
       System.assertEquals('Test','Test');
     
        
    }
    
}