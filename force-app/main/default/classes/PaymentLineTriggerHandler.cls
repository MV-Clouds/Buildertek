public without sharing class PaymentLineTriggerHandler {

    public PaymentLineTriggerHandler(boolean isExecuting, integer size) {

    }

    public void afterInsert(List<buildertek__BT_Payment_Lines__c> newPaymentLines) {
        Set<Id> paymentSet = new Set<Id>();
        for (buildertek__BT_Payment_Lines__c paymentLine : newPaymentLines) {
            paymentSet.add(paymentLine.buildertek__Payment__c);
        }
        
        List<buildertek__BT_Payment__c> paymentList = [SELECT Id, Name, buildertek__Amount__c, buildertek__Invoices_AP__c, buildertek__Invoices_AP__r.buildertek__Tax__c, (SELECT Id, Name, buildertek__Amount_F__c FROM Payment_Lines__r) FROM buildertek__BT_Payment__c WHERE Id IN :paymentSet];

        for (buildertek__BT_Payment__c payment : paymentList) {
            decimal paymentCount = 0;
            for (buildertek__BT_Payment_Lines__c paymentLine : payment.Payment_Lines__r) {
                paymentCount += paymentLine.buildertek__Amount_F__c;
            }

            paymentCount = paymentCount + (paymentCount*payment.buildertek__Invoices_AP__r.buildertek__Tax__c/100);
            payment.buildertek__Amount__c = paymentCount;
        }

        if (paymentList.size() > 0) {
            update paymentList;
        }
    }
}