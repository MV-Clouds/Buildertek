public without sharing class PaymentLineTriggerHandler {

    public PaymentLineTriggerHandler(boolean isExecuting, integer size) {

    }

    // public void afterInsert(List<buildertek__BT_Payment_Lines__c> newPaymentLines) {
    //     Set<Id> paymentSet = new Set<Id>();
    //     for (buildertek__BT_Payment_Lines__c paymentLine : newPaymentLines) {
    //         paymentSet.add(paymentLine.buildertek__Payment__c);
    //     }
        
    //     List<buildertek__BT_Payment__c> paymentList = [SELECT Id, Name, buildertek__Amount__c, buildertek__Invoices_AP__c, buildertek__Invoices_AP__r.buildertek__Tax__c, (SELECT Id, Name, buildertek__Amount_F__c FROM Payment_Lines__r) FROM buildertek__BT_Payment__c WHERE Id IN :paymentSet];

    //     for (buildertek__BT_Payment__c payment : paymentList) {
    //         decimal paymentCount = 0;
    //         for (buildertek__BT_Payment_Lines__c paymentLine : payment.Payment_Lines__r) {
    //             paymentCount += paymentLine.buildertek__Amount_F__c;
    //         }

    //         paymentCount = paymentCount + (paymentCount*payment.buildertek__Invoices_AP__r.buildertek__Tax__c/100);
    //         payment.buildertek__Amount__c = paymentCount;
    //     }

    //     if (paymentList.size() > 0) {
    //         update paymentList;
    //     }
    // }

    public void onAfterInsert(List<buildertek__BT_Payment_Lines__c> newPaymentLines) {
        try {
            Set<Id> PaymentId = new Set<Id>();

            for (buildertek__BT_Payment_Lines__c PaymentLine : newPaymentLines) {
                if (PaymentLine.buildertek__Payment__c != null) {
                    PaymentId.add(PaymentLine.buildertek__Payment__c);
                }
            }
            
            if (!PaymentId.isEmpty()) {
                updateAmountOnPayment(PaymentId);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public void onAfterUpdate(List<buildertek__BT_Payment_Lines__c> newPaymentLines, Map<Id, buildertek__BT_Payment_Lines__c> oldPaymentLineMap) {
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
}