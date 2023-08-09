@isTest
public with sharing class CreateRFQForPRLControllerTest {
    @TestSetup
    static void RFQForPRL() {

        buildertek__Pricing_Request__c price = new buildertek__Pricing_Request__c();
        price.Name = 'test';
        insert price;

        buildertek__Pricing_Request_Line__c priceLine = new buildertek__Pricing_Request_Line__c();
        priceLine.buildertek__Description__c = 'test';
        priceLine.buildertek__Pricing_Request__c = price.Id;
        insert priceLine;
        
        buildertek__Expense__c expense = new buildertek__Expense__c();
        expense.buildertek__Description__c = 'Test';
        expense.buildertek__Type__c = 'Material';
        expense.buildertek__Payment_Method__c = 'Cash';
        expense.buildertek__Amount__c = 12345;        
        insert expense;

        // buildertek__Schedule__c schedule = new buildertek__Schedule__c();
        // schedule.buildertek__Description__c = 'Test';
        // insert schedule;

        // buildertek__Project_Task__c pTask = new buildertek__Project_Task__c();
        // pTask.Name = 'Test';
        // pTask.buildertek__Start__c = System.today();
        // pTask.buildertek__Schedule__c = schedule.Id;
        // insert pTask;

        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.buildertek__Description__c = 'test';
        insert rfq;

        buildertek__Pricing_Request_Line__c reqLine = new buildertek__Pricing_Request_Line__c();
        reqLine.buildertek__Description__c = 'test';
        reqLine.buildertek__Pricing_Request__c = price.Id;
        reqLine.buildertek__RFQ__c = rfq.Id;
        insert reqLine;

    }
    @isTest
    static void RFQForPRL1(){

        Contact con = new Contact();
        con.LastName = 'test';
        insert con;

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'test';
        project.buildertek__Administrator__c = con.Id;
        insert project;

        buildertek__Budget__c budget = new buildertek__Budget__c();
        budget.Name = 'test';
        budget.buildertek__Project__c = project.Id;
        insert budget;

        buildertek__Budget_Item__c bItem = new buildertek__Budget_Item__c();
        bItem.Name = 'Test';
        bItem.buildertek__Budget__c = budget.Id;
        insert bItem;

        buildertek__Admin_Interface_Node_Configuration__c Admin = new buildertek__Admin_Interface_Node_Configuration__c();
        Admin.Name = 'Budget Configuration';
        Admin.buildertek__Automatically_add_Expense_to_Budget__c = true;
        Admin.buildertek__Automatically_add_Time_Card_to_Budget__c = true;
        insert Admin;

        ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
        buildertek__Pricing_Request_Line__c priceLine = [SELECT Id,Name FROM buildertek__Pricing_Request_Line__c LIMIT 1];

        ListView lv = [SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible, CreatedDate, 
                        CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LastViewedDate, LastReferencedDate 
                        FROM ListView WHERE SobjectType = 'buildertek__Expense__c'];

        buildertek__RFQ__c rfq = [SELECT Id,Name FROM buildertek__RFQ__c LIMIT 1];

        buildertek__Pricing_Request_Line__c reqLine = [SELECT Id,Name FROM buildertek__Pricing_Request_Line__c LIMIT 1];

       // CreateRFQForPRLController.getRecordField(priceLine.Id);
        CreateRFQForPRLController.getRecordField(project.Id);
        CreateRFQForPRLController.getFieldSet('buildertek__Project__c','test set');
        CreateRFQForPRLController.getDropDown('buildertek__Project__c','Name');
        CreateRFQForPRLController.getParentObjRec(project.Id);
        CreateRFQForPRLController.getBudgetNameFromProject(project.Id);
        CreateRFQForPRLController.getBudgetNameFromProject('');
        CreateRFQForPRLController.getobjectName(project.Id);
        CreateRFQForPRLController.getListViews();
        CreateRFQForPRLController.getbudgetrecord(Admin.Id);
        CreateRFQForPRLController.getbudgettimecardrecord(Admin.Id);
        CreateRFQForPRLController.duplicateExpense('12345','Material','Cash','test');
        CreateRFQForPRLController.getBudgets(budget.Id);
        //CreateRFQForPRLController.getproschedule(pTask.Id);  
        CreateRFQForPRLController.getprobudgetline(bItem.Id);
        CreateRFQForPRLController.updateRfqq(reqLine.Id,rfq.Id);
        CreateRFQForPRLController.checkIsRFQ(reqLine.Id);        
    }
    @isTest
    static void RFQForPRL2(){

        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'test';
        insert project;

        buildertek__Admin_Interface_Node_Configuration__c Admin = new buildertek__Admin_Interface_Node_Configuration__c();
        Admin.Name = 'test';
        Admin.buildertek__Automatically_add_Expense_to_Budget__c = false;
        Admin.buildertek__Automatically_add_Time_Card_to_Budget__c = false;
        insert Admin;

        Test.startTest();

        CreateRFQForPRLController.getRecordField(project.Id);
        CreateRFQForPRLController.getbudgetrecord(Admin.Id);
        CreateRFQForPRLController.getbudgettimecardrecord(Admin.Id);
        CreateRFQForPRLController.duplicateExpense('12345','ab','abc','terest');
        CreateRFQForPRLController.getDropDown('buildertek__Project__c','abc');

        Test.stopTest();
    }
}