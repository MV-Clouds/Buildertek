public with sharing class Invoice_From_Timecard {
    @AuraEnabled
    public static String createInv(String recordId){
        System.debug('<<<----createInv---->>>');

        buildertek__Time_Cards__c timeCard = new buildertek__Time_Cards__c();
        timeCard = [SELECT Id,Name,buildertek__Resource__r.Name,buildertek__Project__c,buildertek__Daily_Expense__c FROM buildertek__Time_Cards__c WHERE Id =: recordId];
        System.debug('timeCard---->>>'+timeCard);

        List<buildertek__Account_Payable_Clone__c> InvList = new List<buildertek__Account_Payable_Clone__c>();
        buildertek__Account_Payable_Clone__c Inv = new buildertek__Account_Payable_Clone__c();

        Inv.buildertek__Description__c = timeCard.buildertek__Resource__r.Name;
        Inv.buildertek__Status__c = 'Open';
        Inv.buildertek__Project__c = timeCard.buildertek__Project__c;
        Inv.buildertek__Time_Card__c = timeCard.Id;
        System.debug('Inv---->>>'+Inv.Id);
        InvList.add(Inv);
        insert InvList;
        System.debug('InvList---->>>'+InvList);

        List<buildertek__Account_Payable_Item_Clone__c> InvLineList = new List<buildertek__Account_Payable_Item_Clone__c>();
        for (buildertek__Account_Payable_Clone__c InvLines : InvList) {
                System.debug('<<<----In Invoice Line---->>>');
                buildertek__Account_Payable_Item_Clone__c InvLine = new buildertek__Account_Payable_Item_Clone__c();
                InvLine.buildertek__Account_Payable_Clone__c = InvLines.Id;
                InvLine.Name = 'Labor';
                InvLine.buildertek__Quantity__c = 1;
                System.debug('buildertek__Daily_Expense__c ====> '+timeCard.buildertek__Daily_Expense__c);
                InvLine.buildertek__Unit_Price__c = timeCard.buildertek__Daily_Expense__c;
                System.debug('InvLine => '+InvLine);
                InvLineList.add(InvLine);
        }
        insert InvLineList;
        System.debug('InvLineList---->>>'+InvLineList);
        System.debug('<<<----Success---->>>');
        System.debug('recordId---->>>'+recordId);

        return Inv.Id;

    }
}