@isTest
public class QuoteHeader_TC {
     
    static TestMethod void quoteController1(){
    	Account a = new Account();
        a.name = 'test';
        insert a;
    	QuoteHeader_AC  qh = new QuoteHeader_AC(null);
    	qh.Save(); 
    	system.assertEquals(a.id,a.id);
    }
}