// integration Betweek Quickbook and Salsforce

public without sharing class QBIntegrationQueue {
    

    // --------------- ------------- ----------------- Sales Invoice and Payment(Receipt) QB Integration Flow - START ------------------- --------------------- ----------------------- --------------------
    @future(callout=true)
    public static void QB_Payment_Invoice_Flow_Callout(Id Sales_invoice_Id, Id receiptID){
        //  *********  Integration flow --> Customer - TaxRate - Term - Items(Product and Service) - Invoice - Payment(Receipt)
        
        // 1. BT Sales Invoice Customer Account(Parent Customer) --> QB Customer [ ----- first Code Create Customer in QB From Invoice Customer account(or Project Customer Account), if Customer Already available in QB Then QB Customer id Must be store on Account Object) -----]
        // 2. BT Sales Invoice Tax Rate (Field) --> QB Tax Rate                  
        // 3. BT Sales Invoice Term (Picklist filed) --> QB Term
        // 4. BT Sals invoice related invoice Lines (Related Objects) --> QB Product and Service
        // 5. BT Sales Invoice (Object) --> QB Invoice
        // 6. BT receipt (Object) --> QB Payment
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__Tax_Rate__c, buildertek__QB_Invoice_URL__c, buildertek__QB_Invoice_Number__c	,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Terms__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            else if(SI.buildertek__Customer_Account__c == null){
                system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__SubTotal__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            String SyncObjName = 'buildertek__Billings__c';

            // if(acc.buildertek__QB_Id__c == null){
                // Customer - items - invoice - PAYMENT
                Create_Customer_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in QB_Payment_Invoice_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Customer_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String SyncObjName){
        try {
            String Customer_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Customer_RequestBody = QBMap.mapAccountData(acc, 1);
            system.debug('JSON Body >>' +  Customer_RequestBody);
            HttpResponse Customer_Response = QBCallOutService.QBAPICallOut(Customer_EndPoint , Customer_RequestBody, Get_Access_Token);
            system.debug('Customer API Status Code >> ' + Customer_Response.getStatusCode());
            System.debug('Customer_Response.getBody() :: '+ Customer_Response.getBody());
            if(Customer_Response.getStatusCode() == 200){
                QBCustomerResponseJSON Customer_Response_Deser = QBCustomerResponseJSON.parse(Customer_Response.getBody());
                QBCustomerResponseJSON.Customer customer = new QBCustomerResponseJSON.Customer();
                customer = Customer_Response_Deser.Customer;
                String CustomerQBId = customer.Id;
                String SyncToken = customer.SyncToken;
                // this condition define wheather You want to countine the integration or not...
                if(SyncObjName != 'Account'){ 
                    // Create_TaxRate_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, SyncObjName);
                    Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
                }
                UpdateAccount(acc.Id, CustomerQBId, QBMetadata, SyncToken, 'Customer');
            }
            else{
                QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBIntegrationQueue', 'Create_Customer_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Customer_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateAccount_OnError(acc.Id, ErrorMessage);
                UpdateRecord_OnError(acc.Id, ErrorMessage, 'Account');
                if(SyncObjName != 'Account'){
                    String ErrorMessage1 = 'Error During Customer Callout :- ' + ErrorMessage;
                    UpdateRecord_OnError(SI.Id, ErrorMessage1, SyncObjName);
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Customer_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_item_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String SyncObjName){
        try {

            List<buildertek__Billable_Lines__c> ItemstoCreate = new List<buildertek__Billable_Lines__c>();
            for(buildertek__Billable_Lines__c Items : SILines){
                if(Items.buildertek__QB_Id__c == null){
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
    
                            // First Add Existing Invoice Lines(if available)....And Then Added Newly created invoice Lines to the Qb Invoice....
                            for(buildertek__Billable_Lines__c SIL : SILines){
                                if(SIL.buildertek__QB_Id__c != null){
                                    lineIdsMap.put(
                                        Id.valueOf(SIL.Id), 
                                        new List<String>{SIL.buildertek__QB_Id__c, SIL.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__SubTotal__c), string.valueOf(SIL.buildertek__Quantity__c), string.valueOf(SIL.Unit_Price__c)}
                                    );
                                }
                            }

                            for (QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                                if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                    lineIdsMap.put(
                                        // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                        Id.valueOf(batchItem.bId), // Salesforce ID
                                        // List Of QB Line Id, QB Line Name , Total Price, Quantity, Unite Price...
                                        new List<String> { batchItem.Item.Id , batchItem.Item.Name, String.valueOf((batchItem.Item.QtyOnHand)*(batchItem.Item.UnitPrice)), String.valueOf(batchItem.Item.QtyOnHand), String.valueOf(batchItem.Item.UnitPrice) } // QuickBooks ID
                                    );
                                }
                            }
                            
                            if( i == (totalBatches-1)){
                                System.debug('when last batch finish.. crerate sales invoice');
                                System.debug('lineIdsMap >> ' + lineIdsMap);
                                    // Create_invoice_in_QB(SI, CustomerQBId, lineIdsMap, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId, SyncObjName);

                                // update sales invoice lines....
                                UpdateSIline(ItemstoCreate, lineIdsMap);
                            }
                        }
                        else{
                            QBException.QB_response( InvoiceItem_Response.getStatusCode(),  InvoiceItem_Response.getBody(), 'QBIntegrationQueue', 'Create_item_in_QB');
                            QBOErrorJSON Response_Error = QBOErrorJSON.parse(InvoiceItem_Response.getBody());
                            QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                            falut = Response_Error.Fault;
                            String ErrorMessage = 'Error During Invoice Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                            // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                            UpdateRecord_OnError(SI.Id, ErrorMessage, SyncObjName);
                        }
                    // }
                }
            }
            else{
                    System.debug('All Items of the invoice is available in QB');
                    Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                    for(buildertek__Billable_Lines__c SIl : SILines){
                        lineIdsMap1.put(
                                // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                Id.valueOf(SIl.Id), // Salesforce ID
                                new List<String> { SIl.buildertek__QB_Id__c , SIl.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__SubTotal__c), string.valueOf(SIL.buildertek__Quantity__c), string.valueOf(SIL.Unit_Price__c) } // QuickBooks ID
                        );
                    }
                        Create_TaxRate_in_QB(SILines, SI, lineIdsMap1, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
            }
        } catch (Exception e) {
            System.debug('Error in Create_item_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_TaxRate_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI,Map<Id, List<String>> lineIdsMap, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String SyncObjName){
        try {
            List<buildertek__Billings__c> allInvoice = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QB_Invoice_URL__c,buildertek__QB_Invoice_Number__c, buildertek__QB_Id__c,buildertek__Tax_Rate__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c];
            Boolean IsTaxRateExistInQB = false; // to break loop if once invoice flow going forward...
            String taxCodeId;
            Double taxRateValue;
            String taxCodeName;
            taxCodeName = 'Tax - ' + string.valueOf(SI.buildertek__Tax_Rate__c);
            // String  taxCodeName = taxName.substring(0, taxName.length() - 2);
             System.debug('taxName------>' + taxCodeName);
            String encodedQueryParam = EncodingUtil.urlEncode('Select * From TaxCode Where Name = \''+taxCodeName + '\'', 'UTF-8');

            String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 

            HttpResponse get_TaxRate_from_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null,false);
                if(get_TaxRate_from_QB_ResponseBody.getStatusCode() == 200){
                    System.debug('get_TaxRate_from_QB_ResponseBody.getBody() :: ' + get_TaxRate_from_QB_ResponseBody.getBody());

                    QBTaxRateJSON get_TaxRate_from_QB_ResponseBody_Deser = QBTaxRateJSON.parse(get_TaxRate_from_QB_ResponseBody.getBody());
                    System.debug('get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse >> ' + get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse);
                    // Accessing Id and RateValue directly from the TaxRate instanceß
                    if(get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse.totalCount != null){
                        QBTaxRateJSON.TaxCode  getTaxRateDetail = get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse.TaxCode[0];
                        System.debug('getTaxRateDetail----->' + getTaxRateDetail);
                        // TaxRate is already exist in QB
                        taxCodeId = getTaxRateDetail.Id;
                        taxRateValue = SI.buildertek__Tax_Rate__c;
                        System.debug('taxCodeId -----> ' + taxCodeId);
                        System.debug('taxRateValue -----> ' + taxRateValue);
                        System.debug('// Create Invoice with exsiting tax rate ID...');
                        Create_Term_in_QB(SILines, SI, lineIdsMap, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, taxCodeId, taxRateValue, SyncObjName);
                    }
                    else{
                        // TaxRate is not exist in QB
                        System.debug('// Create New Tax Rate In QB...');
                        taxCodeId = null;
                        taxRateValue = null;
                        String TaxRate_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/taxservice/taxcode?minorversion=' + QBMetadata.buildertek__minorversion__c; 
                        String TaxRate_RequestBody = QBMap.mapTaxRateData(SI);           
                        HttpResponse TaxRate_ResponseBody = QBCallOutService.QBAPICallOut(TaxRate_EndPoint, TaxRate_RequestBody,false);
                        if(TaxRate_ResponseBody.getStatusCode() == 200){
                            System.debug('TaxRate_ResponseBody.getBody() :: '+ TaxRate_ResponseBody.getBody());
                            QBTaxCodeResponseJSON TaxRate_ResponseBody_Deser =  QBTaxCodeResponseJSON.parse(TaxRate_ResponseBody.getBody());
                            List<QBTaxCodeResponseJSON.TaxRateDetails> TaxRateDetai = new  List<QBTaxCodeResponseJSON.TaxRateDetails>();
                            TaxRateDetai = TaxRate_ResponseBody_Deser.TaxRateDetails;
                            taxCodeId = TaxRate_ResponseBody_Deser.TaxCodeId;
                            taxRateValue = TaxRateDetai[0].RateValue;
                            Create_Term_in_QB(SILines, SI, lineIdsMap, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, taxCodeId, taxRateValue, SyncObjName);
                        }
                        else{
                            QBException.QB_response( TaxRate_ResponseBody.getStatusCode(),  TaxRate_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                            QBOErrorJSON Response_Error = QBOErrorJSON.parse(TaxRate_ResponseBody.getBody());
                            QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                            falut = Response_Error.Fault;
                            String ErrorMessage = 'Error During Tax Rate Callout :- '+'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                            // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                            UpdateRecord_OnError(SI.Id, ErrorMessage, SyncObjName);
                        }
                    }
                }
                else{
                    QBException.QB_response( get_TaxRate_from_QB_ResponseBody.getStatusCode(),  get_TaxRate_from_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                }
            
        } catch (Exception e) {
            System.debug('Error in Create_TaxRate_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Term_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, Map<Id, List<String>> lineIdsMap, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String taxCodeId, Double taxRateValue, String SyncObjName){
        try {
            String termName = SI.buildertek__Terms__c;
            String encodedQueryParam = EncodingUtil.urlEncode('Select * From Term Where Name = \''+termName + '\'', 'UTF-8');
            String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 
            String TermQBId = null;

            // Check if term Availbe or not in QB....
            HttpResponse term_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null,false);
            System.debug('term_QB_ResponseBody >> ' + term_QB_ResponseBody);
                if(term_QB_ResponseBody.getStatusCode() == 200){
                    QBtermsResponseJSON term_QB_ResponseBody_Desr = QBtermsResponseJSON.parse(term_QB_ResponseBody.getBody());
                    QBtermsResponseJSON.QueryResponse QueryResponse = new QBtermsResponseJSON.QueryResponse();
                    QueryResponse = term_QB_ResponseBody_Desr.QueryResponse;
                    System.debug('term_QB_ResponseBody_Desr.QueryResponse >> ' + term_QB_ResponseBody_Desr.QueryResponse);
                    List<QBtermsResponseJSON.Term> Terms = new List<QBtermsResponseJSON.Term>();
                    if(QueryResponse.Term != null){
                        // If Tearm Available in QB.. Create Invoice with That Term....
                        Terms = QueryResponse.Term;
                        System.debug('Term.QueryResponse >> ' + Terms[0].Id);
                        TermQBId = Terms[0].Id;

                        Create_invoice_in_QB(SI, CustomerQBId, lineIdsMap,QBMetadata, Get_Access_Token, receiptID, taxCodeId, taxRateValue, TermQBId, SyncObjName);
                    }
                    else{
                        // Create Invoice Without Term...
                        Create_invoice_in_QB(SI, CustomerQBId, lineIdsMap,QBMetadata, Get_Access_Token, receiptID, taxCodeId, taxRateValue, TermQBId, SyncObjName);
                    }
                }
                else{
                    QBException.QB_response( term_QB_ResponseBody.getStatusCode(),  term_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'createTerms');
                    QBOErrorJSON Response_Error = QBOErrorJSON.parse(term_QB_ResponseBody.getBody());
                    QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                    falut = Response_Error.Fault;
                    String ErrorMessage = 'Error During Term Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                    // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                    UpdateRecord_OnError(SI.Id, ErrorMessage, SyncObjName);
                }
            
        } catch (Exception e) {
            System.debug('Error in Create_Term_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_invoice_in_QB(buildertek__Billings__c SI, String CustomerQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String taxCodeId, Double taxRateValue, String TermQBId, String SyncObjName){
        try {
            // String CustomerQBId = acc.buildertek__QB_Id__c;
            // Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
            String Invoice_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String Invoice_RequestBody = QBMap.mapInvoiceDataBatch(SI, CustomerQBId, lineIdsMap, taxCodeId, TermQBId);
            System.debug('Invoice_RequestBody >> ' + Invoice_RequestBody);
            HttpResponse Invoice_Response = QBCallOutService.QBAPICallOut(Invoice_EndPoint , Invoice_RequestBody, Get_Access_Token);
            
            system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
            system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());
            
            if(Invoice_Response.getStatusCode() == 200){
                QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
                QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
                invoice = Invoice_Response_desr.Invoice;
                String InvoiceQBId = invoice.Id;
                String QbInvNumber = invoice.DocNumber;
                String QBInvSyncTocken = invoice.SyncToken;
                if(receiptID != null){
                    Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
                }
                UpdateSalesInvoice(SI.Id, InvoiceQBId, taxCodeId, taxRateValue,QBMetadata, TermQBId, QbInvNumber, QBInvSyncTocken);
            }
            else{
                QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueue', 'Create_invoice_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Invoice_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Error During Item Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                UpdateRecord_OnError(SI.Id, ErrorMessage, SyncObjName);
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Payment_In_QB(String InvoiceQBId, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, String SyncObjName){
        try {
            SyncObjName = 'buildertek__Receipt__c';
            buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c, buildertek__QB_Receipt_URL__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
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
                UpdateReceipt(receipt.Id, payment.Id, QBMetadata);
            }
            else{
                QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Payment_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Error During Payment Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateReceipt_OnError(receiptID, ErrorMessage);
                UpdateRecord_OnError(receiptID, ErrorMessage , SyncObjName);
            }
        } catch (Exception e) {
            System.debug('Error in Create_Payment_In_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
// --------------- ------------- ----------------- Sales Invoice and Payment(Receipt) QB Integration Flow - END ---------------------------------------- ----------------------- --------------------
// ============================================================================================================================================================================================


// ============================================================================================================================================================================================

    // Sync Contractor Inoivce and Payable Invoice with QB Bill API Callout Feature Methods -- Starts ----
    @future(callout=true)
    public static void QB_ContactorInvoice_Flow_Callout(String COInvId, String SyncObjName){
        try {
            buildertek__Account_Payable__c CoInv = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c,  buildertek__Terms__c FROM buildertek__Account_Payable__c WHERE Id =: COInvId LIMIT 1];
            Account vendor = null;
            if(CoInv.buildertek__Purchase_Order__c != null){
                if(CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c != null){
                    vendor = [SELECT Id, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c LIMIT 1];
                }
            }
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(vendor, QBMetadata, Get_Access_Token, CoInv, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in QB_ContactorInvoice_Flow_Callout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    @future(callout=true)
    public static void QB_PayableInvoice_Flow_Callout(String PayableId, String SyncObjName){
        try {
            buildertek__Account_Payable_Clone__c PayableInv = [SELECT Id, Name, buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QB_Integration_Response_Message__c,buildertek__Vendor__c FROM buildertek__Account_Payable_Clone__c WHERE Id =: PayableId LIMIT 1 ];
            Account vendor = null;
            if(PayableInv.buildertek__Vendor__c != null){
                vendor = [SELECT Id, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PayableInv.buildertek__Vendor__c LIMIT 1];
            }
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(vendor, QBMetadata, Get_Access_Token, PayableInv, SyncObjName);
        } catch (Exception e) {
            System.debug('Error in QB_PayableInvoice_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    // Sync Contractor Inoivce and Payable Invoice with QB Bill API Callout Feature Methods -- End ----

    //  Purchase Order QB Integration Flow - STARTS --------------
    @future(callout=true)
    public static void QB_PO_Flow_Callout(Id PORecordId, String SyncObjName){
        try {
            buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__PO_Total__c,buildertek__Tax_Amount__c FROM buildertek__Purchase_Order__c WHERE Id =: PORecordId LIMIT 1];
            Account acc = new Account();
            if(PO.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Vendor__c limit 1];
            }
            else if(PO.buildertek__Vendor__c == null){
                system.debug('Project Id ' + PO.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Purchase_Order_Item__c> POLines = [SELECT Id, Name, buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Total_Price__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: PORecordId];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, PO, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in QB_PO_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    @future(callout=true)
    public static void QB_Expense_Flow_Callout(Id expenseRecordId, String SyncObjName){
        try {
            buildertek__Expense__c expense = [SELECT Id, Name, buildertek__Payment_Method__c, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Total_Expense__c,buildertek__Tax_Rate__c FROM buildertek__Expense__c WHERE Id =: expenseRecordId LIMIT 1];
            Account acc = new Account();
            if(expense.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: expense.buildertek__Vendor__c limit 1];
            }
            else if(expense.buildertek__Vendor__c == null){
                system.debug('Project Id ' + expense.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: expense.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Expense_Line__c> expenseLines = [SELECT Id, Name, buildertek__BT_Expense__c,buildertek__BT_Expense__r.Name,buildertek__Total__c,buildertek__Description__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Price__c FROM buildertek__Expense_Line__c WHERE buildertek__BT_Expense__c =: expenseRecordId];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, expense, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in QB_Expense_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_PO_in_QB(buildertek__Purchase_Order__c PO, String VendorQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String SyncObjName){
        try {
            String PO_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/purchaseorder?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String PO_RequestBody = QBMap.mapPODataBatch(PO, VendorQBId, lineIdsMap);
            System.debug('PO_RequestBody >> ' + PO_RequestBody);
            HttpResponse PO_Response = QBCallOutService.QBAPICallOut(PO_EndPoint , PO_RequestBody, Get_Access_Token);
            
            system.debug('PO API Status Code >> ' + PO_Response.getStatusCode());
            system.debug('PO Resopnce >> ' + PO_Response.getBody());
            
            if(PO_Response.getStatusCode() == 200){
                QBPOResponseJSON PO_Response_desr = QBPOResponseJSON.parse(PO_Response.getBody());
                QBPOResponseJSON.PurchaseOrder pos = new QBPOResponseJSON.PurchaseOrder();
                pos = PO_Response_desr.PurchaseOrder;
                String POQBId = pos.Id;
                String QBPONumber = pos.DocNumber;
                String QBPOSyncTocken = pos.SyncToken;
                UpdatePO(PO.Id, POQBId,QBMetadata, QBPONumber, QBPOSyncTocken);
            }
            else{
                QBException.QB_response( PO_Response.getStatusCode(),  PO_Response.getBody(), 'QBPOIntegrationQueue', 'Create_PO_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(PO_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                String ErrorMessage1 = 'Error During PO Callout :- ' + 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdatePO_OnError(PO.Id, ErrorMessage1);
                UpdateRecord_OnError(PO.Id, ErrorMessage1, SyncObjName);
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Expense_in_QB(buildertek__Expense__c expense, String VendorQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String SyncObjName){
        try {
            String Expense_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/purchase?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String Expense_RequestBody = QBMap.mapExpenseDataBatch(expense, VendorQBId, lineIdsMap);
            System.debug('Expense_RequestBody >> ' + Expense_RequestBody);
            HttpResponse Expense_Response = QBCallOutService.QBAPICallOut(Expense_EndPoint , Expense_RequestBody, Get_Access_Token);
            
            system.debug('Expense API Status Code >> ' + Expense_Response.getStatusCode());
            system.debug('Expense Response >> ' + Expense_Response.getBody());
            
            if(Expense_Response.getStatusCode() == 200){
                QBExpenseResponseJSON Expense_Response_desr = QBExpenseResponseJSON.parse(Expense_Response.getBody());
                QBExpenseResponseJSON.Purchase expenses = new QBExpenseResponseJSON.Purchase();
                expenses = Expense_Response_desr.Purchase;
                String ExpenseQBId = expenses.Id;
                // String QBExpenseNumber = expenses.DocNumber;
                String QBExpenseSyncTocken = expenses.SyncToken;
                UpdateExpense(expense.Id, ExpenseQBId,QBMetadata, QBExpenseSyncTocken);
            }
            else{
                QBException.QB_response( Expense_Response.getStatusCode(),  Expense_Response.getBody(), 'QBExpenseIntegrationQueue', 'Create_Expense_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Expense_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                String ErrorMessage1 = 'Error During Expense Callout :- ' + 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdatePO_OnError(PO.Id, ErrorMessage1);
                UpdateRecord_OnError(expense.Id, ErrorMessage1, SyncObjName);
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    //  Purchase Order QB Integration Flow - Ends --------

    // ------------------------------------------------------- Utility Class - Starts ---------------------------------------------------------------------------------------
    public static void Create_Vendor_in_QB(Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, sObject SObjRecord, String SyncObjName){
        try {
            String Vendor_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/vendor?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Vendor_RequestBody = QBMap.mapVendorAccountData(acc);
            system.debug('JSON Body >>' +  Vendor_RequestBody);
            HttpResponse Vendor_Response = QBCallOutService.QBAPICallOut(Vendor_EndPoint , Vendor_RequestBody, Get_Access_Token);
            system.debug('Vendor API Status Code >> ' + Vendor_Response.getStatusCode());
            System.debug('Vendor_Response.getBody() :: '+ Vendor_Response.getBody());
            if(Vendor_Response.getStatusCode() == 200){
                QBVendorResponseJSON Vendor_Response_Deser = QBVendorResponseJSON.parse(Vendor_Response.getBody());
                QBVendorResponseJSON.Vendor vendor = new QBVendorResponseJSON.Vendor();
                vendor = Vendor_Response_Deser.Vendor;
                String VendorQBId = vendor.Id;
                String SyncToken = vendor.SyncToken;
                System.debug(SyncObjName + ' :: ' + SObjRecord);
                Create_Lines_to_Items_in_QB(SObjRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName);
                UpdateAccount(acc.Id, VendorQBId, QBMetadata, SyncToken, 'Vendor');

            }
            else{
                QBException.QB_response( Vendor_Response.getStatusCode(),  Vendor_Response.getBody(), 'QBIntegrationQueue', 'Create_Vendor_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Vendor_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                String ErrorMessage1 = 'Error During Vendor Callout :- ' + 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateAccount_OnError(acc.Id, ErrorMessage);
                UpdateRecord_OnError(acc.Id, ErrorMessage, 'Account');
                UpdateRecord_OnError(SObjRecord.Id, ErrorMessage1, SyncObjName);
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            
        }
    }

    public static void Create_Lines_to_Items_in_QB(sObject SObejctRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, String SyncObjName){
        try {

            List<sObject> ItemsWithoutQBId = new List<sObject>();
            Map<String ,sObject> ItemToSyncMap = new Map<String ,sObject>();
            List<sObject> ItemList = new List<sObject>();
            
            // Sync Purchase Order Lines
            if(SyncObjName == 'buildertek__Purchase_Order__c'){
                ItemList = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Purchase invoice Lines....
                    buildertek__Purchase_Order_Item__c Items = (buildertek__Purchase_Order_Item__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemToSyncMap.put(Items.Name, Items);
                    }
                }
            }
            // Sync Contractor Invoice Lines
            else if(SyncObjName == 'buildertek__Account_Payable__c'){
                ItemList = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Contractor invoice Lines....
                    buildertek__Account_Payable_Item__c Items = (buildertek__Account_Payable_Item__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemToSyncMap.put(Items.Name, Items);
                    }
                }
            }
            // Sync Payable Invoice Lines
            else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                ItemList = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Account_Payable_Item_Clone__c WHERE buildertek__Account_Payable_Clone__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Payable invoice Lines....
                    buildertek__Account_Payable_Item_Clone__c Items = (buildertek__Account_Payable_Item_Clone__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemToSyncMap.put(Items.Name, Items);
                    }
                }
            }

            else if(SyncObjName == 'buildertek__Expense__c'){
                ItemList = [SELECT Id, Name, buildertek__BT_Expense__c,buildertek__BT_Expense__r.Name,buildertek__Total__c,buildertek__Description__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Price__c FROM buildertek__Expense_Line__c WHERE buildertek__BT_Expense__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Payable invoice Lines....
                    buildertek__Expense_Line__c Items = (buildertek__Expense_Line__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemToSyncMap.put(Items.Name, Items);
                    }
                }
            }
            list<sObject> ItemsNotHaveQBId = ItemToSyncMap.values(); // List of SF Line Without QB Id.....

            List<sObject> ItemstoCreate = new List<sObject>();  // List of SF Lines Without QB Id And Without Dupliacte Name (So These Are need to Create In QB)....
            Map<String, QBBatchResJSON.Item> QBItemsToAssign_Map = new Map<String, QBBatchResJSON.Item>(); // Map Of QB Dupliate Item Name and Duplicate Item QB Object...
            

            // If Any SF Lines does not availbale in QB... Else All SF Line Have QB Id (Already Synced With QB)...
            if(ItemsNotHaveQBId.size() > 0){

                // Create Query String for API callout Endpoint....
                String ItemNames = '(';
                for(integer i=0; i<ItemsNotHaveQBId.size(); i++){
                    if(ItemsNotHaveQBId[i].get('buildertek__QB_Id__c') == null){
                        if(i != (ItemsNotHaveQBId.size() - 1)){
                            ItemNames += '\''+ItemsNotHaveQBId[i].get('Name') + '\',';
                        }
                        else{
                            ItemNames += '\''+ItemsNotHaveQBId[i].get('Name') + '\')';
                        }
                    }
                } 

                // API Callout to Check Duplicate Name's Items alredy Exist or Not in QB...
                String ItemQuery = EncodingUtil.urlEncode('select * from Item WHERE name in '+ ItemNames + ' STARTPOSITION 1 MAXRESULTS 1000', 'UTF-8');
                string GET_Items_JSONBody = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + ItemQuery + '&minorversion='+ QBMetadata.buildertek__minorversion__c;   
                HttpResponse GET_Items_Response = QBCallOutService.QBAPICallOut_GET(GET_Items_JSONBody, null, false);
                System.debug('GET_Items_Response.getStatusCode() : ' + GET_Items_Response.getStatusCode());
                System.debug('GET_Items_Response.getBody() : ' + GET_Items_Response.getBody());
                list<QBBatchResJSON.Item> queryItemsList = new list<QBBatchResJSON.Item>();
                if(GET_Items_Response.getStatusCode() == 200){
                    QBBatchResJSON GET_Items_Response_Desr = QBBatchResJSON.parse(GET_Items_Response.getBody());
                    system.debug('GET_Items_Response_Desr : ' + GET_Items_Response_Desr);
                    QBBatchResJSON.QueryResponse queryRes = new QBBatchResJSON.QueryResponse();
                    queryRes = GET_Items_Response_Desr.QueryResponse;
                    system.debug('queryRes : ' + queryRes);
                    if(queryRes.maxResults != null){
                        queryItemsList = queryRes.Item;
                        system.debug('Item List Size : ' + queryRes.Item.size());
                    }
                }

                System.debug('Items With Duplicate Name : ' + ItemToSyncMap.keySet());
    
                // IF SF Lines Are Not Synced With QB But Item With Duplicate Name Already Availabel In QB.... Then Use QB ID of That QB Items for SF Lines
                if(queryItemsList.size() > 0){
                    system.debug('Item List : ' + queryItemsList);
                    for(QBBatchResJSON.Item queryItem : queryItemsList){
                        if(ItemToSyncMap.containsKey(queryItem.Name)){
                            // If Duplicate Name Item Found... then USE QB Id insted of Create New QB Item...
                            QBItemsToAssign_Map.put(queryItem.Name, queryItem);
                        }
                        else{
                            // if Duplicate Name Not Found... Create New QB Item....
                            ItemstoCreate.add(ItemToSyncMap.get(queryItem.Name));
                        }
                    }

                    System.debug('No of Items to create  : ' + ItemstoCreate);
                    System.debug('QBItemsToAssign_Map : ' + QBItemsToAssign_Map.keySet());
                }
                else{
                    // If None of the Line have Duplicate Name In QB....
                    System.debug('.... None of the Line have Duplicate Name In QB .....');
                    ItemstoCreate = ItemsNotHaveQBId;
                }
                // When SF Line Does Not Have QB In and Also Item With Duplicate Name Not Found In QB....
                if(ItemstoCreate.size() > 0){
                Integer totalItems = ItemstoCreate.size();
                Integer batchSize = 30;
                Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed
                Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
    
                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);
    
                    List<sObject> itemsBatch = new List<sObject>();
    
                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                            itemsBatch.add(ItemstoCreate[j]);
                    }
                    System.debug('Items Are Going to Create : '+(i+1) +' ***** No. Batch length ******** '+ itemsBatch.size());
                    
                            // API Callout to Sync Items in QB...
                            String Items_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
                            String Items_RequestBody = QBMap.MapItemDataToBatch(itemsBatch, SyncObjName); 
                            System.debug('Items_RequestBody ' +Items_RequestBody);
                            HttpResponse Items_Response = QBCallOutService.QBAPICallOut(Items_EndPoint , Items_RequestBody, Get_Access_Token);
                            system.debug('Item Batch API Status Code >> ' + Items_Response.getStatusCode());
                            system.debug('Item Batch Resopnce >> ' + Items_Response.getBody());

                        if(Items_Response.getStatusCode() == 200){
                            QBBatchResJSON response = QBBatchResJSON.parse(Items_Response.getBody());

                            for(sObject Item : ItemList){
                                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                                    buildertek__Purchase_Order_Item__c Items = (buildertek__Purchase_Order_Item__c)Item;

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                                    if(QBDuplicateNameItem != null){
                                        Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                        Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                                    }

                                    if(Items.buildertek__QB_Id__c != null){
                                        lineIdsMap.put(
                                            Id.valueOf(Items.Id), 
                                            new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                        );
                                    }
        
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                                    buildertek__Account_Payable_Item__c Items = (buildertek__Account_Payable_Item__c)Item;

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                                    if(QBDuplicateNameItem != null){
                                        Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                        Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                                    }

                                    if(Items.buildertek__QB_Id__c != null){
                                        lineIdsMap.put(
                                            Id.valueOf(Items.Id), 
                                            new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                        );
                                    }
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                                    buildertek__Account_Payable_Item_Clone__c Items = (buildertek__Account_Payable_Item_Clone__c)Item;

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                                    if(QBDuplicateNameItem != null){
                                        Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                        Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                                    }

                                    if(Items.buildertek__QB_Id__c != null){
                                        lineIdsMap.put(
                                            Id.valueOf(Items.Id), 
                                            new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                        );
                                    }
                                }
                                else if(SyncObjName == 'buildertek__Expense__c'){
                                    buildertek__Expense_Line__c Items = (buildertek__Expense_Line__c)Item;

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                                    if(QBDuplicateNameItem != null){
                                        Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                        Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                                    }

                                    if(Items.buildertek__QB_Id__c != null){
                                        lineIdsMap.put(
                                            Id.valueOf(Items.Id), 
                                            new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Price__c)}
                                        );
                                    }
                                }
                            
                            }
                            // Added Newly created invoice Lines to the Qb Invoice....
                            for (QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                                if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                    lineIdsMap.put(
                                        // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                        Id.valueOf(batchItem.bId), // Salesforce ID
                                        // List Of QB Line Id, QB Line Name , Total Price, Quantity, Unite Price...
                                        new List<String> { batchItem.Item.Id , batchItem.Item.Name, String.valueOf((batchItem.Item.QtyOnHand)*(batchItem.Item.UnitPrice)), String.valueOf(batchItem.Item.QtyOnHand), String.valueOf(batchItem.Item.UnitPrice) } // QuickBooks ID
                                    );
                                }
                            }
                            
                            if( i == (totalBatches-1)){
                                System.debug('when last batch finish.. crerate sales invoice');
                                System.debug('lineIdsMap >> ' + lineIdsMap);
    
                                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                                    buildertek__Purchase_Order__c PO = (buildertek__Purchase_Order__c)SObejctRecord;
                                    Create_PO_in_QB(PO, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                                    UpdatePOline(ItemList, lineIdsMap);
                                    
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                                    Create_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap);
                                    UpdateCOinvLines(ItemList, lineIdsMap);
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                                    String TermQBId = null;
                                    Create_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap,TermQBId, SyncObjName);
                                    UpdatePayinvLines(ItemList, lineIdsMap);
                                }
                                else if(SyncObjName == 'buildertek__Expense__c'){
                                    buildertek__Expense__c expense = (buildertek__Expense__c)SObejctRecord;
                                    Create_Expense_in_QB(expense, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                                    UpdateExpenseLines(ItemList, lineIdsMap);
                                }
                            }
                        }
                        else{
                            QBException.QB_response( Items_Response.getStatusCode(),  Items_Response.getBody(), 'QBIntegrationQueue', 'Create_item_in_QB');
                            QBOErrorJSON Response_Error = QBOErrorJSON.parse(Items_Response.getBody());
                            QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                            falut = Response_Error.Fault;
                            String ErrorMessage1 = 'Error During Co Line Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                            // UpdateContractorInvoice_OnError(CoInv.Id, ErrorMessage1);
                            UpdateRecord_OnError(SObejctRecord.Id, ErrorMessage1, SyncObjName);
    
                        }
                    // }
                    }
                }
                else{
                    // When All SF Item with Duplicate Name Availbale In QB But SF Items Does Not Have QB ID... Then Assign QB Id First And Then Sync With Invoice/Bill/PO/Expense.... 
                    System.debug('.... All SF Lines Have Duplicate Name...');
                    Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();

                    for(sObject Item : ItemList){
                        if(SyncObjName == 'buildertek__Purchase_Order__c'){
                            buildertek__Purchase_Order_Item__c Items = (buildertek__Purchase_Order_Item__c)Item;

                            // Assign QB Id to Dupliacte Name Lines...
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                            if(QBDuplicateNameItem != null){
                                Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                            }

                            if(Items.buildertek__QB_Id__c != null){
                                lineIdsMap.put(
                                    Id.valueOf(Items.Id), 
                                    new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                );
                            }

                        }
                        else if(SyncObjName == 'buildertek__Account_Payable__c'){
                            buildertek__Account_Payable_Item__c Items = (buildertek__Account_Payable_Item__c)Item;

                            // Assign QB Id to Dupliacte Name Lines...
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                            if(QBDuplicateNameItem != null){
                                Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                            }

                            if(Items.buildertek__QB_Id__c != null){
                                lineIdsMap.put(
                                    Id.valueOf(Items.Id), 
                                    new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                );
                            }
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            buildertek__Account_Payable_Item_Clone__c Items = (buildertek__Account_Payable_Item_Clone__c)Item;

                            // Assign QB Id to Dupliacte Name Lines...
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(String.valueOf(Items.get('Name')));
                            if(QBDuplicateNameItem != null){
                                Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                            }

                            if(Items.buildertek__QB_Id__c != null){
                                lineIdsMap.put(
                                    Id.valueOf(Items.Id), 
                                    new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__Total_Price__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                );
                            }
                        }
                    
                    }

                    if(lineIdsMap.size() > 0){
                        System.debug('lineIdsMap When Items To Create is NUll>> ' + lineIdsMap);
                        if(SyncObjName == 'buildertek__Purchase_Order__c'){
                            buildertek__Purchase_Order__c PO = (buildertek__Purchase_Order__c)SObejctRecord;
                            Create_PO_in_QB(PO, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                            UpdatePOline(ItemList, lineIdsMap);
                            
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable__c'){
                            Create_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap);
                            UpdateCOinvLines(ItemList, lineIdsMap);
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            String TermQBId = null;
                            Create_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap,TermQBId, SyncObjName);
                            UpdatePayinvLines(ItemList, lineIdsMap);
                        }
                    }
                }
            }
            else{
                // When All SF Lines Have QB Id... Then Nothing to Do With Items... Just Sync With Parent QB Objects(Invoice/Bill/PO/Expense)
                System.debug('All Items are Synced with QB');
                Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                Map<Id, String> QBItemIdMap = new Map<Id, String>();
                Map<Id, String> QBItemNameMap = new Map<Id, String>();
                Map<Id, Decimal> UnitPriceMap = new Map<Id, Decimal>();
                Map<Id, Decimal> QuantityMap = new Map<Id, Decimal>();
                Map<Id, Decimal> TotalPriceMap = new Map<Id, Decimal>();
                for(sObject Item : ItemList){
                    if(SyncObjName == 'buildertek__Purchase_Order__c'){
                        buildertek__Purchase_Order_Item__c record = (buildertek__Purchase_Order_Item__c)Item;
                        QBItemIdMap.put(record.Id, record.buildertek__QB_Id__c);
                        QBItemNameMap.put(record.Id, record.buildertek__QBO_Name__c);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                        TotalPriceMap.put(record.Id, record.buildertek__Total_Price__c);
                    }
                    else if(SyncObjName == 'buildertek__Account_Payable__c'){
                        buildertek__Account_Payable_Item__c record = (buildertek__Account_Payable_Item__c)Item;
                        QBItemIdMap.put(record.Id, record.buildertek__QB_Id__c);
                        QBItemNameMap.put(record.Id, record.buildertek__QBO_Name__c);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                        TotalPriceMap.put(record.Id, record.buildertek__Total_Price__c);
                    }
                    else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                        buildertek__Account_Payable_Item_Clone__c record = (buildertek__Account_Payable_Item_Clone__c)Item;
                        QBItemIdMap.put(record.Id, record.buildertek__QB_Id__c);
                        QBItemNameMap.put(record.Id, record.buildertek__QBO_Name__c);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                        TotalPriceMap.put(record.Id, record.buildertek__Total_Price__c);
                    }
                }
                for(sObject Item : ItemList){
                    lineIdsMap1.put(
                            // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                            Id.valueOf(Item.Id), // Salesforce ID
                            new List<String> { 
                                QBItemIdMap.get(Item.Id) , 
                                QBItemNameMap.get(Item.Id), 
                                string.valueOf(TotalPriceMap.get(Item.Id)), 
                                string.valueOf(QuantityMap.get(Item.Id)), 
                                string.valueOf(UnitPriceMap.get(Item.Id))
                            }
                    );
                }

                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                    buildertek__Purchase_Order__c PO = (buildertek__Purchase_Order__c)SObejctRecord;
                    Create_PO_in_QB(PO, VendorQBId, lineIdsMap1,QBMetadata, Get_Access_Token, SyncObjName);
                }
                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                    Create_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap1);
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                    String TermQBId = null;
                    Create_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap1 ,TermQBId, SyncObjName);
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in QB_ContactorInvoice_Flow_Callout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Term_for_Bill_in_QB(sObject SObejctRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, String SyncObjName, Map<Id, List<String>> lineIdsMap){
        try {
            buildertek__Account_Payable__c CoInv = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c,  buildertek__Terms__c FROM buildertek__Account_Payable__c WHERE Id =: SObejctRecord.Id LIMIT 1];
            String termName = CoInv.buildertek__Terms__c;
            String encodedQueryParam = EncodingUtil.urlEncode('Select * From Term Where Name = \''+termName + '\'', 'UTF-8');
            String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 
            String TermQBId = null;

            // Check if term Availbe or not in QB....
            HttpResponse term_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null,false);
            System.debug('term_QB_ResponseBody >> ' + term_QB_ResponseBody);
                if(term_QB_ResponseBody.getStatusCode() == 200){
                    QBtermsResponseJSON term_QB_ResponseBody_Desr = QBtermsResponseJSON.parse(term_QB_ResponseBody.getBody());
                    QBtermsResponseJSON.QueryResponse QueryResponse = new QBtermsResponseJSON.QueryResponse();
                    QueryResponse = term_QB_ResponseBody_Desr.QueryResponse;
                    System.debug('term_QB_ResponseBody_Desr.QueryResponse >> ' + term_QB_ResponseBody_Desr.QueryResponse);
                    List<QBtermsResponseJSON.Term> Terms = new List<QBtermsResponseJSON.Term>();
                    if(QueryResponse.Term != null){
                        // If Tearm Available in QB.. Create Bill with That Term....
                        Terms = QueryResponse.Term;
                        System.debug('Term.QueryResponse >> ' + Terms[0].Id);
                        TermQBId = Terms[0].Id;

                        if(SyncObjName == 'buildertek__Account_Payable__c'){
                            // Create_CoInvLines_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, TermQBId, SyncObjName);
                            Create_Bill_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap, TermQBId, SyncObjName);
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            // If Brian Ask for Term then use this condition to create Term
                        }
                    }
                    else{
                        if(SyncObjName == 'buildertek__Account_Payable__c'){
                            // Create_CoInvLines_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, TermQBId, SyncObjName);
                            Create_Bill_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap, TermQBId, SyncObjName);
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            // If Brian Ask for Term then use this condition to create Term

                        }
                    }
                }
                else{
                    QBException.QB_response( term_QB_ResponseBody.getStatusCode(),  term_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'createTerms');
                    QBOErrorJSON Response_Error = QBOErrorJSON.parse(term_QB_ResponseBody.getBody());
                    QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                    falut = Response_Error.Fault;
                    String ErrorMessage1 = 'Error During Term Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                    // UpdateContractorInvoice_OnError(CoInv.Id, ErrorMessage1);
                    UpdateRecord_OnError(CoInv.Id, ErrorMessage1, SyncObjName);

                }
            
        } catch (Exception e) {
            System.debug('Error in Create_Term_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
     // Create Bill from BT Contractor Invoice Or Payable Invoice based on SyncObjName...
     public static void Create_Bill_in_QB(sObject SobjectRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, Map<Id, List<String>> lineIdsMap, String TermQBId, String SyncObjName){
        try {
            String QB_Bill_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/bill?minorversion=' + QBMetadata.buildertek__minorversion__c;   
            String QB_Bill_RequestBody = QBMap.mapQBBillData(SobjectRecord, lineIdsMap, VendorQBId, TermQBId, SyncObjName);
            system.debug('JSON Body >>' +  QB_Bill_RequestBody);
            HttpResponse QB_Bill_Response = QBCallOutService.QBAPICallOut(QB_Bill_EndPoint , QB_Bill_RequestBody, Get_Access_Token);
            system.debug('QB_Bill_Response API Status Code >> ' + QB_Bill_Response.getStatusCode());
            System.debug('QB_Bill_Response.getBody() :: '+ QB_Bill_Response.getBody());
            if(QB_Bill_Response.getStatusCode() == 200){
                QBBillResponseJSON QB_Bill_Deser = QBBillResponseJSON.parse(QB_Bill_Response.getBody());
                QBBillResponseJSON.Bill bill = new QBBillResponseJSON.Bill();
                bill = QB_Bill_Deser.Bill;
                String QB_BillId = bill.Id;
                String QB_BillSyncToken = bill.SyncToken;
                if(SyncObjName == 'buildertek__Account_Payable__c'){
                    UpdateContractorInvoice(SobjectRecord, QB_BillId, QB_BillSyncToken, QBMetadata);
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                    UpdatePayableInvoice(SobjectRecord, QB_BillId, QB_BillSyncToken, QBMetadata);
                }
            }
            else{
                QBException.QB_response( QB_Bill_Response.getStatusCode(),  QB_Bill_Response.getBody(), 'QBIntegrationQueue', 'Create_Bill_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(QB_Bill_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage1 = 'Error During Bill Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateContractorInvoice_OnError(CoInv.Id, ErrorMessage1);
                UpdateRecord_OnError(SobjectRecord.Id, ErrorMessage1, SyncObjName);
                
            }

        } catch (Exception e ) {
            System.debug('Error in Create_Bill_in_QB : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }   
    // ------------------------------------------------------- Utility Class - End ---------------------------------------------------------------------------------------
    

    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aura Enable Method - START <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    @AuraEnabled
    public static String Create_Invoice_in_QB_AuraCallout(String recordId, String SyncObjName){
        // This method run from the Quick action button to create Customer, Invoice and invoice in QB...
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__Tax_Rate__c, buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: recordId LIMIT 1];

            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            // else if(SI.buildertek__Customer_Account__c == null && SI.buildertek__Project__c != null){
            //     system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
            //     acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
            // }
            else{
                acc = null;
            }

            List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__SubTotal__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: recordId];
            if(SILines.size() == 0){
                return 'no_invoicelines';
            }
            else if(acc == null){
                return 'no_customer_account';
            }
            else if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Type__c == 'Vendor'){
                return 'account_synced_as_vendor';
            }
            else{
                string receiptID;
                QB_Payment_Invoice_Flow_Callout(recordId, receiptID);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Customer_invoice_item_payment_in_QB_Using_Button : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Customer_In_QB_AuraCallout(String AccoountId, String SyncObjName){
        try {
           Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: AccoountId limit 1];
           buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
           Boolean Get_Access_Token = false;

               buildertek__Billings__c SI = null;
               List<buildertek__Billable_Lines__c> SILines = null;
               String receiptID = null;               
               Create_Customer_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
               return 'Completed';
            
        } catch (Exception e) {
            System.debug('Error in Create_Customer_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Vendor_In_QB_AuraCallout(String AccoountId, String SyncObjName){
        try {
            Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: AccoountId limit 1];
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;
            sObject SObjRecord = acc;
            Create_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, SObjRecord, SyncObjName);
            return 'Completed';

        } catch (Exception e) {
            System.debug('Error in Create_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Purchase_Order_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__PO_Total__c,buildertek__Tax_Amount__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];

            Account acc = null;
            if(PO.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Vendor__c limit 1];
            }

            List<buildertek__Purchase_Order_Item__c> POLines = [SELECT Id, Name, buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Total_Price__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId];

            if(POLines.size() == 0){
                return 'no_polines';
            }
            else if(acc == null){
                return 'no_vendor_account';
            }
            else if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Type__c == 'Customer'){
                return 'account_sync_as_customer';
            }
            else{
                string receiptID;
                QB_PO_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Contractor_Invoice_to_Bill_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Account_Payable__c CoInv = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c,  buildertek__Terms__c FROM buildertek__Account_Payable__c WHERE Id =: recordId LIMIT 1];

            List<buildertek__Account_Payable_Item__c> COInvLines = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c =: CoInv.Id];

            Account acc = null;
            if(CoInv.buildertek__Purchase_Order__c != null){
                if(CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c != null){
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c limit 1];
                }
            }

            if(COInvLines.size() == 0){
                return 'no_colines';
            }
             else if(CoInv.buildertek__Purchase_Order__c == null){
                return 'no_po';
            }
            else if(CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c == null){
                return 'no_vendor_account';
            }
            else if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Type__c == 'Customer'){
                return 'account_sync_as_customer';
            }
            else{
                QB_ContactorInvoice_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Contractor_Invoice_to_Bill_in_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Payable_Invoice_to_Bill_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Account_Payable_Clone__c PayableInv = [SELECT Id, Name, buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QB_Integration_Response_Message__c,buildertek__Vendor__c FROM buildertek__Account_Payable_Clone__c WHERE Id =: recordId LIMIT 1 ];

            List<buildertek__Account_Payable_Item_Clone__c> payableLines = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Account_Payable_Item_Clone__c WHERE buildertek__Account_Payable_Clone__c =: PayableInv.Id];

            Account acc = null;
            if(PayableInv.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QB_Type__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PayableInv.buildertek__Vendor__c limit 1];
            }

            if(payableLines.size() == 0){
                return 'no_payablelines';
            }
            else if(PayableInv.buildertek__Vendor__c == null){
                return 'no_vendor_account';
            }
            else if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Type__c == 'Customer'){
                return 'account_sync_as_customer';
            }
            else{
                QB_PayableInvoice_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Contractor_Invoice_to_Bill_in_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }
    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aura Enable Method - END >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>


        // ..... ....... ........... .......... ............. Update Records Utility Methods - STARTS ...... ........ ......... ......... .............
        public static void UpdateAccount(String acc_Id, String QB_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata, String SyncToken, String AccountType){
            try {
                system.debug('Account going to Update');
                Account Acc = [SELECT Id,Name, buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Integration_Response_Message__c FROM Account WHERE Id =: acc_Id LIMIT 1];
                Acc.buildertek__QB_Id__c = QB_Id;
                Acc.buildertek__QBO_SyncToken__c = SyncToken;
                Acc.buildertek__QB_Type__c = AccountType;
                Acc.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                if(AccountType == 'Customer'){
                    Acc.buildertek__QB_Record_URL__c = QBMetadata.buildertek__Qb_URL__c + 'customerdetail?nameId=' + QB_Id;
                }
                else if(AccountType == 'Vendor'){
                     Acc.buildertek__QB_Record_URL__c = QBMetadata.buildertek__Qb_URL__c + 'vendordetail?nameId=' + QB_Id;
                }
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
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                }
    
                update SILines;
            } catch (Exception e) {
                System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    
        public static void UpdateSalesInvoice(String invoice_Id, String QB_invoice_Id, String taxCodeId, Double taxRateValue , buildertek__QuickBooks_Setting__mdt  QBMetadata, String TermQBId, String QbInvNumber, String QBInvSyncTocken){
            try {
                system.debug('sales Invoice going to Update');
                String qbInvoiceURL = QBMetadata.buildertek__Qb_URL__c + 'invoice?txnId=' + QB_invoice_Id;
                buildertek__Billings__c Invoice = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QB_Invoice_Number__c	, buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c, buildertek__QB_Invoice_URL__c,buildertek__QB_Integration_Response_Message__c FROM buildertek__Billings__c WHERE ID =:invoice_Id LIMIT 1];
                Invoice.buildertek__QB_Id__c = QB_invoice_Id;
                Invoice.buildertek__QBO_Tax_Rate_ID__c = taxCodeId;
                Invoice.buildertek__QBO_Tax_Rate__c = taxRateValue;
                Invoice.buildertek__QB_Invoice_URL__c = qbInvoiceURL;
                Invoice.buildertek__QBO_Term_Id__c = TermQBId;
                Invoice.buildertek__QB_Invoice_Number__c = QbInvNumber;
                Invoice.buildertek__QBO_SyncToken__c = QBInvSyncTocken;
                Invoice.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';

                update Invoice;
            } catch (Exception e) {
                System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    
        public static void UpdateReceipt(String receipt_Id, String QB_Payment_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata){
            try {
                system.debug('Receipt going to Update');
                String qbPaymentURL = QBMetadata.buildertek__Qb_URL__c + 'recvpayment?txnId=' + QB_Payment_Id;
                buildertek__Receipt__c receipt = [SELECT Id, Name , buildertek__QB_Id__c, buildertek__QB_Receipt_URL__c,buildertek__QB_Integration_Response_Message__c FROM buildertek__Receipt__c WHERE ID =:receipt_Id LIMIT 1];
                receipt.buildertek__QB_Id__c = QB_Payment_Id;
                receipt.buildertek__QB_Receipt_URL__c = qbPaymentURL;
                receipt.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update receipt;
            } catch (Exception e) {
                System.debug('Error in UpdateReceipt : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
        
        public static void UpdateCOinvLines(list<buildertek__Account_Payable_Item__c> CoLinestoUpdate, Map<Id, List<String>> lineIdsMap){
            try {
                System.debug('Going to Update Contractor invoice Lines');
                for(buildertek__Account_Payable_Item__c record : CoLinestoUpdate){
                    List<String> qbIdAndNameList = lineIdsMap.get(record.Id);

                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if(qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                    update CoLinestoUpdate;
                }
                
            } catch (Exception e) {
                System.debug('Error in UpdateCOinvLines : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateContractorInvoice(sObject CoInv, String QB_BillId, String QB_BillSyncToken, buildertek__QuickBooks_Setting__mdt  QBMetadata){
            try {
                buildertek__Account_Payable__c Coinvoice = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c FROM buildertek__Account_Payable__c WHERE Id =:CoInv.Id LIMIT 1];
                String QBUrl =  QBMetadata.buildertek__Qb_URL__c + 'bill?&txnId=' + QB_BillId;
                Coinvoice.buildertek__QB_Id__c = QB_BillId;
                Coinvoice.buildertek__QBO_SyncToken__c = QB_BillSyncToken;
                Coinvoice.buildertek__QB_Record_URL__c = QBUrl;
                Coinvoice.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update Coinvoice;
            } catch (Exception e) {
            System.debug('Error in UpdateContractorInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdatePayinvLines(list<buildertek__Account_Payable_Item_Clone__c> PayLinestoUpdate, Map<Id, List<String>> lineIdsMap){
            try {
                System.debug('Going to Update Payable invoice Lines');
                for(buildertek__Account_Payable_Item_Clone__c record : PayLinestoUpdate){
                    List<String> qbIdAndNameList = lineIdsMap.get(record.Id);

                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if(qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                    update PayLinestoUpdate;
                }
                
            } catch (Exception e) {
                System.debug('Error in UpdateCOinvLines : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateExpenseLines(list<buildertek__Expense_Line__c> ExpenseLinestoUpdate, Map<Id, List<String>> lineIdsMap){
            try {
                System.debug('Going to Update Expense Lines');
                for(buildertek__Expense_Line__c record : ExpenseLinestoUpdate){
                    List<String> qbIdAndNameList = lineIdsMap.get(record.Id);

                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if(qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                    update ExpenseLinestoUpdate;
                }
                
            } catch (Exception e) {
                System.debug('Error in UpdateCOinvLines : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdatePayableInvoice(sObject PayInv, String QB_BillId, String QB_BillSyncToken, buildertek__QuickBooks_Setting__mdt  QBMetadata){
            System.debug('Going to update Payable Invoice');
            try {
                buildertek__Account_Payable_Clone__c PayInvoice = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Vendor__c, buildertek__QB_Integration_Response_Message__c FROM buildertek__Account_Payable_Clone__c WHERE Id =:PayInv.Id LIMIT 1];
                String QBUrl =  QBMetadata.buildertek__Qb_URL__c + 'bill?&txnId=' + QB_BillId;
                PayInvoice.buildertek__QB_Id__c = QB_BillId;
                PayInvoice.buildertek__QBO_SyncToken__c = QB_BillSyncToken;
                PayInvoice.buildertek__QB_Record_URL__c = QBUrl;
                PayInvoice.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update PayInvoice;
            } catch (Exception e) {
            System.debug('Error in UpdatePayableInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdatePOline(list<buildertek__Purchase_Order_Item__c> SILines, Map<Id, List<String>> lineIdsMap){
            try {
                system.debug('PO line going to Update');
    
                for (buildertek__Purchase_Order_Item__c record : SILines) {
                    // Check if the Salesforce ID exists in the mapping and update the QuickBooks ID
                    List<String> qbIdAndNameList = lineIdsMap.get(record.Id);
    
                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if (qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                }
    
                update SILines;
            } catch (Exception e) {
                System.debug('Error in UpdatePOline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdatePO(String recordId, String QB_PO_Id, buildertek__QuickBooks_Setting__mdt  QBMetadata, String QBPONumber, String QBPOSyncTocken){
            try {
                system.debug('PO going to Update');
                String qbPOURL = QBMetadata.buildertek__Qb_URL__c + 'purchaseorder?txnId=' + QB_PO_Id;
                buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__QB_Record_URL__c, buildertek__QB_PO_Number__c, buildertek__QB_Id__c, buildertek__QBO_SyncToken__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
                PO.buildertek__QB_Id__c = QB_PO_Id;
                PO.buildertek__QB_Record_URL__c = qbPOURL;
                PO.buildertek__QB_PO_Number__c = QBPONumber;
                PO.buildertek__QBO_SyncToken__c = QBPOSyncTocken;
                PO.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update PO;
            } catch (Exception e) {
                System.debug('Error in UpdatePO : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateExpense(String recordId, String QB_Expense_Id, buildertek__QuickBooks_Setting__mdt  QBMetadata, String QBExpenseSyncTocken){
            try {
                system.debug('Expense going to Update');
                String qbExpenseURL = QBMetadata.buildertek__Qb_URL__c + 'purchase?txnId=' + QB_Expense_Id;
                buildertek__Expense__c Expense = [SELECT Id, Name, buildertek__QB_Record_URL__c, buildertek__QB_PO_Number__c, buildertek__QB_Id__c, buildertek__QBO_SyncToken__c FROM buildertek__Expense__c WHERE Id =: recordId LIMIT 1];
                Expense.buildertek__QB_Id__c = QB_Expense_Id;
                Expense.buildertek__QB_Record_URL__c = qbExpenseURL;
                // Expense.buildertek__QB_PO_Number__c = QBExpenseNumber;
                Expense.buildertek__QBO_SyncToken__c = QBExpenseSyncTocken;
                Expense.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update Expense;
            } catch (Exception e) {
                System.debug('Error in UpdatePO : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateRecord_OnError(String recordId, String ErrorMessage, String SyncObjName){
            try {
                String DynamicQuery = 'SELECT Id, Name, buildertek__QB_Integration_Response_Message__c FROM ' + SyncObjName + ' WHERE Id = \'' + recordId + '\' LIMIT 1';
                sObject recordToUpdate = Database.query(DynamicQuery);
                recordToUpdate.put('buildertek__QB_Integration_Response_Message__c', ErrorMessage);
                Database.update(recordToUpdate, false);
            } catch (Exception e) {
                System.debug('Error in UpdateRecord_OnError : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
        // ..... ....... ........... .......... ............. Update Records Utility Methods - END ...... ........ ......... ......... .............
    
    @AuraEnabled
    public static string Create_Expense_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Expense__c expense = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Total_Expense__c,buildertek__Tax_Rate__c FROM buildertek__Expense__c WHERE Id =: recordId LIMIT 1];

            Account acc = null;
            if(expense.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: expense.buildertek__Vendor__c limit 1];
            }

            List<buildertek__Expense_Line__c> expenseLines = [SELECT Id, Name, buildertek__BT_Expense__c,buildertek__BT_Expense__r.Name,buildertek__Total__c,buildertek__Description__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Price__c FROM buildertek__Expense_Line__c WHERE buildertek__BT_Expense__c =: recordId];

            if(expenseLines.size() == 0){
                return 'no_expenselines';
            }
            else if(acc == null){
                return 'no_vendor_account';
            }
            else if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Type__c == 'Customer'){
                return 'account_sync_as_customer';
            }
            else{
                QB_Expense_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }
}