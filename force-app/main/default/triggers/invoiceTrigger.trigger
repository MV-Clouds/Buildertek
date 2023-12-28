trigger invoiceTrigger on Billings__c (before insert, before update, before delete, after insert, after update, after delete) {
    InvoiceTrigger_HDL handler = new InvoiceTrigger_HDL();
    list<buildertek__Billings__c> BillingRecordList = new list<buildertek__Billings__c>();

    if (Trigger.isBefore) {
        if(Trigger.isInsert){
            BT_Utils.genrateAutoNumber([Select Id, buildertek__Auto_Number1__c from buildertek__Billings__c 
                                     where Project__c =:trigger.New[0].Project__c 
                                     ORDER BY CREATEDDATE DESC  LIMIT 1], trigger.New, 'buildertek__Auto_Number1__c');
        }
        if(Trigger.isInsert || Trigger.isUpdate){
            for(buildertek__Billings__c BillingRec : trigger.New){
                if(BillingRec.buildertek__Balance__c <= 0 && BillingRec.buildertek__Total_Amount_Tax__c > 0){
                    if(Trigger.isUpdate) {
                        BillingRec.buildertek__Status__c = 'Paid';
                    }   
                }
                else if(BillingRec.buildertek__Receipts__c > 0 && BillingRec.buildertek__Balance__c > 0){
                    BillingRec.buildertek__Status__c = 'Partially Paid';
                }
                BillingRecordList.add(BillingRec);
            }
            handler.OnBeforeInsert(Trigger.new);

            if(Trigger.isUpdate){
            // handler.DeleteBudgetLine(Trigger.old ,Trigger.new , Trigger.oldMap , Trigger.newMap);
                handler.onBeforeUpdate(Trigger.old ,Trigger.new , Trigger.oldMap , Trigger.newMap);
            }
        } 
        else if(Trigger.isDelete){
            system.debug('before Delete');
            for(buildertek__Billings__c Inv : trigger.old){
                if(Inv.buildertek__Status__c == 'Paid' || Inv.buildertek__Status__c == 'Partially Paid' ){
                    Inv.adderror('You cannot delete a Paid or Partially Paid Invoice');    
                }
            }

            for(buildertek__Billings__c Inv : trigger.old){
                if(Inv.buildertek__BT_Finance_Transaction__c != null){
                    Inv.adderror('You cannot delete this Sales Invoice because it is related to a Finance Transaction record. Please delete the Finance Transaction record first then try again.');    
                }
            }
        }
    } else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            handler.OnAfterInsert(Trigger.new, Trigger.newMap);
            handler.onAfterInsertSI(Trigger.new); 
        } else if(Trigger.isUpdate){
            handler.OnAfterUpdate(Trigger.old, Trigger.new, Trigger.newMap, Trigger.oldMap); 
            handler.DeleteBudgetLine(Trigger.old ,Trigger.new , Trigger.oldMap , Trigger.newMap);
            handler.onAfterUpdateSI(Trigger.new , Trigger.oldMap);

        } else if(Trigger.isDelete){
            handler.onAfterDeleteSI(Trigger.old);
        }
    }
    
    
}