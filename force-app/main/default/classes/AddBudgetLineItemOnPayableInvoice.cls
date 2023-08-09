/* AddBudgetLineItemOnPayableInvoice
 *
 * @author: Nishit Suthar
 * @version: 1.0
 * @description: Class for adding Budget & BudgetLine logic to PayableInvioce
 * @uses: InPayableTrigger
 * @history: None
 * yyyy-mm-dd : 2023/03/14
*/
public with sharing class AddBudgetLineItemOnPayableInvoice {
    public static void createNewBudgetLineItem(Id payInvoice){

        buildertek__Account_Payable_Clone__c payableInvoice = [Select Id, buildertek__Description__c, buildertek__Budget__c,buildertek__Total_Amount__c , buildertek__Budget_Line__c from buildertek__Account_Payable_Clone__c where Id =:payInvoice limit 1];
        buildertek__Budget_Line_Group__c  budgetlinegroup =[select id,Name from buildertek__Budget_Line_Group__c  where Name = 'Invoice (AP)' limit 1];
        
        buildertek__Budget_Item__c budgetitem = new buildertek__Budget_Item__c();
        budgetitem.buildertek__Budget__c = payableInvoice.buildertek__Budget__c;
        budgetitem.Name = payableInvoice.buildertek__Description__c;
        budgetitem.buildertek__Quantity__c = 1; 
        budgetitem.buildertek__Invoice_total__c = payableInvoice.buildertek__Total_Amount__c;
        System.debug('payableInvoice.buildertek__Total_Amount__c '+payableInvoice.buildertek__Total_Amount__c);
        System.debug('budgetitem.buildertek__Invoice_total__c '+budgetitem.buildertek__Invoice_total__c);
        budgetitem.buildertek__UOM__c = 'Each';
        budgetitem.buildertek__Group__c  = budgetlinegroup.id; 
        insert budgetitem;
        
        InvoiceAPTriggerHandler.isFirstTime = true;
        payableInvoice.buildertek__Budget_Line__c = budgetitem.id;
        InvoiceAPTriggerHandler.isFirstTime = false;
        update payableInvoice;
        
    }
    
    public static void deleteBudgetItem(Id payInvoice, Id BudgetLineId){

        buildertek__Account_Payable_Clone__c payableInvoice = [Select Id, buildertek__Description__c, buildertek__Budget__c,buildertek__Total_Amount__c , buildertek__Budget_Line__c from buildertek__Account_Payable_Clone__c where Id =:payInvoice limit 1];
        
        List<buildertek__Budget_Item__c> budgetitem = [Select Id, Name from buildertek__Budget_Item__c where Id =:BudgetLineId limit 1];
        
        
        if (budgetitem.size() > 0) {

            List<buildertek__Account_Payable_Clone__c> payableInvoiceList = [Select Id, buildertek__Budget_Line__c, buildertek__Description__c from buildertek__Account_Payable_Clone__c where buildertek__Budget_Line__c =:budgetitem[0].Id];
            
            if(payableInvoice.buildertek__Description__c == budgetitem[0].Name && payableInvoiceList.size() == 0){
                delete budgetitem;
            } 
        }
    }

    public static void updateBudgetLine(Id payInvoice , Id budgetId, Id BudgetLineId){
        buildertek__Account_Payable_Clone__c payableInvoice = [Select Id, buildertek__Description__c, buildertek__Budget__c,buildertek__Total_Amount__c , buildertek__Budget_Line__c from buildertek__Account_Payable_Clone__c where Id =:payInvoice limit 1];
        buildertek__Budget_Item__c budgetitem = [Select Id, Name , buildertek__Invoice_total__c , buildertek__Budget__c  from buildertek__Budget_Item__c where Id =:BudgetLineId  AND buildertek__Budget__c=:budgetId limit 1];

        if(budgetitem.buildertek__Invoice_total__c == null){
            budgetitem.buildertek__Invoice_total__c = payableInvoice.buildertek__Total_Amount__c;
        }else{
            budgetitem.buildertek__Invoice_total__c += payableInvoice.buildertek__Total_Amount__c;
        }
        update budgetitem;
    }

    public static void updateBudgetLineSub(Id payInvoice , Id budgetId, Id BudgetLineId){
        System.debug('budgetId '+budgetId);
        System.debug('BudgetLineId '+BudgetLineId);
        buildertek__Account_Payable_Clone__c payableInvoice = [Select Id, buildertek__Description__c, buildertek__Budget__c,buildertek__Total_Amount__c , buildertek__Budget_Line__c from buildertek__Account_Payable_Clone__c where Id =:payInvoice limit 1];

        List<buildertek__Budget_Item__c> budgetitem = [Select Id, Name , buildertek__Invoice_total__c , buildertek__Budget__c  from buildertek__Budget_Item__c where Id =:BudgetLineId  AND buildertek__Budget__c=:budgetId limit 1];

        if (budgetitem.size() > 0) {
            if(budgetitem[0].buildertek__Invoice_total__c != null || budgetitem[0].buildertek__Invoice_total__c > 0){
                System.debug('budgetitem.buildertek__Invoice_total__c '+budgetitem[0].buildertek__Invoice_total__c);
                System.debug('payableInvoice.buildertek__Total_Amount__c '+payableInvoice.buildertek__Total_Amount__c);
                budgetitem[0].buildertek__Invoice_total__c = budgetitem[0].buildertek__Invoice_total__c - payableInvoice.buildertek__Total_Amount__c;
            }else{
                budgetitem[0].buildertek__Invoice_total__c = 0;
            }
            update budgetitem;
            System.debug('budgetitem.buildertek__Invoice_total__c '+budgetitem[0].buildertek__Invoice_total__c);
        }
    }
}