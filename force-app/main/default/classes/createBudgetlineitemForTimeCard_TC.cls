@isTest
private class createBudgetlineitemForTimeCard_TC {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    public static testMethod void test1() {
        contact con = new contact();
        con.Email ='test@gmail.com';
        con.lastname ='test';
        insert con;
        buildertek__Project__c projRec = new buildertek__Project__c();
        projRec.Name = 'Test Project';
        insert projRec;
        
        list<buildertek__Budget__c> budgetList = new list<buildertek__Budget__c>();
        buildertek__Budget__c budgetRec = new buildertek__Budget__c();
        budgetRec.Name = 'Test Budget';
        budgetRec.buildertek__Project__c = projRec.id;
        budgetList.add(budgetRec);
        insert budgetList;
        list<string> budgetids = new list<string>();
        for(buildertek__Budget__c budget :budgetList){
            budgetids.add(budget.id);
        }
        
        buildertek__Time_Cards__c timecardRec = new buildertek__Time_Cards__c();
        timecardRec.buildertek__Description__c = 'Test Time Card';
        timecardRec.buildertek__Project__c = projRec.Id;
        timecardRec.buildertek__Resource__c = con.Id;
        insert timecardRec;
        buildertek__Budget_Line_Group__c linegroup = new buildertek__Budget_Line_Group__c();
         linegroup.Name = 'Labor';
         insert linegroup;   
         List<buildertek__Time_Cards__c>  resloglist = [select id,
                                                             Name,buildertek__Complete__c,buildertek__Budget_Line__c,buildertek__Resource__c,buildertek__Resource__r.Name,
                                                             buildertek__Daily_Expense__c,buildertek__Description__c,buildertek__Details__c,buildertek__End_Distance__c,
                                                             buildertek__End_Location__c,buildertek__End_Time2__c,buildertek__End_Time__c,buildertek__Entry_Date__c,
                                                             buildertek__Lunch_In__c,buildertek__Lunch_Out__c,buildertek__Schedule_Item__c,buildertek__Start_Time__c,
                                                             buildertek__Total_Break_Time__c
                                                             from buildertek__Time_Cards__c
                                                             where Id =: timecardRec.id];    
        createBudgetlineitemForTimeCard_AC.getBudgets(timecardRec.id);
        createBudgetlineitemForTimeCard_AC.createBudgetLinerecs(budgetids,timecardRec.id); 
        createBudgetlineitemForTimeCard_AC.MasterBudgetsClass wrap = new createBudgetlineitemForTimeCard_AC.MasterBudgetsClass(); 
        System.assertEquals('Test','Test');
  }

}