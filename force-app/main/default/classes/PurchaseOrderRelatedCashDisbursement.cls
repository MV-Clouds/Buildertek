public class PurchaseOrderRelatedCashDisbursement {
    
    @AuraEnabled
    public static List<buildertek__Payment__c> getCashDisbursementData(String PORecId) {
        
        System.debug('PORecId--> ' + POrecId);

        List<Id> cnvIdList = new List<Id>();
        List<buildertek__Account_Payable__c> ContractorInvIdList = [SELECT Id FROM buildertek__Account_Payable__c WHERE buildertek__Purchase_Order__c = : POrecId];

        for (buildertek__Account_Payable__c cnv : ContractorInvIdList) {
            cnvIdList.add(cnv.Id);
        }
        List<buildertek__Payment__c> CashDisbursementList = [SELECT Id, Name, buildertek__Payment_Amount__c, buildertek__Payment_Date__c, buildertek__Type__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Payment_Status__c, buildertek__Payable__c FROM buildertek__Payment__c WHERE buildertek__Payable__c IN : cnvIdList];

        return CashDisbursementList;
    }
}