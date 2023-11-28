public without sharing class QBMap {

    public static String mapAccountData(Account acc, Integer a){
        String accId = acc.Id;
        String QBId = acc.QBO_ID__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        String AccountId = acc.Id;
        //Map given account fields
        customer.CompanyName = acc.Name +' - '+AccountId.right(4).substring(0,4);
        customer.Taxable = True;       
        customer.SyncToken = acc.QBO_SyncToken__c;
        customer.sparse = True;
        customer.Notes = acc.Description;
     
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
        customer.Id = acc.QBO_ID__c;
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

    public static String mapInvoiceDataBatch(buildertek__Billings__c inv, String CustomerId, Map<Id, List<String>> lineIdsMap, String taxCodeId) {
        try {
            System.debug(' in mapInvoiceData method');
            String invId = inv.Id;
            String invQBId = inv.QBO_ID__c;
            DateTime yourDate = Datetime.now();
            Date txnDate = Date.valueOf(yourDate.format('yyyy-MM-dd'));
            QBInvoiceJSON invoice = new QBInvoiceJSON();
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



    // public static string mapReceipt_PaymetData_Hard(buildertek__Receipt__c receipt){
    //     try {

    //         QBReceiptJSON QBPayment = new QBReceiptJSON();
    //         QBPayment.TotalAmt = receipt.buildertek__Amount__c;
    //         QBPayment.CustomerRef = new QBReceiptJSON.CustomerRef();

    //         QBReceiptJSON.CustomerRef QBPayment_cust = new QBReceiptJSON.CustomerRef();
    //         QBPayment_cust.value = '113';
    //         QBPayment.CustomerRef = QBPayment_cust;

    //         return JSON.serialize(QBPayment, True);
    //     } catch (Exception e ) {
    //         system.debug('error in mapReceipt_PaymetData >> ' + e.getMessage() +'\n'+ e );
    //         return null;
    //     }
    // } 
    // public static String mapInvoiceLineData(buildertek__Billable_Lines__c newline){
    //     try {
    //     String lineId = newline.Id;
    //     String QBId = newline.QBO_ID__c;
    //     String IncomeAccount = 'BuilderTek';
    //     String Iv = '01';
    //     QBInvoiceLineJSON Iline = new QBInvoiceLineJSON();
    //     String Todate = Date.today().format();

    //     // Iline.Taxable = True;  
    //     // Iline.Name = newline.Name;     
    //     Iline.Name = newline.buildertek__Item_Name__c +'-'+ lineId.right(4).substring(0,4);     
    //     Iline.SyncToken = newline.QBO_SyncToken__c;
    //     Iline.sparse = True;
    //     Iline.Description = newline.Description__c;
    //     Iline.UnitPrice = newline.Unit_Price__c;
    //     Iline.Type = 'Service';
    //     // Iline.QtyOnHand = newline.buildertek__Quantity__c;
    //     // Iline.TrackQtyOnHand = true;
    //     // Iline.InvStartDate = Todate;
    //     Iline.IncomeAccountRef = new QBInvoiceLineJSON.IncomeAccountRef();
    //     Iline.AssetAccountRef = new QBInvoiceLineJSON.AssetAccountRef();

    //     QBInvoiceLineJSON.IncomeAccountRef Iacc = new QBInvoiceLineJSON.IncomeAccountRef();
    //     Iacc.name = IncomeAccount;
    //     Iacc.value = Iv;
    //     Iline.IncomeAccountRef = Iacc;

    //     // QBInvoiceLineJSON.AssetAccountRef Aacc = new QBInvoiceLineJSON.AssetAccountRef();
    //     // Aacc.name = IncomeAccount;
    //     // Aacc.value = Iv;
    //     // Iline.AssetAccountRef = Aacc;
     
    //     return JSON.serialize(Iline, True);
    //     }catch(Exception e){
    //         System.debug('Exception is >> '+ e.getMessage());
    //         return null;
    //     }
    // }
    // public static String mapInvoiceData(buildertek__Billings__c inv, String CustomerId, String LineiD, String LineName){
    //     String invId = inv.Id;
    //     String QBId = inv.QBO_ID__c;

    //     QBInvoiceJSON invoice = new QBInvoiceJSON();
    //     invoice.TotalAmt = String.valueOf(inv.buildertek__Total_Amount_Tax__c);
    //     invoice.Balance = inv.buildertek__Total_Amount_Tax__c;
    //     invoice.Line = new List<QBInvoiceJSON.line>();

    //     QBInvoiceJSON.line Line = new QBInvoiceJSON.line();
    //     Line.DetailType = 'SalesItemLineDetail';
    //     Line.Amount = inv.buildertek__Total_Amount_Tax__c;
    //     Line.Id = '1';
    //     Line.LineNum = '1';
    //     Line.Qty = inv.buildertek__Quantity__c;
    //     Line.SalesItemLineDetail = new QBInvoiceJSON.SalesItemLineDetail();

    //     QBInvoiceJSON.SalesItemLineDetail SILD = new QBInvoiceJSON.SalesItemLineDetail();
    //     SILD.ItemRef = new QBInvoiceJSON.ItemRef();

    //     QBInvoiceJSON.ItemRef ItemRef = new QBInvoiceJSON.ItemRef();
    //     ItemRef.name = LineName;
    //     ItemRef.value = LineiD;

    //     SILD.ItemRef = ItemRef;
    //     Line.SalesItemLineDetail = SILD;
    //     invoice.Line.add(Line);

    //     invoice.CustomerRef = new QBInvoiceJSON.CustomerRef();
    //     QBInvoiceJSON.CustomerRef customer = new QBInvoiceJSON.CustomerRef();
    //     customer.value = CustomerId;

    //     invoice.CustomerRef = customer;

    //     // System.debug('Invoice request Body :: ' + JSON.serialize(invoice, True).replace('"Long_x":', '"Long":'));

    //     return JSON.serialize(invoice, True).replace('"Long_x":', '"Long":');
    // }
}