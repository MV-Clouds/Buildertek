@isTest
public with sharing class Invoice_From_TimecardTest {
    @TestSetup
    static void InvoiceMethod() {
        buildertek__Time_Cards__c t = new buildertek__Time_Cards__c();
        t.buildertek__Description__c = 'Test';
        insert t;

        buildertek__Account_Payable_Clone__c Inv = new buildertek__Account_Payable_Clone__c();
        Inv.buildertek__Description__c = 'Test Desc';
        insert Inv;
    }
    @isTest
    static void InvoiceMethod1(){

        buildertek__Time_Cards__c t = new buildertek__Time_Cards__c();
        t = [select Id,Name From buildertek__Time_Cards__c LIMIT 1];

        Invoice_From_Timecard.createInv(t.Id);
    }
}