public with sharing class AccountPayableHelper {
    
    public static boolean bypassTrigger = false; //this variable using in PucrchaseOrderDAO and on that develoment is going on so we can't remove this rightnow
    public static boolean skipInvoicePOUpdate = false;


    public static void beforeDelete(List<buildertek__Account_Payable__c> listAccountPayable) {

        List<buildertek__Account_Payable_Item__c> listAccountPayableItem = [SELECT Id, Name, buildertek__Purchase_Order_Item__c, buildertek__Purchase_Order_Item__r.Id, buildertek__Purchase_Order_Item__r.buildertek__Quantity_Received__c, buildertek__Account_Payable__c, buildertek__Quantity__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c IN :listAccountPayable];
        List<buildertek__Purchase_Order_Item__c> listPurchaseOrderItem = new List<buildertek__Purchase_Order_Item__c>();

        for(buildertek__Account_Payable_Item__c currAccountPayableItem : listAccountPayableItem) {
            if(currAccountPayableItem.buildertek__Purchase_Order_Item__r != null) {
                currAccountPayableItem.buildertek__Purchase_Order_Item__r.buildertek__Quantity_Received__c = currAccountPayableItem.buildertek__Purchase_Order_Item__r.buildertek__Quantity_Received__c - currAccountPayableItem.buildertek__Quantity__c;
                listPurchaseOrderItem.add(currAccountPayableItem.buildertek__Purchase_Order_Item__r);
            }
        }

        if(listPurchaseOrderItem.size() > 0) {
            update listPurchaseOrderItem;
        }

        for(buildertek__Account_Payable__c currPayable : listAccountPayable) {
            if(String.isNotBlank(currPayable.buildertek__Status__c)) {
                // Changes as per brian Rquirement discussed on call - 29 nov 2023
                if(currPayable.buildertek__Status__c.equalsIgnoreCase('Approved') || currPayable.buildertek__Status__c.equalsIgnoreCase('Paid') 
                   || currPayable.buildertek__Status__c.equalsIgnoreCase('Partially Paid') || currPayable.buildertek__Status__c.equalsIgnoreCase('Partially Payment')) {
                    if(currPayable.buildertek__Status__c.equalsIgnoreCase('Approved')){
                        currPayable.addError('Contractor Invoice status is marked as Approved, therefore you cannot delete this contractor invoice.');
                    }
                    else if(currPayable.buildertek__Status__c.equalsIgnoreCase('Paid')){
                        currPayable.addError('Contractor Invoice status is marked as Paid, therefore you cannot delete this contractor invoice.');
                    }
                    else if(currPayable.buildertek__Status__c.equalsIgnoreCase('Partially Paid')){
                        currPayable.addError('Contractor Invoice status is marked as Partially Paid, therefore you cannot delete this contractor invoice.');
                    }
                    else if(currPayable.buildertek__Status__c.equalsIgnoreCase('Partial Payment')){
                        currPayable.addError('Contractor Invoice status is marked as Partial Payment, therefore you cannot delete this contractor invoice.');
                    }
                   }
            }
        }

    }

    public static void handleDeleteforBL(List<buildertek__Account_Payable__c> oldInvoiceList) {
        Map<Id, buildertek__Account_Payable__c> toDeleteBudgetItems = new Map<Id, buildertek__Account_Payable__c>();
        for(buildertek__Account_Payable__c invoice : oldInvoiceList){
            if(invoice.buildertek__BT_Budget_Line__c != null){
                toDeleteBudgetItems.put(invoice.buildertek__BT_Budget_Line__c, invoice);
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                //if name contains invoice name then only delete
                if(budgetItem.Name.contains(toDeleteBudgetItems.get(budgetItem.Id).Name)){
                    toDeleteBudgetLine.add(budgetItem); 
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }
            if(toDeleteBudgetLine.size() > 0){
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLine;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> allBudgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Invoice_PO__c FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            for(buildertek__Budget_Item__c budgetItem : allBudgetItems){
                budgetItem.buildertek__Invoice_PO__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Net_Amount__c;
            }
            update allBudgetItems;
        }
        
    }

    public static void updateforBudgetLine(buildertek__Account_Payable__c[] NewInvoiceList, Map<Id, buildertek__Account_Payable__c> oldInvoiceMap){
        String BLGroupID;
        list<buildertek__Budget_Line_Group__c> BLGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name LIKE '%Invoice (PO)%'];
        if (BLGroup.size() == 0){
            System.debug('Create Budgt Line Group');
            buildertek__Budget_Line_Group__c BLG = new buildertek__Budget_Line_Group__c(Name = 'Invoice (PO)');
            insert BLG;

            BLGroupID = BLG.Id;
        } else {
            BLGroupID = BLGroup[0].Id;
        }

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__Account_Payable__c invoice : NewInvoiceList){
            if(invoice.buildertek__BT_Budget_Line__c == null && invoice.buildertek__Budget__c != null ){
                buildertek__Account_Payable__c oldInvoice = oldInvoiceMap.get(invoice.Id);
                if(oldInvoice == null || oldInvoice.buildertek__BT_Budget_Line__c == null){
                    buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                    if (invoice.buildertek__Description__c != '' && invoice.buildertek__Description__c != null) {
                        if(invoice.Name.length() + invoice.buildertek__Description__c.length() <= 80){
                            budgetItem.Name = invoice.Name + ' ' + invoice.buildertek__Description__c;
                        } else {
                            budgetItem.Name = invoice.Name.substring(0, 80 - invoice.buildertek__Description__c.length()) + ' ' + invoice.buildertek__Description__c;
                        }
                    } else {
                        budgetItem.Name = invoice.Name;
                    }
                    budgetItem.buildertek__Unit_Price__c = 0;
                    budgetItem.buildertek__Invoice_PO__c = invoice.buildertek__Net_Amount__c;
                    budgetItem.buildertek__Quantity__c = 1;
                    budgetItem.buildertek__Group__c = BLGroupID;
                    budgetItem.buildertek__Budget__c = invoice.buildertek__Budget__c;
                    budgetItem.buildertek__Cost_Code__c = invoice.buildertek__Cost_Code__c;
                    toInsertBudgetItems.add(budgetItem);
                }

            }
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;

            for(buildertek__Account_Payable__c invoice : NewInvoiceList){
                if(invoice.buildertek__BT_Budget_Line__c == null && invoice.buildertek__Budget__c != null){
                    for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                        if(budgetItem.buildertek__Budget__c == invoice.buildertek__Budget__c){
                            invoice.buildertek__BT_Budget_Line__c = budgetItem.Id;
                        }
                    }
                }
            }
        }

        Map<Id, buildertek__Account_Payable__c> toDeleteBudgetItems = new Map<Id, buildertek__Account_Payable__c>();
        for(buildertek__Account_Payable__c invoice : NewInvoiceList){
            buildertek__Account_Payable__c oldInvoice = oldInvoiceMap.get(invoice.Id);
            if(oldInvoice != null && oldInvoice.buildertek__BT_Budget_Line__c != null && invoice.buildertek__BT_Budget_Line__c != oldInvoice.buildertek__BT_Budget_Line__c){
                invoice.buildertek__Budget__c = null;
                System.debug('oldInvoice.buildertek__BT_Budget_Line__c: ' + oldInvoice.buildertek__BT_Budget_Line__c);
                toDeleteBudgetItems.put(oldInvoice.buildertek__BT_Budget_Line__c, invoice);
            }
        }

        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> toDeleteBudgetItemsList = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            List<buildertek__Budget_Item__c> toDeleteBudgetLine = new List<buildertek__Budget_Item__c>();

            for(buildertek__Budget_Item__c budgetItem : toDeleteBudgetItemsList){
                //if name contains invoice name then only delete
                if(budgetItem.Name.contains(toDeleteBudgetItems.get(budgetItem.Id).Name)){
                    toDeleteBudgetLine.add(budgetItem); 
                    toDeleteBudgetItems.remove(budgetItem.Id);
                }
            }
            if(toDeleteBudgetLine.size() > 0 && skipInvoicePOUpdate == false){
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = true;
                delete toDeleteBudgetLine;
                BudgetItemTriggerHandler.blnSkipBudgetItemTrigger = false;
            }
        }

        //if toDeleteBudgetItems
        if(toDeleteBudgetItems.size() > 0){
            List<buildertek__Budget_Item__c> allBudgetItems = [SELECT Id, Name, buildertek__Budget__c, buildertek__Invoice_PO__c FROM buildertek__Budget_Item__c WHERE Id IN :toDeleteBudgetItems.keySet()];
            for(buildertek__Budget_Item__c budgetItem : allBudgetItems){
                budgetItem.buildertek__Invoice_PO__c -= toDeleteBudgetItems.get(budgetItem.Id).buildertek__Net_Amount__c;
            }
            update allBudgetItems;
        }
    }
   
    public static void afterUpdate(buildertek__Account_Payable__c[] oldPayableList, buildertek__Account_Payable__c[] updatedPayableList, Map<ID, buildertek__Account_Payable__c> PayableMap, Map<Id, buildertek__Account_Payable__c> oldPayableMap){

        Set<Id> InvoiceIdsforBL = new Set<Id>();
        for (buildertek__Account_Payable__c pay : updatedPayableList) {
            if(pay.buildertek__Budget__c != null){
                InvoiceIdsforBL.add(pay.Id);
            }
        }
        BillLineItemTriggerHandler.recalculateInvoice(InvoiceIdsforBL);

        System.debug('afterUpdate:::');
        SET<Id> purchaseOderIdSet = new SET<Id>();
        SET<Id> budgetIdSet = new SET<Id>();
        SET<Id> budgetPurchaseOderIdSet = new SET<Id>();
        decimal totalAmount = 0;
        Map<String, String> purchaseOrderMap = new Map<String, String>();
        Map<String, Decimal> budgetMap = new Map<String, Decimal>();
        List<buildertek__Budget__c> budgetListToUpdate = new List<buildertek__Budget__c>();
        Set<Id> invoiceIds = new Set<Id>();
        for(buildertek__Account_Payable__c pay : updatedPayableList){ 
            purchaseOderIdSet.add(pay.buildertek__Purchase_Order__c); 

            if (pay.buildertek__Net_Amount__c != oldPayableMap.get(pay.Id).buildertek__Net_Amount__c) {
                invoiceIds.add(pay.Id);
            }
        } 
        system.debug('purchaseOderIdSet --------> '+purchaseOderIdSet);
        List<buildertek__Purchase_Order__c> purchaseOrderList = new  List<buildertek__Purchase_Order__c>();
        purchaseOrderList = [SELECT Id,  Name,  buildertek__Budget__c  FROM buildertek__Purchase_Order__c  WHERE Id IN: purchaseOderIdSet];
          
        if(purchaseOrderList.size() > 0){
            for(buildertek__Purchase_Order__c PO : purchaseOrderList){
                if(PO.buildertek__Budget__c !=null){
                budgetIdSet.add(PO.buildertek__Budget__c); 
                }
            }
        }
            List<buildertek__Purchase_Order__c> budgetPurchaseOrderList = new List<buildertek__Purchase_Order__c>();
             
        if(budgetIdSet !=null)  {          
                budgetPurchaseOrderList= [SELECT Id,
                                            Name,
                                            buildertek__Budget__c
                                            FROM buildertek__Purchase_Order__c
                                            WHERE buildertek__Budget__c IN: budgetIdSet];
            
        }
        if(budgetPurchaseOrderList.size() > 0){
            system.debug('budgetPurchaseOrderList Size --------> '+budgetPurchaseOrderList.size());
            for(buildertek__Purchase_Order__c purchaseOrder : budgetPurchaseOrderList){
                budgetPurchaseOderIdSet.add(purchaseOrder.Id);
                purchaseOrderMap.put(purchaseOrder.Id, purchaseOrder.buildertek__Budget__c);
            } 
        }
            List<buildertek__Account_Payable__c> payablesList = new  List<buildertek__Account_Payable__c>();
        if(budgetPurchaseOderIdSet !=null){
            
            payablesList = [SELECT Id,   Name,  buildertek__Purchase_Order__c,    buildertek__Purchase_Order__r.buildertek__Budget__c,  buildertek__Payments__c   FROM buildertek__Account_Payable__c    WHERE buildertek__Purchase_Order__c IN: budgetPurchaseOderIdSet];
            
                                                    
            system.debug('payablesList --------> '+payablesList);
            system.debug('payablesList Size --------> '+payablesList.size());
        }
        if(payablesList.size()>0){
            for(buildertek__Account_Payable__c payable : payablesList){ 
                //totalAmount += invoice.buildertek__Total_Amount_Tax__c;
                if(budgetMap.get(payable.buildertek__Purchase_Order__r.buildertek__Budget__c) == null){
                    budgetMap.put(payable.buildertek__Purchase_Order__r.buildertek__Budget__c, payable.buildertek__Payments__c);    
                }else{
                   decimal finalTotalAmount = budgetMap.get(payable.buildertek__Purchase_Order__r.buildertek__Budget__c) + payable.buildertek__Payments__c; 
                   budgetMap.put(payable.buildertek__Purchase_Order__r.buildertek__Budget__c, finalTotalAmount);
                }
                 
            }  
        }                                            
            for(String budgetId : budgetMap.keySet()){
                if(budgetId != null ){
                    
                        buildertek__Budget__c newBudget =  new buildertek__Budget__c();
                        newBudget.Id = budgetId;
                        newBudget.buildertek__Paid_To_Date__c = budgetMap.get(budgetId);
                        budgetListToUpdate.add(newBudget);    
                    
                }
            } 
            if(budgetListToUpdate.size() > 0){
                if ( Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Paid_To_Date__c.isUpdateable()) {
                   update budgetListToUpdate;  
                        }
            }   
            
        if (invoiceIds.size() > 0) {
            List<buildertek__Finance_Transaction__c> transactionList = [SELECT Id, Name, buildertek__Contractor_Invoice_PO__c FROM buildertek__Finance_Transaction__c WHERE buildertek__Contractor_Invoice_PO__c IN: invoiceIds];
            for (buildertek__Finance_Transaction__c fTransaction : transactionList) {
                fTransaction.buildertek__Amount__c = PayableMap.get(fTransaction.buildertek__Contractor_Invoice_PO__c).buildertek__Net_Amount__c * (-1);
                fTransaction.buildertek__Debit_Amount__c = PayableMap.get(fTransaction.buildertek__Contractor_Invoice_PO__c).buildertek__Net_Amount__c;
            }
            if (transactionList.size() > 0) {
                update transactionList;
            }
        }

        Set<Id> poIdsToUpdate = new Set<Id>();
        for (buildertek__Account_Payable__c ci : updatedPayableList) {
            buildertek__Account_Payable__c oldci = oldPayableMap.get(ci.Id);
            
            if (oldci.buildertek__Purchase_Order__c != null){
                poIdsToUpdate.add(oldci.buildertek__Purchase_Order__c);
            }

            if (ci.buildertek__Purchase_Order__c != null){
                poIdsToUpdate.add(ci.buildertek__Purchase_Order__c);
            }
        }

        if (!poIdsToUpdate.isEmpty()) {
            updateAmountOnpurchaseorder(poIdsToUpdate);
        }
        
    }
    
    //updateforBudgetLine


    //onbeforeInsert
    public static void onbeforeInsert(buildertek__Account_Payable__c[] invoiceList){
        String budgetLineGroupId ;
        list<buildertek__Budget_Line_Group__c> budgetLineGroups = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name LIKE '%Invoice (PO)%'];
        if (budgetLineGroups.size() == 0){
            buildertek__Budget_Line_Group__c budgetLineGroup = new buildertek__Budget_Line_Group__c(Name = 'Invoice (PO)');
            insert budgetLineGroup;
            budgetLineGroupId = budgetLineGroup.Id;
        } else {
            budgetLineGroupId = budgetLineGroups[0].Id;
        }
        System.debug('budgetLineGroupId: ' + budgetLineGroupId);

        List<buildertek__Budget_Item__c> toInsertBudgetItems = new List<buildertek__Budget_Item__c>();
        for(buildertek__Account_Payable__c invoice : invoiceList){
            if(invoice.buildertek__Budget__c != null && invoice.buildertek__BT_Budget_Line__c == null){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                if (invoice.buildertek__Description__c != '' && invoice.buildertek__Description__c != null) {
                    if(invoice.Name.length() + invoice.buildertek__Description__c.length() <= 80){
                        budgetItem.Name = invoice.Name + ' ' + invoice.buildertek__Description__c;
                    } else {
                        budgetItem.Name = invoice.Name.substring(0, 80 - invoice.buildertek__Description__c.length()) + ' ' + invoice.buildertek__Description__c;
                    }
                } else {
                    budgetItem.Name = invoice.Name;
                }
                budgetItem.buildertek__Unit_Price__c = 0;
                budgetItem.buildertek__Invoice_PO__c = invoice.buildertek__Net_Amount__c;
                budgetItem.buildertek__Quantity__c = 1;
                budgetItem.buildertek__Group__c = budgetLineGroupId;
                budgetItem.buildertek__Budget__c = invoice.buildertek__Budget__c;
                budgetItem.buildertek__Cost_Code__c = invoice.buildertek__Cost_Code__c;
                toInsertBudgetItems.add(budgetItem);
            }
        }

        if(toInsertBudgetItems.size() > 0){
            insert toInsertBudgetItems;

            for(buildertek__Account_Payable__c invoice : invoiceList){
                if(invoice.buildertek__Budget__c != null){
                    for(buildertek__Budget_Item__c budgetItem : toInsertBudgetItems){
                        if(budgetItem.buildertek__Budget__c == invoice.buildertek__Budget__c){
                            invoice.buildertek__BT_Budget_Line__c = budgetItem.Id;
                        }
                    }
                }
            }
        }
}


    public static void UpdateCOntractorInvoiceStatus(List<buildertek__Account_Payable__c> newAccountPayList, Map<Id, buildertek__Account_Payable__c> oldAccountPayMap) {
        try {
            Set<Id> contractorInvoiceIdsToUpdate = new Set<Id>();
            List<buildertek__Account_Payable__c> contractorInvoiceListForStatusUpdate = new List<buildertek__Account_Payable__c>();
        
            for (buildertek__Account_Payable__c pay : newAccountPayList) {
                buildertek__Account_Payable__c oldAPLine = oldAccountPayMap.get(pay.Id);
                if (pay.buildertek__Payments__c != oldAPLine.buildertek__Payments__c && pay.buildertek__Payments__c == 0) {
                    contractorInvoiceIdsToUpdate.add(pay.Id);
                }
            }
        
            List<buildertek__Account_Payable__c> getContInvoiceRecord = [Select Id, Name, buildertek__Payments__c, buildertek__Status__c FROM buildertek__Account_Payable__c WHERE Id IN :contractorInvoiceIdsToUpdate];

            for (buildertek__Account_Payable__c updateCI : getContInvoiceRecord) {
                updateCI.buildertek__Status__c = 'Open';
                contractorInvoiceListForStatusUpdate.add(updateCI);
            }
            
            update contractorInvoiceListForStatusUpdate;

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            
        }
    }
    
    public static void onbeforeUpdate(buildertek__Account_Payable__c[] updatedPayableList){ 
        for(buildertek__Account_Payable__c inv : updatedPayableList){ 
            if(inv.buildertek__Terms__c == 'Due on Receipt'){
            inv.buildertek__Due_Date__c = Date.today();
            }if(inv.buildertek__Date_Received__c != null && inv.buildertek__Terms__c != 'Due on Receipt'){
                if(inv.buildertek__Terms__c == 'Net 15'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Date_Received__c + 15;
                }else if(inv.buildertek__Terms__c == 'Net 30'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Date_Received__c + 30;
                }else if(inv.buildertek__Terms__c == 'Net 60'){
                    inv.buildertek__Due_Date__c = inv.buildertek__Date_Received__c + 60;
                }
            }
            
        }
    }
    

    public static void OnAfterInsert(buildertek__Account_Payable__c[] invoiceList, Map<Id, buildertek__Account_Payable__c> invoiceNewMap){

        Set<Id> invoiceIds = new Set<Id>();
        for (buildertek__Account_Payable__c invoice : invoiceList) {
            invoiceIds.add(invoice.Id);
        }
        if (invoiceIds.size() > 0) {
            List<buildertek__Finance_Transaction__c> transactionList = [SELECT Id, Name, buildertek__Contractor_Invoice_PO__c FROM buildertek__Finance_Transaction__c WHERE buildertek__Contractor_Invoice_PO__c IN: invoiceIds];
            for (buildertek__Finance_Transaction__c fTransaction : transactionList) {
                fTransaction.buildertek__Amount__c = invoiceNewMap.get(fTransaction.buildertek__Contractor_Invoice_PO__c).buildertek__Net_Amount__c * (-1);
                fTransaction.buildertek__Debit_Amount__c = invoiceNewMap.get(fTransaction.buildertek__Contractor_Invoice_PO__c).buildertek__Net_Amount__c;
            }
            if (transactionList.size() > 0) {
                update transactionList;
            }
        }

        Set<Id> poIdsToUpdate = new Set<Id>();
        for (buildertek__Account_Payable__c ci : invoiceList) {
            if (ci.buildertek__Purchase_Order__c != null){
                poIdsToUpdate.add(ci.buildertek__Purchase_Order__c);
            }
        }
        if (!poIdsToUpdate.isEmpty()) {
            updateAmountOnpurchaseorder(poIdsToUpdate);
        }

        Set<Id> invoicewithBL = new Set<Id>();
        for (buildertek__Account_Payable__c ci : invoiceList) {
            if (ci.buildertek__BT_Budget_Line__c != null){
                invoicewithBL.add(ci.Id);
            }
        }
        BillLineItemTriggerHandler.recalculateInvoice(invoicewithBL);
    }

    public static void RestrictToUpdateCashDisbursement(buildertek__Account_Payable__c[] invoiceList, Map<Id, buildertek__Account_Payable__c> newInvoiceMap ,  Map<Id, buildertek__Account_Payable__c> oldInvoiceMap ){

        List<buildertek__Payment__c> cashDisbursementList= [Select Id , Name , buildertek__Payable__c From buildertek__Payment__c WHERE buildertek__Payable__c=:newInvoiceMap.keySet()];
        for(buildertek__Account_Payable__c invoice : invoiceList){ 
            if(!cashDisbursementList.isEmpty() && invoice.buildertek__Payments__c == oldInvoiceMap.get(invoice.Id).buildertek__Payments__c){
                invoice.addError('You cannot update this Contractor Invoice because there is a Cash Disbursement associated with it.  If you would like to change this Contractor Invoice, please remove the Cash Disbursement first.');
            }
        }
    }

    public static void updateBudgetAndBudgetLine(buildertek__Account_Payable__c[] invoiceList, Map<Id, buildertek__Account_Payable__c> newInvoiceMap ,  Map<Id, buildertek__Account_Payable__c> oldInvoiceMap ){
        Map<String, buildertek__Budget_Item__c> MapToUpte = new  Map<String, buildertek__Budget_Item__c>();
        String BLGroupID;
        list<buildertek__Budget_Line_Group__c> BLGroup = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c WHERE Name LIKE '%Invoice (PO)%'];
            // Check is Buddget line group with name sales invoice is avialable or on if not abailabe it will create new
            if (BLGroup.size() == 0){
                System.debug('Create Budgt Line Group');
                buildertek__Budget_Line_Group__c BLG = new buildertek__Budget_Line_Group__c(Name = 'Invoice (PO)');
                insert BLG;

                BLGroupID = BLG.Id;
            } else {
                BLGroupID = BLGroup[0].Id;
            }

            for(buildertek__Account_Payable__c invoicePo : invoiceList){
                if(invoicePo.buildertek__BT_Budget_Line__c==null && invoicePo.buildertek__Budget__c != oldInvoiceMap.get(invoicePo.Id).buildertek__Budget__c && invoicePo.buildertek__Budget__c!=null){
                        buildertek__Budget_Item__c budgetLine = new buildertek__Budget_Item__c();
                        if (invoicePo.buildertek__Description__c != '' && invoicePo.buildertek__Description__c != null) {
                            // budgetLine.Name = invoicePo.Name + ' ' + invoicePo.buildertek__Description__c;

                            //if the above combination is not less than 80 characters
                            if(invoicePo.Name.length() + invoicePo.buildertek__Description__c.length() <= 80){
                                budgetLine.Name = invoicePo.Name + ' ' + invoicePo.buildertek__Description__c;
                            } else {
                                budgetLine.Name = invoicePo.Name.substring(0, 80 - invoicePo.buildertek__Description__c.length()) + ' ' + invoicePo.buildertek__Description__c;
                            }
                        } else {
                            budgetLine.Name = invoicePo.Name;
                        }
                        budgetLine.buildertek__Unit_Price__c = 0;
                        budgetLine.buildertek__Invoice_PO__c = invoicePo.buildertek__Net_Amount__c;
                        budgetLine.buildertek__Quantity__c = 1;
                        budgetLine.buildertek__Group__c = BLGroupID;
                        budgetLine.buildertek__Budget__c = invoicePo.buildertek__Budget__c;
                        budgetLine.buildertek__Cost_Code__c = invoicePo.buildertek__Cost_Code__c; 
                        MapToUpte.put(invoicePo.Id, budgetLine);
                }
            }
            if(MapToUpte.size() > 0){
                insert MapToUpte.values();
    
                for(buildertek__Account_Payable__c invoicePo : invoiceList){
                    if(invoicePo.buildertek__BT_Budget_Line__c==null && invoicePo.buildertek__Budget__c != oldInvoiceMap.get(invoicePo.Id).buildertek__Budget__c && invoicePo.buildertek__Budget__c!=null){
                            invoicePo.buildertek__BT_Budget_Line__c = MapToUpte.get(invoicePo.Id).Id;
                    }
                }

            } 

            // Remove Budget when Budget Line is removed from Sales invoice --------------------------------------
            for(buildertek__Account_Payable__c invoicePo : invoiceList){
                if(!skipInvoicePOUpdate  && invoicePo.buildertek__BT_Budget_Line__c == null && oldInvoiceMap.get(invoicePo.id).buildertek__BT_Budget_Line__c != null && invoicePo.buildertek__Budget__c != null){
                    invoicePo.buildertek__Budget__c = null;
                }
            }
    }

    // If user remove budget line from  invoice it will delete  invoice in perticular  invoicce auto created from Code.
    public static void DeleteBudgetLine(buildertek__Account_Payable__c[] oldInvoiceList, buildertek__Account_Payable__c[] newInvoiceList, Map<ID, buildertek__Account_Payable__c> oldInvoiceMap , Map<ID, buildertek__Account_Payable__c> newInvoiceMap){
        list<buildertek__Budget_Item__c> BudgetLineToDELETE = new list<buildertek__Budget_Item__c>();
        list<buildertek__Account_Payable__c> SaleInvoiceToUpdate = new list<buildertek__Account_Payable__c>();
        Set<Id> BudgetLineToDELETESet = new Set<Id>();

        for(buildertek__Account_Payable__c invoicePo : newInvoiceList){
            if(invoicePo.buildertek__BT_Budget_Line__c == null && oldInvoiceMap.get(invoicePo.id).buildertek__BT_Budget_Line__c != null){
                String BlName = '%'+invoicePo.Name+'%';
                list<buildertek__Budget_Item__c> BLlist = [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id =: oldInvoiceMap.get(invoicePo.id).buildertek__BT_Budget_Line__c AND Name LIKE :BlName LIMIT 1];
                for(buildertek__Budget_Item__c bl : BLlist){
                    BudgetLineToDELETESet.add(bl.Id);
                    }
                }
            }
            if( !skipInvoicePOUpdate && BudgetLineToDELETESet.size() > 0){
                System.debug('Budget line Is going to Delete From  Invoice PO');
                for(buildertek__Budget_Item__c BL : [SELECT Id, Name FROM buildertek__Budget_Item__c WHERE Id IN: BudgetLineToDELETESet]){
                    BudgetLineToDELETE.add(BL);
                }
                delete BudgetLineToDELETE;
            }
}

    public static void onAfterDelete(List<buildertek__Account_Payable__c> oldContractorInvoiceList) {
        try {
            Set<Id> poIds = new Set<Id>();
            for (buildertek__Account_Payable__c ci : oldContractorInvoiceList) {
                if (ci.buildertek__Purchase_Order__c != null){
                    poIds.add(ci.buildertek__Purchase_Order__c);
                }
            }
            updateAmountOnpurchaseorder(poIds);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void updateAmountOnpurchaseorder(Set<Id> purchaseOrderIds) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__Purchase_Order__c, SUM(buildertek__Net_Amount__c) totalAmount FROM buildertek__Account_Payable__c WHERE buildertek__Purchase_Order__c IN :purchaseOrderIds GROUP BY buildertek__Purchase_Order__c]){
                Id poId = (Id)aggregatedResult.get('buildertek__Purchase_Order__c');
                totalAmountMap.put(poId, aggregatedResult);
            }
            
            List<buildertek__Purchase_Order__c> purchaseOrderToUpdate = new List<buildertek__Purchase_Order__c>();
            
            for (Id poId :purchaseOrderIds) {
                if(totalAmountMap.containsKey(poId)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(poId);
                    Decimal totalAmount = (Decimal)aggregatedResult.get('totalAmount');

                    buildertek__Purchase_Order__c purchaseorder = new buildertek__Purchase_Order__c(Id = poId);
                    purchaseorder.buildertek__Total_Invoiced__c = totalAmount;
                    purchaseOrderToUpdate.add(purchaseorder);
                } else {
                    buildertek__Purchase_Order__c purchaseorder = new buildertek__Purchase_Order__c(Id = poId);
                    purchaseorder.buildertek__Total_Invoiced__c = 0;
                    purchaseOrderToUpdate.add(purchaseorder);
                }
            }
            System.debug('purchaseOrderToUpdate: ' + purchaseOrderToUpdate);
            if (!purchaseOrderToUpdate.isEmpty()) {
                update purchaseOrderToUpdate;
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