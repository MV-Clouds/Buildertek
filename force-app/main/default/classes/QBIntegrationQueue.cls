public without sharing class QBIntegrationQueue {

    @future(callout=true)
    public static void QBcallouts(Id Sales_invoice_Id, Id receiptID, Boolean Create_Payment){
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c, buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            else if(SI.buildertek__Customer_Account__c == null){
                system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,buildertek__QBO_Name__c,QBO_SyncToken__c,Description__c,Unit_Price__c,Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            if(acc.buildertek__QBO_ID__c == null){
                // Customer - items - invoice - PAYMENT
                Create_Customer_invoice_item_payment_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
            }
            else{
                System.debug('Customer Available in QB');
                if(SILines.size() > 0){
                    // items - invoice - PAYMENT
                    String CustomerQBId = acc.buildertek__QBO_ID__c;
                    Create_item_invoice_Payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                }
                else {
                    if(SI.buildertek__QBO_ID__c == null){
                        // invoice - PAYMENT
                        Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
                        for(buildertek__Billable_Lines__c SIl : SILines){
                            lineIdsMap.put(
                                        // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                    Id.valueOf(SIl.Id), // Salesforce ID
                                    new List<String> { SIl.buildertek__QBO_ID__c , SIl.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__Total__c) } // QuickBooks ID
                                );
                        }
                        String CustomerQBId = acc.buildertek__QBO_ID__c;
                        Create_invoice_Payment_in_QB(SI, CustomerQBId, lineIdsMap,QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                    }
                    else{
                        // PAYMENT
                        String CustomerQBId = acc.buildertek__QBO_ID__c;
                        String InvoiceQBId = SI.buildertek__QBO_ID__c;
                        Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID);
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error in QBcallouts ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }

    }

    public static void Create_Customer_invoice_item_payment_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment){
        try {
            String Customer_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Customer_RequestBody = QBMap.mapAccountData(acc, 1);
            system.debug('JSON Body >>' +  Customer_RequestBody);
            HttpResponse Customer_Response = QBCallOutService.QBAPICallOut(Customer_EndPoint , Customer_RequestBody, Get_Access_Token);
            system.debug('Customer API Status Code >> ' + Customer_Response.getStatusCode());
            if(Customer_Response.getStatusCode() == 200){
                System.debug('Customer_Response.getBody() :: '+ Customer_Response.getBody());
                QBCustomerResponseJSON Customer_Response_Deser = QBCustomerResponseJSON.parse(Customer_Response.getBody());
                QBCustomerResponseJSON.Customer customer = new QBCustomerResponseJSON.Customer();
                customer = Customer_Response_Deser.Customer;
                String CustomerQBId = customer.Id;
                Create_item_invoice_Payment_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                UpdateAccount(acc.Id, CustomerQBId);
            }
            else{
                QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Customer_invoice_item_payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_item_invoice_Payment_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment){
        try {

            List<buildertek__Billable_Lines__c> ItemstoCreate = new List<buildertek__Billable_Lines__c>();
            for(buildertek__Billable_Lines__c Items : SILines){
                if(Items.buildertek__QBO_ID__c == null){
                    ItemstoCreate.add(Items);
                }
            }

            if(ItemstoCreate.size() > 0){
                Integer totalItems = ItemstoCreate.size();
                Integer batchSize = 30;
                Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed
                // Boolean No_Line_To_Create_IN_QB = true;
                Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();

                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);
    
                    List<buildertek__Billable_Lines__c> itemsBatch = new List<buildertek__Billable_Lines__c>();
    
                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                            itemsBatch.add(ItemstoCreate[j]);
                    }
                    System.debug((i+1) +' ***** No. Batch length ******** '+ itemsBatch.size());
                    // if(itemsBatch.size() > 0){
                        String InvoiceItem_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
                        String InvoiceItem_RequestBody = QBMap.MapInvoiceLineToBatch(itemsBatch); 
                        System.debug('InvoiceItem_RequestBody ' +InvoiceItem_RequestBody);
                        HttpResponse InvoiceItem_Response = QBCallOutService.QBAPICallOut(InvoiceItem_EndPoint , InvoiceItem_RequestBody, Get_Access_Token);
    
                        system.debug('Invoice Line API Status Code >> ' + InvoiceItem_Response.getStatusCode());
                        system.debug('Invoice Line Resopnce >> ' + InvoiceItem_Response.getBody());
    
                        if(InvoiceItem_Response.getStatusCode() == 200){
                            QBBatchResJSON response = QBBatchResJSON.parse(InvoiceItem_Response.getBody());
    
                            for (QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                                if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                    lineIdsMap.put(
                                        // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                        Id.valueOf(batchItem.bId), // Salesforce ID
                                        new List<String> { batchItem.Item.Id , batchItem.Item.Name, String.valueOf(batchItem.Item.UnitPrice) } // QuickBooks ID
                                    );
                                }
                            }
                            
                            if( i == (totalBatches-1)){
                                System.debug('when last batch finish.. crerate sales invoice');
                                System.debug('lineIdsMap >> ' + lineIdsMap);
                                if(SI.buildertek__QBO_ID__c == null){
                                    Create_invoice_Payment_in_QB(SI, CustomerQBId, lineIdsMap,QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                                }
                                else{
                                    System.debug('Invoice available in QB...');
                                    if(Create_Payment == true){
                                        String InvoiceQBId = SI.buildertek__QBO_ID__c;
                                        Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID);
                                    }
                                }
                                // update sales invoice lines....
                                UpdateSIline(ItemstoCreate, lineIdsMap);
                            }
                            // No_Line_To_Create_IN_QB = false;
                        }
                        else{
                            QBException.QB_response( InvoiceItem_Response.getStatusCode(),  InvoiceItem_Response.getBody(), 'QBIntegrationQueue', 'Create_item_invoice_Payment_in_QB');
                        }
                    // }
                }
            }
            else{
                // if(No_Line_To_Create_IN_QB == true){
                    System.debug('All Items of the invoice is available in QB');
                    Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                    for(buildertek__Billable_Lines__c SIl : SILines){
                        lineIdsMap1.put(
                                // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                Id.valueOf(SIl.Id), // Salesforce ID
                                new List<String> { SIl.buildertek__QBO_ID__c , SIl.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__Total__c) } // QuickBooks ID
                            );
                    }
                    if(SI.buildertek__QBO_ID__c == null){
                        Create_invoice_Payment_in_QB(SI, CustomerQBId, lineIdsMap1,QBMetadata, Get_Access_Token, receiptID, true);
                    }
                    else{
                        System.debug('Invoice available in QB...');
                        if(Create_Payment == true){
                            String InvoiceQBId = SI.buildertek__QBO_ID__c;
                            Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID);
                        }
                    }
                // }
            }
        } catch (Exception e) {
            System.debug('Error in Create_item_invoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_invoice_Payment_in_QB(buildertek__Billings__c SI, String CustomerQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment){
        try {
            // String CustomerQBId = acc.buildertek__QBO_ID__c;
            // Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
            String Invoice_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String Invoice_RequestBody = QBMap.mapInvoiceDataBatch(SI, CustomerQBId, lineIdsMap);
            System.debug('Invoice_RequestBody >> ' + Invoice_RequestBody);
            HttpResponse Invoice_Response = QBCallOutService.QBAPICallOut(Invoice_EndPoint , Invoice_RequestBody, Get_Access_Token);
            
            system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
            system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());
            
            if(Invoice_Response.getStatusCode() == 200){
                QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
                QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
                invoice = Invoice_Response_desr.Invoice;
                String InvoiceQBId = invoice.Id;
                if(Create_Payment == true){
                    Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID);
                }
                UpdateSalesInvoice(SI.Id, InvoiceQBId);
            }
            else{
                QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueue', 'Create_invoice_Payment_in_QB');
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Payment_In_QB(String InvoiceQBId, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
        try {
            buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
            String Payment_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Payment_RequestBody = QBMap.mapReceipt_PaymetData(receipt, CustomerQBId, InvoiceQBId);
            system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
            HttpResponse Payment_Response = QBCallOutService.QBAPICallOut(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
            system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
            if(Payment_Response.getStatusCode() == 200){
                QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
                QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
                payment = Payment_Response_desr.Payment;
                System.debug('payment response :: '+ payment);
                String paymentQBID = payment.Id;
                UpdateReceipt(receipt.Id, payment.Id);
            }
            else{
                QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
            }
        } catch (Exception e) {
            System.debug('Error in Create_Payment_In_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }


    // ..... Update Records ......
    public static void UpdateAccount(String acc_Id, String QB_Id){
        try {
            system.debug('Account going to Update');
            Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c  FROM Account WHERE Id =: acc_Id LIMIT 1];
            Acc.buildertek__QBO_ID__c = QB_Id;
            update Acc;
        
        } catch (Exception e) {
            System.debug('Error in UpdateAccount : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdateSIline(list<buildertek__Billable_Lines__c> SILines, Map<Id, List<String>> lineIdsMap){
        try {
            system.debug('sales Invoice line going to Update');

            for (buildertek__Billable_Lines__c record : SILines) {
                // Check if the Salesforce ID exists in the mapping and update the QuickBooks ID
                List<String> qbIdAndNameList = lineIdsMap.get(record.Id);

                // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                if (qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                    record.buildertek__QBO_ID__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                    record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                    // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                }
            }

            update SILines;
        } catch (Exception e) {
            System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdateSalesInvoice(String invoice_Id, String QB_invoice_Id){
        try {
            system.debug('sales Invoice going to Update');
            buildertek__Billings__c Invoice = [SELECT Id, Name , buildertek__QBO_ID__c FROM buildertek__Billings__c WHERE ID =:invoice_Id LIMIT 1];
            Invoice.buildertek__QBO_ID__c = QB_invoice_Id;
            update Invoice;
        } catch (Exception e) {
            System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void UpdateReceipt(String receipt_Id, String QB_Payment_Id){
        try {
            system.debug('Receipt going to Update');
            buildertek__Receipt__c receipt = [SELECT Id, Name , buildertek__QBO_ID__c FROM buildertek__Receipt__c WHERE ID =:receipt_Id LIMIT 1];
            receipt.buildertek__QBO_ID__c = QB_Payment_Id;
            update receipt;
        } catch (Exception e) {
            System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    @AuraEnabled
    public static boolean Create_customer_item_invoice_in_QB_flow(String Sales_invoice_Id){
        // This method run from the Quick action button to create Customer, Invoice and invoice in QB...
        try {
            string receiptID;
            boolean create_Payment = false;
            QBcallouts(Sales_invoice_Id, receiptID, create_Payment);
            return true;
        } catch (Exception e) {
            System.debug('Error in Create_Customer_invoice_item_payment_in_QB_Using_Button : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    
}