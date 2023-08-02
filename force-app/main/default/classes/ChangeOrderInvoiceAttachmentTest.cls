@istest
public class ChangeOrderInvoiceAttachmentTest {
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
        PageReference pgRef = Page.ChangeOrderInvoiceAttachment; //Create Page Reference - 'ChangeOrderInvoiceAttachment' is the name of Page
        Test.setCurrentPage(pgRef); //Set the page for Test Method
        //Pass parentId to page
        ApexPages.currentPage().getParameters().put('parentId', changeOrder.Id);
        
        ChangeOrderInvoiceAttachmentController controller = new  ChangeOrderInvoiceAttachmentController();
        controller.attachPDF();
        controller.redirectToPage();
        Test.stopTest();
    }
}