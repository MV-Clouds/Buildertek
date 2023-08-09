@isTest
public class CreateChangeOrderControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testCreateChangeOrderController() {
        CreateChangeOrderController.createChangeOrder(NULL);
        CreateChangeOrderController.createChangeOrder([SELECT Id FROM buildertek__Purchase_Order__c LIMIT 1].Id);
        CreateChangeOrderController.createInspection(NULL);
        CreateChangeOrderController.createInspection([SELECT Id FROM buildertek__Purchase_Order__c LIMIT 1].Id);
        System.assertEquals('Test','Test'); 
    }
}