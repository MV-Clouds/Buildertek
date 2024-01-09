public with sharing class CreatePaymentFromPayableInvController {
    @AuraEnabled
    public static ResponseBase createPaymentFromPI(String payableInvoiceId) {
        ResponseBase msg = new ResponseBase();
        try {
            
            List<buildertek__BT_Payment_Lines__c> newPaymentLines = new List<buildertek__BT_Payment_Lines__c>();

            List<buildertek__Account_Payable_Clone__c> payableInvoicerec = [SELECT Id, buildertek__Vendor__c, buildertek__Project__c FROM buildertek__Account_Payable_Clone__c WHERE Id = :payableInvoiceId];

            if (!payableInvoicerec.isEmpty()) {
                List<buildertek__Account_Payable_Item_Clone__c> payableInvoiceLines = [SELECT Id FROM buildertek__Account_Payable_Item_Clone__c Where buildertek__Account_Payable_Clone__c = :payableInvoicerec[0].Id];

                buildertek__BT_Payment__c newPaymentrecord = new buildertek__BT_Payment__c();
                newPaymentrecord.buildertek__Invoices_AP__c = payableInvoicerec[0].Id;
                newPaymentrecord.buildertek__Project__c = payableInvoicerec[0].buildertek__Project__c;
                newPaymentrecord.buildertek__Amount__c = 0;
                newPaymentrecord.buildertek__Payee__c = payableInvoicerec[0].buildertek__Vendor__c;

                
                insert newPaymentrecord;

                if (payableInvoiceLines.size() > 0) {
                    for (buildertek__Account_Payable_Item_Clone__c payableInvoiceline : payableInvoiceLines) {
                        buildertek__BT_Payment_Lines__c newPaymentLine = new buildertek__BT_Payment_Lines__c();
                        newPaymentLine.buildertek__Payment__c = newPaymentrecord.Id;
                        newPaymentLine.buildertek__Invoice_Line_AP__c = payableInvoiceline.Id;

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