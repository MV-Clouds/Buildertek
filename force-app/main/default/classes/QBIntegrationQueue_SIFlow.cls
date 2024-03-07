public with sharing class QBIntegrationQueue_SIFlow {

//  *********  Integration flow --> Customer - Items(Product and Service) - TaxRate - Term  - Invoice - Payment(Receipt)

// 1. BT Sales Invoice Customer Account(Parent Customer) --> QB Customer [ ----- first Code Create Customer in QB From Invoice Customer account(or Project Customer Account), if Customer Already available in QB Then QB Customer id Must be store on Account Object) -----]
// 2. BT Sals invoice related invoice Lines (Related Objects) --> QB Product and Service
// 3. BT Sales Invoice Tax Rate (Field) --> QB Tax Rate                  
// 4. BT Sales Invoice Term (Picklist filed) --> QB Term
// 5. BT Sales Invoice (Object) --> QB Invoice
// 6. BT receipt (Object) --> QB Payment    


        @future(callout=true)
        public static void qb_Payment_Invoice_Flow_Callout(Id Sales_invoice_Id, Id receiptID){

            try {
                buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c,buildertek__Tax_Rate__c, buildertek__QB_Invoice_URL__c, buildertek__QB_Invoice_Number__c	,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Terms__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
                Account acc = new Account();
                if(SI.buildertek__Customer_Account__c != null){
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
                }
                else if(SI.buildertek__Customer_Account__c == null){
                    system.debug('Project Id ' + SI.buildertek__Project__r.buildertek__Customer__c);
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: SI.buildertek__Project__r.buildertek__Customer__c limit 1];
                }
                List<buildertek__Billable_Lines__c> SILines = [SELECT Id, Name, buildertek__Billings__c,buildertek__Billings__r.Name,buildertek__Total__c,buildertek__SubTotal__c,buildertek__Item_Name__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Description__c,buildertek__Unit_Price__c,buildertek__Type__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];
    
                buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
                
                String SyncObjName = 'buildertek__Billings__c';
    
                // if(acc.buildertek__QB_Id__c == null){
                    // Customer - items - invoice - PAYMENT
                    salesInvoiceFlow_Wrapper SI_Wrapper = new salesInvoiceFlow_Wrapper();
                    SI_Wrapper.SILines = SILines;
                    SI_Wrapper.SI = SI;
                    SI_Wrapper.acc = acc;
                    SI_Wrapper.QBMetadata = QBMetadata;
                    SI_Wrapper.receiptID = receiptID;
                    SI_Wrapper.SyncObjName = SyncObjName;
                    system.debug('SI_Wrapper : ' + SI_Wrapper);
                    sync_Customer_in_QB(SI_Wrapper);
                    
    
            } catch (Exception e) {
                System.debug('Error in qb_Payment_Invoice_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
            }
        }
    
        public static void sync_Customer_in_QB(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                String Customer_EndPoint = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + SI_Wrapper.QBMetadata.buildertek__minorversion__c;            
                String Customer_RequestBody = QBMap.mapAccountData(SI_Wrapper, 1);
                system.debug('JSON Body >>' +  Customer_RequestBody);
                HttpResponse Customer_Response = QBCallOutService.QBAPICallOut(Customer_EndPoint , Customer_RequestBody);
                system.debug('Customer API Status Code >> ' + Customer_Response.getStatusCode());
                System.debug('Customer_Response.getBody() :: '+ Customer_Response.getBody());
                SI_Wrapper.SyncToken = null;
                if(Customer_Response.getStatusCode() == 200){
                    QBCustomerResponseJSON Customer_Response_Deser = QBCustomerResponseJSON.parse(Customer_Response.getBody());
                    QBCustomerResponseJSON.Customer customer = new QBCustomerResponseJSON.Customer();
                    customer = Customer_Response_Deser.Customer;
                    String CustomerQBId = customer.Id;
                    String SyncToken = customer.SyncToken;
                    // this condition define wheather You want to countine the integration or not...
                        SI_Wrapper.QBId = CustomerQBId;
                        SI_Wrapper.SyncToken = SyncToken;
                        System.debug('SI_Wrapper for line to Item Create and Account Update : ' + SI_Wrapper);

                    if(SI_Wrapper.SyncObjName != 'Account'){ 
                        sync_lines_to_items(SI_Wrapper);
                    }
                    UpdateAccount(SI_Wrapper, 'Customer');
                }
                else{
                    QBOErrorJSON Response_Error = QBOErrorJSON.parse(Customer_Response.getBody());
                    QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                    falut = Response_Error.Fault;
                    String QBErrorCode = falut.Error[0].code;
                    System.debug('QBErrorCode : ' + QBErrorCode);
                    if(QBErrorCode == '5010'){
                        System.debug('Sync Token Mismatch Error For Customer, Need Query and GET QB Record to Update Sync Token');
                        SI_Wrapper.QueryCustomer_VendorFlag = true;
                        Query_QB_Record(SI_Wrapper);
                    }
                    else{
                        // UpdateAccount_OnError(acc.Id, ErrorMessage);
                        QBException.QB_response( Customer_Response.getStatusCode(),  Customer_Response.getBody(), 'QBIntegrationQueue', 'sync_Customer_in_QB');
                        String ErrorMessage = 'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                        QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.acc.Id, ErrorMessage, 'Account');
                        if(SI_Wrapper.SyncObjName != 'Account'){
                            String ErrorMessage1 = 'Error During Customer Callout :- ' + ErrorMessage;
                            QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.SI.Id, ErrorMessage1, SI_Wrapper.SyncObjName);
                            if(SI_Wrapper.receiptID != null){
                                // Update Receipt Record On eroor...
                                QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage1, 'buildertek__Receipt__c');
                            }
                        }
                    }
                }
                
            } catch (Exception e) {
                System.debug('Error in sync_Customer_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void sync_lines_to_items(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                set<String> ItemsWithoutQBId = new set<String>();           // To Store Unique Name Of SF Lines.....
                List<buildertek__Billable_Lines__c> ItemToSync = new List<buildertek__Billable_Lines__c>();
                List<buildertek__Billable_Lines__c> ItemList = new List<buildertek__Billable_Lines__c>();
                ItemList = SI_Wrapper.SILines;
            // Sync sales Inovice Lines
                for(buildertek__Billable_Lines__c Items : ItemList){
                    if(Items.buildertek__QB_Id__c == null){
                        ItemsWithoutQBId.add(Items.buildertek__Item_Name__c);
                        ItemToSync.add(Items);
                    }
                }
            
            // If Any SF Lines does not availbale in QB... Else All SF Line Have QB Id (Already Synced With QB)...
            if(ItemsWithoutQBId.size() > 0){
                
                list<String> ItemsNotHaveQBId_List = new list<String>(ItemsWithoutQBId); // List of Unique Name SF Line Without QB Id.....(Set to List COnversion for Interate using for Loop)     
                // Create Query String for API callout Endpoint....
                String ItemNames = '(';
                for(integer i=0; i<ItemsNotHaveQBId_List.size(); i++){
                    if(i != (ItemsNotHaveQBId_List.size() - 1)){
                        ItemNames += '\''+ItemsNotHaveQBId_List[i] + '\',';
                    }
                    else{
                        ItemNames += '\''+ItemsNotHaveQBId_List[i] + '\')';
                    }
                } 

                // API Callout to Check Duplicate Name's Items alredy Exist or Not in QB...
                String ItemQuery = EncodingUtil.urlEncode('select * from Item WHERE name in '+ ItemNames + ' STARTPOSITION 1 MAXRESULTS 1000', 'UTF-8');
                string GET_Items_JSONBody = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/query?query=' + ItemQuery + '&minorversion='+ SI_Wrapper.QBMetadata.buildertek__minorversion__c;   
                HttpResponse GET_Items_Response = QBCallOutService.QBAPICallOut_GET(GET_Items_JSONBody, null);
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
                        system.debug('Number Of Duplicate Name Items In QB ' + queryRes.Item.size());
                    }
                }
                // -------- 
                map<String, QBBatchResJSON.Item> queryItems_Map = new map<String, QBBatchResJSON.Item>();   // For Furter Query and Filteration
                List<buildertek__Billable_Lines__c> ItemstoCreate = new List<buildertek__Billable_Lines__c>();  // List of SF Lines Without QB Id And Without Dupliacte Name (So These Are need to Create In QB)....
                map<String, buildertek__Billable_Lines__c> ItemstoCreate_Map = new map<String, buildertek__Billable_Lines__c>();
                Map<Id, QBBatchResJSON.Item> QBItemsToAssign_Map = new Map<Id, QBBatchResJSON.Item>(); // Map Of QB Dupliate Item Name and Duplicate Item QB Object...
                List<buildertek__Billable_Lines__c> QBItemsToAssign = new List<buildertek__Billable_Lines__c>();

                // IF SF Lines Are Not Synced With QB But Item With Duplicate Name Already Availabel In QB.... Then Use QB ID of That QB Items for SF Lines
                if(queryItemsList.size() > 0){
                    
                    for(QBBatchResJSON.Item queryItem : queryItemsList){
                        queryItems_Map.put(queryItem.Name.toLowerCase(), queryItem);
                    }
                    system.debug('Duplicate Name Items In QB' + queryItems_Map.keySet());

                    // Filter Duplicate Name SF Items And SF Items To Create IN QB...
                    for(buildertek__Billable_Lines__c item : ItemToSync){

                        String ItemName = item.buildertek__Item_Name__c.toLowerCase();
                        String DupliacteItemName = queryItems_Map.get(ItemName) != null ? queryItems_Map.get(ItemName).Name : null;

                        if(ItemName != DupliacteItemName){
                            // QB Will create Only Unique name Items.. So we only add unique name Lines in Map
                            ItemstoCreate_Map.put(ItemName, item);
                        }
                        
                        
                    }

                    ItemstoCreate = ItemstoCreate_Map.values();

                    for(buildertek__Billable_Lines__c item : ItemToSync){
                        String ItemName = item.buildertek__Item_Name__c.toLowerCase();
    
                        Id CreteItemId;
                        if(ItemstoCreate_Map.keySet().size() > 0){
                            CreteItemId = ItemstoCreate_Map.get(ItemName) != null ? ItemstoCreate_Map.get(ItemName).Id : null; 
                        }
                        if(item.Id != CreteItemId){
                            QBItemsToAssign_Map.put(item.Id, queryItems_Map.get(ItemName));
                            QBItemsToAssign.add(item);
                        }
                    }
                }
                else{
                    // If None of the Line have Duplicate Name In QB....
                    System.debug('.... None of the Line have Duplicate Name In QB .....');
                    // ItemstoCreate = ItemToSync;
                    for(buildertek__Billable_Lines__c item : ItemToSync){
                        String ItemName = item.buildertek__Item_Name__c.toLowerCase();
                        ItemstoCreate_Map.put(ItemName, item);
                    }

                    for(buildertek__Billable_Lines__c item : ItemToSync){
                        String ItemName = item.buildertek__Item_Name__c.toLowerCase();
                        Id CreteItemId;
                        if(ItemstoCreate_Map.keySet().size() > 0){
                            CreteItemId = ItemstoCreate_Map.get(ItemName) != null ? ItemstoCreate_Map.get(ItemName).Id : null; 
                        }
                        if(item.Id != CreteItemId){
                            // QBItemsToAssign_Map.put(item.Id, queryItems_Map.get(ItemName));
                            QBItemsToAssign.add(item);
                        }
                    }

                    ItemstoCreate = ItemstoCreate_Map.values();
                }

                System.debug('No of Items to create  : ' + ItemstoCreate.size());
                System.debug('no of QBItemsToAssign : ' + QBItemsToAssign.size());

                // When SF Line Does Not Have QB In and Also Item With Duplicate Name Not Found In QB....
                if(ItemstoCreate.size() > 0){
                Integer totalItems = ItemstoCreate.size();
                Integer batchSize = 30;
                Integer totalBatches = (totalItems + batchSize - 1) / batchSize; // Calculate total batches needed
                Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
    
                for (Integer i = 0; i < totalBatches; i++) {
                    Integer startIdx = i * batchSize;
                    Integer endIdx = Math.min((i + 1) * batchSize, totalItems);
    
                    List<buildertek__Billable_Lines__c> itemsBatch = new List<buildertek__Billable_Lines__c>();
    
                    // Create the sublist for the current batch
                    for (Integer j = startIdx; j < endIdx; j++) {
                            itemsBatch.add(ItemstoCreate[j]);
                    }
                    System.debug('Items Are Going to Create : '+(i+1) +' ***** No. Batch length ******** '+ itemsBatch.size());
                    
                            // API Callout to Sync Items in QB...
                            String Items_EndPoint = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/batch?minorversion=' + SI_Wrapper.QBMetadata.buildertek__minorversion__c;
                            String Items_RequestBody = QBMap.MapInvoiceLineToBatch(itemsBatch); 
                            System.debug('Items_RequestBody ' +Items_RequestBody);
                            HttpResponse Items_Response = QBCallOutService.QBAPICallOut(Items_EndPoint , Items_RequestBody);
                            system.debug('Item Batch API Status Code >> ' + Items_Response.getStatusCode());
                            system.debug('Item Batch Resopnce >> ' + Items_Response.getBody());

                        if(Items_Response.getStatusCode() == 200){
                            QBBatchResJSON response = QBBatchResJSON.parse(Items_Response.getBody());

                            Map<String, QBBatchResJSON.BatchItemResponse> NewCreatedItem_Map = new Map<String, QBBatchResJSON.BatchItemResponse>();
                            Map<Id, QBBatchResJSON.BatchItemResponse> NewCreatedItemToAssign_Map = new Map<Id, QBBatchResJSON.BatchItemResponse>();

                            for(QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                                if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                    NewCreatedItem_Map.put((batchItem.item.Name).toLowerCase(), batchItem);
                                }
                            }
                            system.debug(' --- NewCreatedItem_Map ---- : ' + NewCreatedItem_Map);

                            for(buildertek__Billable_Lines__c item : QBItemsToAssign){
                                // string ItemName = item.buildertek__Item_Name__c.toLowerCase();
                                string ItemName = (item.buildertek__Item_Name__c).toLowerCase();
                                NewCreatedItemToAssign_Map.put(item.Id, NewCreatedItem_Map.get(ItemName));
                            }
                            system.debug(' --- NewCreatedItemToAssign_Map ---- : ' + NewCreatedItemToAssign_Map);
                            
                            for(buildertek__Billable_Lines__c Items : ItemList){

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
                                    if(QBDuplicateNameItem != null){
                                        Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                        Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                                    }
                                
                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.BatchItemResponse newCraetedItem = NewCreatedItemToAssign_Map.get(Items.Id);
                                    if(newCraetedItem != null){
                                        Items.buildertek__QB_Id__c = newCraetedItem.Item.Id;
                                        Items.buildertek__QBO_Name__c = newCraetedItem.Item.Name;
                                    }

                                    if(Items.buildertek__QB_Id__c != null){
                                        lineIdsMap.put(
                                            Id.valueOf(Items.Id), 
                                            new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__SubTotal__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                        );
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
                                SI_Wrapper.lineIdsMap = lineIdsMap;
                                SI_Wrapper.SILines = ItemList;
                                sync_TaxRate_in_QB(SI_Wrapper);
                                UpdateSIline(SI_Wrapper);
                                // UpdateSIline(ItemList, lineIdsMap);
                            }
                        }
                        else{
                            QBException.QB_response( Items_Response.getStatusCode(),  Items_Response.getBody(), 'QBIntegrationQueue', 'sync_item_in_QB');
                            QBOErrorJSON Response_Error = QBOErrorJSON.parse(Items_Response.getBody());
                            QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                            falut = Response_Error.Fault;
                            String ErrorMessage1 = 'Error During Co Line Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                            // UpdateContractorInvoice_OnError(CoInv.Id, ErrorMessage1);
                            QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.SI.Id, ErrorMessage1, SI_Wrapper.SyncObjName);
                            if(SI_Wrapper.receiptID != null){
                                // Update Receipt Record On eroor...
                                QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage1, 'buildertek__Receipt__c');
                            }
    
                        }
                    // }
                    }
                }
                else{
                    // When All SF Item with Duplicate Name Availbale In QB But SF Items Does Not Have QB ID... Then Assign QB Id First And Then Sync With Invoice/Bill/PO/Expense.... 
                    System.debug('.... All SF Lines Have Duplicate Name...');
                    Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();

                    for(buildertek__Billable_Lines__c Items : ItemList){

                            // Assign QB Id to Dupliacte Name Lines...
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
                            if(QBDuplicateNameItem != null){
                                Items.buildertek__QB_Id__c = QBDuplicateNameItem.Id;
                                Items.buildertek__QBO_Name__c = QBDuplicateNameItem.Name;
                            }

                            if(Items.buildertek__QB_Id__c != null){
                                lineIdsMap.put(
                                    Id.valueOf(Items.Id), 
                                    new List<String>{Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__SubTotal__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)}
                                );
                            }
                    
                    }

                    if(lineIdsMap.size() > 0){
                        System.debug('lineIdsMap When Items To Create is NUll>> ' + lineIdsMap);
                        // UpdateSIline(ItemList, lineIdsMap);
                        SI_Wrapper.lineIdsMap = lineIdsMap;
                        SI_Wrapper.SILines = ItemList;
                        sync_TaxRate_in_QB(SI_Wrapper);
                        UpdateSIline(SI_Wrapper);
                    }
                }
            }
            else{
                // When All SF Lines Have QB Id... Then Nothing to Do With Items... Just Sync With Parent QB Objects(Invoice/Bill/PO/Expense)
                System.debug('All Items are Synced with QB');
                Map<Id, List<String>> lineIdsMap1 = new Map<Id, List<String>>();
                for(buildertek__Billable_Lines__c Items : ItemList){
                    lineIdsMap1.put(
                            // Assuming SalesforceId__c is of type Id and QbId__c is of type String
                            Id.valueOf(Items.Id), // Salesforce ID
                            new List<String> { 
                               Items.buildertek__QB_Id__c, Items.buildertek__QBO_Name__c, string.valueOf(Items.buildertek__SubTotal__c), string.valueOf(Items.buildertek__Quantity__c), string.valueOf(Items.buildertek__Unit_Price__c)
                            }
                    );
                }
                // UpdateSIline(ItemList, lineIdsMap1);
                SI_Wrapper.lineIdsMap = lineIdsMap1;
                SI_Wrapper.SILines = ItemList;
                sync_TaxRate_in_QB(SI_Wrapper);
                UpdateSIline(SI_Wrapper);
               
            }
            } catch (Exception e) {
                System.debug('Error in sync_lines_to_items : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
                
            }
        }
    
        public static void sync_TaxRate_in_QB(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                List<buildertek__Billings__c> allInvoice = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QB_Invoice_URL__c,buildertek__QB_Invoice_Number__c, buildertek__QB_Id__c,buildertek__Tax_Rate__c,buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Due_Date__c,buildertek__Amount__c,buildertek__Total_Amount_Tax__c FROM buildertek__Billings__c];
                Boolean IsTaxRateExistInQB = false; // to break loop if once invoice flow going forward...
                String taxCodeId;
                Double taxRateValue;
                String taxCodeName;
                taxCodeName = (SI_Wrapper.SI.buildertek__Tax_Rate__c != null) 
                ? 'Tax - ' + String.valueOf(SI_Wrapper.SI.buildertek__Tax_Rate__c)
                : 'Tax - 0.0000';
                // String  taxCodeName = taxName.substring(0, taxName.length() - 2);
                 System.debug('taxName------>' + taxCodeName);
                String encodedQueryParam = EncodingUtil.urlEncode('Select * From TaxCode Where Name = \''+taxCodeName + '\'', 'UTF-8');
    
                String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ SI_Wrapper.QBMetadata.buildertek__minorversion__c; 
    
                HttpResponse get_TaxRate_from_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null);
                    if(get_TaxRate_from_QB_ResponseBody.getStatusCode() == 200){
                        System.debug('get_TaxRate_from_QB_ResponseBody.getBody() :: ' + get_TaxRate_from_QB_ResponseBody.getBody());
    
                        QBTaxRateJSON get_TaxRate_from_QB_ResponseBody_Deser = QBTaxRateJSON.parse(get_TaxRate_from_QB_ResponseBody.getBody());
                        System.debug('get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse >> ' + get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse);
                        // Accessing Id and RateValue directly from the TaxRate instanceß
                        if(get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse.totalCount != null){
                            QBTaxRateJSON.TaxCode  getTaxRateDetail = get_TaxRate_from_QB_ResponseBody_Deser.QueryResponse.TaxCode[0];
                            System.debug('getTaxRateDetail----->' + getTaxRateDetail);
                            // TaxRate is already exist in QB
                            SI_Wrapper.taxCodeId = getTaxRateDetail.Id;
                            SI_Wrapper.taxRateValue = SI_Wrapper.SI.buildertek__Tax_Rate__c;
                            System.debug('taxCodeId -----> ' + taxCodeId);
                            System.debug('taxRateValue -----> ' + taxRateValue);
                            System.debug('// Create Invoice with exsiting tax rate ID...');
                            sync_Term_in_QB(SI_Wrapper);
                        }
                        else{
                            // TaxRate is not exist in QB
                            System.debug('// Create New Tax Rate In QB...');
                            String TaxRate_EndPoint = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/taxservice/taxcode?minorversion=' + SI_Wrapper.QBMetadata.buildertek__minorversion__c; 
                            String TaxRate_RequestBody = QBMap.mapTaxRateData(SI_Wrapper.SI);           
                            system.debug('TaxRate_RequestBody :: ' + TaxRate_RequestBody);
                            HttpResponse TaxRate_ResponseBody = QBCallOutService.QBAPICallOut(TaxRate_EndPoint, TaxRate_RequestBody);
                            system.debug('TaxRate_ResponseBody :: ' + TaxRate_ResponseBody.getBody());
                            if(TaxRate_ResponseBody.getStatusCode() == 200){
                                System.debug('TaxRate_ResponseBody.getBody() :: '+ TaxRate_ResponseBody.getBody());
                                QBTaxCodeResponseJSON TaxRate_ResponseBody_Deser =  QBTaxCodeResponseJSON.parse(TaxRate_ResponseBody.getBody());
                                List<QBTaxCodeResponseJSON.TaxRateDetails> TaxRateDetai = new  List<QBTaxCodeResponseJSON.TaxRateDetails>();
                                TaxRateDetai = TaxRate_ResponseBody_Deser.TaxRateDetails;
                                SI_Wrapper.taxCodeId = TaxRate_ResponseBody_Deser.TaxCodeId;
                                SI_Wrapper.taxRateValue = TaxRateDetai[0].RateValue;
                                sync_Term_in_QB(SI_Wrapper);
                            }
                            else{
                                QBException.QB_response( TaxRate_ResponseBody.getStatusCode(),  TaxRate_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                                QBOErrorJSON Response_Error = QBOErrorJSON.parse(TaxRate_ResponseBody.getBody());
                                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                                falut = Response_Error.Fault;
                                String ErrorMessage = 'Error During Tax Rate Callout :- '+'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                                // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                                QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.SI.Id, ErrorMessage, SI_Wrapper.SyncObjName);
                                if(SI_Wrapper.receiptID != null){
                                    // Update Receipt Record On eroor...
                                    QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage, 'buildertek__Receipt__c');
                                }
                            }
                        }
                    }
                    else{
                        QBException.QB_response( get_TaxRate_from_QB_ResponseBody.getStatusCode(),  get_TaxRate_from_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'Create_Customer_invoice_item_payment_in_QB');
                    }
                
            } catch (Exception e) {
                System.debug('Error in sync_TaxRate_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }   
    
        public static void sync_Term_in_QB(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                String termName = SI_Wrapper.SI.buildertek__Terms__c;
                String encodedQueryParam = EncodingUtil.urlEncode('Select * From Term Where Name = \''+termName + '\'', 'UTF-8');
                String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ SI_Wrapper.QBMetadata.buildertek__minorversion__c; 
                // String TermQBId = null;
    
                // Check if term Availbe or not in QB....
                HttpResponse term_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null);
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
                            SI_Wrapper.TermQBId = Terms[0].Id;
    
                            sync_invoice_in_QB(SI_Wrapper);
                        }
                        else{
                            // Create Invoice Without Term...
                            sync_invoice_in_QB(SI_Wrapper);
                        }
                    }
                    else{
                        QBException.QB_response( term_QB_ResponseBody.getStatusCode(),  term_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'createTerms');
                        QBOErrorJSON Response_Error = QBOErrorJSON.parse(term_QB_ResponseBody.getBody());
                        QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                        falut = Response_Error.Fault;
                        String ErrorMessage = 'Error During Term Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                        // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                        QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.SI.Id, ErrorMessage, SI_Wrapper.SyncObjName);
                        if(SI_Wrapper.receiptID != null){
                            // Update Receipt Record On eroor...
                            QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage, 'buildertek__Receipt__c');
                        }
                    }
                
            } catch (Exception e) {
                System.debug('Error in sync_Term_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }    
    
        public static void sync_invoice_in_QB(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                // String CustomerQBId = acc.buildertek__QB_Id__c;
                // Map<Id, List<String>> lineIdsMap = new Map<Id, List<String>>();
                String Invoice_EndPoint = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/invoice?minorversion=' + SI_Wrapper.QBMetadata.buildertek__minorversion__c;
                String Invoice_RequestBody = QBMap.mapInvoiceDataBatch(SI_Wrapper);
                System.debug('Invoice_RequestBody >> ' + Invoice_RequestBody);
                HttpResponse Invoice_Response = QBCallOutService.QBAPICallOut(Invoice_EndPoint , Invoice_RequestBody);
                
                system.debug('Invoice API Status Code >> ' + Invoice_Response.getStatusCode());
                system.debug('Invoice Resopnce >> ' + Invoice_Response.getBody());
                
                SI_Wrapper.SyncToken = null;
                if(Invoice_Response.getStatusCode() == 200){
                    QBInvoiceResponseJSON Invoice_Response_desr = QBInvoiceResponseJSON.parse(Invoice_Response.getBody());
                    QBInvoiceResponseJSON.Invoice invoice = new QBInvoiceResponseJSON.Invoice();
                    invoice = Invoice_Response_desr.Invoice;
                    SI_Wrapper.InvoiceQBId = invoice.Id;
                    SI_Wrapper.QbInvNumber = invoice.DocNumber;
                    SI_Wrapper.QBInvSyncTocken = invoice.SyncToken;
                    if(SI_Wrapper.receiptID != null){
                        sync_Payment_In_QB(SI_Wrapper);
                    }
                    // UpdateSalesInvoice(SI.Id, InvoiceQBId, taxCodeId, taxRateValue,QBMetadata, TermQBId, QbInvNumber, QBInvSyncTocken);
                    UpdateSalesInvoice(SI_Wrapper);
                }
                else{
                    QBOErrorJSON Response_Error = QBOErrorJSON.parse(Invoice_Response.getBody());
                    QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                    falut = Response_Error.Fault;
                    String QBErrorCode = falut.Error[0].code;
                    System.debug('QBErrorCode : ' + QBErrorCode);
                    if(QBErrorCode == '5010'){
                        System.debug('Sync Token Mismatch Error, Need Query and GET QB Record to Update Sync Token');
                        Query_QB_Record(SI_Wrapper);
                    }
                    else {
                        QBException.QB_response( Invoice_Response.getStatusCode(),  Invoice_Response.getBody(), 'QBIntegrationQueue', 'sync_invoice_in_QB');
                        String ErrorMessage = 'Error During Invoice Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                        // UpdateSalesInvoice_OnError(SI.Id, ErrorMessage);
                        QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.SI.Id, ErrorMessage, SI_Wrapper.SyncObjName);
                        if(SI_Wrapper.receiptID != null){
                            // Update Receipt Record On eroor...
                            QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage, 'buildertek__Receipt__c');
                        }
                    }
                }
    
                
            } catch (Exception e) {
                System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    
        public static void sync_Payment_In_QB(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                SI_Wrapper.SyncObjName = 'buildertek__Receipt__c';
                buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c, buildertek__QB_Id__c,buildertek__QB_Receipt_URL__c, buildertek__QBO_SyncToken__c FROM buildertek__Receipt__c WHERE Id =: SI_Wrapper.receiptID LIMIT 1];
                SI_Wrapper.receipt = receipt;
                String Payment_EndPoint = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + SI_Wrapper.QBMetadata.buildertek__minorversion__c;            
                String Payment_RequestBody = QBMap.mapReceipt_PaymetData(SI_Wrapper);
                system.debug('Payment_RequestBody >>' +  Payment_RequestBody);
                HttpResponse Payment_Response = QBCallOutService.QBAPICallOut(Payment_EndPoint , Payment_RequestBody);
                system.debug('Payment_RequestBody API Status Code >> ' + Payment_Response.getStatusCode());
                SI_Wrapper.SyncToken = null;
                if(Payment_Response.getStatusCode() == 200){
                    QBReceiptResponseJSON Payment_Response_desr = QBReceiptResponseJSON.parse(Payment_Response.getBody());
                    QBReceiptResponseJSON.Payment payment = new QBReceiptResponseJSON.Payment();
                    payment = Payment_Response_desr.Payment;
                    System.debug('payment response :: '+ payment);
                    String paymentQBID = payment.Id;
                    SI_Wrapper.receiptQBID = paymentQBID;
                    SI_Wrapper.SyncToken = payment.SyncToken;
                    UpdateReceipt(SI_Wrapper);
                }
                else{
                    QBOErrorJSON Response_Error = QBOErrorJSON.parse(Payment_Response.getBody());
                    QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                    falut = Response_Error.Fault;
                    String QBErrorCode = falut.Error[0].code;
                    System.debug('QBErrorCode : ' + QBErrorCode);
                    if(QBErrorCode == '5010'){
                        SI_Wrapper.QBId = receipt.buildertek__QB_Id__c;
                        System.debug('Sync Token Mismatch Error, Need Query and GET QB Record to Update Sync Token');
                        Query_QB_Record(SI_Wrapper);
                    }
                    else{
                        QBException.QB_response( Payment_Response.getStatusCode(),  Payment_Response.getBody(), 'QBIntegrationQueueable', 'QBIntegrationMethod');
                        String ErrorMessage = 'Error During Payment Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                        // UpdateReceipt_OnError(receiptID, ErrorMessage);
                        QBIntegrationQueue.UpdateRecord_OnError(SI_Wrapper.receiptID, ErrorMessage , SI_Wrapper.SyncObjName);
                    }
                }
            } catch (Exception e) {
                System.debug('Error in sync_Payment_In_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    // --------------- ------------- ----------------- Sales Invoice and Payment(Receipt) QB Integration Flow - END ---------------------------------------- ----------------------- --------------------
    

        // ..... ....... ........... .......... ............. Update Records Utility Methods - STARTS ...... ........ ......... ......... .............
        public static void UpdateAccount(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper, String AccountType){
            try {
                system.debug('Account going to Update');
                Account Acc = [SELECT Id,Name, buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c,buildertek__QB_Integration_Response_Message__c FROM Account WHERE Id =: SI_Wrapper.acc.Id LIMIT 1];
                Acc.buildertek__QB_Id__c = SI_Wrapper.QBId;
                Acc.buildertek__QBO_SyncToken__c = SI_Wrapper.SyncToken;
                Acc.buildertek__QB_Type__c = AccountType;
                Acc.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                if(AccountType == 'Customer'){
                    Acc.buildertek__QB_Record_URL__c = SI_Wrapper.QBMetadata.buildertek__Qb_URL__c + 'customerdetail?nameId=' + SI_Wrapper.QBId;
                }
                else if(AccountType == 'Vendor'){
                    Acc.buildertek__QB_Record_URL__c = SI_Wrapper.QBMetadata.buildertek__Qb_URL__c + 'vendordetail?nameId=' + SI_Wrapper.QBId;
                }
                update Acc;
            
            } catch (Exception e) {
                System.debug('Error in UpdateAccount : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateSIline(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                system.debug('sales Invoice line going to Update');

                for (buildertek__Billable_Lines__c record : SI_Wrapper.SILines) {
                    // Check if the Salesforce ID exists in the mapping and update the QuickBooks ID
                    List<String> qbIdAndNameList = SI_Wrapper.lineIdsMap.get(record.Id);

                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if (qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                }

                update SI_Wrapper.SILines;
            } catch (Exception e) {
                System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateSalesInvoice(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                system.debug('sales Invoice going to Update');
                String qbInvoiceURL = SI_Wrapper.QBMetadata.buildertek__Qb_URL__c + 'invoice?txnId=' + SI_Wrapper.InvoiceQBId;
                buildertek__Billings__c Invoice = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QB_Invoice_Number__c	, buildertek__QBO_Tax_Rate__c,buildertek__QBO_Tax_Rate_ID__c, buildertek__QB_Invoice_URL__c,buildertek__QB_Integration_Response_Message__c FROM buildertek__Billings__c WHERE ID =: SI_Wrapper.SI.Id LIMIT 1];
                Invoice.buildertek__QB_Id__c = SI_Wrapper.InvoiceQBId;
                Invoice.buildertek__QBO_Tax_Rate_ID__c = SI_Wrapper.taxCodeId;
                Invoice.buildertek__QBO_Tax_Rate__c = SI_Wrapper.taxRateValue;
                Invoice.buildertek__QB_Invoice_URL__c = qbInvoiceURL;
                Invoice.buildertek__QBO_Term_Id__c = SI_Wrapper.TermQBId;
                Invoice.buildertek__QB_Invoice_Number__c = SI_Wrapper.QbInvNumber;
                Invoice.buildertek__QBO_SyncToken__c = SI_Wrapper.QBInvSyncTocken;
                Invoice.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';

                update Invoice;
            } catch (Exception e) {
                System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void UpdateReceipt(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                system.debug('Receipt going to Update');
                String qbPaymentURL = SI_Wrapper.QBMetadata.buildertek__Qb_URL__c + 'recvpayment?txnId=' + SI_Wrapper.receiptQBID;
                buildertek__Receipt__c receipt = [SELECT Id, Name , buildertek__QB_Id__c, buildertek__QB_Receipt_URL__c,buildertek__QB_Integration_Response_Message__c,buildertek__QBO_SyncToken__c FROM buildertek__Receipt__c WHERE ID =:SI_Wrapper.receiptID LIMIT 1];
                receipt.buildertek__QB_Id__c = SI_Wrapper.receiptQBID;
                receipt.buildertek__QBO_SyncToken__c = SI_Wrapper.SyncToken;
                receipt.buildertek__QB_Receipt_URL__c = qbPaymentURL;
                receipt.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
                update receipt;
            } catch (Exception e) {
                System.debug('Error in UpdateReceipt : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
            // ..... ....... ........... .......... ............. Update Records Utility Methods - END ...... ........ ......... ......... .............

        public static void Query_QB_Record(QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper){
            try {
                sObject sObj = SI_Wrapper.SI;
                String QBObject;
                String QBId;
                if(SI_Wrapper.SyncObjName == 'buildertek__Billings__c'){
                    // If Sync tocken misatch for customer in sales invoice flow... Query Customer from QB
                    if(SI_Wrapper.QueryCustomer_VendorFlag == true){
                        QBId = SI_Wrapper.acc.buildertek__QB_Id__c;
                        if(SI_Wrapper.acc.buildertek__QB_Type__c == 'Customer'){
                            QBObject = 'Customer';
                        }
                        else if(SI_Wrapper.acc.buildertek__QB_Type__c == 'Vendor'){
                            QBObject = 'Vendor';
                        }
                    }
                    else{
                        QBObject = 'Invoice';
                        QBId = string.valueOf(sObj.get('buildertek__QB_Id__c'));
                    }
                }
                else if(SI_Wrapper.SyncObjName == 'buildertek__Purchase_Order__c'){

                }
                else if(SI_Wrapper.SyncObjName == 'buildertek__Account_Payable__c'){

                }
                else if(SI_Wrapper.SyncObjName == 'buildertek__Account_Payable_Clone__c'){

                }
                else if(SI_Wrapper.SyncObjName == 'buildertek__Expense__c'){

                }
                else if(SI_Wrapper.SyncObjName == 'buildertek__Receipt__c'){
                    QBObject = 'Payment';
                    QBId = SI_Wrapper.receiptQBID;
                }
                else if(SI_Wrapper.SyncObjName == 'Account'){
                    QBId = SI_Wrapper.acc.buildertek__QB_Id__c;
                    if(SI_Wrapper.acc.buildertek__QB_Type__c == 'Customer'){
                        QBObject = 'Customer';
                    }
                    else if(SI_Wrapper.acc.buildertek__QB_Type__c == 'Vendor'){
                        QBObject = 'Vendor';
                    }
                }

                String ItemQuery = EncodingUtil.urlEncode('select * from ' +QBObject+ ' WHERE Id = \''+ QBId + '\'', 'UTF-8');
                string GET_Items_JSONBody = '/v3/company/' + SI_Wrapper.QBMetadata.buildertek__Company_Id__c + '/query?query=' + ItemQuery + '&minorversion='+ SI_Wrapper.QBMetadata.buildertek__minorversion__c;   
                HttpResponse GET_Items_Response = QBCallOutService.QBAPICallOut_GET(GET_Items_JSONBody, null);
                System.debug('GET_Items_Response.getStatusCode() : ' + GET_Items_Response.getStatusCode());
                System.debug('GET_Items_Response.getBody() : ' + GET_Items_Response.getBody());

                String SyncToken;
                if(GET_Items_Response.getStatusCode() == 200){
                    if(SI_Wrapper.SyncObjName == 'buildertek__Billings__c'){
                        if(SI_Wrapper.QueryCustomer_VendorFlag == true){
                            // Deserialize Customer...
                            String QB_Type = SI_Wrapper.acc.buildertek__QB_Type__c;
                            if(QB_Type == 'Customer'){
                                QBCustomerResponseJSON Query_Customer_Parse = QBCustomerResponseJSON.parse(GET_Items_Response.getBody());
                                if(Query_Customer_Parse.QueryResponse.Customer != null){
                                    System.debug('Query_Customer_Parse : '+ Query_Customer_Parse);
                                    list<QBCustomerResponseJSON.Customer> Customer = Query_Customer_Parse.QueryResponse.Customer;
                                    System.debug('Query_Bill_ Sync Token : ' + Customer[0].SyncToken);
                                    SI_Wrapper.SyncToken = Customer[0].SyncToken;
                                    SI_Wrapper.QueryCustomer_VendorFlag = false;            // Do not forget to make this variable false....
                                    sync_Customer_in_QB(SI_Wrapper);
                                }
                            }
                            else if(QB_Type == 'Vendor'){
    
                            }
                        }
                        else{
                            // Deserialize Invoice...
                            QBInvoiceResponseJSON Query_Invoice_Parse = QBInvoiceResponseJSON.parse(GET_Items_Response.getBody());
                            if(Query_Invoice_Parse.QueryResponse.totalCount != null){
                                list<QBInvoiceResponseJSON.Invoice> invoice = Query_Invoice_Parse.QueryResponse.Invoice;
                                SyncToken = invoice[0].SyncToken;
                                System.debug('Query_Invoice_ Sync Token : ' + SyncToken);
                                SI_Wrapper.SyncToken = invoice[0].SyncToken;
                                sync_invoice_in_QB(SI_Wrapper);
                            }
                        }
                    }
                    else if(SI_Wrapper.SyncObjName == 'buildertek__Purchase_Order__c'){
    
                    }
                    else if(SI_Wrapper.SyncObjName == 'buildertek__Account_Payable__c'){
                        QBBillResponseJSON Query_Bill_Parse = QBBillResponseJSON.parse(GET_Items_Response.getBody());
                        if(Query_Bill_Parse.QueryResponse.totalCount != null){
                            list<QBBillResponseJSON.Bill> bill = Query_Bill_Parse.QueryResponse.Bill;
                            System.debug('Query_Bill_ Sync Token : ' + bill[0].SyncToken);
                        }
                    }
                    else if(SI_Wrapper.SyncObjName == 'buildertek__Account_Payable_Clone__c'){
    
                    }
                    else if(SI_Wrapper.SyncObjName == 'buildertek__Expense__c'){
    
                    }
                    else if(SI_Wrapper.SyncObjName == 'buildertek__Receipt__c'){
                        QBObject = 'Payment';
                        QBId = SI_Wrapper.receiptQBID;
                        QBReceiptResponseJSON Query_Payment_Parse = QBReceiptResponseJSON.parse(GET_Items_Response.getBody());
                        if(Query_Payment_Parse.QueryResponse.Payment != null){
                            list<QBReceiptResponseJSON.Payment> Payment = Query_Payment_Parse.QueryResponse.Payment;
                            System.debug('Query_Bill_ Sync Token : ' + Payment[0].SyncToken);
                            SI_Wrapper.SyncToken = Payment[0].SyncToken;
                            sync_Payment_In_QB(SI_Wrapper);
                        }
                    }
                    else if(SI_Wrapper.SyncObjName == 'Account'){
                        String QB_Type = SI_Wrapper.acc.buildertek__QB_Type__c;
                        if(QB_Type == 'Customer'){
                            QBCustomerResponseJSON Query_Customer_Parse = QBCustomerResponseJSON.parse(GET_Items_Response.getBody());
                            if(Query_Customer_Parse.QueryResponse.Customer != null){
                                System.debug('Query_Customer_Parse : '+ Query_Customer_Parse);
                                list<QBCustomerResponseJSON.Customer> Customer = Query_Customer_Parse.QueryResponse.Customer;
                                System.debug('Query_Bill_ Sync Token : ' + Customer[0].SyncToken);
                                SI_Wrapper.SyncToken = Customer[0].SyncToken;
                                sync_Customer_in_QB(SI_Wrapper);
                            }
                        }
                        else if(QB_Type == 'Vendor'){

                        }
                    }
                }


            } catch (Exception e) {
                System.debug('Error in Query_QB_Record ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public class salesInvoiceFlow_Wrapper{
            public List<buildertek__Billable_Lines__c> SILines;
            public buildertek__Receipt__c receipt;
            public buildertek__Billings__c SI;
            public Map<Id, List<String>> lineIdsMap;
            public String QBId;
            public String SyncToken;
            public buildertek__QuickBooks_Setting__mdt QBMetadata;
            public String receiptID;
            public String taxCodeId;
            public Double taxRateValue;
            public String SyncObjName;
            public String InvoiceQBId;
            public string receiptQBID;
            public string QbInvNumber;
            public string QBInvSyncTocken;
            public String TermQBId;
            public Account acc;
            public Boolean QueryCustomer_VendorFlag = false;
         }

}