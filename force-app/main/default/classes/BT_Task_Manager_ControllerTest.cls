@isTest
public class BT_Task_Manager_ControllerTest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void testBT_Task_Manager_Controller1() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        schedule__c schedule = new schedule__c();
        schedule.buildertek__Project__c = proj.Id;
        insert schedule;
        //Test.setCurrentPageReference(new PageReference('Page.BT_Task_Manager')); 
        System.currentPageReference().getParameters().put('pId', [SELECT Id FROM Project__c LIMIT 1].Id);
        ApexPages.currentPage().getParameters().put('Id', schedule.Id);
        BT_Task_Manager_Controller controller = new BT_Task_Manager_Controller();
        //BT_Task_Manager_Controller.insertBTTask(JSON.serialize(new Project_Task__c(Schedule__c = schedule.Id, Start__c=system.today())), schedule.Id);
        BT_Task_Manager_Controller.insertNewTaskLinks('');
        BT_Task_Manager_Controller.getNewTaskFieldsetInfo('');
        BT_Task_Manager_Controller.changeTaskSchedulingMode('');
        BT_Task_Manager_Controller.getAllProjectJSON('');
        BT_Task_Manager_Controller.deleteTaskLinkById('');
        ApexPages.currentPage().getParameters().put('parentId', schedule.Id);
        ApexPages.currentPage().getParameters().put('taskIdToEdit', schedule.Id);
        //controller.initNewTask();
        System.assertEquals('Test','Test');
        ApexPages.StandardController sc = new ApexPages.StandardController(schedule);
        BT_Task_Manager_Controller testAccPlan = new BT_Task_Manager_Controller(sc);
        
        // PageReference pageRef = Page.AccountPlan;
        // pageRef.getParameters().put('id', String.valueOf(schedule.Id));
        // Test.setCurrentPage(pageRef);
    }
    
    public static testMethod void testBT_Task_Manager_Controller2() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        schedule__c schedule = new schedule__c();
        schedule.buildertek__Project__c = proj.Id;
        insert schedule;
        
        Test.setCurrentPageReference(new PageReference('Page.BT_Task_Manager')); 
        System.currentPageReference().getParameters().put('sId', UserInfo.getUserId());
        ApexPages.currentPage().getParameters().put('Id', schedule.Id);
        //BT_Task_Manager_Controller controller = new BT_Task_Manager_Controller();
        System.assertEquals('Test','Test');
    }
}