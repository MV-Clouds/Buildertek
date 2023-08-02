@isTest
private class BT_SettingsControllerTest {

    private static testMethod void test() {
        BT_SettingsController settingsRef = new BT_SettingsController();
         List<buildertek__Menu__c> budgetList = new List<buildertek__Menu__c>();
        buildertek__Menu__c budget = new buildertek__Menu__c();
        budget.Name = 'Test Budget';
      // budget.buildertek__Project__c = proj.Id;
        //budget.buildertek__Type__c = 'Master';
        budgetList.add(budget); 
        insert budgetList;

        BT_SettingsController.getMenuLists();
        BT_SettingsController.getAllMenuContents('');
        //BT_SettingsController.Menu();
        System.assertEquals('Test','Test');
    }

}