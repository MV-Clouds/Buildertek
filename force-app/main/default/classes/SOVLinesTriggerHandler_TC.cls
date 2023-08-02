@isTest
public class SOVLinesTriggerHandler_TC {
    public static testMethod void test1() {
        buildertek__Schedule_of_Values__c sv = new buildertek__Schedule_of_Values__c();
        sv.Name = 'test name';
        insert sv;
        
        List<buildertek__Schedule_of_Value_Lines__c> bclist = new List<buildertek__Schedule_of_Value_Lines__c>();
        buildertek__Schedule_of_Value_Lines__c bc = new buildertek__Schedule_of_Value_Lines__c();
        bc.buildertek__Item__c = 'test';
        bc.buildertek__Schedule_of_Values__c = sv.Id;
        bc.buildertek__Item_New__c = 6;
        bc.buildertek__Description_of_Work__c = 'test';
        insert bc;
        bclist.add(bc);
        
        buildertek__Schedule_of_Value_Lines__c bc2 = new buildertek__Schedule_of_Value_Lines__c();
        bc2.buildertek__Item__c = 'test';
        bc2.buildertek__Schedule_of_Values__c = sv.Id;
        bc2.buildertek__Item_New__c = 9;
        bc2.buildertek__Description_of_Work__c = 'test';
        insert bc2;
        bclist.add(bc2);
    }
    public static testMethod void afterInsert() {
         buildertek__Schedule_of_Values__c sv = new buildertek__Schedule_of_Values__c();
        sv.Name = 'test name';
        sv.buildertek__Type__c = 'Standard';
        insert sv;
    }
       public static testMethod void test2() {
        buildertek__Schedule_of_Values__c sv = new buildertek__Schedule_of_Values__c();
        sv.Name = 'test name';
        sv.buildertek__Type__c = 'Vendor';
        insert sv;
     
        List<buildertek__Schedule_of_Value_Lines__c> bclist = new List<buildertek__Schedule_of_Value_Lines__c>();
        buildertek__Schedule_of_Value_Lines__c bc2 = new buildertek__Schedule_of_Value_Lines__c();
        bc2.buildertek__Item__c = 'test1';
        bc2.buildertek__Schedule_of_Values__c = sv.Id;
        bc2.buildertek__Item_New__c = 9;
        bc2.buildertek__Description_of_Work__c = 'test1';
        bc2.buildertek__Status__c = 'Pending';
        insert bc2;
        bclist.add(bc2);
         
        buildertek__Schedule_of_Value_Lines__c bc1 = new buildertek__Schedule_of_Value_Lines__c();
        bc1.buildertek__Item__c = 'test2';
        bc1.buildertek__Schedule_of_Values__c = sv.Id;
        bc1.buildertek__Item_New__c = 10;
        bc1.buildertek__Description_of_Work__c = 'test2';
        bc1.buildertek__Status__c = 'Pending';
        insert bc1;
        bclist.add(bc1);
         
         Map<ID,buildertek__Schedule_of_Value_Lines__c> mapSovl = new  Map<ID,buildertek__Schedule_of_Value_Lines__c>();
         mapSovl.put(bc1.Id,bc1);
         mapSovl.put(bc2.Id,bc2);
         
         bclist[0].buildertek__Status__c = 'Approved';
         bclist[1].buildertek__Status__c = 'Approved';
     
         update bclist;
         
        // SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatusOnAfterUpdate(bclist,mapSovl);
         buildertek__Schedule_of_Values__c ch = [select buildertek__Status__c from buildertek__Schedule_of_Values__c where id =:sv.Id];
         //System.assertEquals('Company Approved', ch.buildertek__Status__c);
         
         }
         
         /*-----------------------------------------------------------------------------------------------------------------------------*/
           public static testMethod void test3() {
          buildertek__Schedule_of_Values__c sv1 = new buildertek__Schedule_of_Values__c();
        sv1.Name = 'test name';
         sv1.buildertek__Type__c = 'Vendor';
        insert sv1;
     
        List<buildertek__Schedule_of_Value_Lines__c> bclist1 = new List<buildertek__Schedule_of_Value_Lines__c>();
        buildertek__Schedule_of_Value_Lines__c bc3 = new buildertek__Schedule_of_Value_Lines__c();
        bc3.buildertek__Item__c = 'test3';
        bc3.buildertek__Schedule_of_Values__c = sv1.Id;
        bc3.buildertek__Item_New__c = 9;
        bc3.buildertek__Description_of_Work__c = 'test1';
        bc3.buildertek__Status__c = 'Pending';
        insert bc3;
        bclist1.add(bc3);
         
        buildertek__Schedule_of_Value_Lines__c bc4 = new buildertek__Schedule_of_Value_Lines__c();
        bc4.buildertek__Item__c = 'test4';
        bc4.buildertek__Schedule_of_Values__c = sv1.Id;
        bc4.buildertek__Item_New__c = 10;
        bc4.buildertek__Description_of_Work__c = 'test2';
        bc4.buildertek__Status__c = 'Pending';
        insert bc4;
        bclist1.add(bc4);
         
         Map<ID,buildertek__Schedule_of_Value_Lines__c> mapSovl1 = new  Map<ID,buildertek__Schedule_of_Value_Lines__c>();
         mapSovl1.put(bc3.Id,bc3);
         mapSovl1.put(bc4.Id,bc4);
         
         bclist1[0].buildertek__Status__c = 'Approved'; 
         bclist1[1].buildertek__Status__c = 'Rejected';
     
         update bclist1;
         
       //  SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatusOnAfterUpdate(bclist1,mapSovl1); 
           buildertek__Schedule_of_Values__c ch = [select buildertek__Status__c from buildertek__Schedule_of_Values__c where id =:sv1.Id];
        // System.assertEquals('Partially Rejected', ch.buildertek__Status__c);
         System.assertEquals('Pending', ch.buildertek__Status__c);
     }
     
       /*-----------------------------------------------------------------------------------------------------------------------------*/
           public static testMethod void test4() {
          buildertek__Schedule_of_Values__c sv1 = new buildertek__Schedule_of_Values__c();
        sv1.Name = 'test name';
         sv1.buildertek__Type__c = 'Vendor';
        insert sv1;
   
        buildertek__Schedule_of_Value_Lines__c bc3 = new buildertek__Schedule_of_Value_Lines__c();
        bc3.buildertek__Item__c = 'test3';
        bc3.buildertek__Schedule_of_Values__c = sv1.Id;
        bc3.buildertek__Item_New__c = 9;
        bc3.buildertek__Description_of_Work__c = 'test1';
        bc3.buildertek__Status__c = 'Rejected';
        insert bc3;
   
    
       
         
     
         
       //  SOVLinesTriggerHandler.updateSOVStatusBasedOnSOVLinesStatusOnAfterUpdate(bclist1,mapSovl1); 
           buildertek__Schedule_of_Values__c ch = [select buildertek__Status__c from buildertek__Schedule_of_Values__c where id =:sv1.Id];
        // System.assertEquals('Partially Rejected', ch.buildertek__Status__c);
         System.assertEquals('Pending', ch.buildertek__Status__c);
     }
     
}