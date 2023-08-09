@isTest
public class BTServiceRequestAssignmentTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testBTServiceRequestAssignment1() {
        List<Service_Request__c> listServiceRequests = BTServiceRequestAssignment.getAllSR();
        System.assertEquals(0, listServiceRequests.size());
        BTServiceRequestAssignment.getAllAvailableResources();
        BTServiceRequestAssignment.getListViews();
        BTServiceRequestAssignment.getProductList();
        BTServiceRequestAssignment.addNewProduct();
        BTServiceRequestAssignment.getProductFamily();
        BTServiceRequestAssignment.assignedResources('', '');
        BTServiceRequestAssignment.assignedResources([SELECT Id FROM Service_Request__c LIMIT 1].Id, UserInfo.getUserId());
    }
}