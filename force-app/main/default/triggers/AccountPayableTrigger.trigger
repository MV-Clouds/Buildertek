/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-18-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
trigger AccountPayableTrigger on buildertek__Account_Payable__c (before insert,before update,before delete, after insert, after update, after delete) {
    if (Trigger.isBefore) {
        System.debug('AccountPayableTrigger Before Trigger');

        if(Trigger.isInsert || Trigger.isUpdate) {
            list<Account_Payable__c> AccountPayableList = new list<Account_Payable__c>();
            for(Account_Payable__c AccountPayable : trigger.New){
                if(AccountPayable.Balance__c <= 0 && AccountPayable.Payments__c != 0){
                    AccountPayable.Status__c = 'Paid'; 
                }
                else if(AccountPayable.Balance__c > 0 && AccountPayable.Payments__c > 0){
                    AccountPayable.Status__c = 'Partially Paid';
                }
                AccountPayableList.add(AccountPayable);
                
            }
            
            BT_Utils.genrateAutoNumber([Select Id, Auto_Number1__c from Account_Payable__c   where Purchase_Order__c =:AccountPayableList[0].Purchase_Order__c   ORDER BY CREATEDDATE DESC  LIMIT 1], AccountPayableList, 'Auto_Number1__c');
            AccountPayableHelper.onbeforeUpdate(trigger.new);
           
            if(Trigger.isUpdate){
                // AccountPayableHelper.RestrictToUpdateCashDisbursement(Trigger.new, Trigger.newMap ,Trigger.oldMap);       // -->>>>> Changes for BUIL-3675 --> commnent by Brian to disable RestrictToUpdateCashDisbursement Functionality...
                AccountPayableHelper.updateBudgetAndBudgetLine(Trigger.new, Trigger.newMap ,Trigger.oldMap);
            }



        }else if(Trigger.isDelete){
            AccountPayableHelper.beforeDelete(Trigger.old);    
        }
    } else if (Trigger.isAfter) {
        // System.debug('After Trigger');
        if (Trigger.isInsert) {
            System.debug(' AccountPayableTrigger After Trigger insert');
            AccountPayableHelper.OnAfterInsert(Trigger.new, Trigger.newMap); 
        } else if(Trigger.isUpdate){
            System.debug(' AccountPayableTrigger After Trigger update');
            AccountPayableHelper.afterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap); 
            AccountPayableHelper.DeleteBudgetLine(Trigger.old ,Trigger.new , Trigger.oldMap , Trigger.newMap);
            AccountPayableHelper.UpdateCOntractorInvoiceStatus(Trigger.new , Trigger.oldMap);

        } else if(Trigger.isDelete){
            AccountPayableHelper.onAfterDelete(Trigger.old); 
        }
    }
}