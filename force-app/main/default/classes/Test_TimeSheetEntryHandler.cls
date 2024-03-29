@isTest
private class Test_TimeSheetEntryHandler {

    @isTest
    static void testAfterInsert() {

        buildertek__Budget__c testbudget = new buildertek__Budget__c();
        insert testbudget;

        Contact con = new Contact();
        con.LastName = 'jones';
        con.buildertek__Hourly_Rate__c = 10;
        insert con;

        buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
        budgetItem.buildertek__Budget__c = testbudget.Id;
        budgetItem.Name = 'Test Budget Item';
        budgetItem.buildertek__Labor_TimeSheet__c = 100; // Assuming initial labor time
        insert budgetItem;

        buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
        timeSheet.buildertek__BT_Budget__c = testbudget.Id;
        timeSheet.buildertek__BT_Budget_Line__c = budgetItem.Id;
        timeSheet.buildertek__Contact__c = con.Id;
        insert timeSheet;

        buildertek__BT_Time_Sheet_Entry__c timeSheetEntry = new buildertek__BT_Time_Sheet_Entry__c();
        timeSheetEntry.buildertek__BT_Time_Sheet__c = timeSheet.Id;
        insert timeSheetEntry;

        // Call the method to be tested
        Test.startTest();
        TimeSheetEntryHandler handler = new TimeSheetEntryHandler();
        handler.afterInsert(new List<buildertek__BT_Time_Sheet_Entry__c>{timeSheetEntry});
        Test.stopTest();

        // Query the updated records and assert the results
        List<buildertek__BT_Time_Sheet_Entry__c> updatedTimeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE Id = :timeSheetEntry.Id];
        System.assertEquals(1, updatedTimeSheetEntries.size());
        System.assertEquals(timeSheet.Id, updatedTimeSheetEntries[0].buildertek__BT_Time_Sheet__c);

        // Add more assertions as needed to verify the behavior of the method
    }

//     @isTest
//     static void testAfterUpdate() {
//         // Create test data
//         buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
//         // Populate necessary fields in timeSheet
//         insert timeSheet;

//         buildertek__BT_Time_Sheet_Entry__c oldTimeSheetEntry = new buildertek__BT_Time_Sheet_Entry__c();
//         // Populate necessary fields in oldTimeSheetEntry
//         oldTimeSheetEntry.buildertek__BT_Time_Sheet__c = timeSheet.Id;
//         // Insert oldTimeSheetEntry
//         insert oldTimeSheetEntry;

//         buildertek__BT_Time_Sheet_Entry__c newTimeSheetEntry = new buildertek__BT_Time_Sheet_Entry__c();
//         // Populate necessary fields in newTimeSheetEntry
//         newTimeSheetEntry.Id = oldTimeSheetEntry.Id;
//         // Update newTimeSheetEntry
//         update newTimeSheetEntry;

//         // Call the method to be tested
//         Test.startTest();
//         TimeSheetEntryHandler handler = new TimeSheetEntryHandler();
//         handler.afterUpdate(new List<buildertek__BT_Time_Sheet_Entry__c>{newTimeSheetEntry}, new List<buildertek__BT_Time_Sheet_Entry__c>{oldTimeSheetEntry});
//         Test.stopTest();

//         // Query the updated records and assert the results
//         List<buildertek__BT_Time_Sheet_Entry__c> updatedTimeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE Id = :oldTimeSheetEntry.Id];
//         System.assertEquals(1, updatedTimeSheetEntries.size());
//         System.assertEquals(timeSheet.Id, updatedTimeSheetEntries[0].buildertek__BT_Time_Sheet__c);

//         // Add more assertions as needed to verify the behavior of the method
//     }
//     @isTest
//     static void testRecalculateTimeSheetTotals() {
//         // Create test data
//         buildertek__Budget__c testbudget = new buildertek__Budget__c();
//         insert testbudget;


//         buildertek__BT_Time_Sheet__c timeSheet = new buildertek__BT_Time_Sheet__c();
//         // Populate necessary fields in timeSheet
//         insert timeSheet;

//         buildertek__BT_Time_Sheet_Entry__c timeSheetEntry = new buildertek__BT_Time_Sheet_Entry__c();
//         // Populate necessary fields in timeSheetEntry
//         timeSheetEntry.buildertek__BT_Time_Sheet__c = timeSheet.Id;
//         timeSheetEntry.buildertek__Start_Time__c = Datetime.now();
//         timeSheetEntry.buildertek__End_Time__c = Datetime.now().addHours(2);
//         // Insert timeSheetEntry
//         insert timeSheetEntry;

//         // Call the method to be tested
//         Test.startTest();
//         TimeSheetEntryHandler.recalculateTimeSheetTotals(new Set<Id>{timeSheet.Id});
//         Test.stopTest();

//         // Query the updated records and assert the results
//         List<buildertek__BT_Time_Sheet_Entry__c> updatedTimeSheetEntries = [SELECT Id, buildertek__BT_Time_Sheet__c FROM buildertek__BT_Time_Sheet_Entry__c WHERE Id = :timeSheetEntry.Id];
//         System.assertEquals(1, updatedTimeSheetEntries.size());
//         System.assertEquals(timeSheet.Id, updatedTimeSheetEntries[0].buildertek__BT_Time_Sheet__c);

//         // Add more assertions as needed to verify the behavior of the method
//     }
}
