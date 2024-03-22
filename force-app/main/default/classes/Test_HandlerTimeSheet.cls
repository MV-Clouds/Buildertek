@isTest
private class Test_HandlerTimeSheet {

    @isTest static void testBeforeInsert() {
        // Create test data
        buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c(Name='Army');
        insert budgetLineGroup;
        buildertek__Budget__c testbudget = new buildertek__Budget__c();
        insert testbudget;
        List<buildertek__BT_Time_Sheet__c> newTimeSheets = new List<buildertek__BT_Time_Sheet__c>();
        buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
        timeSheet.Name = 'Test Time Sheet';
        timeSheet.buildertek__BT_Budget__c = testbudget.Id;
        newTimeSheets.add(timeSheet);

        // Call the method to test
        HandlerTimeSheet handler = new HandlerTimeSheet();
        Test.startTest();
        handler.beforeInsert(newTimeSheets);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(1, [SELECT count() FROM buildertek__Budget_Item__c]);
        System.assertNotEquals(null, newTimeSheets[0].buildertek__BT_Budget_Line__c);
    }

    @isTest static void testAfterInsert() {
        // Create test data
        List<buildertek__BT_Time_Sheet__c> newTimeSheets = new List<buildertek__BT_Time_Sheet__c>();
        buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
        insert timeSheet;
        newTimeSheets.add(timeSheet);

        // Call the method to test
        HandlerTimeSheet handler = new HandlerTimeSheet();
        Test.startTest();
        handler.afterInsert(newTimeSheets);
        Test.stopTest();

        // Perform assertions
        // Add assertions as needed
    }

    @isTest static void testBeforeUpdate() {
        // Create test data
       
        buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
        insert timeSheet;
        
        Map<Id, buildertek__BT_Time_Sheet__c> oldTimeSheets = new Map<Id, buildertek__BT_Time_Sheet__c>{ timeSheet.Id => timeSheet };

        buildertek__Budget__c testbudget = new buildertek__Budget__c();
        insert testbudget;

        timeSheet.buildertek__BT_Budget__c = testbudget.Id;
        update timeSheet;


        List<buildertek__BT_Time_Sheet__c> newTimeSheets = new List<buildertek__BT_Time_Sheet__c>{ timeSheet };

        // Call the method to test
        HandlerTimeSheet handler = new HandlerTimeSheet();
        Test.startTest();
        handler.beforeUpdate(newTimeSheets, oldTimeSheets);
        Test.stopTest();

        // Perform assertions
        // Add assertions as needed
    }

    @isTest static void testAfterUpdate() {
        // Create test data
        buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
        insert timeSheet;

        Map<Id, buildertek__BT_Time_Sheet__c> oldTimeSheets = new Map<Id, buildertek__BT_Time_Sheet__c>{ timeSheet.Id => timeSheet };

        List<buildertek__BT_Time_Sheet__c> newTimeSheets = new List<buildertek__BT_Time_Sheet__c>{ timeSheet };

        // Call the method to test
        HandlerTimeSheet handler = new HandlerTimeSheet();
        Test.startTest();
        handler.afterUpdate(newTimeSheets, oldTimeSheets);
        Test.stopTest();

        // Perform assertions
        // Add assertions as needed
    }

@isTest static void testBeforeDelete() {
    // Create test data
    buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
    timeSheet.buildertek__BT_Budget_Line__c = 'BudgetLineId';
    insert timeSheet;

    List<buildertek__BT_Time_Sheet__c> oldTimeSheets = new List<buildertek__BT_Time_Sheet__c>{ timeSheet };

    // Create related budget item records
    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
    budgetItem.Name = 'Test Budget Item';
    budgetItem.buildertek__Labor_TimeSheet__c = 100; // Assuming initial labor time
    insert budgetItem;

    timeSheet.buildertek__BT_Budget_Line__c = budgetItem.Id;
    update timeSheet;

    // Call the method to test
    HandlerTimeSheet handler = new HandlerTimeSheet();
    Test.startTest();
    handler.beforeDelete(oldTimeSheets);
    Test.stopTest();

    // Perform assertions
    List<buildertek__Budget_Item__c> queriedBudgetItems = [SELECT Id, buildertek__Labor_TimeSheet__c FROM buildertek__Budget_Item__c WHERE Id = :budgetItem.Id];
    System.assertEquals(1, queriedBudgetItems.size());
    System.assertEquals(0, queriedBudgetItems[0].buildertek__Labor_TimeSheet__c);
}

}
