public without sharing class QBMap {

    public static String mapAccountData(Account acc, Integer a){
        String accId = acc.Id;
        String QBId = acc.buildertek__QBO_ID__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        String AccountId = acc.Id;
        //Map given account fields
        customer.CompanyName = acc.Name +' - '+AccountId.right(4).substring(0,4);
        customer.Taxable = True; 
        customer.Notes = acc.Description;
        if(acc.buildertek__QBO_ID__c != null && acc.buildertek__QBO_ID__c != ''){
            customer.Id = acc.buildertek__QBO_ID__c;
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
        tax.TaxCode = 'Tax - ' + string.valueOf(SI.buildertek__Tax_Rate__c);	
	    tax.TaxRateDetails = new List<QBTaxCodeJSON.TaxRateDetails>();

        QBTaxCodeJSON.TaxRateDetails taxrate = new QBTaxCodeJSON.TaxRateDetails();
        taxrate.RateValue = string.valueOf(SI.buildertek__Tax_Rate__c);
        taxrate.TaxApplicableOn = 'Sales';
        taxrate.TaxAgencyId = '1';
        taxrate.TaxRateName = 'Tax - ' + string.valueOf(SI.buildertek__Tax_Rate__c);
        tax.TaxRateDetails.add(taxrate);

        return JSON.serialize(tax);
    }

    public static String MapInvoiceLineToBatch(List<buildertek__Billable_Lines__c> SILine) {
        try {
            System.debug('\n in createProducts \n');
            QBBatchReqJSON batchItemRequest = new QBBatchReqJSON();
            
            for (buildertek__Billable_Lines__c item : SILine) {
                String lineId = item.Id;
                Boolean taxable = true;
                DateTime yourDate = Datetime.now();
                Date invStartDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
                System.debug('item.Unit_Price__c >> ' + item.Unit_Price__c);
                Decimal UnitePrice = item.Unit_Price__c != null ? item.Unit_Price__c : 0;
                batchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    true, // Set TrackQtyOnHand as needed
                    item.buildertek__Item_Name__c +'-'+ item.Name,
                    item.buildertek__Quantity__c,
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
            // createInvoiceLines(batchItemRequest);
            return JSON.serialize(batchItemRequest);
        } catch (Exception e) {
            System.debug('Exception in createProduct :: '  + e.getMessage());
            return null;
        }
    }

    public static String mapInvoiceDataBatch(buildertek__Billings__c inv, String CustomerId, Map<Id, List<String>> lineIdsMap, String taxCodeId, String TermQBId) {
        try {
            System.debug(' in mapInvoiceData method');
            String invId = inv.Id;
            String invQBId = inv.QBO_ID__c;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
            QBInvoiceJSON invoice = new QBInvoiceJSON();

            if(inv.buildertek__QBO_ID__c != null && inv.buildertek__QBO_ID__c != ''){
                invoice.Id = inv.buildertek__QBO_ID__c;
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
                    qbTotal = qbIdAndNameList[2];
                    qbQuantity = qbIdAndNameList[3];
                    qbUnitPrice = qbIdAndNameList[4];
                }

                QBInvoiceJSON.line Linee = new QBInvoiceJSON.line();
                Linee.DetailType = 'SalesItemLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = qbId;
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
    
    public static string mapReceipt_PaymetData(buildertek__Receipt__c receipt, String CustomerId, String invoiceQBID){
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
            linkedLine.TxnId = invoiceQBID;

            line.LinkedTxn.add(linkedLine);
            QBPayment.Line.add(line);

            return JSON.serialize(QBPayment, True);
        } catch (Exception e ) {
            system.debug('error in mapReceipt_PaymetData >> ' + e.getMessage() +'\n'+ e );
            return null;
        }
    }

    public static String mapVendorAccountData(Account acc){
        String accId = acc.Id;
        QBVendorJSON Vendor = new QBVendorJSON();
        
        String AccountId = acc.Id;
        //Map given account fields
        Vendor.CompanyName = acc.Name +' - '+AccountId.right(4).substring(0,4);
        Vendor.Active = true;  

        // If QB Id is Not Null, Update Vendor in QB Else Create New Vendor In QB.....
        if(acc.buildertek__QBO_ID__c != null && acc.buildertek__QBO_ID__c != ''){
            Vendor.Id = acc.buildertek__QBO_ID__c;
            Vendor.SyncToken = acc.buildertek__QBO_SyncToken__c;
            Vendor.sparse = true;
        }
     
        //Create Shipping address
        QBVendorJSON.BillAddr BillAddr = new QBVendorJSON.BillAddr();
        BillAddr.City = acc.ShippingCity;
        BillAddr.Line1 = acc.ShippingStreet;
        BillAddr.CountrySubDivisionCode = acc.ShippingState;
        BillAddr.PostalCode = acc.ShippingPostalCode;
        BillAddr.Lat = String.valueOf(acc.ShippingLatitude);
        BillAddr.Long_x = String.valueOf(acc.ShippingLongitude);
        BillAddr.CountrySubDivisionCode = acc.ShippingCountry;
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

    // Contractor Inovice line also associated with "Product and Service" in Quickbook....
    public static String MapContractorInvoiceLineToBatch(List<buildertek__Account_Payable_Item__c> COInvLine) {
        try {
            System.debug('\n in MapContractorInvoiceLineToBatch \n');
            QBBatchReqJSON batchItemRequest = new QBBatchReqJSON();
            
            for (buildertek__Account_Payable_Item__c item : COInvLine) {
                String lineId = item.Id;
                Boolean taxable = true;
                DateTime yourDate = Datetime.now();
                Date invStartDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
                // System.debug('item.Unit_Price__c >> ' + item.buildertek__Unit_Price__c	);
                Decimal UnitePrice = item.buildertek__Unit_Price__c	 != null ? item.buildertek__Unit_Price__c	 : 0;
                batchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    true, // Set TrackQtyOnHand as needed
                    item.Name,
                    item.buildertek__Quantity__c,
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
            // createInvoiceLines(batchItemRequest);
            return JSON.serialize(batchItemRequest);
        } catch (Exception e) {
            System.debug('Exception in MapContractorInvoiceLineToBatch :: '  + e.getMessage());
            return null;
        }
    }

    public static String mapContractorInvoiceData(sObject CoInv, Map<Id, List<String>> lineIdsMap, String VendorQBId){
        try {
            buildertek__Account_Payable__c CoInvoice = [SELECT Id, Name , buildertek__QBO_ID__c,buildertek__QBO_SyncToken__c, buildertek__QB_Record_URL__c, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.buildertek__Vendor__c, buildertek__QBO_Bill_Number__c FROM buildertek__Account_Payable__c WHERE Id =: CoInv.Id LIMIT 1];

            QBBillReqJSON QbBill = new QBBillReqJSON();
            if(CoInvoice.buildertek__QBO_ID__c != null && CoInvoice.buildertek__QBO_ID__c != ''){
                QbBill.Id = CoInvoice.buildertek__QBO_ID__c;
                QbBill.sparse = true;
                QbBill.SyncToken = CoInvoice.buildertek__QBO_SyncToken__c;
            }
            QbBill.Line = new list<QBBillReqJSON.Line>();
            
            for(String LineId : lineIdsMap.keySet()){
                
                QBBillReqJSON.Line lines = new QBBillReqJSON.Line();
                
                
                
                QbBill.Line.add(lines);
            }
            
            
                        QBBillReqJSON.VendorRef vendor = new QBBillReqJSON.VendorRef();
                        vendor.value = VendorQBId;
                        QbBill.VendorRef = vendor;

            
            return null;
        } catch (Exception e) {
            System.debug('Exception in mapContractorInvoiceData :: '  + e.getMessage());
            return null;
        }
    }

    // Purchase Order line also associated with "Product and Service" in Quickbook....
    public static String mapPOLineToBatch(List<buildertek__Purchase_Order_Item__c> COInvLine) {
        try {
            System.debug('\n in MapPOLineToBatch \n');
            QBBatchReqJSON batchItemRequest = new QBBatchReqJSON();
            
            for (buildertek__Purchase_Order_Item__c item : COInvLine) {
                String lineId = item.Id;
                Boolean taxable = true;
                DateTime yourDate = Datetime.now();
                Date invStartDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
                Decimal UnitePrice = item.buildertek__Unit_Price__c	 != null ? item.buildertek__Unit_Price__c	 : 0;
                batchItemRequest.addBatchItem(
                    String.valueOf(item.Id),
                    true, // Set TrackQtyOnHand as needed
                    item.Name,
                    item.buildertek__Quantity__c,
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
            // createInvoiceLines(batchItemRequest);
            return JSON.serialize(batchItemRequest);
        } catch (Exception e) {
            System.debug('Exception in MapContractorInvoiceLineToBatch :: '  + e.getMessage());
            return null;
        }
    }

    public static String mapPODataBatch(buildertek__Purchase_Order__c inv, String VendorQBId, Map<Id, List<String>> lineIdsMap) {
        try {
            System.debug(' in mapPODataBatch method');
            String invId = inv.Id;
            String invQBId = inv.QBO_ID__c;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));

            QBPOJSON purchaseorder = new QBPOJSON();

            if(inv.buildertek__QBO_ID__c != null && inv.buildertek__QBO_ID__c != ''){
                purchaseorder.Id = inv.buildertek__QBO_ID__c;
                purchaseorder.sparse = true;
                purchaseorder.SyncToken = inv.buildertek__QBO_SyncToken__c;
            }
            
            purchaseorder.TotalAmt = inv.buildertek__PO_Total__c;
            // purchaseorder.TxnDate = txnDate;
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
                    qbTotal = qbIdAndNameList[2];
                    qbQuantity = qbIdAndNameList[3];
                    qbUnitPrice = qbIdAndNameList[4];
                }

                QBPOJSON.line Linee = new QBPOJSON.line();
                Linee.DetailType = 'ItemBasedExpenseLineDetail';
                Linee.Amount = Double.valueOf(qbTotal);
                Linee.Id = qbId;
                // Linee.LineNum =lineNumber;
                Linee.ItemBasedExpenseLineDetail = new QBPOJSON.ItemBasedExpenseLineDetail();
                
                QBPOJSON.ItemBasedExpenseLineDetail POLD = new QBPOJSON.ItemBasedExpenseLineDetail();
                POLD.ItemRef = new QBPOJSON.ItemRef();
                POLD.Qty = Integer.valueOf(qbQuantity);
                POLD.UnitPrice = Integer.valueOf(qbUnitPrice);
                
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
}