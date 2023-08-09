@isTest
public class InvoicePDFControllerTest {
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test 1';
        con.Email='test@test.com';
        insert con;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Billings__c billingInvoice = new buildertek__Billings__c();
        billingInvoice.buildertek__Project__c = project.Id;
        insert billingInvoice;
        
        buildertek__Contract__c contractInvoice = new buildertek__Contract__c();
        contractInvoice.buildertek__Project__c = project.Id;
        insert contractInvoice;
        
        buildertek__Change_Order__c changeOrderInvoice = new buildertek__Change_Order__c();
        changeOrderInvoice.buildertek__Project__c = project.Id;
        insert changeOrderInvoice;
    }
    static testMethod void TestBillingTest() {
        Account acc =[Select id,Name from Account where Name ='Test 1'];
        
        buildertek__Project__c project = [Select id,Name from buildertek__Project__c where buildertek__Account__c =:acc.Id];
        
        buildertek__Billings__c billing = [Select id,Name from buildertek__Billings__c where buildertek__Project__c =:project.Id];
        
        Test.startTest();
        PageReference billings = Page.BT_Invoice; //Create Page Reference - 'BT_Invoice' is the name of Page
        Test.setCurrentPage(billings); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id',billing.Id);//Pass Id to page
        
        //InvoicePDFController controller = new  InvoicePDFController();
        Test.stopTest();
        
    }
    static testMethod void TestChangeOrderTest() {
        Account acc =[Select id,Name from Account where Name ='Test 1'];
        
        buildertek__Project__c project = [Select id,Name from buildertek__Project__c where buildertek__Account__c =:acc.Id];
        
        Change_Order__c changeOrder = [Select id,Name from Change_Order__c where buildertek__Project__c =:project.Id];
        
        Test.startTest();
        PageReference changeOrders = Page.BT_Invoice; //Create Page Reference - 'BT_Invoice' is the name of Page
        Test.setCurrentPage(changeOrders); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id',changeOrder.Id);//Pass Id to page
        
     //   InvoicePDFController controller = new  InvoicePDFController();
        Test.stopTest();
         
    }
    static testMethod void TestContractTest() {
        Account acc =[Select id,Name from Account where Name ='Test 1'];
        
        buildertek__Project__c project = [Select id,Name from buildertek__Project__c where buildertek__Account__c =:acc.Id];
        
        buildertek__Contract__c contract = [Select id,Name from buildertek__Contract__c where buildertek__Project__c =:project.Id];
        
        Test.startTest();
        PageReference contracts = Page.BT_Invoice; //Create Page Reference - 'BT_Invoice' is the name of Page
        Test.setCurrentPage(contracts); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id',contract.Id);//Pass Id to page
        
        //InvoicePDFController controller = new  InvoicePDFController();
        Test.stopTest();
        
    }
}