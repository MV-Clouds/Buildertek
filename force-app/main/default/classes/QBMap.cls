public without sharing class QBMap {

    public static String mapAccountData(Account acc, Integer a){
        String accId = acc.Id;
        String QBId = acc.buildertek__QB_Id__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        String AccountId = acc.Id;
        //Map given account fields
        // customer.CompanyName = acc.Name +' - '+AccountId.right(4).substring(0,4);
        customer.CompanyName = acc.Name;
        
        customer.Taxable = True; 
        customer.Notes = acc.Description;
        if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Id__c != ''){
            customer.Id = acc.buildertek__QB_Id__c;
            customer.SyncToken = acc.buildertek__QBO_SyncToken__c;
            customer.sparse = true;
        }
     
        //Create Shipping address
        QBCustomerJSON.ShipAddr shipAddy = new QBCustomerJSON.ShipAddr();
        shipAddy.City = acc.ShippingCity;
        shipAddy.Line1 = acc.ShippingStreet;
        shipAddy.CountrySubDivisionCode = acc.ShippingState;
        shipAddy.PostalCode = acc.ShippingPostalCode;
        shipAddy.Lat = String.valueOf(acc.ShippingLatitude);
        shipAddy.Long_x = String.valueOf(acc.ShippingLongitude);
        shipAddy.Country = acc.ShippingCountry;
        shipAddy.CountrySubDivisionCode = acc.ShippingCountry;
        customer.ShipAddr = shipAddy;

        customer.PrintOnCheckName = acc.Name;

        //Create Email Address
        QBCustomerJSON.PrimaryEmailAddr Addr = new QBCustomerJSON.PrimaryEmailAddr();
        Addr.Address = acc.buildertek__Email_Address__c;
        customer.PrimaryEmailAddr = Addr;

        // Create FAX
        QBCustomerJSON.Fax fax = new QBCustomerJSON.Fax();
        fax.FreeFormNumber = acc.Fax;
        customer.Fax = fax;

        //Create Primary Phone
        QBCustomerJSON.PrimaryPhone phone = new QBCustomerJSON.PrimaryPhone ();
        phone.FreeFormNumber = acc.Phone;
        customer.PrimaryPhone = phone;

        customer.Job = False;
        customer.IsProject = False;
        customer.DisplayName = acc.Name;

        //Create Billing Address
        QBCustomerJSON.BillAddr billAddy = new QBCustomerJSON.BillAddr();
        billAddy.City = acc.BillingCity;
        billAddy.Line1 = acc.BillingStreet;
        billAddy.CountrySubDivisionCode = acc.BillingState;
        billAddy.PostalCode = acc.BillingPostalCode;
        billAddy.Lat = String.valueOf(acc.BillingLatitude);
        billAddy.Long_x = String.valueOf(acc.BillingLongitude);
        billAddy.Country = acc.BillingCountry;
       // billAddy.CountrySubDivisionCode = acc.BillingCountry;
        customer.BillAddr = billAddy;
        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');
 
    }
    public static String  mapTaxRateData(buildertek__Billings__c SI){
        
        QBTaxCodeJSON tax = new QBTaxCodeJSON();
        // String taxName = 'Tax - ' + string.valueOf(SI.buildertek__Tax_Rate__c);
        // tax.TaxCode = 'Tax - ' + string.valueOf(SI.buildertek__Tax_Rate__c);	
        tax.TaxCode = (SI.buildertek__Tax_Rate__c != null) 
                ? 'Tax - ' + String.valueOf(SI.buildertek__Tax_Rate__c)
                : 'Tax - 0.0000';
	    tax.TaxRateDetails = new List<QBTaxCodeJSON.TaxRateDetails>();

        QBTaxCodeJSON.TaxRateDetails taxrate = new QBTaxCodeJSON.TaxRateDetails();
        taxrate.RateValue = (SI.buildertek__Tax_Rate__c != null) 
        ? 'Tax - ' + String.valueOf(SI.buildertek__Tax_Rate__c)
        : 'Tax - 0.0000';
        taxrate.TaxApplicableOn = 'Sales';
        taxrate.TaxAgencyId = '1';
        taxrate.TaxRateName = (SI.buildertek__Tax_Rate__c != null) 
        ? 'Tax - ' + String.valueOf(SI.buildertek__Tax_Rate__c)
        : 'Tax - 0.0000';
        tax.TaxRateDetails.add(taxrate);

        return JSON.serialize(tax);
    }

    // Sales Inovice line associated with "Product and Service" in Quickbook....
    public static String MapInvoiceLineToBatch(List<buildertek__Billable_Lines__c> SILine) {
        try {
            System.debug('\n in createProducts \n');
            QBBatchReqJSON BatchItemRequest = new QBBatchReqJSON();
            
            for (buildertek__Billable_Lines__c item : SILine) {
                String lineId = item.Id;
                String LineName = item.buildertek__Item_Name__c;
                Boolean taxable = true;
                DateTime yourDate = Datetime.now();
                Date invStartDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
                System.debug('item.Unit_Price__c >> ' + item.Unit_Price__c);
                Decimal UnitePrice = item.Unit_Price__c != null ? item.Unit_Price__c : 0;
                Decimal Quantity = item.buildertek__Quantity__c != null ? item.buildertek__Quantity__c : 0;
                BatchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    true, // Set TrackQtyOnHand as needed
                    LineName,
                    Quantity,
                    UnitePrice,
                    // item.buildertek__Total__c,
                    'Sales of Product Income',
                    '79', // Assuming a fixed value for income account value
                    invStartDate,
                    'Inventory',
                    taxable,
                    'Test acc',
                    '100',
                    'Cost of Goods Sold',
                    '80'
                );
            }
            
            // Now perform the API callout using QBBatchReqJSON class
            // createInvoiceLines(BatchItemRequest);
            return JSON.serialize(BatchItemRequest);
        } catch (Exception e) {
            System.debug('Exception in createProduct :: '  + e.getMessage());
            return null;
        }
    }

    public static String mapInvoiceDataBatch(buildertek__Billings__c inv, String CustomerId, Map<Id, List<String>> lineIdsMap, String taxCodeId, String TermQBId) {
        try {
            System.debug(' in mapInvoiceData method==> '+lineIdsMap);
            String invId = inv.Id;
            String invQBId = inv.buildertek__QB_Id__c;
            DateTime yourDate = Datetime.now();
            System.debug('Current Time  : ' + Datetime.now());
            System.debug('2 hours delay Time  : ' + Datetime.now().addHours(-8));
            
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
            QBInvoiceJSON invoice = new QBInvoiceJSON();

            if(inv.buildertek__QB_Id__c != null && inv.buildertek__QB_Id__c != ''){
                invoice.Id = inv.buildertek__QB_Id__c;
                invoice.sparse = true;
                invoice.SyncToken = inv.buildertek__QBO_SyncToken__c;
            }
            
            invoice.TotalAmt = inv.buildertek__Total_Amount_Tax__c;
            invoice.Balance = inv.buildertek__Total_Amount_Tax__c;
            invoice.TxnDate = txnDate;
            invoice.Line = new List<QBInvoiceJSON.line>();
    
            // Iterate through the lineIdsMap to add line items to invoice
            Integer lineNumber = 1;
            for (String lineId : lineIdsMap.keySet()) {
                List<String> qbIdAndNameList = lineIdsMap.get(lineId);
                String qbId = '';
                String qbName = '';
                String qbTotal = '';
                String qbQuantity = '';
                String qbUnitPrice = '';

                if (qbIdAndNameList != null) {
                    qbId = qbIdAndNameList[0]; // Retrieve QuickBooks ID
                    qbName = qbIdAndNameList[1]; // Retrieve QuickBooks Name
                    qbTotal = qbIdAndNameList[2] != null ? qbIdAndNameList[2] : '0'; // Retrive Item Total Value(SubTotal)
                    qbQuantity = qbIdAndNameList[3] != null ? qbIdAndNameList[3] : '0'; // Retrive Item Quantity
                    qbUnitPrice = qbIdAndNameList[4] != null ? qbIdAndNameList[4] : '0'; // Retrive Unite Prices
                }

                QBInvoiceJSON.line Linee = new QBInvoiceJSON.line();
                Linee.DetailType = 'SalesItemLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = string.ValueOf(lineNumber);
                Linee.LineNum =lineNumber;
                Linee.SalesItemLineDetail = new QBInvoiceJSON.SalesItemLineDetail();
                
                QBInvoiceJSON.SalesItemLineDetail SILD = new QBInvoiceJSON.SalesItemLineDetail();
                SILD.ItemRef = new QBInvoiceJSON.ItemRef();
                SILD.Qty = Double.valueOf(qbQuantity);
                SILD.UnitPrice = Double.valueOf(qbUnitPrice); 
                
                QBInvoiceJSON.ItemRef ItemRef = new QBInvoiceJSON.ItemRef();
                ItemRef.name = qbName;
                ItemRef.value = qbId; // Retrieve the line ID from the map

                if(taxCodeId != null){
                    QBInvoiceJSON.TxnTaxDetail TaxDetail = new QBInvoiceJSON.TxnTaxDetail();
                    QBInvoiceJSON.TxnTaxCodeRef taxCodeRef = new QBInvoiceJSON.TxnTaxCodeRef();
                    taxCodeRef.value = taxCodeId;
    
                    TaxDetail.TxnTaxCodeRef = taxCodeRef;
                    invoice.TxnTaxDetail = TaxDetail;
                }
                
                SILD.ItemRef = ItemRef;
                Linee.SalesItemLineDetail = SILD;
                invoice.Line.add(Linee);
                
                lineNumber++;
            }
            
            invoice.CustomerRef = new QBInvoiceJSON.CustomerRef();
            QBInvoiceJSON.CustomerRef customer = new QBInvoiceJSON.CustomerRef();
            customer.value = CustomerId;
            invoice.CustomerRef = customer;

            QBInvoiceJSON.SalesTermRef term = new QBInvoiceJSON.SalesTermRef();
            term.value = TermQBId;
            invoice.SalesTermRef = term;
            
            // System.debug('Invoice request Body :: ' + JSON.serialize(invoice, True).replace('"Long_x":', '"Long":'));
            
            return JSON.serialize(invoice, True).replace('"Long_x":', '"Long":');
        } catch (Exception e) {
            System.debug('exception in mapInvoiceData :: ' + e.getMessage());
            return null;
        }
    }
    
    public static string mapReceipt_PaymetData(buildertek__Receipt__c receipt, String CustomerId, String invoiceQBOID){
        try {

            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));

            QBReceiptJSON QBPayment = new QBReceiptJSON();
            System.debug('PAyment Amount :: ' + receipt.buildertek__Amount__c );
            if(receipt.buildertek__Amount__c == null ){
                QBPayment.TotalAmt = 0;
            }
            else{
                QBPayment.TotalAmt = receipt.buildertek__Amount__c;
            }
            QBPayment.TxnDate = txnDate;
            QBPayment.CustomerRef = new QBReceiptJSON.CustomerRef();
            QBPayment.Line = new list<QBReceiptJSON.Line>();  

            QBReceiptJSON.CustomerRef QBPayment_cust = new QBReceiptJSON.CustomerRef();
            QBPayment_cust.value = CustomerId;
            QBPayment.CustomerRef = QBPayment_cust;

            QBReceiptJSON.Line line = new QBReceiptJSON.Line();
            line.Amount = receipt.buildertek__Amount__c;
            line.LinkedTxn = new list<QBReceiptJSON.LinkedTxn>();

            QBReceiptJSON.LinkedTxn linkedLine = new QBReceiptJSON.LinkedTxn();
            linkedLine.TxnType = 'Invoice';
            linkedLine.TxnId = invoiceQBOID;

            line.LinkedTxn.add(linkedLine);
            QBPayment.Line.add(line);

            return JSON.serialize(QBPayment, True);
        } catch (Exception e ) {
            system.debug('error in mapReceipt_PaymetData >> ' + e.getMessage() +'\n'+ e );
            return null;
        }
    }

    // ---------------------------------------------------------------------------------------------------------

    public static String mapVendorAccountData(Account acc){
        String accId = acc.Id;
        QBVendorJSON Vendor = new QBVendorJSON();
        
        String AccountId = acc.Id;
        //Map given account fields
        // Vendor.CompanyName = acc.Name +' - '+AccountId.right(4).substring(0,4);
        Vendor.CompanyName = acc.Name;
        Vendor.Active = true;  

        // If QB Id is Not Null, Update Vendor in QB Else Create New Vendor In QB.....
        if(acc.buildertek__QB_Id__c != null && acc.buildertek__QB_Id__c != ''){
            Vendor.Id = acc.buildertek__QB_Id__c;
            Vendor.SyncToken = acc.buildertek__QBO_SyncToken__c;
            Vendor.sparse = true;
        }
     
        //Create Shipping address
        QBVendorJSON.BillAddr BillAddr = new QBVendorJSON.BillAddr();
        BillAddr.City = acc.BillingCity;
        BillAddr.Line1 = acc.BillingStreet;
        BillAddr.CountrySubDivisionCode = acc.BillingState;
        BillAddr.PostalCode = acc.BillingPostalCode;
        BillAddr.Lat = String.valueOf(acc.BillingLatitude);
        BillAddr.Long_x = String.valueOf(acc.BillingLongitude);
        BillAddr.CountrySubDivisionCode = acc.BillingCountry;
        Vendor.BillAddr = BillAddr;

        Vendor.PrintOnCheckName = acc.Name;

        //Create Email Address
        QBVendorJSON.PrimaryEmailAddr Addr = new QBVendorJSON.PrimaryEmailAddr();
        Addr.Address = acc.buildertek__Email_Address__c;
        Vendor.PrimaryEmailAddr = Addr;

        //Create Primary Phone
        QBVendorJSON.PrimaryPhone phone = new QBVendorJSON.PrimaryPhone ();
        phone.FreeFormNumber = acc.Phone;
        Vendor.PrimaryPhone = phone;
        Vendor.DisplayName = acc.Name;

        return JSON.serialize(Vendor, True).replace('"Long_x":', '"Long":');
    }

    // Line associated with "Product and Service" in Quickbook....
    public static String MapItemDataToBatch(List<sObject> sObjectItemList, String SyncObjName) {
        try {
            System.debug('\n in MapItemDataToBatch \n');
            QBBatchReqJSON BatchItemRequest = new QBBatchReqJSON();
            List<sObject> ItemList = new List<sObject>();

            Map<Id, String> NameMap = new Map<Id, String>();
            Map<Id, Decimal> UnitPriceMap = new Map<Id, Decimal>();
            Map<Id, Decimal> QuantityMap = new Map<Id, Decimal>();

            for(sObject Item : sObjectItemList){
                // Type conversation from sObject to Generic Object....
                // Store Field Data Into Respective Map....
                if(SyncObjName == 'buildertek__Purchase_Order__c'){
                        buildertek__Purchase_Order_Item__c record = (buildertek__Purchase_Order_Item__c)Item;
                        NameMap.put(record.Id, record.Name);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                }
                else if(SyncObjName == 'buildertek__Account_Payable__c'){
                        buildertek__Account_Payable_Item__c record = (buildertek__Account_Payable_Item__c)Item;
                        NameMap.put(record.Id, record.Name);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                }
                else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                        buildertek__Account_Payable_Item_Clone__c record = (buildertek__Account_Payable_Item_Clone__c)Item;
                        NameMap.put(record.Id, record.Name);
                        UnitPriceMap.put(record.Id, record.buildertek__Unit_Price__c);
                        QuantityMap.put(record.Id, record.buildertek__Quantity__c);
                }
                else if(SyncObjName == 'buildertek__Expense__c'){
                    buildertek__Expense_Line__c record = (buildertek__Expense_Line__c)Item;
                    String itemName = record.buildertek__Product_Description__c;
                    NameMap.put(record.Id, itemName);
                    UnitPriceMap.put(record.Id, record.buildertek__Price__c);
                    QuantityMap.put(record.Id, record.buildertek__Quantity__c);
            }
            }
            
            // Creating a Batch
            for (sObject item : sObjectItemList) {
                Boolean taxable = true;
                Boolean TrackQtyOnHand = true;
                DateTime yourDate = Datetime.now();
                Date invStartDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
                // System.debug('item.Unit_Price__c >> ' + item.buildertek__Unit_Price__c	);
                String Name = NameMap.get(item.Id);
                Decimal UnitePrice = UnitPriceMap.get(item.Id) != null ? UnitPriceMap.get(item.Id) : 0;
                Decimal Quantity = QuantityMap.get(item.Id) != null ? QuantityMap.get(item.Id) : 0;
                BatchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    TrackQtyOnHand, // Set TrackQtyOnHand as needed
                    Name,
                    Quantity,
                    UnitePrice,
                    // item.buildertek__Total__c,
                    'Sales of Product Income',
                    '79', // Assuming a fixed value for income account value
                    invStartDate,
                    'Inventory',
                    taxable,
                    'Test acc',
                    '100',  // Assuming a fixed value for Asset account value
                    'Cost of Goods Sold',
                    '80'    // Assuming a fixed value for Expense account value
                );
            }
            return JSON.serialize(BatchItemRequest);
        } catch (Exception e) {
            System.debug('Exception in MapItemDataToBatch :: '  + e.getMessage());
            System.debug('Error in MapItemDataToBatch ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            return null;
        }
    }

    // Map Contractor Invoice Data or Payable Invoice Data......
    public static String mapQBBillData(sObject SOBJ, Map<Id, List<String>> lineIdsMap, String VendorQBId, String TermQBId, String SyncObjName){
        try {
            String QBOID = null;
            String QBSyncToken = null;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));

            if(SyncObjName == 'buildertek__Account_Payable__c'){
                buildertek__Account_Payable__c record = (buildertek__Account_Payable__c)SOBJ;
                QBOID = record.buildertek__QB_Id__c;
                QBSyncToken = record.buildertek__QBO_SyncToken__c;
            }
            else if(SyncObjName == 'buildertek__Account_Payable_Clone__c'){
                buildertek__Account_Payable_Clone__c record = (buildertek__Account_Payable_Clone__c)SOBJ;
                QBOID = record.buildertek__QB_Id__c;
                QBSyncToken = record.buildertek__QBO_SyncToken__c;
            }

            QBBillReqJSON QbBill = new QBBillReqJSON();
            if(QBOID != null && QBOID != ''){
                QbBill.Id = QBOID;
                QbBill.sparse = true;
                QbBill.SyncToken = QBSyncToken;
            }

            QBBillReqJSON.VendorRef vendor = new QBBillReqJSON.VendorRef();
            vendor.value = VendorQBId;
            QbBill.VendorRef = vendor;
            QbBill.TxnDate = txnDate;

            QBBillReqJSON.SalesTermRef term = new QBBillReqJSON.SalesTermRef();
            term.value = TermQBId;
            QbBill.SalesTermRef = term;
            
            QbBill.Line = new list<QBBillReqJSON.Line>();
            Integer lineNumber = 1;
            for(String LineId : lineIdsMap.keySet()){
                List<String> qbIdAndNameList = lineIdsMap.get(lineId);
                String qbId = '';
                String qbName = '';
                String qbTotal = '';
                String qbQuantity = '';
                String qbUnitPrice = '';
                
                if (qbIdAndNameList != null) {
                    qbId = qbIdAndNameList[0]; // Retrieve QuickBooks ID
                    qbName = qbIdAndNameList[1]; // Retrieve QuickBooks Name
                    qbTotal = qbIdAndNameList[2] != null ? qbIdAndNameList[2] : '0'; // Retrive Item Total Value(SubTotal)
                    qbQuantity = qbIdAndNameList[3] != null ? qbIdAndNameList[3] : '0'; // Retrive Item Quantity
                    qbUnitPrice = qbIdAndNameList[4] != null ? qbIdAndNameList[4] : '0'; // Retrive Unite Prices
                }
                
                QBBillReqJSON.Line Linee = new QBBillReqJSON.Line();
                Linee.DetailType = 'ItemBasedExpenseLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = string.ValueOf(lineNumber);
                // Linee.ItemBasedExpenseLineDetail = new QBPOJSON.ItemBasedExpenseLineDetail();
                
                QBBillReqJSON.ItemBasedExpenseLineDetail POLD = new QBBillReqJSON.ItemBasedExpenseLineDetail();
                POLD.ItemRef = new QBBillReqJSON.ItemRef();
                POLD.Qty = Double.valueOf(qbQuantity);
                POLD.UnitPrice = Double.valueOf(qbUnitPrice);
                
                QBBillReqJSON.ItemRef ItemRef = new QBBillReqJSON.ItemRef();
                ItemRef.name = qbName;
                ItemRef.value = qbId; // Retrieve the line ID from the map
                
                POLD.ItemRef = ItemRef;
                Linee.ItemBasedExpenseLineDetail = POLD;
                QbBill.Line.add(Linee);
                
                lineNumber++;
            }
    
            return JSON.serialize(QbBill);
        } catch (Exception e) {
            System.debug('Exception in mapQBBillData :: '  + e.getMessage());
            System.debug('Error in mapQBBillData ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            return null;
        }
    }

    public static String mapPODataBatch(buildertek__Purchase_Order__c inv, String VendorQBId, Map<Id, List<String>> lineIdsMap) {
        try {
            System.debug(' in mapPODataBatch method');
            String invId = inv.Id;
            String invQBId = inv.buildertek__QB_Id__c;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));

            QBPOJSON purchaseorder = new QBPOJSON();

            if(inv.buildertek__QB_Id__c != null && inv.buildertek__QB_Id__c != ''){
                purchaseorder.Id = inv.buildertek__QB_Id__c;
                purchaseorder.sparse = true;
                purchaseorder.SyncToken = inv.buildertek__QBO_SyncToken__c;
            }
            
            purchaseorder.TotalAmt = inv.buildertek__PO_Total__c;
            purchaseorder.TxnDate = txnDate;
            purchaseorder.Line = new List<QBPOJSON.line>();
    
            // Iterate through the lineIdsMap to add line items to purchaseorder
            Integer lineNumber = 1;
            for (String lineId : lineIdsMap.keySet()) {
                List<String> qbIdAndNameList = lineIdsMap.get(lineId);
                String qbId = '';
                String qbName = '';
                String qbTotal = '';
                String qbQuantity = '';
                String qbUnitPrice = '';

                if (qbIdAndNameList != null) {
                    qbId = qbIdAndNameList[0]; // Retrieve QuickBooks ID
                    qbName = qbIdAndNameList[1]; // Retrieve QuickBooks Name
                    qbTotal = qbIdAndNameList[2] != null ? qbIdAndNameList[2] : '0'; // Retrive Item Total Value(SubTotal)
                    qbQuantity = qbIdAndNameList[3] != null ? qbIdAndNameList[3] : '0'; // Retrive Item Quantity
                    qbUnitPrice = qbIdAndNameList[4] != null ? qbIdAndNameList[4] : '0'; // Retrive Unite Prices
                }

                QBPOJSON.line Linee = new QBPOJSON.line();
                Linee.DetailType = 'ItemBasedExpenseLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = string.ValueOf(lineNumber);
                // Linee.LineNum =lineNumber;
                Linee.ItemBasedExpenseLineDetail = new QBPOJSON.ItemBasedExpenseLineDetail();
                
                QBPOJSON.ItemBasedExpenseLineDetail POLD = new QBPOJSON.ItemBasedExpenseLineDetail();
                POLD.ItemRef = new QBPOJSON.ItemRef();
                POLD.Qty = Double.valueOf(qbQuantity);
                POLD.UnitPrice = Double.valueOf(qbUnitPrice);
                
                QBPOJSON.ItemRef ItemRef = new QBPOJSON.ItemRef();
                ItemRef.name = qbName;
                ItemRef.value = qbId; // Retrieve the line ID from the map
                
                POLD.ItemRef = ItemRef;
                Linee.ItemBasedExpenseLineDetail = POLD;
                purchaseorder.Line.add(Linee);
                
                lineNumber++;
            }
            
            QBPOJSON.VendorRef vendor = new QBPOJSON.VendorRef();
            vendor.value = VendorQBId;
            purchaseorder.VendorRef = vendor;
            
            return JSON.serialize(purchaseorder, True).replace('"Long_x":', '"Long":');
        } catch (Exception e) {
            System.debug('exception in mappurchaseorderData :: ' + e.getMessage());
            return null;
        }
    }

    public static String mapExpenseDataBatch(buildertek__Expense__c expense, String VendorQBId, Map<Id, List<String>> lineIdsMap, String PayMethodId) {
        try {
            System.debug('karan test---> ' + expense);
            System.debug('karan test1---> ' + lineIdsMap);
            System.debug('VendorQBId---> ' + VendorQBId);
            String QBOID = null;
            String QBSyncToken = null;
            String paymenttype = null;
            String vendorname = expense.buildertek__Vendor__r.Name;
            String vendortype = expense.buildertek__Vendor__r.buildertek__BT_Account_Type__c;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
    
            QBOID = expense.buildertek__QB_Id__c;
            QBSyncToken = expense.buildertek__QBO_SyncToken__c;
            paymenttype = 'CreditCard';
    
            QBExpenseJSON QbExpense = new QBExpenseJSON();
            if (QBOID != null && QBOID != '') {
                QbExpense.Id = QBOID;
                QbExpense.sparse = true;
                QbExpense.SyncToken = QBSyncToken;
            }
            QbExpense.PaymentType = paymenttype;
            QbExpense.TxnDate = txnDate;

            QBExpenseJSON.AccountRef AccRef2 = new QBExpenseJSON.AccountRef();
            AccRef2.name = 'Visa'; // Replace with the actual value
            AccRef2.value = '42';
            QbExpense.AccountRef = AccRef2;

            QBExpenseJSON.EntityRef Vendorinfo = new QBExpenseJSON.EntityRef();
            Vendorinfo.name = vendorname; // Replace with the actual value
            Vendorinfo.value = VendorQBId;
            Vendorinfo.type = vendortype;
            QbExpense.EntityRef = Vendorinfo;

            QBExpenseJSON.PaymentMethodRef paymethod = new QBExpenseJSON.PaymentMethodRef();
            paymethod.value = PayMethodId;
            QbExpense.PaymentMethodRef = paymethod;
    
            // QbExpense.CustomField = new List<String>{'CustomField1', 'CustomField2'};
    
            // Assuming you want to set values for PurchaseEx
            // QbExpense.PurchaseEx = new QBExpenseJSON.PurchaseEx();
            // QbExpense.PurchaseEx.any_y = new List<QBExpenseJSON.any_y>();
            // QBExpenseJSON.any_y anyY = new QBExpenseJSON.any_y();
            // anyY.value = new QBExpenseJSON.value();
            // anyY.value.Value = 'AnyValue'; // Replace with actual value
            // QbExpense.PurchaseEx.any_y.add(anyY);
    
            QbExpense.Line = new List<QBExpenseJSON.Line>();
            Integer lineNumber = 1;
            for (String LineId : lineIdsMap.keySet()) {
                List<String> qbIdAndNameList = lineIdsMap.get(LineId);
    
                String qbId = '';
                String qbName = '';
                String qbTotal = '';
                String qbQuantity = '';
                String qbUnitPrice = '';
    
                if (qbIdAndNameList != null) {
                    qbId = qbIdAndNameList[0]; // Retrieve QuickBooks ID
                    qbName = qbIdAndNameList[1]; // Retrieve QuickBooks Name
                    qbTotal = qbIdAndNameList[2] != null ? qbIdAndNameList[2] : '0'; // Retrive Item Total Value(SubTotal)
                    qbQuantity = qbIdAndNameList[3] != null ? qbIdAndNameList[3] : '0'; // Retrive Item Quantity
                    qbUnitPrice = qbIdAndNameList[4] != null ? qbIdAndNameList[4] : '0'; // Retrive Unite Prices
                }
    
                QBExpenseJSON.Line Linee = new QBExpenseJSON.Line();
                Linee.DetailType = 'ItemBasedExpenseLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = String.valueOf(lineNumber);
                Linee.ItemBasedExpenseLineDetail = new QBExpenseJSON.ItemBasedExpenseLineDetail();
    
                QBExpenseJSON.ItemBasedExpenseLineDetail POLD = new QBExpenseJSON.ItemBasedExpenseLineDetail();
                POLD.ItemRef = new QBExpenseJSON.ItemRef();
                POLD.Qty = Double.valueOf(qbQuantity);
                POLD.UnitPrice = Double.valueOf(qbUnitPrice);
    
                POLD.ItemRef.name = qbName;
                POLD.ItemRef.value = qbId;
    
                // Assuming you want to set values for TaxCodeRef
                POLD.TaxCodeRef = new QBExpenseJSON.TaxCodeRef();
                POLD.TaxCodeRef.value = 'NON'; // Replace with the actual value
    
                // Assuming you want to set other fields in AccountBasedExpenseLineDetail
                POLD.BillableStatus = 'NotBillable'; // Replace with the actual value
    
                Linee.ItemBasedExpenseLineDetail = POLD;
                QbExpense.Line.add(Linee);
    
                lineNumber++;
            }
    
            // Serialize the final QBExpense object to JSON
            return JSON.serialize(QbExpense).replace('"any_y":', '"any":');
        } catch (Exception e) {
            System.debug('Exception in mapQBBillData :: ' + e.getMessage());
            return null;
        }
    }    

    public static String mapPMData(String pmname){

        QBPMCreateJSON paymentMethod = new QBPMCreateJSON();
        paymentMethod.Name = pmname;
        paymentMethod.Active = true;

        return JSON.serialize(paymentMethod);
    }
}