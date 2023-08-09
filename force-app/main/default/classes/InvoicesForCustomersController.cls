public  with sharing class InvoicesForCustomersController {
  /* @AuraEnabled
    public static list<buildertek__Account_Payable__c> getInvoices(string AccId){
        list<buildertek__Account_Payable__c> accountpayableList = [select id,Name,buildertek__Vendor__c from buildertek__Account_Payable__c where buildertek__Vendor__c =:AccId];
       return accountpayableList; 
    }*/ 
    @AuraEnabled
    public static list<buildertek__Billings__c> getInvoices(string AccId){
        list<buildertek__Billings__c> billingList = [select id,Name,buildertek__Customer_Account__c from buildertek__Billings__c where buildertek__Customer_Account__c =:AccId];
       return billingList; 
    }
}