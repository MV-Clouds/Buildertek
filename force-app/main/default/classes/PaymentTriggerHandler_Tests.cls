@isTest
private class PaymentTriggerHandler_Tests {

    static testMethod void main() {

        buildertek__Account_Payable_Clone__c ap = new buildertek__Account_Payable_Clone__c();
        ap.buildertek__Description__c = 'test1';
        insert ap;


        buildertek__Account_Payable_Item_Clone__c apLines =  new buildertek__Account_Payable_Item_Clone__c();
        apLines.Name = 'test2';
        apLines.buildertek__Account_Payable_Clone__c = ap.Id;

        insert apLines;

        buildertek__BT_Payment__c pay = new buildertek__BT_Payment__c();
        pay.buildertek__Description__c = 'test3';
        pay.buildertek__Invoices_AP__c = ap.Id;
        pay.buildertek__Amount__c = 40;
        insert pay;

        buildertek__BT_Payment__c payment = new buildertek__BT_Payment__c();
        payment.buildertek__Description__c = 'test4';
        payment.buildertek__Invoices_AP__c = ap.Id;
        payment.buildertek__Amount__c = 40;
        insert payment;


        payment.buildertek__Amount__c = 20000;
        update payment;

        delete payment;

       /* buildertek__BT_Payment_Lines__c payLines = new buildertek__BT_Payment_Lines__c();
        payLines.buildertek__Payment__c = pay.Id;
        payLines.buildertek__Invoice_Line_AP__c = apLines.Id;
        payLines.buildertek__Amount__c = 10000;
        insert payLines;

        payLines.buildertek__Amount__c = 20000;
        update payLines;

        buildertek__BT_Payment_Lines__c payLines1 = new buildertek__BT_Payment_Lines__c();
        payLines1.buildertek__Payment__c = pay.Id;
        payLines1.buildertek__Invoice_Line_AP__c = apLines.Id;
        payLines1.buildertek__Amount__c = 10000;
        insert payLines1;
        delete payLines1;*/



        /* list<String> invoiceIds = new list<String> ();
        string oldPaymentline = 'ap.Id';
        if(oldPaymentline != null){

            invoiceIds.add(ap.Id);

        }

        system.debug('invoiceIds----->'+invoiceIds);
        List<buildertek__Account_Payable_Clone__c> invoiceRecList = [select Id, Name, buildertek__Payment_Amount__c  from buildertek__Account_Payable_Clone__c where Id IN: invoiceIds];

        List<AggregateResult> result = [SELECT SUM(buildertek__Amount__c)totalCost, buildertek__Invoices_AP__c FROM buildertek__BT_Payment__c
                                        WHERE buildertek__Invoices_AP__c IN: invoiceIds group by buildertek__Invoices_AP__c];

        system.debug('result----->'+result);
        Map<String,decimal> invoiceMap = new Map<String,decimal>();

        system.debug('invoiceRecList----->'+invoiceRecList);
        if(!invoiceRecList.isEmpty()){
            for(AggregateResult agg : result){
                invoiceMap.put((String)agg.get('buildertek__Invoices_AP__c'), (decimal)agg.get('totalCost'));
            }
        }

        if(!invoiceRecList.isEmpty()){
            for(buildertek__Account_Payable_Clone__c invoice : invoiceRecList){
                invoice.buildertek__Payment_Amount__c = invoiceMap.get(invoice.Id);
            }
            update invoiceRecList;
        } */

    }
}