@IsTest
public class NewBudgetTest {

    @IsTest
    static void testMethod1(){
        buildertek__Budget__c bud = new buildertek__Budget__c();
        bud.Name = 'All';
        insert bud;

        Test.startTest();
            NewBudget.getFieldSet();
            NewBudget.getDropDown('Account', 'Name');
            NewBudget.getListViews();
        Test.stopTest();
    }
}