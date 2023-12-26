public without sharing class ReceiptTriggerHandler {


    public static void OnAfterInsert(buildertek__Receipt__c[] newReceiptList){
        SET<Id> receiptIdSet = new SET<Id>();
        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Receipt__c> receiptToUpdate = new List<buildertek__Receipt__c>();
        
        for(buildertek__Receipt__c recp : newReceiptList){
            projectIdSet.add(recp.buildertek__Project__c);     
        }
        
        List<buildertek__Receipt__c> receiptList;
        
        if(projectIdSet.size() > 0){
            if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible()&& Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()&& Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Project__c.isAccessible()){
                receiptList = [SELECT Id,  Name FROM buildertek__Receipt__c  WHERE buildertek__Project__c IN: projectIdSet   ORDER BY CreatedDate ASC];   
            }
        }else{
            if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible()&&  Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()){
                 receiptList = [SELECT Id,    Name  FROM buildertek__Receipt__c  ORDER BY CreatedDate ASC LIMIT 50000];
            }
        }                                                            
        
        
        String receiptId;
        Integer i = 1;
        if(receiptList != null){
        for(buildertek__Receipt__c recpt : receiptList){
            system.debug('increment --------> '+i);
            if(i > 9){
                receiptId = 'CR-00';      
            }else if(i > 99){
                receiptId = 'CR-0';    
            }else if(i > 999){
                receiptId = 'CR-';    
            }else{
                receiptId = 'CR-000';    
            }
            recpt.buildertek__Receipt_Number__c = receiptId + i;
            receiptToUpdate.add(recpt);
            i++;    
        }
        if(Schema.sObjectType.buildertek__Receipt__c.isUpdateable() && Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Receipt_Number__c.isUpdateable()){
              update receiptToUpdate;  
           }
        }

    }

    public static void QBIntegrationOnInsert(buildertek__Receipt__c[] newReceiptList, buildertek__Receipt__c[] oldReceiptList){
        try {

            for(buildertek__Receipt__c rec : newReceiptList){
                // QBIntegrationQueueable.QBIntegrationMethod(rec.buildertek__Billing__c, rec.Id);
                boolean Create_Payment = true;
                QBIntegrationQueue_SIFlow.qb_Payment_Invoice_Flow_Callout(rec.buildertek__Billing__c, rec.Id);
                // QBPaymentCreation.CreateQBPayment(rec.Id);
            }
            
        } catch (Exception e) {
            System.debug('Error in QBIntegrationOnInsert Trigger handler >> ' + e.getMessage() + '\n' + e);
        }
    }


    // public static void OnAfterDelete(buildertek__Receipt__c[] oldReceiptList){
    //     SET<Id> receiptIdSet = new SET<Id>();
    //     SET<Id> projectIdSet = new SET<Id>();
    //     List<buildertek__Receipt__c> receiptToUpdate = new List<buildertek__Receipt__c>();
        
    //     for(buildertek__Receipt__c recp : oldReceiptList){
    //         projectIdSet.add(recp.buildertek__Project__c);     
    //     }
        
    //     List<buildertek__Receipt__c> receiptList;
        
    //     if(projectIdSet.size() > 0){
    //         if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()&&  Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Project__c.isAccessible()){
    //             receiptList = [SELECT Id,  Name   FROM buildertek__Receipt__c WHERE buildertek__Project__c IN: projectIdSet   ORDER BY CreatedDate ASC];    
    //         }
    //     }else{
    //         if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible() &&  Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()){
    //             receiptList = [SELECT Id,  Name  FROM buildertek__Receipt__c ORDER BY CreatedDate ASC LIMIT 50000];
    //         }
    //     }                                                            
        
        
    //     String receiptId;
    //     Integer i = 1;
    //     for(buildertek__Receipt__c recpt : receiptList){
    //         system.debug('increment --------> '+i);
    //         if(i > 9){
    //             receiptId = 'CR-00';      
    //         }else if(i > 99){
    //             receiptId = 'CR-0';    
    //         }else if(i > 999){
    //             receiptId = 'CR-';    
    //         }else{
    //             receiptId = 'CR-000';    
    //         }
    //         recpt.buildertek__Receipt_Number__c = receiptId + i;
    //         receiptToUpdate.add(recpt);
    //         i++;    
    //     }
    //     if(Schema.sObjectType.buildertek__Receipt__c.isUpdateable() &&  Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Receipt_Number__c.isUpdateable()){
    //         update receiptToUpdate;      
    //     }
       
    // }

    public static void onAfterInsertReceipt(List<buildertek__Receipt__c> newReceiptList) {
        try {
            Set<Id> ChangeOrderIds = new Set<Id>();
            for (buildertek__Receipt__c ReceiptLine : newReceiptList) {
                if (ReceiptLine.buildertek__BT_Change_Order__c != null) {
                    ChangeOrderIds.add(ReceiptLine.buildertek__BT_Change_Order__c);
                }
            }
            
            if (!ChangeOrderIds.isEmpty()) {
                updateAmountOnChangeOrder(ChangeOrderIds);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public static void onAfterUpdate(List<buildertek__Receipt__c> newReceiptList, Map<Id, buildertek__Receipt__c> oldReceiptMap) {
        try {
            Set<Id> changeOrderIdsToUpdate = new Set<Id>();
    
            for (buildertek__Receipt__c ReceiptLine : newReceiptList) {
                buildertek__Receipt__c oldrec = oldReceiptMap.get(ReceiptLine.Id);
    
                if (ReceiptLine.buildertek__BT_Change_Order__c != oldrec.buildertek__BT_Change_Order__c ||
                    ReceiptLine.buildertek__Amount__c != oldrec.buildertek__Amount__c) {
                        if (oldrec.buildertek__BT_Change_Order__c != null) {
                            changeOrderIdsToUpdate.add(oldrec.buildertek__BT_Change_Order__c);
                        }
                        if (ReceiptLine.buildertek__BT_Change_Order__c != null) {
                            changeOrderIdsToUpdate.add(ReceiptLine.buildertek__BT_Change_Order__c);
                        }
                }
            }
    
            if (!changeOrderIdsToUpdate.isEmpty()) {
                updateAmountOnChangeOrder(changeOrderIdsToUpdate);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
    
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }    

    public static void onAfterDelete(List<buildertek__Receipt__c> oldReceiptList) {
        try {
            Set<Id> changeOrderIdsToUpdate = new Set<Id>();
            for (buildertek__Receipt__c ReceiptLine : oldReceiptList) {
                if (ReceiptLine.buildertek__BT_Change_Order__c != null) {
                    changeOrderIdsToUpdate.add(ReceiptLine.buildertek__BT_Change_Order__c);
                }
            }
            
            if (!changeOrderIdsToUpdate.isEmpty()) {
                updateAmountOnChangeOrder(changeOrderIdsToUpdate);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void updateAmountOnChangeOrder(Set<Id> ChangeOrderIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            Set<Id> siID = new Set<Id>();
            List<buildertek__Billings__c> salesinvo = [SELECT Id FROM buildertek__Billings__c WHERE buildertek__Change_Order__c IN :ChangeOrderIds];
            for (buildertek__Billings__c si : salesinvo) {
                siID.add(si.Id);
            }
            for (AggregateResult aggregatedResult : [SELECT buildertek__BT_Change_Order__c, SUM(buildertek__Amount__c) totalAmount FROM buildertek__Receipt__c WHERE buildertek__BT_Change_Order__c IN :ChangeOrderIds AND buildertek__Posting_Status__c != 'Canceled' AND buildertek__Billing__c IN :siID GROUP BY buildertek__BT_Change_Order__c]){
                Id ChangeOrderId = (Id)aggregatedResult.get('buildertek__BT_Change_Order__c');
                totalAmountMap.put(ChangeOrderId, aggregatedResult);
            }
            
            List<buildertek__Change_Order__c> changeOrderToUpdate = new List<buildertek__Change_Order__c>();
            
            for (Id coID :ChangeOrderIds) {
                if(totalAmountMap.containsKey(coID)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(coID);
                    Decimal totalAmount = (Decimal)aggregatedResult.get('totalAmount');

                    buildertek__Change_Order__c co = new buildertek__Change_Order__c(Id = coID);
                    co.buildertek__Total_Receipts__c = totalAmount;
                    changeOrderToUpdate.add(co);
                } else {
                    buildertek__Change_Order__c co = new buildertek__Change_Order__c(Id = coID);
                    co.buildertek__Total_Receipts__c = 0;
                    changeOrderToUpdate.add(co);
                }
            }
            System.debug('changeOrderToUpdate: ' + changeOrderToUpdate);
            if (!changeOrderToUpdate.isEmpty()) {
                update changeOrderToUpdate;
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