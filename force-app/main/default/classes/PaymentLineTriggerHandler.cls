public without sharing class PaymentLineTriggerHandler {
    public PaymentLineTriggerHandler(boolean isExecuting, integer size) {

    }

    public  void onAfterInsert(List<buildertek__BT_Payment_Lines__c> newPaymentLines) {
        try {
            Set<Id> PaymentId = new Set<Id>();

            for (buildertek__BT_Payment_Lines__c PaymentLine : newPaymentLines) {
                if (PaymentLine.buildertek__Payment__c != null) {
                    PaymentId.add(PaymentLine.buildertek__Payment__c);
                }
            }
            
            if (!PaymentId.isEmpty()) {
                updateAmountOnPayment(PaymentId);
                recalculateTotalforBudgetLine(PaymentId);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public  void onAfterUpdate(List<buildertek__BT_Payment_Lines__c> newPaymentLines, Map<Id, buildertek__BT_Payment_Lines__c> oldPaymentLineMap) {
        try {
            Set<Id> PaymentId = new Set<Id>();
    
            for (buildertek__BT_Payment_Lines__c PaymentLine : newPaymentLines) {
                buildertek__BT_Payment_Lines__c oldPaymentLine = oldPaymentLineMap.get(PaymentLine.Id);
    
                if (PaymentLine.buildertek__Payment__c != oldPaymentLine.buildertek__Payment__c ||
                    PaymentLine.buildertek__Amount_F__c != oldPaymentLine.buildertek__Amount_F__c || 
                    PaymentLine.buildertek__Invoice_Line_AP__c != oldPaymentLine.buildertek__Invoice_Line_AP__c ||
                    PaymentLine.buildertek__Quantity__c != oldPaymentLine.buildertek__Quantity__c ||
                    PaymentLine.buildertek__Unit_Price__c != oldPaymentLine.buildertek__Unit_Price__c) {
                        if (oldPaymentLine.buildertek__Payment__c != null) {
                            PaymentId.add(oldPaymentLine.buildertek__Payment__c);
                        }
                        if (PaymentLine.buildertek__Payment__c != null) {
                            PaymentId.add(PaymentLine.buildertek__Payment__c);
                        }
                }
            }
    
            if (!PaymentId.isEmpty()) {
                updateAmountOnPayment(PaymentId);
                recalculateTotalforBudgetLine(PaymentId);
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
    
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }    

    public void onAfterDelete(List<buildertek__BT_Payment_Lines__c> oldPaymentLineList) {
        try {
            Set<Id> PaymentId = new Set<Id>();

            for (buildertek__BT_Payment_Lines__c PaymentLine : oldPaymentLineList) {
                if (PaymentLine.buildertek__Payment__c != null) {
                    PaymentId.add(PaymentLine.buildertek__Payment__c);
                }
            }

            if (!PaymentId.isEmpty()) {
                updateAmountOnPayment(PaymentId);
                recalculateTotalforBudgetLine(PaymentId);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public void updateAmountOnPayment(Set<Id> PaymentIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__Payment__c, SUM(buildertek__Amount_F__c) totalAmount FROM buildertek__BT_Payment_Lines__c WHERE buildertek__Payment__c IN :PaymentIds GROUP BY buildertek__Payment__c]){
                Id PaymentId = (Id)aggregatedResult.get('buildertek__Payment__c');
                totalAmountMap.put(PaymentId, aggregatedResult);
            }
            
            List<buildertek__BT_Payment__c> paymentToUpdate = new List<buildertek__BT_Payment__c>();
            
            for (Id payID :PaymentIds) {
                if(totalAmountMap.containsKey(payID)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(payID);
                    Decimal totalAmount = (Decimal)aggregatedResult.get('totalAmount');

                    buildertek__BT_Payment__c co = new buildertek__BT_Payment__c(Id = payID);
                    co.buildertek__Amount__c = totalAmount;
                    paymentToUpdate.add(co);
                } else {
                    buildertek__BT_Payment__c co = new buildertek__BT_Payment__c(Id = payID);
                    co.buildertek__Amount__c = 0;
                    paymentToUpdate.add(co);
                }
            }
            System.debug('paymentToUpdate: ' + paymentToUpdate);
            if (!paymentToUpdate.isEmpty()) {
                update paymentToUpdate;
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void recalculateTotalforBudgetLine(Set<Id> PaymentIds){

        List<buildertek__BT_Payment__c> PaymentsList = [SELECT Id, Name, buildertek__BT_Budget__c, buildertek__BT_Budget_Line__c FROM buildertek__BT_Payment__c WHERE Id IN :PaymentIds];

        Set<Id> BudgetLineIds = new Set<Id>();
        for (buildertek__BT_Payment__c Payment : PaymentsList) {
            if (Payment.buildertek__BT_Budget_Line__c != null) {
                BudgetLineIds.add(Payment.buildertek__BT_Budget_Line__c);
            }
        }

        List<buildertek__BT_Payment_Lines__c> PaymentLineList = [SELECT Id, Name, buildertek__Payment__r.buildertek__BT_Budget_Line__c, buildertek__Amount_F__c, buildertek__Payment__r.buildertek__Tax__c FROM buildertek__BT_Payment_Lines__c WHERE buildertek__Payment__r.buildertek__BT_Budget_Line__c IN :BudgetLineIds];
        
        //make a map where budget line id is the key and the paymentLines are the values
        Map<Id, List<buildertek__BT_Payment_Lines__c>> budgetLineToPaymentLinesMap = new Map<Id, List<buildertek__BT_Payment_Lines__c>>();
        for (buildertek__BT_Payment_Lines__c PaymentLine : PaymentLineList) {
            if (!budgetLineToPaymentLinesMap.containsKey(PaymentLine.buildertek__Payment__r.buildertek__BT_Budget_Line__c)) {
                budgetLineToPaymentLinesMap.put(PaymentLine.buildertek__Payment__r.buildertek__BT_Budget_Line__c, new List<buildertek__BT_Payment_Lines__c>());
            }
            budgetLineToPaymentLinesMap.get(PaymentLine.buildertek__Payment__r.buildertek__BT_Budget_Line__c).add(PaymentLine);
        }

        //iterate over the map and calculate the total amount for each budget line, total amount = sum of all payment lines + (tax * sum of all payment lines)
        Map<Id, Decimal> budgetLineToTotalAmountMap = new Map<Id, Decimal>();
        for (Id budgetLineId : budgetLineToPaymentLinesMap.keySet()) {
            Decimal totalAmount = 0;
            for (buildertek__BT_Payment_Lines__c PaymentLine : budgetLineToPaymentLinesMap.get(budgetLineId)) {
                totalAmount += PaymentLine.buildertek__Amount_F__c;
                if (PaymentLine.buildertek__Payment__r.buildertek__Tax__c != null) {
                    totalAmount += (PaymentLine.buildertek__Payment__r.buildertek__Tax__c/100) * PaymentLine.buildertek__Amount_F__c;
                }
            }
            budgetLineToTotalAmountMap.put(budgetLineId, totalAmount);
        }

        //update the budget line records
        List<buildertek__Budget_Item__c> budgetLineToUpdate = new List<buildertek__Budget_Item__c>();
        for (Id budgetLineId : budgetLineToTotalAmountMap.keySet()) {
            buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c(Id = budgetLineId);
            budgetLine.buildertek__Payable_Invoice_Payments__c = budgetLineToTotalAmountMap.get(budgetLineId);
            budgetLineToUpdate.add(budgetLine);
        }

        if (!budgetLineToUpdate.isEmpty()) {
            update budgetLineToUpdate;
        }

    }
}