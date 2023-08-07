@isTest
private class NewScheduleItemControllerTest {

	@isTest
    static void testGetPurchaseOrderData() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        insert con;
        
        // Create a test WorkOrder record
        WorkOrder testWorkOrder = new WorkOrder();
        testWorkOrder.buildertek__Project__c = proj.Id; // Replace with a valid Project Id
        testWorkOrder.ContactId = con.Id; // Replace with a valid Contact Id
        insert testWorkOrder;

        // Call the method being tested
        Test.startTest();
        WorkOrder result = NewScheduleItemController.getPurchaseOrderData(testWorkOrder.Id);
        Test.stopTest();

        // Assert the results
        System.assertEquals(testWorkOrder.Id, result.Id);
        System.assertEquals(testWorkOrder.buildertek__Project__c, result.buildertek__Project__c);
        System.assertEquals(testWorkOrder.ContactId, result.ContactId);
    }
    
    @isTest
    static void testGetSchedulelist() {
        // Create a test Project record
        Project__c testProject = new Project__c(Name = 'Test Project');
        insert testProject;

        // Create some test Schedule records related to the test Project
        List<Schedule__c> testSchedules = new List<Schedule__c>{
            new Schedule__c(buildertek__Description__c = 'Description 1', buildertek__Project__c = testProject.Id),
            new Schedule__c(buildertek__Description__c = 'Description 2', buildertek__Project__c = testProject.Id),
            new Schedule__c(buildertek__Description__c = 'Description 3', buildertek__Project__c = testProject.Id)
        };
        insert testSchedules;

        // Call the method being tested
        Test.startTest();
        List<NewScheduleItemController.ScheduleWrap> result = NewScheduleItemController.getSchedulelist(testProject.Id);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(testSchedules.size(), result.size(), 'Returned list size should be equal to the number of test schedules');

        for (Integer i = 0; i < result.size(); i++) {
            NewScheduleItemController.ScheduleWrap wrap = result[i];
            Schedule__c schedule = testSchedules[i];
            System.assertEquals(schedule.Id, wrap.getSchedulesList.Id, 'Schedule Id should match');
            System.assertEquals(schedule.buildertek__Description__c, wrap.getSchedulesList.buildertek__Description__c, 'Schedule Description should match');
            System.assertEquals(false, wrap.scheduleCheckbox, 'scheduleCheckbox should be initialized as false');
        }
    }
    
     @isTest
    public static void testInsertScheduleTask() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        List<buildertek__Schedule__c> schList = new List<buildertek__Schedule__c>();
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Project__c = proj.Id;
        schList.add(sch);
        insert schList;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.email='test@gmail.com';
        insert con;
        
        buildertek__Project_Task__c schTask = (buildertek__Project_Task__c)buildertek__Project_Task__c.sObjectType.newSObject(null, true);
        schTask.Name = 'Test Task';
        schTask.buildertek__Schedule__c = schList[0].Id;
        schTask.buildertek__Start__c=System.Now().date();
        insert schTask;

        buildertek__Project_Task__c dependencyTask = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today(),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id
        );
        insert dependencyTask;
        buildertek__Project_Task__c dependencyTask1 = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today().addDays(5),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id
        );
        insert dependencyTask1;
        
        buildertek__Project_Task__c dependencyTask2 = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today(),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id,
            buildertek__Lag__c = 1.00
        );
        insert dependencyTask2;
        buildertek__Project_Task__c dependencyTask3 = new buildertek__Project_Task__c(
            Name = 'Dependency Task',
            buildertek__Finish__c = Date.today().addDays(5),
            buildertek__Start__c = Date.today(),
            buildertek__Schedule__c = schList[0].Id,
            buildertek__Lag__c = 1.00
        );
        insert dependencyTask3;
        Date startDate = Date.today().addDays(2);

        Test.startTest();
        // Call the method to test
        String taskId = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask.Id, startDate, proj.Id, con.Id);
        String taskId1 = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask1.Id, startDate, proj.Id, con.Id);
        String taskId2 = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask2.Id, startDate, proj.Id, con.Id);
        String taskId3 = NewScheduleItemController.insertScheduleTask('Test Task', schList[0].Id, dependencyTask3.Id, startDate, proj.Id, con.Id);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, taskId, 'Task Id should not be null');
        // Add more assertions as needed based on the expected behavior of the method
    }

    @isTest
    public static void testModifyDate() {
        // Test data setup
        Date testDate1 = Date.newInstance(2023, 8, 5); // A Friday
        Date testDate2 = Date.newInstance(2023, 8, 4); // A Thursday

        Test.startTest();
        // Call the method to test
        Date resultDate1 = NewScheduleItemController.modifyDate(testDate1);
        Date resultDate2 = NewScheduleItemController.modifyDate(testDate2);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(Date.newInstance(2023, 8, 7), resultDate1, 'Date should be adjusted to the next Monday (2023-08-07)');
        System.assertEquals(Date.newInstance(2023, 8, 4), resultDate2, 'Date should remain unchanged (2023-08-04)');
        // Add more assertions as needed based on the expected behavior of the method
    }
    
    @isTest
    static void testGetPredecessorList() {
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        
        List<buildertek__Schedule__c> schList = new List<buildertek__Schedule__c>();
        buildertek__Schedule__c sch = new buildertek__Schedule__c();
        sch.buildertek__Description__c = 'Test Schedule';
        sch.buildertek__Project__c = proj.Id;
        schList.add(sch);
        insert schList;
        
        Contact con = new Contact();
        con.LastName = 'Test Contact';
        con.email='test@gmail.com';
        insert con;
        
        buildertek__Project_Task__c schTask = (buildertek__Project_Task__c)buildertek__Project_Task__c.sObjectType.newSObject(null, true);
        schTask.Name = 'Test Task';
        schTask.buildertek__Schedule__c = schList[0].Id;
        schTask.buildertek__Start__c=System.Now().date();
        schTask.buildertek__Contractor_Resource__c = con.Id;
        insert schTask;

        buildertek__Project_Task__c testTask1 = new buildertek__Project_Task__c(Name = 'Task 1', buildertek__Schedule__c = schList[0].Id, buildertek__Start__c = System.Now().date());
        buildertek__Project_Task__c testTask2 = new buildertek__Project_Task__c(Name = 'Task 2', buildertek__Schedule__c = schList[0].Id, buildertek__Start__c = System.Now().date());
        List<buildertek__Project_Task__c> testScheduleItems = new List<buildertek__Project_Task__c>{testTask1, testTask2};
        insert testScheduleItems;

        Test.startTest();

        // Call the method to be tested
        Map<String, String> result = NewScheduleItemController.getPredecessorList(schList[0].Id);

        Test.stopTest();

        // Perform assertions
        System.assertEquals(3, result.size());
        System.assertEquals('Task 1', result.get(testTask1.Id));
        System.assertEquals('Task 2', result.get(testTask2.Id));
    }


}