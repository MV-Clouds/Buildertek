public without sharing class QBClone{
    public static final String invSfId = 'a0t1K00000oi0TVQAY';
    public static final buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =:invSfId LIMIT 1];
    public static final List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name,buildertek__Item_Name__c, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Quantity__c,buildertek__QBO_ID__c,QBO_SyncToken__c,buildertek__Billable_Lines__c.buildertek__Total__c,Description__c,Unit_Price__c,Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =:invSfId];
    public static final Map<Id, List<String>> salesforceIdToQbIdMap = new Map<Id, List<String>>();
    public static Integer totalBatches = 0;
    public static Map<Integer, Map<Id, List<String>>> batchResponses = new Map<Integer, Map<Id, List<String>>>();
    public static String accessToken = null;

    @future(callout=true)
    public static void createBatches() {
        try {
            System.debug('in createBatches method');
            if (SILines != null && !SILines.isEmpty()) {
                Integer totalItems = SILines.size();
                Integer batchSize = 30;
                totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed

                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);

                    List<buildertek__Billable_Lines__c> itemsBatch = new List<buildertek__Billable_Lines__c>();

                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                        itemsBatch.add(SILines[j]);
                    }
                    System.debug('************** Batch length ************************* ' + itemsBatch.size());
                    createProducts(itemsBatch, i);
                }
            } else {
                System.debug('SILines is empty. No batches to process.');
            }
        } catch (Exception e) {
            System.debug('Exception in createBatches: ' + e.getMessage());
        }
    }

    public static void createProducts(List<buildertek__Billable_Lines__c> SILine, Integer batchIndex) {
        try {
            System.debug('in createProducts method');
            QBBatchReqJSON batchItemRequest = new QBBatchReqJSON();
            
            for (buildertek__Billable_Lines__c item : SILine) {
                String lineId = item.Id;
                batchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    false, // Set TrackQtyOnHand as needed ==> if true then we need asset & expense account required
                    item.buildertek__Item_Name__c +'-'+ lineId.right(4).substring(0,4),
                    item.buildertek__Quantity__c,
                    item.buildertek__Total__c,
                    'Sales of Product Income',
                    '79', // Assuming a fixed value for income account value
                    'Services'
                );
            }
            String batchPayload = JSON.serialize(batchItemRequest);
            createInvoiceLines(batchPayload, batchIndex);
        } catch (Exception e) {
            System.debug('Exception in createProduct :: '  + e.getMessage());
        }
    }

    public static void createInvoiceLines(String body, Integer batchIndex) {
        try {
            System.debug('in createInvoiceLines method ');
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365355801090/batch');
            req.setMethod('POST');
            req.setHeader('Authorization', 'Bearer ' + getAccessToken());
            req.setheader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(body);
        
            HTTPResponse res = new Http().send(req);

            if (res.getStatusCode() == 200) {
                System.debug('Batch operation successful. Response: ' + res.getBody());
                QBBatchResJSON response = QBBatchResJSON.parse(res.getBody());

                // Check if the response contains BatchItemResponse and extract Salesforce and QB IDs
                if (response != null && response.BatchItemResponse != null && !response.BatchItemResponse.isEmpty()) {
                    for (QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                        if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                            salesforceIdToQbIdMap.put(
                                // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                                Id.valueOf(batchItem.bId), // Salesforce ID
                                new List<String> { batchItem.Item.Id , batchItem.Item.Name , String.valueOf(batchItem.Item.UnitPrice)} // QuickBooks ID
                            );
                        }
                    }
                }
                System.debug('Map ==> ' + salesforceIdToQbIdMap);

                if (!salesforceIdToQbIdMap.isEmpty()) {
                    for (buildertek__Billable_Lines__c record : SILines) {
                        List<String> qbIdAndNameList = salesforceIdToQbIdMap.get(record.Id);
        
                        if (qbIdAndNameList != null) {
                            record.buildertek__QBO_ID__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        }
                        batchResponses.put(batchIndex, new Map<Id, List<String>>(salesforceIdToQbIdMap));
                    }
                }
                // Check if this is the last batch, then process the invoice
                if (batchResponses.size() == totalBatches) {
                    createInvoice();
                }
            } else {
                System.debug('Batch operation failed with status code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
            }
        } catch (Exception e) {
            System.debug('Exception in performBatchOperation :: ' + e.getMessage());
        }
    }

    public static String mapInvoiceData(buildertek__Billings__c inv, String CustomerId, Map<Id, List<String>> lineIdsMap) {
        try {
            System.debug(' in mapInvoiceData method');
            String invId = inv.Id;
            String invQBId = inv.QBO_ID__c;
            
            QBInvoiceJSON invoice = new QBInvoiceJSON();
            invoice.TotalAmt = String.valueOf(inv.buildertek__Total_Amount_Tax__c);
            invoice.Balance = inv.buildertek__Total_Amount_Tax__c;
            invoice.Line = new List<QBInvoiceJSON.line>();
    
            // Iterate through the lineIdsMap to add line items to invoice
            Integer lineNumber = 1;
            for (String lineId : lineIdsMap.keySet()) {
                List<String> qbIdAndNameList = lineIdsMap.get(lineId);
                String qbId = '';
                String qbName = '';
                String qbTotal = '';

                if (qbIdAndNameList != null) {
                    qbId = qbIdAndNameList[0]; // Retrieve QuickBooks ID
                    qbName = qbIdAndNameList[1]; // Retrieve QuickBooks Name
                    qbTotal = qbIdAndNameList[2];
                }

                QBInvoiceJSON.line Linee = new QBInvoiceJSON.line();
                Linee.DetailType = 'SalesItemLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = qbId;
                Linee.LineNum = String.valueOf(lineNumber);
                Linee.SalesItemLineDetail = new QBInvoiceJSON.SalesItemLineDetail();
                
                QBInvoiceJSON.SalesItemLineDetail SILD = new QBInvoiceJSON.SalesItemLineDetail();
                SILD.ItemRef = new QBInvoiceJSON.ItemRef();
                
                QBInvoiceJSON.ItemRef ItemRef = new QBInvoiceJSON.ItemRef();
                ItemRef.name = qbName;
                ItemRef.value = qbId;
                
                SILD.ItemRef = ItemRef;
                Linee.SalesItemLineDetail = SILD;
                invoice.Line.add(Linee);
                
                lineNumber++;
            }
            
            invoice.CustomerRef = new QBInvoiceJSON.CustomerRef();
            QBInvoiceJSON.CustomerRef customer = new QBInvoiceJSON.CustomerRef();
            customer.value = CustomerId;
            invoice.CustomerRef = customer;

            return JSON.serialize(invoice, True).replace('"Long_x":', '"Long":');
        } catch (Exception e) {
            System.debug('exception in mapInvoiceData :: ' + e.getMessage());
            return null;
        }
    }

    public static void createInvoice() {
        System.debug(' IN createInvoice method');
        if(batchResponses.size() == totalBatches){
            String invoiceQBID = '';
            try {
                System.debug(' IN if');
                HttpRequest req = new HttpRequest();
                req.setEndpoint('https://sandbox-quickbooks.api.intuit.com/v3/company/4620816365355801090/invoice');
                req.setMethod('POST');
                req.setHeader('Authorization', 'Bearer ' + getAccessToken());
                req.setheader('Accept', 'application/json');
                req.setHeader('Content-Type', 'application/json');
                String Invoice_RequestBody = QBClone.mapInvoiceData(SI, '73', salesforceIdToQbIdMap);
                System.debug('Invoice_RequestBody :: '+Invoice_RequestBody);
                req.setBody(Invoice_RequestBody);
            
                HTTPResponse res = new Http().send(req);

                if (res.getStatusCode() == 200) {
                    // Successful callout, handle response if needed
                    System.debug('Invoice creation successful. Response: ' + res.getBody());
                    // Parse the response body into QBBatchResJSON
                    QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(res.getBody());
                    QBInvoiceResponseJSON.Invoice inv = new QBInvoiceResponseJSON.Invoice();
                    inv = Invoice_Response_desr.Invoice;
                    invoiceQBID = inv.Id;

                    try {
                        system.debug('sales Invoice & lines going to Update');
                        SI.buildertek__QBO_ID__c = invoiceQBID;
                        // update SILines;
                        // update SI;
                    } catch (Exception e) {
                        System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e);
                    }
                } else {
                    System.debug('invoice creation failed with status code: ' + res.getStatusCode());
                    System.debug('Response: ' + res.getBody());
                }
            } catch (Exception e) {
                System.debug('Exception in createInvoice :: ' + e.getMessage());
            }
        } else{
            System.debug('***batches are not executed as needed***');
            System.debug(batchResponses.size());
            System.debug(totalBatches);
        }
    }
    
    public static String getAccessToken() {
        try {
            System.debug(' in getAccessToken method');
            if (accessToken != null) {
                System.debug('Using existing access token');
                return accessToken;
            }
            String refreshToken = 'AB11708932155Bq3C6WB9DJKYLYh7ov1vXCum0FBuoPcSR0VdX';
            String client_Id = 'ABvVdisEK9DpoYAJkGljKkoeXvEcAKN4kwIYKpLjOBa2Aqwwyj';
            String client_Secret = 'CHYm7V8VWjZ4v44LerLwvU6tHV7RPrwsgyCE5Odu';
            
            HttpRequest req = new HttpRequest();
            req.setEndpoint('https://oauth.platform.intuit.com/oauth2/v1/tokens/bearer');
            req.setMethod('POST');
            req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req.setBody('grant_type=refresh_token&refresh_token=' +  EncodingUtil.urlEncode(refreshToken, 'UTF-8') + '&client_id=' + client_Id + '&client_secret=' + client_Secret);
            
            HTTPResponse res = new Http().send(req);
            
            if (res.getStatusCode() == 200) {
                Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
                System.debug(responseMap);
                System.debug(accessToken);
                accessToken = (String) responseMap.get('access_token');
                System.debug(accessToken);
                return accessToken;
            } else {
                System.debug('Failed to refresh access token. Status Code: ' + res.getStatusCode());
                System.debug('Response: ' + res.getBody());
                return null;
            }
            
        } catch (Exception e) {
            System.debug('Exception in getaccesstoken ::');
            System.debug(e);
            return e.getMessage();
        }
    }
}