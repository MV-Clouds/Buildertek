@isTest
public class contacttimecardBatchcontrollerTest {
     static testMethod void contactTimecardBatchtesting(){
        
         buildertek__Project__c pro = new buildertek__Project__c();
         pro.Name = 'test6';
        insert pro;
        
         List<Contact> cont = new List<Contact>();
    Contact con = new Contact();
    con.Email = 'test@gmail.com';
    con.LastName = 'test4';
    cont.add(con);
    insert cont;
        
        List<buildertek__Time_Cards__c> timelist =  new List<buildertek__Time_Cards__c>();
        buildertek__Time_Cards__c cards = new buildertek__Time_Cards__c();
       // time.Name = 'john';
        cards.buildertek__Description__c = 'test';
        cards.buildertek__End_Time__c = Date.Today();
        cards.buildertek__Resource__c = cont[0].id;
        cards.buildertek__Total_Break_Time__c = 10;
        cards.buildertek__Project__c = pro.id;
        //time.buildertek__Daily_Expense__c = 555;
        timelist.add(cards);
        insert timelist;
        
         
      contacttimecardBatchcontroller newtime = new contacttimecardBatchcontroller();
       newtime.batchjobexcute();
        
        // contactTimecard_Batch contime = new contactTimecard_Batch(timelist);
          //  DataBase.executeBatch(contime); 
        
        
    }


}