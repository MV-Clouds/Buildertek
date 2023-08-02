@isTest
public class ContinuationSheetLine_Test {
    static testmethod void testQuoteTrigger(){
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
        buildertek__SOV_Continuation__c sheetRec = new buildertek__SOV_Continuation__c();
        sheetRec.Name = 'test';
        sheetRec.buildertek__SOV_Payment_Application__c  =payRec.id;
        insert sheetRec;
        buildertek__SOV_Continuation_Sheet_Lines__c sovline = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovline.Name = 'test';
        sovline.buildertek__SOV_Continuation_Sheet__c = sheetRec.id;
        sovline.buildertek__Description_of_Work__c = 'test';
      //  sovline.
        //sovline.buildertek__SOV_Payment_Application__c =payRec.id;
        insert sovline;
    } 
    
    public static testMethod void Test1(){
         
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
       // payRec.RecordType.Name = 'AP';
        insert payRec;
        buildertek__SOV_Continuation__c sheetRec = new buildertek__SOV_Continuation__c();
        sheetRec.Name = 'test';
        sheetRec.buildertek__SOV_Payment_Application__c  =payRec.id;
        insert sheetRec;
        buildertek__SOV_Continuation_Sheet_Lines__c sovline = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovline.buildertek__Status__c = 'Accepted';
        sovline.Name = 'test';
        sovline.buildertek__SOV_Continuation_Sheet__c = sheetRec.id;
        sovline.buildertek__Description_of_Work__c = 'test';
     
        insert sovline;
        sovline.buildertek__Status__c = 'Rejected';
              update sovline;
        
        buildertek__SOV_Continuation__c getSheet = [select Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: sheetRec.id limit 5000];
        buildertek__SOV_Payment_Application__c getPay = [select Name,buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id =: getSheet.buildertek__SOV_Payment_Application__c limit 5000];
       
    }
    
       public static testMethod void Test2(){
         
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
           payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
       // payRec.RecordType.Name = 'AP';
        insert payRec;
        buildertek__SOV_Continuation__c sheetRec = new buildertek__SOV_Continuation__c();
        sheetRec.Name = 'test';
        sheetRec.buildertek__SOV_Payment_Application__c  =payRec.id;
        insert sheetRec;
        buildertek__SOV_Continuation_Sheet_Lines__c sovline = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovline.buildertek__Status__c = 'Accepted';
        sovline.Name = 'test';
        sovline.buildertek__SOV_Continuation_Sheet__c = sheetRec.id;
        sovline.buildertek__Description_of_Work__c = 'test';
     
        insert sovline;
        sovline.buildertek__Status__c = 'Accepted';
              update sovline;
        
        buildertek__SOV_Continuation__c getSheet = [select Name,buildertek__SOV_Payment_Application__c from buildertek__SOV_Continuation__c where Id =: sheetRec.id limit 5000];
        buildertek__SOV_Payment_Application__c getPay = [select Name,buildertek__Status__c from buildertek__SOV_Payment_Application__c where Id =: getSheet.buildertek__SOV_Payment_Application__c limit 5000];
        
       // System.assertEquals('Company Accepted',getPay.buildertek__Status__c);
    }
    
    

}