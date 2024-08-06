public with sharing class changeStatusOnCIControlller {
    
    @AuraEnabled
    public static String changeStatus(String contractorInvoiceID) {
        try {
            buildertek__Account_Payable__c contractorInvoice = new buildertek__Account_Payable__c(
                Id = contractorInvoiceID,
                buildertek__Status__c = 'Paid'
            );
            update contractorInvoice;
            return 'Success';
        } catch(Exception e) {
            System.debug(e.getMessage());
            return 'Error' + e.getMessage();
        }
    }
}