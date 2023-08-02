@isTest
public class ChangeOrderInvoiceControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    static testMethod void TestChangeOrderInvoiceAttachment() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        Change_Order__c changeOrder = new Change_Order__c(Project__c = [SELECT Id FROm Project__c LIMIT 1].Id,
                                                          buildertek__Customer_Account__c = acc.id);
        insert changeOrder;
        
        Change_Order_Item__c changeOrderItem = new Change_Order_Item__c(Change_Order__c = changeOrder.Id);
        insert changeOrderItem;
        Test.startTest();
        PageReference pgRef = Page.ChangeOrderInvoice; //Create Page Reference - 'ChangeOrderInvoice' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        ApexPages.currentPage().getParameters().put('id',changeOrder.Id);//Pass Id to page
        
        ChangeOrderInvoiceController controller = new  ChangeOrderInvoiceController();
        Test.stopTest();
        
        
    }
}