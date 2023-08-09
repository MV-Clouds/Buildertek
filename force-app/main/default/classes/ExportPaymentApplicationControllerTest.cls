@isTest
private class ExportPaymentApplicationControllerTest {
   
    @isTest
    private static void testMethod1() { 
        Test.startTest();
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 100;
        payRec.buildertek__Period_To__c = system.today();
        payRec.buildertek__Less__c  =21700;
        payRec.buildertek__CO_Additions_Approved_This_Month__c=null;
        payRec.buildertek__Change_Order_Additions__c=null;
        payRec.buildertek__CO_Deductions_Approved_in_Previous_Month__c  =null;
        payRec.buildertek__Change_Order_Decuctions__c=null;
        insert payRec;

        buildertek__SOV_Continuation__c sheetRec = new buildertek__SOV_Continuation__c();
        sheetRec.Name = 'test';
        sheetRec.buildertek__SOV_Payment_Application__c  =payRec.id;
        insert sheetRec;


        buildertek__SOV_Continuation_Sheet_Lines__c sovline = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovline.Name = 'test';
        sovline.buildertek__SOV_Continuation_Sheet__c = sheetRec.id;
        sovline.buildertek__Description_of_Work__c = 'test';
        sovline.buildertek__Material_Presently_Stored__c=100;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=300;
        sovline.buildertek__Work_Completed__c=200;
        sovline.buildertek__Scheduled_Value__c=1000;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=1002;
        sovline.buildertek__Grouping__c='';
        sovline.buildertek__Budget_Grouping__c=null;
        insert sovline;

        // buildertek__budget__c budget = new buildertek__budget__c();
        // budget.name = 'New Budget';
        // insert budget;

        ApexPages.currentPage().getParameters().put('id', payRec.id);

        ExportPaymentApplicationController extraPaymentApp = new ExportPaymentApplicationController();
        // ExportPaymentApplicationController extraPaymentApp2 = new ExportPaymentApplicationController();

        Test.stopTest();
        
    }

    @isTest
    private static void testMethod2() { 
        Test.startTest();
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 100;
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
        sovline.buildertek__Material_Presently_Stored__c=100;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=300;
        sovline.buildertek__Work_Completed__c=200;
        sovline.buildertek__Scheduled_Value__c=1000;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=1002;
        sovline.buildertek__Grouping__c='1st Floor';
        sovline.buildertek__Budget_Grouping__c='No Grouping';
        insert sovline;

        ApexPages.currentPage().getParameters().put('id', payRec.id);

        ExportPaymentApplicationController extraPaymentApp = new ExportPaymentApplicationController();
        Test.stopTest();
        
    }
    @isTest
    private static void testMethod23() { 
        Test.startTest();
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 100;
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
        sovline.buildertek__Material_Presently_Stored__c=100;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=300;
        sovline.buildertek__Work_Completed__c=200;
        sovline.buildertek__Scheduled_Value__c=1000;
        sovline.buildertek__Work_Completed_from_Previous_Application__c=1002;
        sovline.buildertek__Grouping__c=null;
        sovline.buildertek__Budget_Grouping__c='No Grouping';
        insert sovline;

        ApexPages.currentPage().getParameters().put('id', payRec.id);

        ExportPaymentApplicationController extraPaymentApp = new ExportPaymentApplicationController();
        Test.stopTest();
        
    }
    

}