@isTest
public class schedule_contacttimecardRecordsTest {
    static testMethod void schedule_contacttimecardRecordstesting(){
        
        //public static testMethod void testschedule() {

/*Test.StartTest();
schedule_contacttimecardRecords sh1 = new schedule_contacttimecardRecords();

String sch = '0 0 23   ?';
        system.schedule('Time Card Records', sch, sh1);
        Test.stopTest(); 
    }*/
        /* buildertek__Project__c pro = new buildertek__Project__c();
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
        
         //contacttimecardBatchcontroller newtime = new contacttimecardBatchcontroller();
      // newtime.batchjobexcute();
        
       
         //schedule_contacttimecardRecords conrec = new schedule_contacttimecardRecords();
        //schedule_contacttimecardRecords.execute();
        schedule_contacttimecardRecords.start();
           //DataBase.executeBatch(conrec); */
             /*String str = 'Time Card Records';
        string sch = ''; 
        sch = '0 0 0 16 2 1 2017';
        //sch ='0 0 1 * * ?';
        System.schedule(str, sch , new schedule_contacttimecardRecords()); 
        
    }*/
      String str = 'Time Card Records';
        string sch = ''; 
        sch = '7 11 0 7 9 ? 2021';
        //sch ='0 0 1 * * ?';
       // System.schedule(str, sch , new schedule_contacttimecardRecords()); 
        
    }


}