// integration Betweek Quickbook and Salsforce

public without sharing class QBIntegrationQueue {
    

    // Sync Contractor Inoivce and Payable Invoice with QB Bill API Callout Future Methods -- Starts ----
    @future(callout=true)
    public static void qb_ContactorInvoice_Flow_Callout(String COInvId, String SyncObjName){
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

            sync_Vendor_in_QB(vendor, QBMetadata, Get_Access_Token, CoInv, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in qb_ContactorInvoice_Flow_Callout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    @future(callout=true)
    public static void qb_PayableInvoice_Flow_Callout(String PayableId, String SyncObjName){
        try {
            buildertek__Account_Payable_Clone__c PayableInv = [SELECT Id, Name, buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QB_Integration_Response_Message__c,buildertek__Vendor__c FROM buildertek__Account_Payable_Clone__c WHERE Id =: PayableId LIMIT 1 ];
            Account vendor = null;
            if(PayableInv.buildertek__Vendor__c != null){
                vendor = [SELECT Id, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PayableInv.buildertek__Vendor__c LIMIT 1];
            }
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;

            sync_Vendor_in_QB(vendor, QBMetadata, Get_Access_Token, PayableInv, SyncObjName);
        } catch (Exception e) {
            System.debug('Error in qb_PayableInvoice_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    // Sync Contractor Inoivce and Payable Invoice with QB Bill API Callout Future Methods -- End ----

    //  Purchase Order QB Integration Flow - STARTS --------------
    @future(callout=true)
    public static void qb_PO_Flow_Callout(Id PORecordId, String SyncObjName){
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

            sync_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, PO, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in qb_PO_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void sync_PO_in_QB(buildertek__Purchase_Order__c PO, String VendorQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String SyncObjName){
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
                QBException.QB_response( PO_Response.getStatusCode(),  PO_Response.getBody(), 'QBPOIntegrationQueue', 'sync_PO_in_QB');
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
    //  Purchase Order QB Integration Flow - Ends --------

    //  Expense QB Integration Flow - Starts --------
    @future(callout=true)
    public static void qb_Expense_Flow_Callout(Id expenseRecordId, String SyncObjName){
        try {
            buildertek__Expense__c expense = [SELECT Id, Name, buildertek__Payment_Method__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Vendor__r.buildertek__BT_Account_Type__c, buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Total_Expense__c,buildertek__Tax_Rate__c FROM buildertek__Expense__c WHERE Id =: expenseRecordId LIMIT 1];
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

            // String SyncObjName = 'buildertek__Billings__c';

            // expenseFlow_Wrapper expense_Wrapper = new expenseFlow_Wrapper();
            // expense_Wrapper.ExpenseLines = expenseLines;
            // expense_Wrapper.Expense = expense;
            // expense_Wrapper.acc = acc;
            // expense_Wrapper.QBMetadata = QBMetadata;
            // expense_Wrapper.Get_Access_Token = Get_Access_Token;
            // // expense_Wrapper.receiptID = receiptID;
            // expense_Wrapper.SyncObjName = SyncObjName;
            // system.debug('expense_Wrapper : ' + expense_Wrapper);
            // sync_Vendor_in_QB(expense_Wrapper);
            sync_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, expense, SyncObjName);

        } catch (Exception e) {
            System.debug('Error in qb_Expense_Flow_Callout ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void sync_expense_in_QB(buildertek__Expense__c expense, String CustomerQBId,Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String PayMethodId, String SyncObjName){
        try {
            String Expense_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/purchase?minorversion=' + QBMetadata.buildertek__minorversion__c;
            String Expense_RequestBody = QBMap.mapExpenseDataBatch(expense, CustomerQBId, lineIdsMap, PayMethodId);
            System.debug('Expense_RequestBody >> ' + Expense_RequestBody);
            HttpResponse Expense_Response = QBCallOutService.QBAPICallOut(Expense_EndPoint , Expense_RequestBody, Get_Access_Token);
            
            system.debug('Expense API Status Code >> ' + Expense_Response.getStatusCode());
            system.debug('Expense Responce >> ' + Expense_Response.getBody());
            
            if(Expense_Response.getStatusCode() == 200){
                QBExpenseResponseJSON Invoice_Response_desr = QBExpenseResponseJSON.parse(Expense_Response.getBody());
                QBExpenseResponseJSON.Purchase invoice = new QBExpenseResponseJSON.Purchase();
                invoice = Invoice_Response_desr.Purchase;
                String InvoiceQBId = invoice.Id;
                // String QbInvNumber = invoice.DocNumber;
                String QBInvSyncTocken = invoice.SyncToken;
                // if(receiptID != null){
                //     sync_Payment_In_QB(InvoiceQBId, CustomerQBId, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
                // }
                UpdateExpense(expense.Id, InvoiceQBId, QBMetadata, QBInvSyncTocken, PayMethodId);
            }
            else{
                QBException.QB_response( Expense_Response.getStatusCode(),  Expense_Response.getBody(), 'QBIntegrationQueue', 'sync_invoice_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(Expense_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage = 'Error During Item Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateSalesInvoice_OnError(expense.Id, ErrorMessage);
                QBIntegrationQueue.UpdateRecord_OnError(expense.Id, ErrorMessage, SyncObjName);
            }

            
        } catch (Exception e) {
            System.debug('Error in Create_inoice_Payment_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }
    //  Expense QB Integration Flow - Ends --------
    

    // ------------------------------------------------------- Utility Class - Starts ---------------------------------------------------------------------------------------
    public static void sync_Vendor_in_QB(Account acc, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, sObject SObjRecord, String SyncObjName){
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
                sync_Lines_to_Items_in_QB(SObjRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName);
                UpdateAccount(acc.Id, VendorQBId, QBMetadata, SyncToken, 'Vendor');

            }
            else{
                QBException.QB_response( Vendor_Response.getStatusCode(),  Vendor_Response.getBody(), 'QBIntegrationQueue', 'sync_Vendor_in_QB');
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
            System.debug('Error in sync_Vendor_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            
        }
    }

    public static void sync_Lines_to_Items_in_QB(sObject SObejctRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, String SyncObjName){
        try {

            set<String> ItemsWithoutQBId = new set<String>();           // To Store Unique Name Of SF Lines.....
            List<sObject> ItemToSync = new List<sObject>();
            List<sObject> ItemList = new List<sObject>();
            
            // Sync Purchase Order Lines
            if(SyncObjName == 'buildertek__Purchase_Order__c'){
                ItemList = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Purchase invoice Lines....
                    buildertek__Purchase_Order_Item__c Items = (buildertek__Purchase_Order_Item__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemsWithoutQBId.add(Items.Name);
                        ItemToSync.add(Items);
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
                        ItemsWithoutQBId.add(Items.Name);
                        ItemToSync.add(Items);
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
                        ItemsWithoutQBId.add(Items.Name);
                        ItemToSync.add(Items);
                    }
                }
            }

            else if(SyncObjName == 'buildertek__Expense__c'){
                ItemList = [SELECT Id, Name, buildertek__BT_Expense__c,buildertek__BT_Expense__r.Name,buildertek__Total__c,buildertek__Description__c,buildertek__Quantity__c,buildertek__QB_Id__c,buildertek__QBO_Name__c,buildertek__QBO_SyncToken__c,buildertek__Price__c FROM buildertek__Expense_Line__c WHERE buildertek__BT_Expense__c =: SObejctRecord.Id];
                for(sObject Item : ItemList){
                    // Type casting --> sObject to Payable invoice Lines....
                    buildertek__Expense_Line__c Items = (buildertek__Expense_Line__c)Item;
                    if(Items.buildertek__QB_Id__c == null){
                        ItemsWithoutQBId.add(Items.Name);
                        ItemToSync.add(Items);
                    }
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
                        system.debug('No Of Duplicate Name Items In QB ' + queryRes.Item.size());
                    }
                }
                // -------- 
                map<String, QBBatchResJSON.Item> queryItems_Map = new map<String, QBBatchResJSON.Item>();   // For Furter Query and Filteration
                List<sObject> ItemstoCreate = new List<sObject>();  // List of SF Lines Without QB Id And Without Dupliacte Name (So These Are need to Create In QB)....
                map<String, sObject> ItemstoCreate_Map = new map<String, sObject>();
                Map<Id, QBBatchResJSON.Item> QBItemsToAssign_Map = new Map<Id, QBBatchResJSON.Item>(); // Map Of QB Dupliate Item Name and Duplicate Item QB Object...
                List<sObject> QBItemsToAssign = new List<sObject>();

                // IF SF Lines Are Not Synced With QB But Item With Duplicate Name Already Availabel In QB.... Then Use QB ID of That QB Items for SF Lines
                if(queryItemsList.size() > 0){
                    
                    for(QBBatchResJSON.Item queryItem : queryItemsList){
                        queryItems_Map.put(queryItem.Name, queryItem);
                    }
                    system.debug('Duplicate Name Items In QB' + queryItems_Map.keySet());

                    // Filter Duplicate Name SF Items And SF Items To Create IN QB...
                    for(sObject item : ItemToSync){

                        String ItemName = string.valueOf(item.get('Name'));
                        String DupliacteItemName = queryItems_Map.get(ItemName).Name;

                        if(ItemName != DupliacteItemName){
                            // QB Will create Only Unique name Items.. So we only add unique name Lines in Map
                            ItemstoCreate_Map.put(ItemName, item);
                        }
                        
                        
                    }

                    ItemstoCreate = ItemstoCreate_Map.values();

                    for(sObject item : ItemToSync){
                        String ItemName = string.valueOf(item.get('Name'));
                        Id CreteItemId;
                        if(ItemstoCreate_Map.keySet().size() > 0){
                            CreteItemId = ItemstoCreate_Map.get(ItemName).Id;
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
                    for(sObject item : ItemToSync){
                        String ItemName = string.valueOf(item.get('Name'));
                        ItemstoCreate_Map.put(ItemName, item);
                    }

                    for(sObject item : ItemToSync){
                        String ItemName = string.valueOf(item.get('Name'));
                        Id CreteItemId;
                        if(ItemstoCreate_Map.keySet().size() > 0){
                            CreteItemId = ItemstoCreate_Map.get(ItemName).Id;
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

                            Map<String, QBBatchResJSON.BatchItemResponse> NewCreatedItem_Map = new Map<String, QBBatchResJSON.BatchItemResponse>();
                            Map<Id, QBBatchResJSON.BatchItemResponse> NewCreatedItemToAssign_Map = new Map<Id, QBBatchResJSON.BatchItemResponse>();

                            for(QBBatchResJSON.BatchItemResponse batchItem : response.BatchItemResponse) {
                                if (batchItem != null && batchItem.Item != null && batchItem.bId != null) {
                                    NewCreatedItem_Map.put(batchItem.item.Name, batchItem);
                                }
                            }
                            system.debug(' --- NewCreatedItem_Map ---- : ' + NewCreatedItem_Map);

                            for(sObject item : QBItemsToAssign){
                                string ItemName = string.valueOf(item.get('Name'));
                                NewCreatedItemToAssign_Map.put(item.Id, NewCreatedItem_Map.get(ItemName));
                            }
                            system.debug(' --- NewCreatedItemToAssign_Map ---- : ' + NewCreatedItemToAssign_Map);
                            
                            for(sObject Item : ItemList){
                                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                                    buildertek__Purchase_Order_Item__c Items = (buildertek__Purchase_Order_Item__c)Item;

                                    // Assign QB Id to Dupliacte Name Lines...
                                    QBBatchResJSON.BatchItemResponse newCraetedItem = NewCreatedItemToAssign_Map.get(Items.Id);
                                    if(newCraetedItem != null){
                                        Items.buildertek__QB_Id__c = newCraetedItem.Item.Id;
                                        Items.buildertek__QBO_Name__c = newCraetedItem.Item.Name;
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
                                    QBBatchResJSON.BatchItemResponse newCraetedItem = NewCreatedItemToAssign_Map.get(Items.Id);
                                    if(newCraetedItem != null){
                                        Items.buildertek__QB_Id__c = newCraetedItem.Item.Id;
                                        Items.buildertek__QBO_Name__c = newCraetedItem.Item.Name;
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
                                    QBBatchResJSON.BatchItemResponse newCraetedItem = NewCreatedItemToAssign_Map.get(Items.Id);
                                    if(newCraetedItem != null){
                                        Items.buildertek__QB_Id__c = newCraetedItem.Item.Id;
                                        Items.buildertek__QBO_Name__c = newCraetedItem.Item.Name;
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
                                    QBBatchResJSON.BatchItemResponse newCraetedItem = NewCreatedItemToAssign_Map.get(Items.Id);
                                    if(newCraetedItem != null){
                                        Items.buildertek__QB_Id__c = newCraetedItem.Item.Id;
                                        Items.buildertek__QBO_Name__c = newCraetedItem.Item.Name;
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
                                    sync_PO_in_QB(PO, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                                    UpdatePOline(ItemList, lineIdsMap);
                                    
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                                    sync_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap);
                                    UpdateCOinvLines(ItemList, lineIdsMap);
                                }
                                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                                    String TermQBId = null;
                                    sync_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap,TermQBId, SyncObjName);
                                    UpdatePayinvLines(ItemList, lineIdsMap);
                                }
                                else if(SyncObjName == 'buildertek__Expense__c'){
                                    buildertek__Expense__c expense = (buildertek__Expense__c)SObejctRecord;
                                    // sync_expense_in_QB(expense, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                                    sync_PaymentMethod_in_QB(expense, VendorQBId, lineIdsMap, QBMetadata, Get_Access_Token, SyncObjName);
                                    UpdateExpenseline(ItemList, lineIdsMap);
                                }
                            }
                        }
                        else{
                            QBException.QB_response( Items_Response.getStatusCode(),  Items_Response.getBody(), 'QBIntegrationQueue', 'sync_item_in_QB');
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
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
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
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
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
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
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
                            QBBatchResJSON.Item QBDuplicateNameItem = QBItemsToAssign_Map.get(Items.Id);
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

                    if(lineIdsMap.size() > 0){
                        System.debug('lineIdsMap When Items To Create is NUll>> ' + lineIdsMap);
                        if(SyncObjName == 'buildertek__Purchase_Order__c'){
                            buildertek__Purchase_Order__c PO = (buildertek__Purchase_Order__c)SObejctRecord;
                            sync_PO_in_QB(PO, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                            UpdatePOline(ItemList, lineIdsMap);
                            
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable__c'){
                            sync_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap);
                            UpdateCOinvLines(ItemList, lineIdsMap);
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            String TermQBId = null;
                            sync_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap,TermQBId, SyncObjName);
                            UpdatePayinvLines(ItemList, lineIdsMap);
                        }
                        else if(SyncObjName == 'buildertek__Expense__c'){
                            buildertek__Expense__c expense = (buildertek__Expense__c)SObejctRecord;
                            // sync_expense_in_QB(expense, VendorQBId, lineIdsMap, QBMetadata,Get_Access_Token, SyncObjName);
                            sync_PaymentMethod_in_QB(expense, VendorQBId, lineIdsMap, QBMetadata, Get_Access_Token, SyncObjName);
                            UpdateExpenseline(ItemList, lineIdsMap);
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
                    else if(SyncObjName == 'buildertek__Expense__c'){
                        buildertek__Expense_Line__c record = (buildertek__Expense_Line__c)Item;
                        QBItemIdMap.put(record.Id, record.buildertek__QB_Id__c);
                        QBItemNameMap.put(record.Id, record.buildertek__QBO_Name__c);
                        UnitPriceMap.put(record.Id, record.buildertek__Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                        TotalPriceMap.put(record.Id, record.buildertek__Total__c);
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
                    sync_PO_in_QB(PO, VendorQBId, lineIdsMap1,QBMetadata, Get_Access_Token, SyncObjName);
                }
                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                    sync_Term_for_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, SyncObjName, lineIdsMap1);
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                    String TermQBId = null;
                    sync_Bill_in_QB(SObejctRecord, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap1 ,TermQBId, SyncObjName);
                }
                else if(SyncObjName == 'buildertek__Expense__c'){
                    buildertek__Expense__c expense = (buildertek__Expense__c)SObejctRecord;
                    // sync_expense_in_QB(expense, VendorQBId, lineIdsMap1, QBMetadata, Get_Access_Token, SyncObjName);
                    sync_PaymentMethod_in_QB(expense, VendorQBId, lineIdsMap1, QBMetadata, Get_Access_Token, SyncObjName);
                }
            }
            
        } catch (Exception e) {
            System.debug('Error in sync_Lines_to_Items_in_QB : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void sync_Term_for_Bill_in_QB(sObject SObejctRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, String SyncObjName, Map<Id, List<String>> lineIdsMap){
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
                            sync_Bill_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap, TermQBId, SyncObjName);
                        }
                        else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                            // If Brian Ask for Term then use this condition to create Term
                        }
                    }
                    else{
                        if(SyncObjName == 'buildertek__Account_Payable__c'){
                            // Create_CoInvLines_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, TermQBId, SyncObjName);
                            sync_Bill_in_QB(CoInv, VendorQBId, QBMetadata, Get_Access_Token, lineIdsMap, TermQBId, SyncObjName);
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
            System.debug('Error in sync_Term_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }

    public static void sync_Bill_in_QB(sObject SobjectRecord, String VendorQBId, buildertek__QuickBooks_Setting__mdt QBMetadata , boolean Get_Access_Token, Map<Id, List<String>> lineIdsMap, String TermQBId, String SyncObjName){
         // Create Bill from BT Contractor Invoice Or Payable Invoice based on SyncObjName...
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
                QBException.QB_response( QB_Bill_Response.getStatusCode(),  QB_Bill_Response.getBody(), 'QBIntegrationQueue', 'sync_Bill_in_QB');
                QBOErrorJSON Response_Error = QBOErrorJSON.parse(QB_Bill_Response.getBody());
                QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                falut = Response_Error.Fault;
                String ErrorMessage1 = 'Error During Bill Callout :- '+ ' Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                // UpdateContractorInvoice_OnError(CoInv.Id, ErrorMessage1);
                UpdateRecord_OnError(SobjectRecord.Id, ErrorMessage1, SyncObjName);
                
            }

        } catch (Exception e ) {
            System.debug('Error in sync_Bill_in_QB : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
        }
    }   
    // ------------------------------------------------------- Utility Class - End ---------------------------------------------------------------------------------------
    

    // >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Aura Enable Method - START <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
    @AuraEnabled
    public static String sync_Invoice_in_QB_AuraCallout(String recordId, String SyncObjName){
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
            else if(acc.buildertek__QB_Id__c == null && acc.buildertek__BT_Account_Type__c != 'Customer'){
                return 'account_type_not_customer';
            }
            else{
                string receiptID;
                QBIntegrationQueue_SIFlow.qb_Payment_Invoice_Flow_Callout(recordId, receiptID);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in Create_Customer_invoice_item_payment_in_QB_Using_Button : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Customer_In_QB_AuraCallout(String recordId, String SyncObjName){
        try {
           Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: recordId limit 1];
           buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
           Boolean Get_Access_Token = false;

               buildertek__Billings__c SI = null;
               List<buildertek__Billable_Lines__c> SILines = null;
               String receiptID = null;               
            //    QBIntegrationQueue_SIFlow.sync_Customer_in_QB(SILines, SI, acc, QBMetadata, Get_Access_Token, receiptID, SyncObjName);
            QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper SI_Wrapper = new QBIntegrationQueue_SIFlow.salesInvoiceFlow_Wrapper();
                    SI_Wrapper.SILines = SILines;
                    SI_Wrapper.SI = SI;
                    SI_Wrapper.acc = acc;
                    SI_Wrapper.QBMetadata = QBMetadata;
                    SI_Wrapper.Get_Access_Token = Get_Access_Token;
                    SI_Wrapper.receiptID = receiptID;
                    SI_Wrapper.SyncObjName = SyncObjName;
                    system.debug('SI_Wrapper AuraEnable: ' + SI_Wrapper);
            QBIntegrationQueue_SIFlow.sync_Customer_in_QB(SI_Wrapper);
               return 'Completed';
            
        } catch (Exception e) {
            System.debug('Error in sync_Customer_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Vendor_In_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            Account acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c, buildertek__QB_Record_URL__c, buildertek__QBO_SyncToken__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: recordId limit 1];
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Qb_URL__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            Boolean Get_Access_Token = false;
            sObject SObjRecord = acc;
            sync_Vendor_in_QB(acc, QBMetadata, Get_Access_Token, SObjRecord, SyncObjName);
            return 'Completed';

        } catch (Exception e) {
            System.debug('Error in sync_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Purchase_Order_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Purchase_Order__c PO = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__PO_Total__c,buildertek__Tax_Amount__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];

            Account acc = null;
            if(PO.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c,buildertek__BT_Account_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PO.buildertek__Vendor__c limit 1];
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
            else if(acc.buildertek__QB_Id__c == null && acc.buildertek__BT_Account_Type__c != 'Vendor'){
                return 'account_type_not_vendor';
            }
            else{
                string receiptID;
                qb_PO_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in sync_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Contractor_Invoice_to_Bill_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Account_Payable__c CoInv = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c,  buildertek__Terms__c FROM buildertek__Account_Payable__c WHERE Id =: recordId LIMIT 1];

            List<buildertek__Account_Payable_Item__c> COInvLines = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c FROM buildertek__Account_Payable_Item__c WHERE buildertek__Account_Payable__c =: CoInv.Id];

            Account acc = null;
            if(CoInv.buildertek__Purchase_Order__c != null){
                if(CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c != null){
                    acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__BT_Account_Type__c,buildertek__QB_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: CoInv.buildertek__Purchase_Order__r.buildertek__Vendor__c limit 1];
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
            else if(acc.buildertek__QB_Id__c == null && acc.buildertek__BT_Account_Type__c != 'Vendor'){
                return 'account_type_not_vendor';
            }
            else{
                qb_ContactorInvoice_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in sync_Contractor_Invoice_to_Bill_in_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Payable_Invoice_to_Bill_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Account_Payable_Clone__c PayableInv = [SELECT Id, Name, buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QB_Integration_Response_Message__c,buildertek__Vendor__c FROM buildertek__Account_Payable_Clone__c WHERE Id =: recordId LIMIT 1 ];

            List<buildertek__Account_Payable_Item_Clone__c> payableLines = [SELECT Id, Name , buildertek__QB_Id__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c,buildertek__QBO_Name__c, buildertek__Unit_Price__c,buildertek__Total_Price__c,buildertek__Quantity__c FROM buildertek__Account_Payable_Item_Clone__c WHERE buildertek__Account_Payable_Clone__c =: PayableInv.Id];

            Account acc = null;
            if(PayableInv.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QB_Type__c,buildertek__QBO_SyncToken__c,buildertek__BT_Account_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: PayableInv.buildertek__Vendor__c limit 1];
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
            else if(acc.buildertek__QB_Id__c == null && acc.buildertek__BT_Account_Type__c != 'Vendor'){
                return 'account_type_not_vendor';
            }
            else{
                qb_PayableInvoice_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in sync_Contractor_Invoice_to_Bill_in_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static string sync_Expense_in_QB_AuraCallout(String recordId, String SyncObjName){
        try {
            buildertek__Expense__c expense = [SELECT Id, Name, buildertek__Payment_Method__c, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Total_Expense__c,buildertek__Tax_Rate__c FROM buildertek__Expense__c WHERE Id =: recordId LIMIT 1];

            Account acc = null;
            if(expense.buildertek__Vendor__c != null){
                acc = [SELECT ID, Name,buildertek__Email_Address__c,Fax,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__QB_Type__c,buildertek__BT_Account_Type__c, Description,ShippingCity,ShippingStreet,ShippingState,ShippingPostalCode,ShippingLatitude,ShippingLongitude,ShippingCountry,Phone,BillingCity,BillingStreet,BillingState,BillingPostalCode,BillingLatitude,BillingLongitude,BillingCountry FROM Account WHERE Id =: expense.buildertek__Vendor__c limit 1];
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
            else if(expense.buildertek__Payment_Method__c == null){
                return 'payment_method_null';
            }
            else{
                qb_Expense_Flow_Callout(recordId, SyncObjName);
                return 'success';
            }
        } catch (Exception e) {
            System.debug('Error in sync_Vendor_In_QB_AuraCallout : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
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

        public static void UpdateExpenseline(list<buildertek__Expense_Line__c> expenseLine, Map<Id, List<String>> lineIdsMap){
            try {
                system.debug('Expense line going to Update');
    
                for (buildertek__Expense_Line__c record : expenseLine) {
                    // Check if the Salesforce ID exists in the mapping and update the QuickBooks ID
                    List<String> qbIdAndNameList = lineIdsMap.get(record.Id);
    
                    // Assuming the list contains QB ID and QB Name in index 0 and 1 respectively
                    if (qbIdAndNameList != null && qbIdAndNameList.size() >= 2) {
                        record.buildertek__QB_Id__c = qbIdAndNameList[0]; // Assign QuickBooks ID
                        record.buildertek__QBO_Name__c = qbIdAndNameList[1];
                        // Optionally, you can also use qbIdAndNameList[1] to access QuickBooks Name if needed
                    }
                }
    
                update expenseLine;
            } catch (Exception e) {
                System.debug('Error in UpdateSIline : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }
    
        public static void UpdateExpense(String invoice_Id, String QB_invoice_Id, buildertek__QuickBooks_Setting__mdt  QBMetadata, String QBInvSyncTocken, String PaymentMethodId){
            try {
                system.debug('sales Invoice going to Update');
                String qbInvoiceURL = QBMetadata.buildertek__Qb_URL__c + 'expense?txnId=' + QB_invoice_Id;
                buildertek__Expense__c Invoice = [SELECT Id, Name, buildertek__Vendor__c,buildertek__QB_Id__c,buildertek__QBO_SyncToken__c,buildertek__Project__r.buildertek__Customer__c,buildertek__Total_Expense__c,buildertek__Tax_Rate__c FROM buildertek__Expense__c WHERE ID =:invoice_Id LIMIT 1];
                Invoice.buildertek__QB_Id__c = QB_invoice_Id;
                Invoice.buildertek__QB_Record_URL__c = qbInvoiceURL;
                Invoice.buildertek__QB_Payment_Method_Id__c = PaymentMethodId;
                Invoice.buildertek__QBO_SyncToken__c = QBInvSyncTocken;
                Invoice.buildertek__QB_Integration_Response_Message__c = 'Integrated Successfully';
    
                update Invoice;
            } catch (Exception e) {
                System.debug('Error in UpdateSalesInvoice : ' + e.getMessage() +'\n'+ e + 'Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            }
        }

        public static void sync_PaymentMethod_in_QB(buildertek__Expense__c expense, String CustomerQBId, Map<Id, List<String>> lineIdsMap, buildertek__QuickBooks_Setting__mdt QBMetadata, Boolean Get_Access_Token, String SyncObjName){
        try {
            String paymentmethodId;
            String paymentmethodName;
            paymentmethodName = string.valueOf(expense.buildertek__Payment_Method__c);
             System.debug('paymentmethodName------>' + paymentmethodName);
            String encodedQueryParam = EncodingUtil.urlEncode('Select * From PaymentMethod Where Name = \''+paymentmethodName + '\'', 'UTF-8');

            String EndPoint_for_get_TaxRate_fromQB = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/query?query=' + encodedQueryParam + '&minorversion='+ QBMetadata.buildertek__minorversion__c; 

            HttpResponse get_PMId_from_QB_ResponseBody = QBCallOutService.QBAPICallOut_GET(EndPoint_for_get_TaxRate_fromQB, null,false);
                if(get_PMId_from_QB_ResponseBody.getStatusCode() == 200){
                    System.debug('get_PMId_from_QB_ResponseBody.getBody() :: ' + get_PMId_from_QB_ResponseBody.getBody());

                    QBPMQueryJSON get_PaymentMethod_from_QB_ResponseBody_Deser = QBPMQueryJSON.parse(get_PMId_from_QB_ResponseBody.getBody());
                    System.debug('get_PaymentMethod_from_QB_ResponseBody_Deser.QueryResponse >> ' + get_PaymentMethod_from_QB_ResponseBody_Deser.QueryResponse);
                    // Accessing Id and RateValue directly from the TaxRate instanceß
                    if(get_PaymentMethod_from_QB_ResponseBody_Deser.QueryResponse.PaymentMethod != null){
                        QBPMQueryJSON.PaymentMethod  getPaymentMethodDetail = get_PaymentMethod_from_QB_ResponseBody_Deser.QueryResponse.PaymentMethod[0];
                        System.debug('getPaymentMethodDetail----->' + getPaymentMethodDetail);
                        // TaxRate is already exist in QB
                        paymentmethodId = getPaymentMethodDetail.Id;
                        // paymentmethodName = expense.buildertek__Payment_Method__c;
                        System.debug('paymentmethodId -----> ' + paymentmethodId);
                        System.debug('paymentmethodName -----> ' + paymentmethodName);
                        System.debug('// Create Invoice with exsiting tax rate ID...');
                        sync_expense_in_QB(expense, CustomerQBId, lineIdsMap, QBMetadata, Get_Access_Token, paymentmethodId, SyncObjName);
                        
                    }
                    else{
                        // TaxRate is not exist in QB
                        System.debug('Creating New Payment Methid In QB');
                        paymentmethodId = null;
                        // paymentmethodName = null;
                        String PaymentMethod_EndPoint = '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/paymentmethod?minorversion=' + QBMetadata.buildertek__minorversion__c; 
                        String PaymentMethod_RequestBody = QBMap.mapPMData(paymentmethodName);
                        System.debug('PaymentMethod_RequestBody--> '+ PaymentMethod_RequestBody);           
                        HttpResponse PaymentMethod_ResponseBody = QBCallOutService.QBAPICallOut(PaymentMethod_EndPoint, PaymentMethod_RequestBody,false);
                        if(PaymentMethod_ResponseBody.getStatusCode() == 200){
                            System.debug('PaymentMethod_ResponseBody.getBody() :: '+ PaymentMethod_ResponseBody.getBody());
                            QBPMResponseJSON PaymentMethod_ResponseBody_Deser =  QBPMResponseJSON.parse(PaymentMethod_ResponseBody.getBody());
                            List<QBPMResponseJSON.PaymentMethod> PMDetails = new  List<QBPMResponseJSON.PaymentMethod>();
                            PMDetails.add(PaymentMethod_ResponseBody_Deser.PaymentMethod);
                            paymentmethodId = PMDetails[0].Id;
                            // paymentmethodName = PMDetails[0].RateValue;
                            sync_expense_in_QB(expense, CustomerQBId, lineIdsMap, QBMetadata, Get_Access_Token, paymentmethodId, SyncObjName);
                        }
                        else{
                            QBException.QB_response( PaymentMethod_ResponseBody.getStatusCode(),  PaymentMethod_ResponseBody.getBody(), 'QBIntegrationQueue', 'sync_PaymentMethod_in_QB');
                            QBOErrorJSON Response_Error = QBOErrorJSON.parse(PaymentMethod_ResponseBody.getBody());
                            QBOErrorJSON.Fault falut = new QBOErrorJSON.Fault();
                            falut = Response_Error.Fault;
                            String ErrorMessage = 'Error During Tax Rate Callout :- '+'Message : ' + falut.Error[0].Message +', Detail : '+ falut.Error[0].Detail;
                            // UpdateSalesInvoice_OnError(expense.Id, ErrorMessage);
                            QBIntegrationQueue.UpdateRecord_OnError(expense.Id, ErrorMessage, SyncObjName);
                        }
                    }
                }
                else{
                    QBException.QB_response( get_PMId_from_QB_ResponseBody.getStatusCode(),  get_PMId_from_QB_ResponseBody.getBody(), 'QBIntegrationQueue', 'sync_PaymentMethod_in_QB');
                }
            
        } catch (Exception e) {
            System.debug('Error in sync_TaxRate_in_QB ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
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


    
}