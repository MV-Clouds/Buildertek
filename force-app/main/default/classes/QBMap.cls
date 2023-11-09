public class QBMap {

    public static String mapAccountData(Account acc, Integer a){
        String accId = acc.Id;
        String QBId = acc.QBO_ID__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        //Map given account fields
        customer.CompanyName = acc.Name;
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

        System.debug('customer 1' + customer);
        if( a == 1){
            customer.Active = True;
            // QBCallout.CreateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
            QBCallout.CreateCustomerAPICall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":'));
        }else if( a == 2){
            customer.Active = True;
            QBCallout.UpdateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
        }else if( a == 3){
            customer.Active = False;
            QBCallout.deleteCustomerCall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
        }

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');

    }

    public static void MapInvoiceData(buildertek__Receipt__c Recpt){
       
       String InvoiceID = Recpt.buildertek__Billing__c;
       buildertek__Billings__c InvoiceName = [SELECT Id, Name, buildertek__Invoiced_Date__c, buildertek__Due_Date__c, buildertek__Total_Amount_Tax__c, buildertek__Customer_Account__c FROM buildertek__Billings__c WHERE Id =: InvoiceID LIMIT 1 ];
       
       System.debug('InvoiceName-------->'+ InvoiceName);
       
       
       
    //     String accId = acc.Id;
    //     String QBId = acc.QBO_ID__c;
    //     QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

    //     //Map given account fields
    //     customer.CompanyName = acc.Name;
    //     customer.Taxable = True;       
    //     customer.SyncToken = acc.QBO_SyncToken__c;
    //     customer.sparse = True;
    //     customer.Notes = acc.Description;
     
    //     //Create Shipping address
    //     QBCustomerJSON.ShipAddr shipAddy = new QBCustomerJSON.ShipAddr();
    //     shipAddy.City = acc.ShippingCity;
    //     shipAddy.Line1 = acc.ShippingStreet;
    //     shipAddy.CountrySubDivisionCode = acc.ShippingState;
    //     shipAddy.PostalCode = acc.ShippingPostalCode;
    //     shipAddy.Lat = String.valueOf(acc.ShippingLatitude);
    //     shipAddy.Long_x = String.valueOf(acc.ShippingLongitude);
    //     shipAddy.Country = acc.ShippingCountry;
    //     shipAddy.CountrySubDivisionCode = acc.ShippingCountry;
    //     customer.ShipAddr = shipAddy;

    //     customer.PrintOnCheckName = acc.Name;

    //     //Create Email Address
    //     QBCustomerJSON.PrimaryEmailAddr Addr = new QBCustomerJSON.PrimaryEmailAddr();
    //     Addr.Address = acc.buildertek__Email_Address__c;
    //     customer.PrimaryEmailAddr = Addr;

    //     // Create FAX
    //     QBCustomerJSON.Fax fax = new QBCustomerJSON.Fax();
    //     fax.FreeFormNumber = acc.Fax;
    //     customer.Fax = fax;

    //     //Create Primary Phone
    //     QBCustomerJSON.PrimaryPhone phone = new QBCustomerJSON.PrimaryPhone ();
    //     phone.FreeFormNumber = acc.Phone;
    //     customer.PrimaryPhone = phone;
    //     customer.Job = False;
    //     customer.IsProject = False;
    //     customer.Id = acc.QBO_ID__c;
    //     customer.DisplayName = acc.Name;

    //     //Create Billing Address
    //     QBCustomerJSON.BillAddr billAddy = new QBCustomerJSON.BillAddr();
    //     billAddy.City = acc.BillingCity;
    //     billAddy.Line1 = acc.BillingStreet;
    //     billAddy.CountrySubDivisionCode = acc.BillingState;
    //     billAddy.PostalCode = acc.BillingPostalCode;
    //     billAddy.Lat = String.valueOf(acc.BillingLatitude);
    //     billAddy.Long_x = String.valueOf(acc.BillingLongitude);
    //     billAddy.Country = acc.BillingCountry;
    //    // billAddy.CountrySubDivisionCode = acc.BillingCountry;
    //     customer.BillAddr = billAddy;

    //     System.debug('customer 1' + customer);
    //     if( a == 1){
    //         customer.Active = True;
    //         QBCallout.CreateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
    //     }else if( a == 2){
    //         customer.Active = True;
    //         QBCallout.UpdateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
    //     }else if( a == 3){
    //         customer.Active = False;
    //         QBCallout.deleteCustomerCall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);
    //     }

    //     return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');

    }


    }