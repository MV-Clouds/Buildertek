public with sharing class CreatePaymentFromPayableInvController {
    @AuraEnabled
    public static ResponseBase createPaymentFromPI(String payableInvoiceId) {
        ResponseBase msg = new ResponseBase();
        try {
            
            List<buildertek__BT_Payment_Lines__c> newPaymentLines = new List<buildertek__BT_Payment_Lines__c>();

            List<buildertek__Account_Payable_Clone__c> payableInvoicerec = [SELECT Id, buildertek__Vendor__c, buildertek__Project__c, buildertek__Tax__c, buildertek__Net_Amount__c  FROM buildertek__Account_Payable_Clone__c WHERE Id = :payableInvoiceId];

            //if buildertek__Net_Amount__c is 0 show error message
            if (payableInvoicerec[0].buildertek__Net_Amount__c == 0) {
                msg.Status = 'Failed';
                msg.Message = 'Remaining Amount is 0. Payment cannot be created.';
                return msg;
            }

            if (!payableInvoicerec.isEmpty()) {
                List<buildertek__Account_Payable_Item_Clone__c> payableInvoiceLines = [SELECT Id, buildertek__Quantity__c, buildertek__Tax__c  FROM buildertek__Account_Payable_Item_Clone__c Where buildertek__Account_Payable_Clone__c = :payableInvoicerec[0].Id];

                //create a map of invoice line id and remaining quantity to be paid on that line
                Map<Id, Decimal> invoiceLineIdToRemainingQuantityMap = new Map<Id, Decimal>();
                for (buildertek__Account_Payable_Item_Clone__c payableInvoiceline : payableInvoiceLines) {
                    invoiceLineIdToRemainingQuantityMap.put(payableInvoiceline.Id, payableInvoiceline.buildertek__Quantity__c);
                }

                //debug the map by iterating over it
                for (Id invoiceLineId : invoiceLineIdToRemainingQuantityMap.keySet()) {
                    System.debug('invoiceLineId: ' + invoiceLineId + ' has quantity: ' + invoiceLineIdToRemainingQuantityMap.get(invoiceLineId));
                }

                //get all the payment lines for this invoice
                List<buildertek__BT_Payment_Lines__c> paymentLines = [SELECT Id, buildertek__Invoice_Line_AP__c, buildertek__QuantityEditable__c FROM buildertek__BT_Payment_Lines__c WHERE buildertek__Invoice_Line_AP__c IN :payableInvoiceLines];

                //update the remaining quantity to be paid on each invoice line
                for (buildertek__BT_Payment_Lines__c paymentLine : paymentLines) {
                    if (invoiceLineIdToRemainingQuantityMap.containsKey(paymentLine.buildertek__Invoice_Line_AP__c)) {
                        invoiceLineIdToRemainingQuantityMap.put(paymentLine.buildertek__Invoice_Line_AP__c, invoiceLineIdToRemainingQuantityMap.get(paymentLine.buildertek__Invoice_Line_AP__c) - paymentLine.buildertek__QuantityEditable__c);
                    }
                }

                //debug the map by iterating over it
                for (Id invoiceLineId : invoiceLineIdToRemainingQuantityMap.keySet()) {
                    System.debug('invoiceLineId: ' + invoiceLineId + ' remaining quantity: ' + invoiceLineIdToRemainingQuantityMap.get(invoiceLineId));
                }

                //create payment record
                buildertek__BT_Payment__c newPaymentrecord = new buildertek__BT_Payment__c();
                newPaymentrecord.buildertek__Invoices_AP__c = payableInvoicerec[0].Id;
                newPaymentrecord.buildertek__Project__c = payableInvoicerec[0].buildertek__Project__c;
                newPaymentrecord.buildertek__Amount__c = 0;
                newPaymentrecord.buildertek__Tax__c = payableInvoicerec[0].buildertek__Tax__c;
                newPaymentrecord.buildertek__Payee__c = payableInvoicerec[0].buildertek__Vendor__c;
                
                insert newPaymentrecord;

                if (payableInvoiceLines.size() > 0 ) {
                    for (buildertek__Account_Payable_Item_Clone__c payableInvoiceline : payableInvoiceLines) {
                        if (invoiceLineIdToRemainingQuantityMap.get(payableInvoiceline.Id) <= 0) {
                            continue;
                        }
                        buildertek__BT_Payment_Lines__c newPaymentLine = new buildertek__BT_Payment_Lines__c();
                        newPaymentLine.buildertek__Payment__c = newPaymentrecord.Id;
                        newPaymentLine.buildertek__Invoice_Line_AP__c = payableInvoiceline.Id;
                        // newPaymentLine.buildertek__QuantityEditable__c = payableInvoiceline.buildertek__Quantity__c;
                        newPaymentLine.buildertek__QuantityEditable__c = invoiceLineIdToRemainingQuantityMap.get(payableInvoiceline.Id);
                        newPaymentLine.buildertek__Tax__c = payableInvoiceline.buildertek__Tax__c;
                        newPaymentLines.add(newPaymentLine);
                    }

                    if (newPaymentLines.size() > 0) {
                        insert newPaymentLines;
                        msg.Status = 'Success';
                        msg.Message = 'Payment is Created Successfully';
                        msg.newRecordId = newPaymentrecord.Id;
                    }
                } else {
                    msg.Status = 'Success';
                    msg.Message = 'Payment is Created Successfully';
                    msg.newRecordId = newPaymentrecord.Id;
                }
            } else {
                msg.Status = 'Failed';
                msg.Message = 'Payable Invoice record is not found';
            }
            
            return msg;
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    
    public virtual class ResponseBase {
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public String Message {get;set;}
        @AuraEnabled 
        public String newRecordId;
    }
}