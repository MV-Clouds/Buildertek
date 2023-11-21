public without sharing class QBIntegrationQueueable{

    // @future(callout=true)
    // public static void QBIntegrationMethod(Id Sales_invoice_Id, Id receiptID){
    //     try {
    //         buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
    //         Account acc = new Account();
    //         if(SI.buildertek__Customer_Account__c != null){
    //             acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
    //         }
    //         else if(SI.buildertek__Customer_Account__c == null){
    //             system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
    //             acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
    //         }
    //         List<buildertek__Billable_Lines__c> SILine = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,QBO_SyncToken__c,Description__c,Unit_Price__c,Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];

    //         buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
    //         Boolean Get_Access_Token = true;
    //         if(acc.buildertek__QBO_ID__c == null && acc != null){
    //             Create_Customer_invoice_item_payment_in_QB(SILine, SI, acc, QBMetadata, Get_Access_Token, receiptID);
    //         }
    //         else{
    //             System.debug('Customer Already Available in QB ');
    //             if(SILine.size() > 0){
    //                 if(SILine[0].buildertek__QBO_ID__c == null){
    //                     Create_item_invoice_Payment_in_QB(SILine, SI, acc, QBMetadata, Get_Access_Token, receiptID);
    //                 }
    //                 else{
    //                     System.debug('Invoice Item Already Available in QB ');
    //                     if(SI.buildertek__QBO_ID__c == null){
    //                         Create_inoice_Payment_in_QB(SILine, SI, acc, QBMetadata, Get_Access_Token, receiptID);
    //                     }
    //                     else{
    //                         System.debug('Invoice Already Available in QB ');
    //                         Create_Payment_In_QB(SILine, SI, acc, QBMetadata, Get_Access_Token, receiptID);
    //                     }
    //                 }
    //             }
    //             else{
    //                 System.debug('There are no Invoice item available');
    //             }
    //         }

    //     } catch (Exception e) {
    //         System.debug('Error in QBIntegrationMethod ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
    //     }
    // }

    // public static void Create_Customer_invoice_item_payment_in_QB(List<buildertek__Billable_Lines__c> SILine, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
    //     try {
    //         String Customer_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //             String Customer_RequestBody = QBMap.mapAccountData(acc, 1);
    //             system.debug('JSON Body >>' +  Customer_RequestBody);
    //             HttpResponse Customer_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Customer_EndPoint , Customer_RequestBody, Get_Access_Token);
    //             system.debug('Customer API Status Code >> ' + Customer_Response.getStatusCode());
    //             // system.debug('Response >> ' + Response.getBody());
    //             if(Customer_Response.getStatusCode() == 200){
    //                 System.debug('Customer_Response.getBody() :: '+ Customer_Response.getBody());
    //                 QBCustomerResponseJSON Customer_Response_Deser = QBCustomerResponseJSON.parse(Customer_Response.getBody());
    //                 QBCustomerResponseJSON.Customer customer = new QBCustomerResponseJSON.Customer();
    //                 customer = Customer_Response_Deser.Customer;
    //                 System.debug('Customer JSON Deserialized >> ' + customer);
    //                 System.debug('Customer JSON Deserialized Id >> ' + customer.Id);

    //                 String CustomerQBID = customer.Id;


    //                 if(SILine.size() > 0){
    //                     if(SILine[0].buildertek__QBO_ID__c == null){
    //                         String InvoiceItem_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/item?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                         String InvoiceItem_RequestBody = QBMap.mapInvoiceLineData(SILine[0]);

    //                         system.debug('InvoiceItem Request Body >>' +  InvoiceItem_RequestBody);
    //                         HttpResponse InvoiceItem_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(InvoiceItem_EndPoint , InvoiceItem_RequestBody, Get_Access_Token);

    //                         system.debug('InvoiceItem API Status Code >> ' + InvoiceItem_Response.getStatusCode());
    //                         system.debug('InvoiceItem Resopnce >> ' + InvoiceItem_Response.getBody());
    //                         if(InvoiceItem_Response.getStatusCode() == 200){
    //                             QBInvoiceLineResponseJSON InvoiceItem_Response_desr = QBInvoiceLineResponseJSON.parse(InvoiceItem_Response.getBody());
    //                             QBInvoiceLineResponseJSON.Item item = new QBInvoiceLineResponseJSON.Item();
    //                             item = InvoiceItem_Response_desr.Item;
    //                             System.debug('InvoiceItem_Response_desr :: '+ item);
    //                             String InvoiceLineQBId = item.Id;
    //                             String InvoiceLineQBName = item.Name;

    //                             if(SI.buildertek__QBO_ID__c == null){
    //                                 String Invoice_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                                 String Invoice_RequestBody = QBMap.mapInvoiceData(SI, CustomerQBID, InvoiceLineQBId, InvoiceLineQBName);
    //                                 system.debug('Invoice_RequestBody >>' +  Invoice_RequestBody);
    //                                 HttpResponse Invoice_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Invoice_EndPoint , Invoice_RequestBody, Get_Access_Token);

    //                                 system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
    //                                 system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());

    //                                 if(Invoice_Response.getStatusCode() == 200){
    //                                     QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
    //                                     QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
    //                                     invoice = Invoice_Response_desr.Invoice;
    //                                     // System.debug('response invoice :: '+ invoice);
    //                                     String invoiceQBID = invoice.Id;

    //                                     buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
    //                                     String Payment_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                                     String Payment_RequestBody = QBMap.mapReceipt_PaymetData(receipt, CustomerQBID, invoiceQBID);
    //                                     system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
    //                                     HttpResponse Payment_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
    //                                     system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
    //                                     if(Payment_Response.getStatusCode() == 200){
    //                                         QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
    //                                         QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
    //                                         payment = Payment_Response_desr.Payment;
    //                                         System.debug('payment response :: '+ payment);
    //                                         String paymentQBID = payment.Id;

    //                                         UpdateReceipt(receipt.Id, payment.Id);

    //                                     }
    //                                     else{
    //                                         QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                                     }

    //                                     UpdateSalesInvoice(SI.Id, invoiceQBID);
    //                                 }
    //                                 else{
    //                                     QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                                 }
    //                             }

    //                             UpdateSIline(SILine[0].ID, InvoiceLineQBId);
    //                         }
    //                         else {
    //                             QBException.QB_response( InvoiceItem_Response.getStatusCode(),  InvoiceItem_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                         }
    //                     }
    //                     else{
    //                         System.debug('there are no sales invoice line available');
    //                     }
    //                 }
    //                 System.debug('calling update account');
    //                 UpdateAccount(acc.Id, CustomerQBID);
    //             }
    //             else {
    //                 QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //             }
    //     } catch (Exception e) {
    //         System.debug('Error in Create_Customer_invoice_item_payment : ' + e.getMessage() +'\n'+ e+ '\n' + e.getStackTraceString());
    //     }
    // }

    // public static void Create_item_invoice_Payment_in_QB(List<buildertek__Billable_Lines__c> SILine, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
    //     try {
    //                 String InvoiceItem_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/item?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                 String InvoiceItem_RequestBody = QBMap.mapInvoiceLineData(SILine[0]);
    //                 system.debug('InvoiceItem Request Body >>' +  InvoiceItem_RequestBody);
    //                 HttpResponse InvoiceItem_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(InvoiceItem_EndPoint , InvoiceItem_RequestBody, Get_Access_Token);

    //                 system.debug('InvoiceItem API Status Code >> ' + InvoiceItem_Response.getStatusCode());
    //                 system.debug('InvoiceItem Resopnce >> ' + InvoiceItem_Response.getBody());
    //                 if(InvoiceItem_Response.getStatusCode() == 200){
    //                     QBInvoiceLineResponseJSON InvoiceItem_Response_desr = QBInvoiceLineResponseJSON.parse(InvoiceItem_Response.getBody());
    //                     QBInvoiceLineResponseJSON.Item item = new QBInvoiceLineResponseJSON.Item();
    //                     item = InvoiceItem_Response_desr.Item;
    //                     System.debug('InvoiceItem_Response_desr :: '+ item);
    //                     String InvoiceLineQBId = item.Id;
    //                     String InvoiceLineQBName = item.Name;

    //                     if(SI.buildertek__QBO_ID__c == null){
    //                         String Invoice_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                         String Invoice_RequestBody = QBMap.mapInvoiceData(SI, acc.buildertek__QBO_ID__c, InvoiceLineQBId, InvoiceLineQBName);
    //                         system.debug('Invoice_RequestBody >>' +  Invoice_RequestBody);
    //                         HttpResponse Invoice_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Invoice_EndPoint , Invoice_RequestBody, Get_Access_Token);

    //                         system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
    //                         system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());

    //                         if(Invoice_Response.getStatusCode() == 200){
    //                             QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
    //                             QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
    //                             invoice = Invoice_Response_desr.Invoice;
    //                             // System.debug('response invoice :: '+ invoice);
    //                             String invoiceQBID = invoice.Id;

    //                             buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
    //                             String Payment_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //                             String Payment_RequestBody = QBMap.mapReceipt_PaymetData(receipt, acc.buildertek__QBO_ID__c, invoiceQBID);
    //                             system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
    //                             HttpResponse Payment_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
    //                             system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
    //                             if(Payment_Response.getStatusCode() == 200){
    //                                 QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
    //                                 QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
    //                                 payment = Payment_Response_desr.Payment;
    //                                 System.debug('payment response :: '+ payment);
    //                                 String paymentQBID = payment.Id;

    //                                 UpdateReceipt(receipt.Id, payment.Id);

    //                             }
    //                             else{
    //                                 QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                             }
    //                             // Do Not Move this Method Above the API Callout... It will Block API Callout...
    //                             UpdateSalesInvoice(SI.Id, invoiceQBID);
    //                         }
    //                         else{
    //                             QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                         }
    //                     }
    //                     else {
    //                         System.debug('Invoice Already Available in QB ');
    //                         Create_Payment_In_QB(SILine, SI, acc, QBMetadata, Get_Access_Token, receiptID);
    //                     }

    //                     UpdateSIline(SILine[0].ID, InvoiceLineQBId);
    //                 }
    //                 else {
    //                     QBException.QB_response( InvoiceItem_Response.getStatusCode(),  InvoiceItem_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //                 }
            
    //     } catch (Exception e) {
    //          System.debug('Error in Create_item_invoice_Payment_in_QB : ' + e.getMessage() +'\n'+ e+ '\n' + e.getStackTraceString());
    //     }
    // }

    // public static void Create_inoice_Payment_in_QB(List<buildertek__Billable_Lines__c> SILine, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
    //     try {
    //         String Invoice_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //         String Invoice_RequestBody = QBMap.mapInvoiceData(SI, acc.buildertek__QBO_ID__c, SILine[0].buildertek__QBO_ID__c, SILine[0].Name);
    //         system.debug('Invoice_RequestBody >>' +  Invoice_RequestBody);
    //         HttpResponse Invoice_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Invoice_EndPoint , Invoice_RequestBody, Get_Access_Token);

    //         system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
    //         system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());

    //         if(Invoice_Response.getStatusCode() == 200){
    //             QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
    //             QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
    //             invoice = Invoice_Response_desr.Invoice;
    //             // System.debug('response invoice :: '+ invoice);
    //             String invoiceQBID = invoice.Id;

    //             buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
    //             String Payment_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //             String Payment_RequestBody = QBMap.mapReceipt_PaymetData(receipt, acc.buildertek__QBO_ID__c, invoiceQBID);
    //             system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
    //             HttpResponse Payment_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
    //             system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
    //             if(Payment_Response.getStatusCode() == 200){
    //                 QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
    //                 QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
    //                 payment = Payment_Response_desr.Payment;
    //                 System.debug('payment response :: '+ payment);
    //                 String paymentQBID = payment.Id;

    //                 UpdateReceipt(receipt.Id, payment.Id);

    //             }
    //             else{
    //                 QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //             }

    //             UpdateSalesInvoice(SI.Id, invoiceQBID);
    //         }
    //         else{
    //             QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //         }
    //     } catch (Exception e) {
    //         System.debug('Error in Create_inoice_Payment_in_QB : ' + e.getMessage() +'\n'+ e + '\n' + e.getStackTraceString());

    //     }
    // }

    // public static void Create_Payment_In_QB(List<buildertek__Billable_Lines__c> SILine, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
    //     try {
    //         buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
    //         String Payment_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
    //         String Payment_RequestBody = QBMap.mapReceipt_PaymetData(receipt, acc.buildertek__QBO_ID__c, SI.buildertek__QBO_ID__c);
    //         system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
    //         HttpResponse Payment_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
    //         system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
    //         if(Payment_Response.getStatusCode() == 200){
    //             QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
    //             QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
    //             payment = Payment_Response_desr.Payment;
    //             System.debug('payment response :: '+ payment);
    //             String paymentQBID = payment.Id;
    //             UpdateReceipt(receipt.Id, payment.Id);

    //         }
    //         else{
    //             QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
    //         }
            
    //     } catch (Exception e) {
    //         System.debug('Error in Create_Payment_In_QB : ' + e.getMessage() +'\n'+ e);
    //     }
    // }

    // public static void UpdateAccount(String acc_Id, String QB_Id){
    //     try {
    //         system.debug('Account going to Update');
    //         Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c  FROM Account WHERE Id =: acc_Id LIMIT 1];
    //         Acc.buildertek__QBO_ID__c = QB_Id;
    //         update Acc;
        
    //     } catch (Exception e) {
    //         System.debug('Error in UpdateAccount : ' + e.getMessage() +'\n'+ e);
    //     }
    // }

    // public static void UpdateSIline(String SIline_Id, String QB_Item_Id){
    //     try {
    //         system.debug('sales Invoice line going to Update');
    //         buildertek__Billable_Lines__c SIline = [SELECT Id, Name , buildertek__QBO_ID__c FROM buildertek__Billable_Lines__c WHERE ID =:SIline_Id LIMIT 1];
    //         SIline.buildertek__QBO_ID__c = QB_Item_Id;
    //         update SIline;
    //     } catch (Exception e) {
    //         System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e);
    //     }
    // }

    // public static void UpdateSalesInvoice(String invoice_Id, String QB_invoice_Id){
    //     try {
    //         system.debug('sales Invoice going to Update');
    //         buildertek__Billings__c Invoice = [SELECT Id, Name , buildertek__QBO_ID__c FROM buildertek__Billings__c WHERE ID =:invoice_Id LIMIT 1];
    //         Invoice.buildertek__QBO_ID__c = QB_invoice_Id;
    //         update Invoice;
    //     } catch (Exception e) {
    //         System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e);
    //     }
    // }

    // public static void UpdateReceipt(String receipt_Id, String QB_Payment_Id){
    //     try {
    //         system.debug('Receipt going to Update');
    //         buildertek__Receipt__c receipt = [SELECT Id, Name , buildertek__QBO_ID__c FROM buildertek__Receipt__c WHERE ID =:receipt_Id LIMIT 1];
    //         receipt.buildertek__QBO_ID__c = QB_Payment_Id;
    //         update receipt;
    //     } catch (Exception e) {
    //         System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e);
    //     }
    // }

    // public static void createInvoceLineBatches(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID) {
    //     try {
    //         System.debug('\n in createBatches \n');
    //         // Ensure SILines is not empty before processing batches
    //             Integer totalItems = SILines.size();
    //             Integer batchSize = 30;
    //             Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed

    //             for (Integer i = 0; i < totalBatches; i++) {
    //                 Integer startIdx = i * batchSize;
    //                 Integer endIdx = Math.min((i + 1) * batchSize, totalItems);

    //                 List<buildertek__Billable_Lines__c> itemsBatch = new List<buildertek__Billable_Lines__c>();

    //                 // Create the sublist for the current batch
    //                 for (Integer j = startIdx; j < endIdx; j++) {
    //                     if(SILines[j].buildertek__QBO_ID__c == null){
    //                         itemsBatch.add(SILines[j]);
    //                     }
    //                 }

    //                 if(itemsBatch.size() > 0){
    //                     String InvoiceLine_RequestBody = QBMap.MapInvoiceLineToBatch(itemsBatch);
    //                     System.debug('InvoiceLine_RequestBody : ' + +InvoiceLine_RequestBody);
    //                     String InvoiceItem_EndPoint = 'https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365355801090/batch';            
    //                     HttpResponse InvoiceItem_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(InvoiceItem_EndPoint , InvoiceLine_RequestBody, Get_Access_Token);
    //                     if(InvoiceItem_Response.getStatusCode() == 200 ){
    //                         if(i == (totalBatches-1)){
    //                             // create invoice
    //                         }
    //                     }
    //                 }

    //             }
    //     } catch (Exception e) {
    //         System.debug('Exception in createBatches: ' + e.getMessage());
    //     }
    // }

}