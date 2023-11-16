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

        // System.debug('customer 1' + customer);
        // if( a == 1){
        //     customer.Active = True;
        //     QBCallout.CreateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
        //     // QBCallout.CreateCustomerAPICall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":'));
        // }else if( a == 2){
        //     customer.Active = True;
        //     QBCallout.UpdateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
        // }else if( a == 3){
        //     customer.Active = False;
        //     QBCallout.deleteCustomerCall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
        // }

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');
 
    }

    public static void MapInvoiceData(buildertek__Receipt__c Recpt){
       
       String InvoiceID = Recpt.buildertek__Billing__c;
       buildertek__Billings__c InvoiceName = [SELECT Id, Name, buildertek__Invoiced_Date__c, buildertek__Due_Date__c, buildertek__Total_Amount_Tax__c, buildertek__Customer_Account__c FROM buildertek__Billings__c WHERE Id =: InvoiceID LIMIT 1 ];
       
       System.debug('InvoiceName-------->'+ InvoiceName);
       
       


    }

    public static String mapInvoiceLineData(buildertek__Billable_Lines__c newline){
        try {
        String lineId = newline.Id;
        String QBId = newline.QBO_ID__c;
        String IncomeAccount = 'BuilderTek';
        String Iv = '01';
        QBInvoiceLineJSON Iline = new QBInvoiceLineJSON();
        String Todate = Date.today().format();

        // Iline.Taxable = True;  
        // Iline.Name = newline.Name;     
        Iline.Name = newline.buildertek__Billings__r.Name + ' '+newline.Name +'-'+ lineId.right(4).substring(0,4);     
        Iline.SyncToken = newline.QBO_SyncToken__c;
        Iline.sparse = True;
        Iline.Description = newline.Description__c;
        Iline.UnitPrice = newline.Unit_Price__c;
        Iline.Type = 'Service';
        // Iline.QtyOnHand = newline.buildertek__Quantity__c;
        // Iline.TrackQtyOnHand = true;
        // Iline.InvStartDate = Todate;
        Iline.IncomeAccountRef = new QBInvoiceLineJSON.IncomeAccountRef();
        Iline.AssetAccountRef = new QBInvoiceLineJSON.AssetAccountRef();

        QBInvoiceLineJSON.IncomeAccountRef Iacc = new QBInvoiceLineJSON.IncomeAccountRef();
        Iacc.name = IncomeAccount;
        Iacc.value = Iv;
        Iline.IncomeAccountRef = Iacc;

        // QBInvoiceLineJSON.AssetAccountRef Aacc = new QBInvoiceLineJSON.AssetAccountRef();
        // Aacc.name = IncomeAccount;
        // Aacc.value = Iv;
        // Iline.AssetAccountRef = Aacc;
     
        return JSON.serialize(Iline, True);
        }catch(Exception e){
            System.debug('Exception is >> '+ e.getMessage());
            return null;
        }
    }

    
    public static String mapInvoiceData(buildertek__Billings__c inv, String CustomerId, String LineiD, String LineName){
        String invId = inv.Id;
        String QBId = inv.QBO_ID__c;

        QBInvoiceJSON invoice = new QBInvoiceJSON();
        invoice.TotalAmt = String.valueOf(inv.buildertek__Total_Amount_Tax__c);
        invoice.Balance = inv.buildertek__Total_Amount_Tax__c;
        invoice.Line = new List<QBInvoiceJSON.line>();

        QBInvoiceJSON.line Line = new QBInvoiceJSON.line();
        Line.DetailType = 'SalesItemLineDetail';
        Line.Amount = inv.buildertek__Total_Amount_Tax__c;
        Line.Id = '1';
        Line.LineNum = '1';
        Line.SalesItemLineDetail = new QBInvoiceJSON.SalesItemLineDetail();

        QBInvoiceJSON.SalesItemLineDetail SILD = new QBInvoiceJSON.SalesItemLineDetail();
        SILD.ItemRef = new QBInvoiceJSON.ItemRef();

        QBInvoiceJSON.ItemRef ItemRef = new QBInvoiceJSON.ItemRef();
        ItemRef.name = LineName;
        ItemRef.value = LineiD;

        SILD.ItemRef = ItemRef;
        Line.SalesItemLineDetail = SILD;
        invoice.Line.add(Line);

        invoice.CustomerRef = new QBInvoiceJSON.CustomerRef();
        QBInvoiceJSON.CustomerRef customer = new QBInvoiceJSON.CustomerRef();
        customer.value = CustomerId;

        invoice.CustomerRef = customer;

        // System.debug('Invoice request Body :: ' + JSON.serialize(invoice, True).replace('"Long_x":', '"Long":'));

        return JSON.serialize(invoice, True).replace('"Long_x":', '"Long":');
    }


    public static string mapReceipt_PaymetData(buildertek__Receipt__c receipt, String CustomerId, String invoiceQBID){
        try {

            QBReceiptJSON QBPayment = new QBReceiptJSON();
            System.debug('PAyment Amount :: ' + receipt.buildertek__Amount__c );
            QBPayment.TotalAmt = receipt.buildertek__Amount__c;
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

    public static string mapReceipt_PaymetData_Hard(buildertek__Receipt__c receipt){
        try {

            QBReceiptJSON QBPayment = new QBReceiptJSON();
            QBPayment.TotalAmt = receipt.buildertek__Amount__c;
            QBPayment.CustomerRef = new QBReceiptJSON.CustomerRef();

            QBReceiptJSON.CustomerRef QBPayment_cust = new QBReceiptJSON.CustomerRef();
            QBPayment_cust.value = '113';
            QBPayment.CustomerRef = QBPayment_cust;

            return JSON.serialize(QBPayment, True);
        } catch (Exception e ) {
            system.debug('error in mapReceipt_PaymetData >> ' + e.getMessage() +'\n'+ e );
            return null;
        }
    }
}