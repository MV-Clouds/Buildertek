@isTest
public with sharing class CreatePaymentApplicationForBudgetTest {
    @TestSetup
    static void testData(){

        buildertek__BT_Payment_App_Sign_Url__c payapp = new buildertek__BT_Payment_App_Sign_Url__c();
        payapp.buildertek__Site_Url__c='https://buildertekcom-developer-edition.na75.force.com/vendor';
        payapp.buildertek__Name__c ='BT Payment App Sign Url';
       insert payapp;


        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Test Project';
        insert project;

        Account acc = new Account();
        acc.Name = 'Testing';
        insert acc;

        Contact con = new Contact();
        con.LastName = 'Testing Contact';
        con.Email = 'Testing@gmail.com';

        insert con;

        buildertek__Admin_Interface_Node_Configuration__c interfaceNode = new buildertek__Admin_Interface_Node_Configuration__c();
        interfaceNode.Name = 'Payment Application Configuration';
        interfaceNode.buildertek__Get_Lines_From_CO__c = true;
        insert interfaceNode;

        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'Testing budget';
        insert budget;

        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Period_To__c = system.today();

        insert paymentApp;

        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;

        buildertek__SOV_Continuation_Sheet_Lines__c sovLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovLine.Name  = 'Testing SOV 1';
        sovLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovLine.buildertek__Description_of_Work__c = 'Test Description';
        sovLine.buildertek__Grouping__c  = '1st Floor';
        sovLine.buildertek__Item_No__c  = 100;
        insert sovLine;

      
                    
    }

    @isTest
    static void testMethod1(){

        buildertek__Budget__c budget = [SELECT Id, Name FROM buildertek__Budget__c LIMIT 1];

        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id, Name FROM buildertek__SOV_Payment_Application__c LIMIT 1];

        buildertek__SOV_Continuation__c sov = [SELECT Id, Name FROM buildertek__SOV_Continuation__c LIMIT 1];

        buildertek__SOV_Payment_Application__c paymentApp1 = new buildertek__SOV_Payment_Application__c();

        buildertek__SOV_Continuation_Sheet_Lines__c sovContLine= [Select id , Name ,buildertek__Description_of_Work__c , buildertek__SOV_Continuation_Sheet__c   from buildertek__SOV_Continuation_Sheet_Lines__c Limit 1];

        paymentApp1.Name = 'Testing paymentApp';
        paymentApp1.buildertek__Retainage__c = 5;
        insert paymentApp1;

        Test.startTest();

        CreatePaymentApplicationForBudget.getRfqTo();
        CreatePaymentApplicationForBudget.getChangeOrderBtValue();
        CreatePaymentApplicationForBudget.getFieldSet();
        CreatePaymentApplicationForBudget.getPaymentApplications(budget.Id);
        CreatePaymentApplicationForBudget.insertContinuationSheet(sov, paymentApp.Id, '123');
        CreatePaymentApplicationForBudget.getPaymentRecord(paymentApp.Id);
        CreatePaymentApplicationForBudget.checkPeriodTo(paymentApp.Id);
        CreatePaymentApplicationForBudget.InsertApplication(paymentApp, null , null);
        CreatePaymentApplicationForBudget.getPaymentAppStatus(sov.Id);
        CreatePaymentApplicationForBudget.updateFormula(sovContLine.Id , sov.Id , 'buildertek__Scheduled_Value__c'  , 1 );
        CreatePaymentApplicationForBudget.submitPAForView(paymentApp.Id, Date.today());

        Test.stopTest();
    
    }

    @isTest
    static void testMethod2(){

        buildertek__Budget__c budget = [SELECT Id, Name FROM buildertek__Budget__c LIMIT 1];


        buildertek__SOV_Continuation__c sov = [SELECT Id, Name FROM buildertek__SOV_Continuation__c LIMIT 1];
        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id, Name, buildertek__Application__c, buildertek__Retainage__c ,buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Vendor__c, buildertek__Project__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>{paymentApp.Id};

        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;

        String json=		'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__SOV_Continuation_Sheet__c": "'+payRec.Id+'"'+
		'  }'+
		']';
       
        
         String jsonData=		'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__SOV_Payment_Application__c": "'+payRec.Id+'"'+
		'  };'+
        '  {'+
		'    "Name": "test2",'+
		'    "buildertek__SOV_Payment_Application__c": "'+payRec.Id+'"'+
		'  }'+
		']';

        String sheetLineData=	'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__Description_of_Work__c": "test"'+
		'  }'+
		']';

        buildertek__SOV_Payment_Application__c sovList = [SELECT Id, Name, buildertek__Application__c,buildertek__Period_To__c , buildertek__Retainage__c , buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Project__c , buildertek__Vendor__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c  where id=:paymentApp.Id  LIMIT 1];

        buildertek__BT_Payment_App_Sign_Url__c payapp=[SELECT Id, Name, buildertek__Site_Url__c, buildertek__Name__c FROM buildertek__BT_Payment_App_Sign_Url__c];

        buildertek__SOV_Continuation__c sov2 = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;

        buildertek__Project__c project =[Select id , name From buildertek__Project__c Limit 1];
        buildertek__SOV_Continuation_Sheet_Lines__c sovContLine= [Select id , Name ,buildertek__Description_of_Work__c , buildertek__SOV_Continuation_Sheet__c   from buildertek__SOV_Continuation_Sheet_Lines__c Limit 1];
        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContLine.Id);



      
        Test.startTest();
        CreatePaymentApplicationForBudget.InsertApplication(sovList, 'Demo', System.today());
        CreatePaymentApplicationForBudget.getContinuationSheetLines(sov.Id);
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, payRec.Id);
        CreatePaymentApplicationForBudget.getDropDown('buildertek__SOV_Continuation_Sheet_Lines__c', 'buildertek__Status__c');
        CreatePaymentApplicationForBudget.AceptConnLines(payRec.Id);
         CreatePaymentApplicationForBudget.createSheetLines(json, payRec.Id);
         CreatePaymentApplicationForBudget.insertContinuationSheet(sov2, payRec.Id, '123');
         CreatePaymentApplicationForBudget.getLienRelease(payRec.Id);
         CreatePaymentApplicationForBudget.getadminvalues();
         CreatePaymentApplicationForBudget.getPaymentAppStatus(paymentApp.Id);
         CreatePaymentApplicationForBudget.getVendorSubmittedPaymentApps(project.Id , paymentApp.Id);
         CreatePaymentApplicationForBudget.getstatus(sovContLine.Id);
         CreatePaymentApplicationForBudget.getreason(sovContLine.Id);
         CreatePaymentApplicationForBudget.isSovSubmitted(paymentApp.Id);
         CreatePaymentApplicationForBudget.getCommUser();
         CreatePaymentApplicationForBudget.updateSheetLines(sheetLineData , sovContLine.Id, paymentApp.Id);
         CreatePaymentApplicationForBudget.acceptsheetline(sheetlineIds , sovContLine.Id);
         CreatePaymentApplicationForBudget.rejectsheetline(sheetlineIds ,'test' );
         CreatePaymentApplicationForBudget.updateFormula(sovContLine.Id , sov.Id , 'buildertek__Work_Completed_from_Previous_Application__c'  , 1 );
        Test.stopTest();
    
    }

    @isTest
    static void testMethod2Clone(){

        buildertek__Budget__c budget = [SELECT Id, Name FROM buildertek__Budget__c LIMIT 1];
        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id, Name, buildertek__Application__c, buildertek__Retainage__c ,buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Vendor__c, buildertek__Project__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>{paymentApp.Id};

        List<String> coId= new  List<String> ();

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        insert co;

        buildertek__Change_Order__c co2=new buildertek__Change_Order__c();
        co2.name='test';
        insert co2;

        coId.add(co.Id);
        coId.add(co2.Id);

        Account acc = new Account();
        acc.Name='test2';
        acc.buildertek__BT_Account_Type__c = 'Vendor';
        insert acc;

        buildertek__Change_Order_Item__c col = new buildertek__Change_Order_Item__c();
        col.buildertek__Change_Order__c = co.Id;
        col.buildertek__Vendor__c = acc.Id;
         insert col;
        
      
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov1 = new buildertek__SOV_Continuation__c();
        sov1.Name = ' Testing SOV';
        sov1.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov1;

        buildertek__SOV_Continuation__c sov2 = new buildertek__SOV_Continuation__c();
        sov2.Name = ' Testing SOV 2 Con';
        sov2.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov2;
      
        List<buildertek__SOV_Continuation__c> sovCon=[SELECT ID , name from buildertek__SOV_Continuation__c];

        

        Test.startTest();
         CreatePaymentApplicationForBudget.createSheetLinesNew(coId , paymentApp.Id);
        Test.stopTest();
    
    }
    @isTest
    static void testMethod3(){

        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='NEWPAYAPP';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=100;
        insert paymentApp;

        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();

        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        payRec.buildertek__Original_Contract_Sum__c=100;

        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        payRec2.buildertek__Original_Contract_Sum__c=100;

        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = payRec.Id;
        insert sov;
        // buildertek__SOV_Continuation_Sheet_Lines__c list=[Select id , name from buildertek__SOV_Continuation_Sheet_Lines__c LIMIT 1];

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 10';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 100;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        String assessmentFormString = JSON.serialize(sovContSheetLine);

        insert sovContSheetLine;

        sovContSheetLine.buildertek__Vendor_Sheet_line_Id__c=sovContSheetLine.Id;
        update sovContSheetLine;

        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContSheetLine.Id);


        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

    
        Test.startTest();
         CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);
         CreatePaymentApplicationForBudget.rejectsheetline(sheetlineIds ,'test' );
         CreatePaymentApplicationForBudget.getApprovedCOs(project.Id ,paymentApp.Id, paymentApp.Id);
         CreatePaymentApplicationForBudget.insertSheetLine(assessmentFormString ,payRec.Id );
         CreatePaymentApplicationForBudget.acceptsheetline(sheetlineIds , sovContSheetLine.Id);

         Test.stopTest();
    
    }

    @isTest
    static void testMethod3Clone(){

        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='NEWPAYAPP';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=100;
        insert paymentApp;

        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();

        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        payRec.buildertek__Original_Contract_Sum__c=100;

        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        payRec2.buildertek__Original_Contract_Sum__c=100;

        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;
        // buildertek__SOV_Continuation_Sheet_Lines__c list=[Select id , name from buildertek__SOV_Continuation_Sheet_Lines__c LIMIT 1];

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 10';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 100;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        String assessmentFormString = JSON.serialize(sovContSheetLine);

        insert sovContSheetLine;

        sovContSheetLine.buildertek__Vendor_Sheet_line_Id__c=sovContSheetLine.Id;
        update sovContSheetLine;

        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContSheetLine.Id);


        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

    
        Test.startTest();
         CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);
         CreatePaymentApplicationForBudget.rejectsheetline(sheetlineIds ,'test' );
         CreatePaymentApplicationForBudget.getApprovedCOs(project.Id ,paymentApp.Id, paymentApp.Id);
         CreatePaymentApplicationForBudget.insertSheetLine(assessmentFormString ,payRec.Id );
         CreatePaymentApplicationForBudget.acceptsheetline(sheetlineIds , sovContSheetLine.Id);
         Test.stopTest();
    
    }


    @isTest
    static void testMethod4(){

        buildertek__Budget__c budget = [SELECT Id, Name FROM buildertek__Budget__c LIMIT 1];


        buildertek__SOV_Continuation__c sov = [SELECT Id, Name FROM buildertek__SOV_Continuation__c LIMIT 1];
        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id, Name, buildertek__Application__c, buildertek__Retainage__c ,buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Vendor__c, buildertek__Project__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>{paymentApp.Id};

        List<String> coId= new  List<String> ();

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        insert co;

        buildertek__Change_Order__c co2=new buildertek__Change_Order__c();
        co2.name='test';
        insert co2;

        coId.add(co.Id);
        coId.add(co2.Id);

        
         
        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;



        String json=		'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__SOV_Continuation_Sheet__c": "'+payRec.Id+'"'+
		'  }'+
		']';
       
        
         String jsonData=		'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__SOV_Payment_Application__c": "'+payRec.Id+'"'+
		'  };'+
        '  {'+
		'    "Name": "test2",'+
		'    "buildertek__SOV_Payment_Application__c": "'+payRec.Id+'"'+
		'  }'+
		']';

        String sheetLineData=	'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__Description_of_Work__c": "test"'+
		'  }'+
		']';

        buildertek__SOV_Payment_Application__c sovList = [SELECT Id, Name, buildertek__Application__c,buildertek__Period_To__c , buildertek__Retainage__c , buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Project__c , buildertek__Vendor__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c  where id=:paymentApp.Id  LIMIT 1];

        buildertek__BT_Payment_App_Sign_Url__c payapp=[SELECT Id, Name, buildertek__Site_Url__c, buildertek__Name__c FROM buildertek__BT_Payment_App_Sign_Url__c];

        buildertek__SOV_Continuation__c sov2 = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;

        buildertek__Project__c project =[Select id , name From buildertek__Project__c Limit 1];
        buildertek__SOV_Continuation_Sheet_Lines__c sovContLine= [Select id , Name , buildertek__Item_No__c, buildertek__SOV_Continuation_Sheet__r.buildertek__SOV_Payment_Application__c , buildertek__Description_of_Work__c , buildertek__SOV_Continuation_Sheet__c   from buildertek__SOV_Continuation_Sheet_Lines__c];
        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContLine.Id);

      Date todayDate= Date.today();
        Test.startTest();
         CreatePaymentApplicationForBudget.updateFormula(sovContLine.Id , sov.Id , 'buildertek__Work_Completed__c'  , 1 );
         CreatePaymentApplicationForBudget.deletesheetline(sheetlineIds);
         CreatePaymentApplicationForBudget.saveSign(sov.Id , 'test' ,'test' , 'test' , 'test');

        Test.stopTest();
    
    }

    @isTest
    static void testMethod5(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORCUSTOMERSOV';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=10;
        paymentApp.buildertek__Total_Completed__c=10;
        paymentApp.buildertek__Total_Material_Stored_To_Date__c=10;
        paymentApp.buildertek__Imported_Payment_IDs__c='Test';


        insert paymentApp;

        
        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();
        PAIds.add(paymentApp.Id);


        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    
        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 3';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        insert sovContSheetLine;

        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContSheetLine.Id);

        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        Test.stopTest();
        

    }

    @isTest
    static void testMethod5Clone(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORCUSTOMERSOV';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;

        insert paymentApp;

        
        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();
        PAIds.add(paymentApp.Id);



        
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 4';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = null;
        insert sovContSheetLine;

        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);
        Test.stopTest();
        

    }

    @isTest
    static void testMethod6(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORPAYAPPS';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;

        insert paymentApp;

        List<String> PAIds = new List<String>();

      


        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;


        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 5';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        insert sovContSheetLine;


        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        Test.stopTest();

    }


    @isTest
    static void testMethod7(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORSOV';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;

        insert paymentApp;

        List<String> PAIds = new List<String>();

      


        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;


        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 6';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        sovContSheetLine.buildertek__Budget_Grouping__c='Change Orders';

        insert sovContSheetLine;


        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        Test.stopTest();

    }

    @isTest
    static void testMethod8(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORSOV';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=10;
        paymentApp.buildertek__Total_Completed__c=10;
        paymentApp.buildertek__Total_Material_Stored_To_Date__c=10;
        paymentApp.buildertek__Imported_Payment_IDs__c='Test';

        insert paymentApp;

        List<String> PAIds = new List<String>();

      


        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        insert payRec2;

        // PAIds.add(payRec.Id);
        // PAIds.add(payRec2.Id);

        
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV 7';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;

        PAIds.add(paymentApp.Id);
        // PAIds.add(payRec2.Id)

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 8';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = null;
        sovContSheetLine.buildertek__Budget_Grouping__c='Change Orders';

        insert sovContSheetLine;


        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        Test.stopTest();

    }

    @isTest
    static void testMethod9(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORSOV';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        insert paymentApp;
        
        List<String> PAIds = new List<String>();

      


        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        insert payRec2;

        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    
        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;

        PAIds.add(paymentApp.Id);
        // PAIds.add(payRec2.Id)

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 9';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = null;
        sovContSheetLine.buildertek__Budget_Grouping__c='Change Orders';

        sovContSheetLine.buildertek__Scheduled_Value__c=1000;
        sovContSheetLine.buildertek__Work_Completed_from_Previous_Application__c=2000;
        sovContSheetLine.buildertek__Work_Completed__c=1000;
        sovContSheetLine.buildertek__Material_Presently_Stored__c=2000;
        // sovContSheetLine.buildertek__Total__c=2000;
        // sovContSheetLine.buildertek__New_G_C__c=2000;
        // sovContSheetLine.buildertek__Balance_To_Finish__c=2000;

        insert sovContSheetLine;

       
        String json=		'['+
		'  {'+
		'    "Name": "test",'+
		'    "buildertek__SOV_Continuation_Sheet__c": "'+paymentApp.Id+'"'+
		'  }'+
		']';
       


        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);


        // CreatePaymentApplicationForBudget.ContinuationDetails wrapper= new  CreatePaymentApplicationForBudget.ContinuationDetails();
        // wrapper.continuationSheet=sov;
        // wrapper.sheetLines=null;
        // wrapper.scheduleValueTotal=100;
        // wrapper.workFromPrevAppTotal=200;
        // wrapper.workcompletedTotal=300;
        // wrapper.materialsStoredTotal=100;
        // wrapper.totalCompletedStored=100;
        // wrapper.materialStroredFromPrev=200;
        // wrapper.gcTotal=200;
        // wrapper.balanceTotal=400;
        // wrapper.isApplication=true;
        // wrapper.projectId='test';
      CreatePaymentApplicationForBudget.getContinuationSheetLines(paymentApp.Id);


        CreatePaymentApplicationForBudget.updateFormula(sovContSheetLine.Id , sov.Id , 'buildertek__Material_Presently_Stored__c'  , 1 );

        CreatePaymentApplicationForBudget.createSheetLines(json, paymentApp.Id);

        CreatePaymentApplicationForBudget.saveSignature(sov.Id, 'test' , 'test' ,'test' ,'test');

        CreatePaymentApplicationForBudget.getPaymentRecord(null);
        CreatePaymentApplicationForBudget.checkPeriodTo(null);



        Test.stopTest();

    }
    @isTest
    static void testMethod10(){

        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AP').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='NEWPAYAPP';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=100;
        insert paymentApp;

        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();

        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        payRec.buildertek__Original_Contract_Sum__c=100;

        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        payRec2.buildertek__Original_Contract_Sum__c=100;

        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;
        // buildertek__SOV_Continuation_Sheet_Lines__c list=[Select id , name from buildertek__SOV_Continuation_Sheet_Lines__c LIMIT 1];

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 10';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        String assessmentFormString = JSON.serialize(sovContSheetLine);

        insert sovContSheetLine;

        sovContSheetLine.buildertek__Vendor_Sheet_line_Id__c=sovContSheetLine.Id;
        update sovContSheetLine;

        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContSheetLine.Id);


        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

    
        Test.startTest();
         CreatePaymentApplicationForBudget.acceptsheetline(sheetlineIds , paymentApp.Id);
         Test.stopTest();
    
    }

    
    @isTest
    static void testMethod11(){
      
        buildertek__Budget__c budget = [SELECT Id, Name FROM buildertek__Budget__c LIMIT 1];
        buildertek__SOV_Payment_Application__c paymentApp = [SELECT Id, Name, buildertek__Application__c, buildertek__Retainage__c ,buildertek__Architect__c, buildertek__Contract_Date__c, buildertek__Vendor__c, buildertek__Project__c, buildertek__Contract_For__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>{paymentApp.Id};

        List<String> coId= new  List<String> ();

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        insert co;

        buildertek__Change_Order__c co2=new buildertek__Change_Order__c();
        co2.name='test';
        insert co2;

        coId.add(co.Id);
        coId.add(co2.Id);

        Account acc = new Account();
        acc.Name='test2';
        acc.buildertek__BT_Account_Type__c = 'Vendor';
        insert acc;

        buildertek__Change_Order_Item__c col = new buildertek__Change_Order_Item__c();
        col.buildertek__Change_Order__c = co.Id;
        col.buildertek__Vendor__c = acc.Id;
         insert col;
        
      
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov1 = new buildertek__SOV_Continuation__c();
        sov1.Name = ' Testing SOV';
        sov1.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov1;

        buildertek__SOV_Continuation__c sov2 = new buildertek__SOV_Continuation__c();
        sov2.Name = ' Testing SOV 2 Con';
        sov2.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov2;
      
        List<buildertek__SOV_Continuation__c> sovCon=[SELECT ID , name from buildertek__SOV_Continuation__c];

        

        Test.startTest();
         CreatePaymentApplicationForBudget.createSheetLinesNew(coId , paymentApp.Id);
        Test.stopTest();
        
    
    }
    @isTest
    static void testMethod12(){

        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='NEWPAYAPP';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=100;
        insert paymentApp;

        buildertek__SOV_Payment_Application__c paymentAppList = [SELECT Id, Name, buildertek__Retainage__c , buildertek__Project__c FROM buildertek__SOV_Payment_Application__c   LIMIT 1];

        List<String> PAIds = new List<String>();

        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        payRec.buildertek__Original_Contract_Sum__c=100;

        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        payRec2.buildertek__Original_Contract_Sum__c=100;

        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = payRec.Id;
        insert sov;
        // buildertek__SOV_Continuation_Sheet_Lines__c list=[Select id , name from buildertek__SOV_Continuation_Sheet_Lines__c LIMIT 1];

        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 10';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 100;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        String assessmentFormString = JSON.serialize(sovContSheetLine);

        insert sovContSheetLine;

        sovContSheetLine.buildertek__Vendor_Sheet_line_Id__c=sovContSheetLine.Id;
        update sovContSheetLine;

        List<String> sheetlineIds= new List<String>();
        sheetlineIds.add(sovContSheetLine.Id);


        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

    
        Test.startTest();
         CreatePaymentApplicationForBudget.importContinuationLines(PAIds, payRec.Id);
         Test.stopTest();
    
    }

    @isTest
    static void testMethod13(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORPAYAPPS';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;

        insert paymentApp;

        List<String> PAIds = new List<String>();

      


        buildertek__SOV_Payment_Application__c payRec = new buildertek__SOV_Payment_Application__c();
        payRec.Name = 'Test PAyment';
        payRec.buildertek__Retainage__c = 10;
        payRec.buildertek__Period_To__c = system.today();
        insert payRec;
          
        buildertek__SOV_Payment_Application__c payRec2 = new buildertek__SOV_Payment_Application__c();
        payRec2.Name = 'Test PAyment';
        payRec2.buildertek__Retainage__c = 10;
        payRec2.buildertek__Period_To__c = system.today();
        insert payRec2;

        PAIds.add(payRec.Id);
        PAIds.add(payRec2.Id);

        
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = payRec.Id;
        insert sov;


        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 5';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        insert sovContSheetLine;


        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        Test.stopTest();

    }

  

    @isTest
    static void testMethod14(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORPAYAPPS';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;

        insert paymentApp;

        List<String> PAIds = new List<String>();

       PAIds.add(paymentApp.Id);
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;


        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 5';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = 'test';
        insert sovContSheetLine;

        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        co.buildertek__Is_CO_Imported__c=false;
        co.buildertek__Status__c='Approved';
        co.buildertek__Project__c=project.Id;


        insert co;

       

        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        CreatePaymentApplicationForBudget.getApprovedCOs(project.Id ,paymentApp.Id, paymentApp.Id);


        Test.stopTest();

    }
    @isTest
    static void testMethod15(){
        Id paymentRecordType = Schema.SObjectType.buildertek__SOV_Payment_Application__c.getRecordTypeInfosByName().get('AR').getRecordTypeId();


        buildertek__SOV_Payment_Application__c paymentApp = new buildertek__SOV_Payment_Application__c();
        paymentApp.Name = 'Testing paymentApp';
        paymentApp.buildertek__Retainage__c = 5;
        paymentApp.buildertek__Is_Pay_App_Created_For__c='FORVENDORPAYAPPS';
        paymentApp.buildertek__Period_To__c = system.today();
        paymentApp.RecordTypeId = paymentRecordType;
        paymentApp.buildertek__Original_Contract_Sum__c=10;
        paymentApp.buildertek__Total_Completed__c=10;
        paymentApp.buildertek__Total_Material_Stored_To_Date__c=10;
        paymentApp.buildertek__Imported_Payment_IDs__c='Test';
        insert paymentApp;

        List<String> PAIds = new List<String>();

       PAIds.add(paymentApp.Id);
        ContinuationSheetLineTriggerHandler.blnSkipAterInsertSheetLineTrigger=true;
        ContinuationSheetLineTriggerHandler.blnSkipSheetLineTrigger=true;

    


        buildertek__SOV_Continuation__c sov = new buildertek__SOV_Continuation__c();
        sov.Name = ' Testing SOV';
        sov.buildertek__SOV_Payment_Application__c = paymentApp.Id;
        insert sov;


        buildertek__SOV_Continuation_Sheet_Lines__c sovContSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
        sovContSheetLine.Name  = 'Testing SOV 5';
        sovContSheetLine.buildertek__SOV_Continuation_Sheet__c = sov.Id;
        sovContSheetLine.buildertek__Description_of_Work__c = 'Test Description';
        sovContSheetLine.buildertek__Grouping__c  = '1st Floor';
        sovContSheetLine.buildertek__Item_No__c  = 1;
        sovContSheetLine.buildertek__Vendor_SOV_Line_Id__c  = null;
        insert sovContSheetLine;

        buildertek__Project__c project=[Select Id , name From buildertek__Project__c LIMIT 1];

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        co.buildertek__Is_CO_Imported__c=false;
        co.buildertek__Status__c='Approved';
        co.buildertek__Project__c=project.Id;


        insert co;

      

        Test.startTest();
        CreatePaymentApplicationForBudget.importContinuationLines(PAIds, paymentApp.Id);

        CreatePaymentApplicationForBudget.getApprovedCOs(project.Id ,paymentApp.Id, paymentApp.Id);


        Test.stopTest();

    }

}