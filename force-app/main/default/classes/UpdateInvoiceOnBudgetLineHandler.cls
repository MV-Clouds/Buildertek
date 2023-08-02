public with sharing class UpdateInvoiceOnBudgetLineHandler {
   public static Set<Id> setBudgetLineIds = new Set<Id>();

   //After Insert , Update and Undelete this method is excecuted
    public void afterTrigger(List<buildertek__Account_Payable_Item_Clone__c> invLineList) {
        System.debug('invLineList 1'+invLineList);
        for(buildertek__Account_Payable_Item_Clone__c invoiceLineAp:invLineList){
            if(invoiceLineAp.buildertek__Budget_Line__c	!= null){
                setBudgetLineIds.add(invoiceLineAp.buildertek__Budget_Line__c);

            }
        }

        if(!setBudgetLineIds.isEmpty()){
            List<buildertek__Budget_Item__c> budgetLineList =[SELECT Id , buildertek__Invoice_total__c ,(SELECT Id , buildertek__Budget_Line__c , buildertek__Total_Price__c From buildertek__Invoice_Lines_AP__r) FROM buildertek__Budget_Item__c WHERE Id=:setBudgetLineIds];
            if(!budgetLineList.isEmpty()){
                List<buildertek__Budget_Item__c> updateBudgetLineList = new List<buildertek__Budget_Item__c>();
                for(buildertek__Budget_Item__c budgetLine:budgetLineList){
                    Double sumInvoice=0;
                    for(buildertek__Account_Payable_Item_Clone__c invoiceLine : budgetLine.buildertek__Invoice_Lines_AP__r){
                        if(invoiceLine.buildertek__Budget_Line__c!=null){
                            sumInvoice+=invoiceLine.buildertek__Total_Price__c;
                        }
                    }
                    budgetLine.buildertek__Invoice_total__c=sumInvoice;
                    updateBudgetLineList.add(budgetLine);
                }
                if(!updateBudgetLineList.isEmpty()){
                    update updateBudgetLineList;
                }
            }
        
        }
    }
    // After Delete and update this method is eexecuted
    public void afterDelete(List<buildertek__Account_Payable_Item_Clone__c> invLineList) {
        System.debug('invLineList 2'+invLineList);
        for(buildertek__Account_Payable_Item_Clone__c invoiceLineAp:invLineList){
            if(invoiceLineAp.buildertek__Budget_Line__c	!= null){
                setBudgetLineIds.add(invoiceLineAp.buildertek__Budget_Line__c);
            }
        }

        if(!setBudgetLineIds.isEmpty()){
            List<buildertek__Budget_Item__c> budgetLineList =[SELECT Id , buildertek__Invoice_total__c ,(SELECT Id , buildertek__Budget_Line__c , buildertek__Total_Price__c From buildertek__Invoice_Lines_AP__r) FROM buildertek__Budget_Item__c WHERE Id=:setBudgetLineIds];
            if(!budgetLineList.isEmpty()){
                List<buildertek__Budget_Item__c> updateBudgetLineList = new List<buildertek__Budget_Item__c>();
                for(buildertek__Budget_Item__c budgetLine:budgetLineList){
                    Double sumInvoice=0;
                    for(buildertek__Account_Payable_Item_Clone__c invoiceLine : budgetLine.buildertek__Invoice_Lines_AP__r){
                        if(invoiceLine.buildertek__Budget_Line__c!=null){
                            sumInvoice+=invoiceLine.buildertek__Total_Price__c;
                        }
                    }
                    budgetLine.buildertek__Invoice_total__c=sumInvoice;
                    updateBudgetLineList.add(budgetLine);
                }
                if(!updateBudgetLineList.isEmpty()){
                     update budgetLineList;
                }
            }
        
        }
    }
}