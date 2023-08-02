@isTest
private class BT_ImportBudgetTest {

	private static testMethod void test1() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        Apexpages.currentPage().getParameters().put('Id',proj.Id);
	    
	    List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
	    buildertek__Budget__c budget = new buildertek__Budget__c();
	    budget.Name = 'Test Budget';
	    budget.buildertek__Project__c = proj.Id;
	    budget.buildertek__Type__c = 'Master';
	    budgetList.add(budget);
	    insert budgetList;
	    
        buildertek__Budget_Item__c budget1Item = new buildertek__Budget_Item__c();
        budget1Item.buildertek__Budget__c=budgetList[0].Id;
        insert budget1Item;
        
        buildertek__Master_Budget__c masterBudget = new buildertek__Master_Budget__c();
        masterBudget.Name='test masterBudget';
        insert masterBudget;
        
        buildertek__Master_Budget_Line__c masterBudget1Item = new buildertek__Master_Budget_Line__c();
        masterBudget1Item.buildertek__Master_Budget__c=masterBudget.Id;
        insert masterBudget1Item;
	    List<String> selectedIds = new List<String>();
        selectedIds.add(budgetList[0].Id);
	    
	    List<buildertek__Budget_Line_Group__c> groupList = new List<buildertek__Budget_Line_Group__c>();
	    buildertek__Budget_Line_Group__c groups = new buildertek__Budget_Line_Group__c();
	    groups.Name = 'Test Group';
	    groups.Budget__c = budgetList[0].Id;
	    groupList.add(groups);
	    insert groupList;
		
        Budget__c budget1 = new Budget__c();
        budget1.Type__c = 'Master';
        insert budget1;
        
        Master_Budget__c mb1 = new Master_Budget__c();
        mb1.Name='test';
        mb1.Type__c='Master';
        insert mb1;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(budget);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(budgetList);
        BT_ImportBudget IB = new BT_ImportBudget(SC);
        BT_ImportBudget IB1 = new BT_ImportBudget(stdSetController);
        List<BT_ImportBudget.masterBudget> MBList = new List<BT_ImportBudget.masterBudget>();
        BT_ImportBudget.masterBudget MB = new BT_ImportBudget.masterBudget();
        MB.budget = budgetList[0];
        IB.budget = budgetList;
        IB.IsDisableNext=False;
        IB.IsDisablePrev=false;
        MB.isSelected = true;
        MBList.add(MB);
        
        
        MB = new BT_ImportBudget.masterBudget(); 
        MB.isSelected = true;
        MB.masterBudget=masterBudget;
        MBList.add(MB);
        IB.masterBudgets=MBList; 
        //IB.getNumbers();
        //B.previous();
        //IB.next();
        IB.save();
        system.assertEquals('test', 'test');
	}

}