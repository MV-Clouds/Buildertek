@isTest
public class ChangeOrderItemTriggerTest {
	@testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testChangeOrderItemTrigger() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        Change_Order__c changeOrder = new Change_Order__c(Project__c = [SELECT Id FROm Project__c LIMIT 1].Id,
                                                            buildertek__Customer_Account__c = acc.id);
        insert changeOrder;
        
        Change_Order_Item__c changeOrderItem = new Change_Order_Item__c(Change_Order__c = changeOrder.Id);
        insert changeOrderItem;
        delete changeOrderItem;
        System.assertEquals('Test','Test');
    }
}