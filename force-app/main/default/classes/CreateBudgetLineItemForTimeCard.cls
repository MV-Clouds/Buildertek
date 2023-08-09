public with sharing class CreateBudgetLineItemForTimeCard {

    public static void updateBudgetItem(Id timeCardId){
        buildertek__Time_Cards__c timeCardData = [Select Id,buildertek__Budget__c,buildertek__Daily_Expense__c,buildertek__Resource__c , buildertek__Resource__r.Name , buildertek__Budget_Line__c, Name from buildertek__Time_Cards__c where Id =:timeCardId limit 1];
        buildertek__Budget_Line_Group__c  budgetlinegroup =[select id,Name from buildertek__Budget_Line_Group__c  where Name = 'Labor' limit 1];

        buildertek__Budget_Item__c budgetitem = new buildertek__Budget_Item__c();
        budgetitem.buildertek__Budget__c = timeCardData.buildertek__Budget__c;
        budgetitem.Name = timeCardData.buildertek__Resource__r.Name;
        budgetitem.buildertek__Quantity__c = 1; 
        budgetitem.buildertek__UOM__c = 'Each';
        budgetitem.buildertek__Group__c  = budgetlinegroup.id; 
        budgetitem.buildertek__Labor__c = timeCardData.buildertek__Daily_Expense__c;
        insert budgetitem;

        timeCardData.buildertek__Budget_Line__c = budgetitem.id;
        update timeCardData;

    }

    public static void deleteBudgetItem(Id timecardId, Id BudgetLineId){
        System.debug('deleteBudgetItem::::');
        buildertek__Time_Cards__c timeCardData = [Select Id,buildertek__Budget__c, buildertek__Resource__c , buildertek__Resource__r.Name , buildertek__Budget_Line__c, Name from buildertek__Time_Cards__c where Id =:timeCardId limit 1];

        buildertek__Budget_Item__c budgetitem = [Select Id, Name from buildertek__Budget_Item__c where Id =:BudgetLineId limit 1];

        List<buildertek__Time_Cards__c> timeCardList =[Select Id, buildertek__Budget_Line__c, Name from buildertek__Time_Cards__c where buildertek__Budget_Line__c =:budgetitem.Id];
        
        if(timeCardData.buildertek__Resource__r.Name == budgetitem.Name){
            System.debug(':::INSIDE IF :::::');
            if(timeCardList.size() == 0){
                delete budgetitem;

            }
        }
    }


    public static void updateIt(Id timeCardId , Id budgetId, Id BudgetLineId){
        buildertek__Time_Cards__c timeCardData = [Select Id,buildertek__Budget__c,buildertek__Daily_Expense__c,buildertek__Resource__c , buildertek__Resource__r.Name , buildertek__Budget_Line__c, Name from buildertek__Time_Cards__c where Id =:timeCardId limit 1];
        buildertek__Budget_Item__c budgetitem = [Select Id, Name , buildertek__Labor__c , buildertek__Budget__c  from buildertek__Budget_Item__c where Id =:BudgetLineId  AND buildertek__Budget__c=:budgetId limit 1];
      
        if(budgetitem.buildertek__Labor__c == null){

            budgetitem.buildertek__Labor__c = timeCardData.buildertek__Daily_Expense__c;
        }else{
            budgetitem.buildertek__Labor__c += timeCardData.buildertek__Daily_Expense__c;


        }
        update budgetitem;


        
    }
    
}