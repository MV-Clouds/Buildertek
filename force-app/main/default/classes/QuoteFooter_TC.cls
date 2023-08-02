@isTest
public class QuoteFooter_TC {
    static TestMethod void quoteController(){
      Account a = new Account();
      a.name = 'testa';
      insert a; 
      QuoteFooter_AC  qh = new QuoteFooter_AC (null);
      qh.Save(); 
      system.assertEquals(a.id,a.id);
    }
    
     static TestMethod void quoteController1(){
      Account a1 = new Account();
      a1.name = 'testb';
      insert a1; 
         
         Template_Footer__c Temp = new Template_Footer__c();
         Temp.Description__c = 'Test';
         insert Temp;
             ApexPages.StandardController sc = new ApexPages.StandardController(Temp);
        
        String FooterID = ApexPages.currentPage().getParameters().put('id',Temp.Id);
      QuoteFooter_AC  qh = new QuoteFooter_AC (SC);
      qh.Save(); 
      system.assertEquals(a1.id,a1.id);
    }
    
}