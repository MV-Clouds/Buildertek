// integration Betweek Quickbook and Salsforce

public without sharing class QBIntegrationQueue {
    

    // --------------- ------------- ----------------- Sales Invoice and Payment(Receipt) QB Integration Flow - START ------------------- --------------------- ----------------------- --------------------

    @future(callout=true)
    public static void QB_Payment_Invoice_Flow_Callout(Id Sales_invoice_Id, Id receiptID, Boolean Create_Payment){
        //  *********  Integration flow --> Customer - TaxRate - Term - Items(Product and Service) - Invoice - Payment(Receipt)
        
        // 1. BT Sales Invoice Customer Account(Parent Customer) --> QB Customer [ ----- first Code Create Customer in QB From Invoice Customer account(or Project Customer Account), if Customer Already available in QB Then QB Customer id Must be store on Account Object) -----]
        // 2. BT Sales Invoice Tax Rate (Field) --> QB Tax Rate                  
        // 3. BT Sales Invoice Term (Picklist filed) --> QB Term
        // 4. BT Sals invoice related invoice Lines (Related Objects) --> QB Product and Service
        // 5. BT Sales Invoice (Object) --> QB Invoice
        // 6. BT receipt (Object) --> QB Payment
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__Tax_Rate__c, buildertek__QB_Invoice_URL__c, buildertek__QB_Invoice_Number__c	,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Terms__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            else if(SI.buildertek__Customer_Account__c == null){
                system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            
            Boolean Get_Access_Token = false;

            if(acc.buildertek__QBO_ID__c == null){
                // Customer - items - invoice - PAYMENT
                boolean CountinueFlow = true;       // this variable define wheather You want to countine the integration or not...
                Create_Customer_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, Create_Payment, CountinueFlow);
            }
            else{
                String CustomerQBId = acc.buildertek__QBO_ID__c;
                System.debug('Customer Available in QB');
                if(SI.buildertek__Tax_Rate__c != null && (SI.buildertek__QBO_Tax_Rate_ID__c == null || SI.buildertek__Tax_Rate__c != SI.buildertek__QBO_Tax_Rate__c)){
                    Create_TaxRate_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                }
                else{
                    System.debug('Tax rate not available for Invoice');
                    String taxCodeId;
                    double taxRateValue;
                    if(SI.buildertek__Tax_Rate__c == null){
                        taxCodeId = null;
                        taxRateValue = null;
                    }
                    else if(SI.buildertek__QBO_Tax_Rate_ID__c != null && SI.buildertek__Tax_Rate__c == SI.buildertek__QBO_Tax_Rate__c){
                            taxCodeId = SI.buildertek__QBO_Tax_Rate_ID__c;
                            taxRateValue = SI.buildertek__QBO_Tax_Rate__c;
                    }

                    if(SI.buildertek__Terms__c != null){
                        // Create invoic With Term...
                        Create_Term_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
                    }
                    else{
                        // Create Invoice without Term...
                        String  TermQBId = null;
                        if(SILines.size() > 0){
                            // items - invoice - PAYMENT
                            Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);
                        }
                    }
                }

            }

        } catch (Exception e) {
            System.debug('Error in QB_Payment_Invoice_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Customer_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment, Boolean CountinueFlow){
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
                if(CountinueFlow == true){ 
                    Create_TaxRate_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                }
                UpdateAccount(acc.Id, CustomerQBId, QBMetadata, SyncToken, 'Customer');
            }
            else{
                QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBIntegrationQueue', 'Create_Customer_in_QB');
                QBOErrorJSON Customer_Response_Error = QBOErrorJSON.parse(Customer_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Customer_Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                UpdateAccount_OnError(acc.Id, ErrorMessage);
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Customer_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_TaxRate_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment){
        try {
            List<buildertek__Billings__c> allInvoice = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QB_Invoice_URL__c,buildertek__QB_Invoice_Number__c, buildertek__QBO_ID__c,buildertek__Tax_Rate__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c];
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
                        Create_Term_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
                        // Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
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
                            Create_Term_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
                            // Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
                            // UpdateInv(taxCodeId, taxRateValue,SI.Id);
                        }
                        else{
                            QBException.QB_response( TaxRate_ResponseBody.getStatusCode(),  TaxRate_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                        }
                    }

                    // Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue);
                    // UpdateInv(taxCodeId, taxRateValue,SI.Id);
                }
                else{
                    QBException.QB_response( get_TaxRate_from_QB_ResponseBody.getStatusCode(),  get_TaxRate_from_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                }
                
            // for(buildertek__Billings__c inv : allInvoice){
            //     if(IsTaxRateExistInQB == false){
            //         if(SI.buildertek__Tax_Rate__c == inv.buildertek__Tax_Rate__c && SI.buildertek__Tax_Rate__c == inv.buildertek__QBO_Tax_Rate__c){
            //             System.debug('No need to create tax in QB');
            //             // assign inv.buildertek__QBO_Tax_Rate_ID__c to SI....
            //             taxCodeId =  inv.buildertek__QBO_Tax_Rate_ID__c;
            //             taxRateValue = inv.buildertek__QBO_Tax_Rate__c;
            //             IsTaxRateExistInQB = true;
            //         }
            //     }
            // }
            // if(IsTaxRateExistInQB == true){
            // }
            // else {
            // }
            
        } catch (Exception e) {
            System.debug('Error in Create_TaxRate_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Term_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment, String taxCodeId, Double taxRateValue){
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

                        Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);
                    }
                    else{
                        // Create Invoice Without Term...
                        Create_item_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);
                        // Create New term in QB...
                    //     String Term_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/term?minorversion=' + QBMetadata.buildertek__minorversion__c;            
                    //     String Term_RequestBody = QBMap.mapQBTerm(SI);
                    //     system.debug('Term JSON Body >>' +  Term_RequestBody);
                    //     HttpResponse Term_Creation_Response = QBCallOutService.QBAPICallOut(Term_EndPoint , Term_RequestBody, Get_Access_Token);
                    //     system.debug('Term_Creation_Response >> ' + Term_Response);
                    //     if(Term_Creation_Response.getStatusCode() == 200){
                    //         QBtermsResponseJSON Term_Creation_Response_Desr = QBtermsResponseJSON.parse(Term_Creation_Response.getBody());
                    //         QBtermsResponseJSON.QueryResponse QueryResponse = new QBtermsResponseJSON.QueryResponse();
                    //         QueryResponse = Term_Creation_Response_Desr.QueryResponse;
                    //         System.debug('Term_Creation_Response_Desr.QueryResponse >> ' + Term_Creation_Response_Desr.QueryResponse);
                    //         List<QBtermsResponseJSON.Term> Terms = new List<QBtermsResponseJSON.Term>();
                    //         if(QueryResponse.Term != null){
                    //             Terms = QueryResponse.Term;
                    //             System.debug('Term.QueryResponse >> ' + Terms[0].Id);
                    //             TermQBId = Terms[0].Id;
                    //         }
                    //     }
                    //    else{

                    //    }
                    }
                }
                else{
                    QBException.QB_response( term_QB_ResponseBody.getStatusCode(),  term_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'createTerms');
                }
            
        } catch (Exception e) {
            System.debug('Error in Create_Term_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_item_in_QB(List<buildertek__Billable_Lines__c> SILines, buildertek__Billings__c SI, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment, String taxCodeId, Double taxRateValue, String TermQBId){
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
    
                            // First Add Existing Invoice Lines(if available)....And Then Added Newly created invoice Lines to the Qb Invoice....
                            for(buildertek__Billable_Lines__c SIL : SILines){
                                if(SIL.buildertek__QBO_ID__c != null){
                                    lineIdsMap.put(
                                        Id.valueOf(SIL.Id), 
                                        new List<String>{SIL.buildertek__QBO_ID__c, SIL.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__Total__c), string.valueOf(SIL.buildertek__Quantity__c), string.valueOf(SIL.Unit_Price__c)}
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
                                    Create_invoice_in_QB(SI, CustomerQBId, lineIdsMap,QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);

                                // update sales invoice lines....
                                UpdateSIline(ItemstoCreate, lineIdsMap);
                            }
                            // No_Line_To_Create_IN_QB = false;
                        }
                        else{
                            QBException.QB_response( InvoiceItem_Response.getStatusCode(),  InvoiceItem_Response.getBody(), 'QBIntegrationQueue', 'Create_item_in_QB');
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
                                new List<String> { SIl.buildertek__QBO_ID__c , SIl.buildertek__QBO_Name__c, string.valueOf(SIL.buildertek__Total__c), string.valueOf(SIL.buildertek__Quantity__c), string.valueOf(SIL.Unit_Price__c) } // QuickBooks ID
                        );
                    }
                        Create_invoice_in_QB(SI, CustomerQBId, lineIdsMap1,QBMetadata, Get_Access_Token, receiptID, Create_Payment, taxCodeId, taxRateValue, TermQBId);
            }
        } catch (Exception e) {
            System.debug('Error in Create_item_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_invoice_in_QB(buildertek__Billings__c SI, String CustomerQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID, Boolean Create_Payment, String taxCodeId, Double taxRateValue, String TermQBId){
        try {
            // String CustomerQBId = acc.buildertek__QBO_ID__c;
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
                if(Create_Payment == true){
                    Create_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID);
                }
                UpdateSalesInvoice(SI.Id, InvoiceQBId, taxCodeId, taxRateValue,QBMetadata, TermQBId, QbInvNumber, QBInvSyncTocken);
            }
            else{
                QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueue', 'Create_invoice_in_QB');
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_Payment_In_QB(String InvoiceQBId, String CustomerQBId, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String receiptID){
        try {
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
            }
        } catch (Exception e) {
            System.debug('Error in Create_Payment_In_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    // --------------- ------------- ----------------- Sales Invoice and Payment(Receipt) QB Integration Flow - END ---------------------------------------- ----------------------- --------------------

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

                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                    // Create Purchase Order In QB
                    // Run Purchase Order Integartion Logic
                }
                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                    // Create Contractor Invoice (Bill) In QB
                    // Run Contractor Invoice Integartion Logic
                    QBIntegrationQueue.Create_CoInvLines_in_QB(SObjRecord, VendorQBId, QBMetadata, Get_Access_Token);
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                    // Create Payable Invoice(Bill) In QB
                    // Run Payable Invoice Integartion Logic
                }
                else if(SyncObjName == 'Account'){
                    // Do Nothing....
                }
                // Create_TaxRate_in_QB(SILines, SI, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, Create_Payment);
                UpdateAccount(acc.Id, VendorQBId, QBMetadata, SyncToken, 'Vendor');

            }
            else{
                QBException.QB_response( Vendor_Response.getStatusCode(),  Vendor_Response.getBody(), 'QBIntegrationQueue', 'Create_Vendor_in_QB');
                QBOErrorJSON Vendor_Response_Error = QBOErrorJSON.parse(Vendor_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Vendor_Response_Error.Fault;
                String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                UpdateAccount_OnError(acc.Id, ErrorMessage);
            }
            
        } catch (Exception e) {
            System.debug('Error in Create_Vendor_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            
        }
    }

    // ---------------------- ****************************** Contactor Invoice QB Integration Flow - START *********************** --------------------------------------- 
    @future(callout=true)
    public static void QB_ContactorInvoice_Flow_Callout(String COInvId){
        try {
            buildertek__Account_Payable__c CoInv = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c, buildertek__QBO_Bill_Number__c FROM buildertek__Account_Payable__c WHERE Id =: COInvId LIMIT 1];

            List<buildertek__Account_Payable_Item__c> COInvLines = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c =: CoInv.Id];

            Account vendor = [SELECT Id, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c LIMIT 1];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;

            Create_Vendor_in_QB(vendor, QBMetadata, Get_Access_Token, CoInv,'buildertek__Account_Payable__c');

        } catch (Exception e) {
            System.debug('Error in QB_ContactorInvoice_Flow_Callout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_CoInvLines_in_QB(sObject CoInv, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token){
        try {
            List<buildertek__Account_Payable_Item__c> COInvLines = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c =: CoInv.Id];

            List<buildertek__Account_Payable_Item__c> ItemstoCreate = new List<buildertek__Account_Payable_Item__c>();
            for(buildertek__Account_Payable_Item__c Items : COInvLines){
                if(Items.buildertek__QBO_ID__c == null){
                    ItemstoCreate.add(Items);
                }
            }

            // If any Line Item Pending to Sync in QB....
            if(ItemstoCreate.size() > 0){
                Integer totalItems = ItemstoCreate.size();
                Integer batchSize = 30;
                Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed
                // Boolean No_Line_To_Create_IN_QB = true;
                Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();

                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);
    
                    List<buildertek__Account_Payable_Item__c> itemsBatch = new List<buildertek__Account_Payable_Item__c>();
    
                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                            itemsBatch.add(ItemstoCreate[j]);
                    }
                    System.debug((i+1) +' ***** No. Batch length ******** '+ itemsBatch.size());
                    // if(itemsBatch.size() > 0){
                        String COLines_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + QBMetadata.buildertek__minorversion__c;
                        String COLines_RequestBody = QBMap.MapContractorInvoiceLineToBatch(itemsBatch); 
                        System.debug('COLines_RequestBody ' +COLines_RequestBody);
                        HttpResponse COLines_Response = QBCallOutService.QBAPICallOut(COLines_EndPoint , COLines_RequestBody, Get_Access_Token);
    
                        system.debug('CO Invoice Line API Status Code >> ' + COLines_Response.getStatusCode());
                        system.debug('CO Invoice Line Resopnce >> ' + COLines_Response.getBody());
    
                        if(COLines_Response.getStatusCode() == 200){
                            QBBatchResJSON response = QBBatchResJSON.parse(COLines_Response.getBody());
    
                            // First Add Existing Invoice Lines(if available)....And Then Added Newly created invoice Lines to the Qb Invoice....
                            for(buildertek__Account_Payable_Item__c COL : COInvLines){
                                if(COL.buildertek__QBO_ID__c != null){
                                    lineIdsMap.put(
                                        Id.valueOf(COL.Id), 
                                        new List<String>{COL.buildertek__QBO_ID__c, COL.buildertek__QBO_Name__c, string.valueOf(COL.buildertek__Total_Price__c), string.valueOf(COL.buildertek__Quantity__c), string.valueOf(COL.buildertek__Unit_Price__c)}
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
                                Create_CoInv_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap);

                                // update Co invoice lines....
                                UpdateCOinvLines(ItemstoCreate, lineIdsMap);

                            }
                            // No_Line_To_Create_IN_QB = false;
                        }
                        else{
                            QBException.QB_response( COLines_Response.getStatusCode(),  COLines_Response.getBody(), 'QBIntegrationQueue', 'Create_item_in_QB');
                        }
                    // }
                }
            }
            else{
                // if(No_Line_To_Create_IN_QB == true){
                    System.debug('All Items of the invoice is available in QB');
                    Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                    for(buildertek__Account_Payable_Item__c COL : COInvLines){
                        lineIdsMap1.put(
                                // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                Id.valueOf(COL.Id), // Salesforce ID
                                new List<String> { COL.buildertek__QBO_ID__c , COL.buildertek__QBO_Name__c, string.valueOf(COL.buildertek__Total_Price__c), string.valueOf(COL.buildertek__Quantity__c), string.valueOf(COL.buildertek__Unit_Price__c) } // QuickBooks ID
                        );
                    }
                    system.debug('lineIdsMap1 :: ' + lineIdsMap1);
                    Create_CoInv_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap1);

            }
            
        } catch (Exception e) {
            System.debug('Error in Create_COInoiceLine_COInv_Flow : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void Create_CoInv_in_QB(sObject CoInv, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, Map<Id, List<String>> lineIdsMap){
        try {
            String ContractorInvoice_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/vendor?minorversion=' + QBMetadata.buildertek__minorversion__c;   
            String ContractorInvoice_RequestBody = QBMap.mapContractorInvoiceData(CoInv, lineIdsMap, VendorQBId);
            system.debug('JSON Body >>' +  ContractorInvoice_RequestBody);
            HttpResponse ContractorInvoice_Response = QBCallOutService.QBAPICallOut(ContractorInvoice_EndPoint , ContractorInvoice_RequestBody, Get_Access_Token);
            system.debug('ContractorInvoice_Response API Status Code >> ' + ContractorInvoice_Response.getStatusCode());
            System.debug('ContractorInvoice_Response.getBody() :: '+ ContractorInvoice_Response.getBody());
            if(ContractorInvoice_Response.getStatusCode() == 200){
                QBBillResponseJSON ContractorInvoice_Deser = QBBillResponseJSON.parse(ContractorInvoice_Response.getBody());
                QBBillResponseJSON.Bill bill = new QBBillResponseJSON.Bill();
                bill = ContractorInvoice_Deser.Bill;
                String QB_BillId = bill.Id;
                String QB_BillSyncToken = bill.SyncToken;
                String QB_BillQbNumber = bill.DocNumber;
                UpdateContractorInvoice(CoInv, QB_BillId, QB_BillSyncToken, QB_BillQbNumber, QBMetadata);
            }
            else{
                QBException.QB_response( ContractorInvoice_Response.getStatusCode(),  ContractorInvoice_Response.getBody(), 'QBIntegrationQueue', 'Create_CoInv_in_QB');
            }

        } catch (Exception e ) {
            System.debug('Error in Create_CoInv_in_QB : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }

    }
    // ---------------------- ************** *********** Contactor Invoice QB Integration Flow - END ********** ************* --------------------------------------- 

    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aura Enable Method - START <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    @AuraEnabled
    public static String Create_customer_item_invoice_in_QB_flow(String Sales_invoice_Id){
        // This method run from the Quick action button to create Customer, Invoice and invoice in QB...
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__Tax_Rate__c, buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];

            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            else if(SI.buildertek__Customer_Account__c == null && SI.buildertek__Project__c != null){
                system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
            }
            else{
                acc = null;
            }

            List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QBO_ID__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];
            if(SILines.size() > 0 && acc != null){
                string receiptID;
                boolean create_Payment = false;
                QB_Payment_Invoice_Flow_Callout(Sales_invoice_Id, receiptID, create_Payment);
                return 'success';
            }
            else if(SILines.size() == 0){
                return 'no_invoicelines';
            }
            else if(acc == null){
                return 'no_customer_account';
            }
            else{
                return null;
            }
        } catch (Exception e) {
            System.debug('Error in Create_Customer_invoice_item_payment_in_QB_Using_Button : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Customer_In_QB_AuraCallout(String AccoountId){
        try {
           Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: AccoountId limit 1];
           buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
           Boolean Get_Access_Token = false;

               buildertek__Billings__c SI = null;
               List<buildertek__Billable_Lines__c> SILines = null;
               String receiptID = null;               
               boolean Create_Payment = false;       // this variable define wheather You want to create Payment from this action not...
               boolean CountinueFlow = false;       // this variable define wheather You want to countine the integration or not...
               Create_Customer_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, Create_Payment, CountinueFlow);
               return 'Completed';
            
        } catch (Exception e) {
            System.debug('Error in Create_Customer_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string Create_Vendor_In_QB_AuraCallout(String AccoountId){
        try {
            Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: AccoountId limit 1];
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;
            sObject SObjRecord = acc;
            String SyncObjName = 'Account';
            Create_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, SObjRecord, SyncObjName);
            return 'Completed';

        } catch (Exception e) {
            System.debug('Error in Create_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }


    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aura Enable Method - END <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

        // ..... ....... ........... .......... ............. Update Records Utility Methods - STARTS ...... ........ ......... ......... .............
        public static void UpdateAccount(String acc_Id, String QB_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata, String SyncToken, String AccountType){
            try {
                system.debug('Account going to Update');
                Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Integration_Response_Message__c FROM Account WHERE Id =: acc_Id LIMIT 1];
                Acc.buildertek__QBO_ID__c = QB_Id;
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
        public static void UpdateAccount_OnError(String acc_Id, String ErrorMessage){
            try {
                system.debug('Account going to Update on error');
                Account Acc = [SELECT Id,Name, buildertek__QBO_ID__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Integration_Response_Message__c FROM Account WHERE Id =: acc_Id LIMIT 1];
                Acc.buildertek__QB_Integration_Response_Message__c = ErrorMessage;
                update Acc;
            } catch (Exception e) {
                System.debug('Error in UpdateAccount_OnError : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
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
    
        public static void UpdateSalesInvoice(String invoice_Id, String QB_invoice_Id, String taxCodeId, Double taxRateValue , buildertek__QuickBooks_Setting__mdt  QBMetadata, String TermQBId, String QbInvNumber, String QBInvSyncTocken){
            try {
                system.debug('sales Invoice going to Update');
                String qbInvoiceURL = QBMetadata.buildertek__Qb_URL__c + 'invoice?txnId=' + QB_invoice_Id;
                buildertek__Billings__c Invoice = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QB_Invoice_Number__c	, buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c, buildertek__QB_Invoice_URL__c FROM buildertek__Billings__c WHERE ID =:invoice_Id LIMIT 1];
                Invoice.buildertek__QBO_ID__c = QB_invoice_Id;
                Invoice.buildertek__QBO_Tax_Rate_ID__c = taxCodeId;
                Invoice.buildertek__QBO_Tax_Rate__c = taxRateValue;
                Invoice.buildertek__QB_Invoice_URL__c = qbInvoiceURL;
                Invoice.buildertek__QBO_Term_Id__c = TermQBId;
                Invoice.buildertek__QB_Invoice_Number__c = QbInvNumber;
                Invoice.buildertek__QBO_SyncToken__c = QBInvSyncTocken;
                update Invoice;
            } catch (Exception e) {
                System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    
        public static void UpdateReceipt(String receipt_Id, String QB_Payment_Id , buildertek__QuickBooks_Setting__mdt  QBMetadata){
            try {
                system.debug('Receipt going to Update');
                String qbPaymentURL = QBMetadata.buildertek__Qb_URL__c + 'recvpayment?txnId=' + QB_Payment_Id;
                buildertek__Receipt__c receipt = [SELECT Id, Name , buildertek__QBO_ID__c, buildertek__QB_Receipt_URL__c FROM buildertek__Receipt__c WHERE ID =:receipt_Id LIMIT 1];
                receipt.buildertek__QBO_ID__c = QB_Payment_Id;
                receipt.buildertek__QB_Receipt_URL__c = qbPaymentURL;
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
                        record.buildertek__QBO_ID__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                    update CoLinestoUpdate;
                }
                
            } catch (Exception e) {
                System.debug('Error in UpdateCOinvLines : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateContractorInvoice(sObject CoInv, String QB_BillId, String QB_BillSyncToken, String QB_BillQbNumber, buildertek__QuickBooks_Setting__mdt  QBMetadata){
            try {
                buildertek__Account_Payable__c Coinvoice = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c, buildertek__QBO_Bill_Number__c FROM buildertek__Account_Payable__c WHERE Id =:CoInv.Id LIMIT 1];
                String QBUrl =  QBMetadata.buildertek__Qb_URL__c + 'bill?&txnId=' + QB_BillId;
                Coinvoice.buildertek__QBO_ID__c = QB_BillId;
                Coinvoice.buildertek__QBO_SyncToken__c = QB_BillSyncToken;
                Coinvoice.buildertek__QBO_Bill_Number__c = QB_BillQbNumber;
                Coinvoice.buildertek__QB_Record_URL__c = QBUrl;
                update Coinvoice;
            } catch (Exception e) {
            System.debug('Error in UpdateContractorInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
        // ..... ....... ........... .......... ............. Update Records Utility Methods - END ...... ........ ......... ......... .............
    
    
}