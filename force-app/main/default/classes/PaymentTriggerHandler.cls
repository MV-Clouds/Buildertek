public class PaymentTriggerHandler {
    public static Boolean isSkipExecution = false;

    public void onBeforeInsert(List<buildertek__BT_Payment__c> newPaymentline, Map<Id, buildertek__BT_Payment__c> newPaymentlineMap){
        String budgetLineGroupId ;
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'No Grouping';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        }else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }
        System.debug('budgetLineGroupId: ' + budgetLineGroupId);

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        List<buildertek__Budget_Item__c> toUpdateBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__BT_Payment__c payment : newPaymentline){
            //if budget line is null and budget is not null
            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c == null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Name = payment.Name;
                budgetItem.buildertek__Budget__c = payment.buildertek__BT_Budget__c;
                budgetItem.buildertek__Group__c = budgetLineGroupId;
                budgetItem.buildertek__Payable_Invoice_Payments__c = payment.buildertek__Total_Amount__c;
                toInsertBudgetItems.add(budgetItem);
            }

            //if budget line is not null and budget is not null
            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c != null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Id = payment.buildertek__BT_Budget_Line__c;
                budgetItem.buildertek__Payable_Invoice_Payments__c += payment.buildertek__Total_Amount__c;
                toUpdateBudgetItems.add(budgetItem);
            }
        }

        if(toUpdateBudgetItems.size() > 0){
            update toUpdateBudgetItems;
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for(buildertek__BT_Payment__c payment : newPaymentline){
            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c != null){
                for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                    if(budgetItem.buildertek__Budget__c == payment.buildertek__BT_Budget__c && budgetItem.Name == payment.Name){
                        payment.buildertek__BT_Budget_Line__c = budgetItem.Id;
                    }
                }
            }
        }

        
    }
    
    public void afterInsert(List<buildertek__BT_Payment__c> newPaymentline, Map<Id, buildertek__BT_Payment__c> newPaymentlineMap){
        
        Set<String> invoiceIds = new Set<String> ();
        if(!newPaymentline.isEmpty()){
            for(buildertek__BT_Payment__c payment : newPaymentline){
                invoiceIds.add(payment.buildertek__Invoices_AP__c);
            }
        }
        
        system.debug('invoiceIds----->'+invoiceIds);        
        List<buildertek__Account_Payable_Clone__c> invoiceRecList = [select Id, Name, buildertek__Payment_Amount__c  from buildertek__Account_Payable_Clone__c where Id IN: invoiceIds];
        
        List<AggregateResult> result = [SELECT SUM(buildertek__Total_Amount__c )totalCost, buildertek__Invoices_AP__c FROM buildertek__BT_Payment__c
                                        WHERE buildertek__Invoices_AP__c IN: invoiceIds group by buildertek__Invoices_AP__c];
        
        system.debug('result----->'+result);
        Map<String,decimal> invoiceMap = new Map<String,decimal>();
        
        system.debug('invoiceRecList----->'+invoiceRecList);
        if(!invoiceRecList.isEmpty()){
            for(AggregateResult agg : result){
                invoiceMap.put((String)agg.get('buildertek__Invoices_AP__c'), (decimal)agg.get('totalCost'));
            }
        }
        system.debug('invoiceMap----->'+invoiceMap);
        if(!invoiceRecList.isEmpty()){
            for(buildertek__Account_Payable_Clone__c invoice : invoiceRecList){
                invoice.buildertek__Payment_Amount__c = invoiceMap.get(invoice.Id);
            }
            update invoiceRecList;
        }
        system.debug('invoiceRecList----->'+invoiceRecList);

        //iterate over newPaymentline and make set of id and pass to PaymentLineTriggerHandler.recalculateTotalforBudgetLine
        Set<Id> paymentIds = new Set<Id>();
        for(buildertek__BT_Payment__c payment : newPaymentline){
            paymentIds.add(payment.Id);
        }
        PaymentLineTriggerHandler.recalculateTotalforBudgetLine(paymentIds);
        
    }

    public void onBeforeUpdate(List<buildertek__BT_Payment__c> oldPayment, List<buildertek__BT_Payment__c> newPayment, Map<Id, buildertek__BT_Payment__c> oldPaymentMap, Map<Id, buildertek__BT_Payment__c> newPaymentMap){
        String budgetLineGroupId ;
        List<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name = 'No Grouping' LIMIT 1];
        if(budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c();
            budgetLineGroup.Name = 'No Grouping';
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        }else{
            budgetLineGroupId = budgetLineGroups[0].Id;
        }
        

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        List<buildertek__Budget_Item__c> toUpdateBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__BT_Payment__c payment : newPayment){
            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c == null){
                buildertek__BT_Payment__c oldPaymnet = oldPaymentMap.get(payment.Id);
                if(oldPaymnet != null && oldPaymnet.buildertek__BT_Budget__c == null){
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Name = payment.Name;
                    budgetItem.buildertek__Budget__c = payment.buildertek__BT_Budget__c;
                    budgetItem.buildertek__Group__c = budgetLineGroupId;
                    budgetItem.buildertek__Payable_Invoice_Payments__c = payment.buildertek__Total_Amount__c;
                    toInsertBudgetItems.add(budgetItem);
                }
            }

            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c != null){
                buildertek__BT_Payment__c oldPaymnet = oldPaymentMap.get(payment.Id);
                if(oldPaymnet != null && oldPaymnet.buildertek__BT_Budget_Line__c != payment.buildertek__BT_Budget_Line__c){
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    budgetItem.Id = payment.buildertek__BT_Budget_Line__c;
                    budgetItem.buildertek__Payable_Invoice_Payments__c = payment.buildertek__Total_Amount__c;
                    toUpdateBudgetItems.add(budgetItem);
                }
            }
        }

        System.debug('toUpdateBudgetItems: ' + toUpdateBudgetItems);

        if(toUpdateBudgetItems.size() > 0){
            update toUpdateBudgetItems;
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;
        }

        for(buildertek__BT_Payment__c payment : newPayment){
            if(payment.buildertek__BT_Budget__c != null && payment.buildertek__BT_Budget_Line__c == null){
                for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                    if(budgetItem.buildertek__Budget__c == payment.buildertek__BT_Budget__c && budgetItem.Name == payment.Name){
                        payment.buildertek__BT_Budget_Line__c = budgetItem.Id;
                    }
                }
            }
        }

        Map<Id, buildertek__BT_Payment__c> toDeleteBudgetItems = new Map<Id, buildertek__BT_Payment__c>();
        for(buildertek__BT_Payment__c payment : newPayment){
            buildertek__BT_Payment__c oldPaymnet = oldPaymentMap.get(payment.Id);
            System.debug('oldPaymnet: ' + oldPaymnet);
            System.debug('payment: ' + payment);
            if(oldPaymnet != null && oldPaymnet.buildertek__BT_Budget_Line__c != null && payment.buildertek__BT_Budget_Line__c != oldPaymnet.buildertek__BT_Budget_Line__c){
                System.debug('Inside if condition');
                payment.buildertek__BT_Budget__c = null;
                toDeleteBudgetItems.put(oldPaymnet.buildertek__BT_Budget_Line__c, oldPaymnet);
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).Name == budgetItem.Name){
                    toDeleteBudgetLine.add(budgetItem);
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }

            System.debug('toDeleteBudgetLine: ' + toDeleteBudgetLine);
            System.debug('toDeleteBudgetItems: ' + toDeleteBudgetItems);

            if(toDeleteBudgetLine.size() > 0 && isSkipExecution == false){
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLine;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name, buildertek__Payable_Invoice_Payments__c FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            System.debug('toDeleteBudgetItemsList: ' + toDeleteBudgetItemsList);
            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c != null && budgetItem.buildertek__Payable_Invoice_Payments__c != null){
                    budgetItem.buildertek__Payable_Invoice_Payments__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c;
                }
            }
            update toDeleteBudgetItemsList;
            
        }

    }
    
    
    public void afterUpdate(List<buildertek__BT_Payment__c> oldPaymentline, List<buildertek__BT_Payment__c> newPaymentline, Map<Id, buildertek__BT_Payment__c> oldPaymentlineMap, Map<Id, buildertek__BT_Payment__c> newPaymentlineMap){
        list<String> invoiceIds = new list<String> ();
        if(!newPaymentline.isEmpty()){
            for(buildertek__BT_Payment__c payment : newPaymentline){
                invoiceIds.add(payment.buildertek__Invoices_AP__c);
            }
        }
        
        system.debug('invoiceIds----->'+invoiceIds);        
        List<buildertek__Account_Payable_Clone__c> invoiceRecList = [select Id, Name, buildertek__Payment_Amount__c  from buildertek__Account_Payable_Clone__c where Id IN: invoiceIds];
        
        List<AggregateResult> result = [SELECT SUM(buildertek__Total_Amount__c)totalCost, buildertek__Invoices_AP__c FROM buildertek__BT_Payment__c
                                        WHERE buildertek__Invoices_AP__c IN: invoiceIds group by buildertek__Invoices_AP__c];
        
        system.debug('result----->'+result);
        Map<String,decimal> invoiceMap = new Map<String,decimal>();
        
        system.debug('invoiceRecList----->'+invoiceRecList);
        if(!invoiceRecList.isEmpty()){
            for(AggregateResult agg : result){
                invoiceMap.put((String)agg.get('buildertek__Invoices_AP__c'), (decimal)agg.get('totalCost'));
            }
        }
        system.debug('invoiceMap----->'+invoiceMap);
        if(!invoiceRecList.isEmpty()){
            for(buildertek__Account_Payable_Clone__c invoice : invoiceRecList){
                invoice.buildertek__Payment_Amount__c = invoiceMap.get(invoice.Id);
            }
            update invoiceRecList;
        }
        system.debug('invoiceRecList----->'+invoiceRecList);

        //iterate over the newPaymentline and make set of id and pass to PaymentLineTriggerHandler.recalculateTotalforBudgetLine
        Set<Id> paymentIds = new Set<Id>();
        for(buildertek__BT_Payment__c payment : newPaymentline){
            paymentIds.add(payment.Id);
        }
        PaymentLineTriggerHandler.recalculateTotalforBudgetLine(paymentIds);
    }
    
    public void onBeforeDelete(List<buildertek__BT_Payment__c> oldPaymentList, Map<Id, buildertek__BT_Payment__c> oldPaymentlineMap){

        System.debug('onBeforeDelete Method::::');
        // Set<Id> invoiceIdSet = new Set<Id>();

        Map<Id, Decimal> paymentSet= new Map<Id, Decimal>();

        
        for(buildertek__BT_Payment__c payment:oldPaymentList){
            paymentSet.put(payment.buildertek__Invoices_AP__c , payment.buildertek__Total_Amount__c);
        }
        System.debug('paymentSet' + paymentSet);
        List<buildertek__Account_Payable_Clone__c> invoiceRecList = [select Id, Name, buildertek__Payment_Amount__c  from buildertek__Account_Payable_Clone__c where Id IN: paymentSet.keySet()];
        System.debug('invoiceRecList' + invoiceRecList);
        for(buildertek__Account_Payable_Clone__c invoice:invoiceRecList){
            for (Id key : paymentSet.keySet()) {
                Decimal value = paymentSet.get(key);
                if(invoice.buildertek__Payment_Amount__c != null){
                    invoice.buildertek__Payment_Amount__c-=value;
                }
            }

        }
        update invoiceRecList;

        //if the name of payment and budget line matches then delete the budget line, or else subtract the payment amount from the budget line
        Map<Id, buildertek__BT_Payment__c> toDeleteBudgetItems = new Map<Id, buildertek__BT_Payment__c>();
        for(buildertek__BT_Payment__c payment : oldPaymentList){
            if(payment.buildertek__BT_Budget_Line__c != null){
                toDeleteBudgetItems.put(payment.buildertek__BT_Budget_Line__c, payment);
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name, buildertek__Payable_Invoice_Payments__c FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).Name == budgetItem.Name){
                    toDeleteBudgetLine.add(budgetItem);
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }

            if(toDeleteBudgetLine.size() > 0 ){
                delete toDeleteBudgetLine;
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name, buildertek__Payable_Invoice_Payments__c FROM buildertek__Budget_Item__c WHERE Id IN: toDeleteBudgetItems.keySet()];
            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                if(toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c != null && budgetItem.buildertek__Payable_Invoice_Payments__c != null){
                    budgetItem.buildertek__Payable_Invoice_Payments__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Total_Amount__c;
                }
            }
            update toDeleteBudgetItemsList;
            
        }
        

        // list<String> invoiceIds = new list<String> ();
        // if(!oldPaymentline.isEmpty()){
        //     for(buildertek__BT_Payment__c payment : oldPaymentline){
        //         invoiceIds.add(payment.buildertek__Invoices_AP__c);
        //     }
        // }
        
        // system.debug('invoiceIds----->'+invoiceIds);        
        // List<buildertek__Account_Payable_Clone__c> invoiceRecList = [select Id, Name, buildertek__Payment_Amount__c  from buildertek__Account_Payable_Clone__c where Id IN: invoiceIds];
        
        // List<AggregateResult> result = [SELECT SUM(buildertek__Amount__c)totalCost, buildertek__Invoices_AP__c FROM buildertek__BT_Payment__c
        //                                 WHERE buildertek__Invoices_AP__c IN: invoiceIds group by buildertek__Invoices_AP__c];
        
        // system.debug('result----->'+result);
        // Map<String,decimal> invoiceMap = new Map<String,decimal>();
        
        // system.debug('invoiceRecList----->'+invoiceRecList);
        // if(!invoiceRecList.isEmpty()){
        //     for(AggregateResult agg : result){
        //         invoiceMap.put((String)agg.get('buildertek__Invoices_AP__c'), (decimal)agg.get('totalCost'));
        //     }
        // }
        // system.debug('invoiceMap----->'+invoiceMap);
        // if(!invoiceRecList.isEmpty()){
        //     for(buildertek__Account_Payable_Clone__c invoice : invoiceRecList){
        //         invoice.buildertek__Payment_Amount__c = invoiceMap.get(invoice.Id);
        //     }
        //     update invoiceRecList;
        // }
        // system.debug('invoiceRecList----->'+invoiceRecList);
    }    
    
}