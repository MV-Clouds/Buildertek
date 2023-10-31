public class QBMap {

    public static String mapAccountData(Account acc){
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

        customer.Active = True;
        System.debug('customer 1' + customer);
        QBCallout.CreateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');

    }

    public static String mapAccountData2(Account acc){
        String accId = acc.Id;
        String QBId = acc.QBO_ID__c;
        String QBTOKN = acc.QBO_SyncToken__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        //Map given account fields
        customer.CompanyName = acc.Name;
        customer.Taxable = True;       
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
        customer.BillAddr = billAddy;

        customer.SyncToken = QBTOKN;
        customer.Id = QBId;
        customer.Active = True;
        System.debug('customer 2' + customer);
        QBCallout.UpdateAcc(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');

    }

    public static String mapAccountData3(Account acc){
        System.debug('IN Delete Method');
        String accId = acc.Id;
        String QBId = acc.QBO_ID__c;
        QBCustomerJSON.Customer customer = new QBCustomerJSON.Customer();

        //Map given account fields
        customer.CompanyName = acc.Name;
        customer.Taxable = True;       
        customer.SyncToken = acc.QBO_SyncToken__c;
        customer.sparse = True;
        customer.Notes = acc.Description;
        customer.Id =QBId;
    
        //Create Shipping address
        QBCustomerJSON.ShipAddr shipAddy = new QBCustomerJSON.ShipAddr();
        shipAddy.City = acc.ShippingCity;
        shipAddy.Line1 = acc.ShippingStreet;
        shipAddy.CountrySubDivisionCode = acc.ShippingState;
        shipAddy.PostalCode = acc.ShippingPostalCode;
        shipAddy.Country = acc.ShippingCountry;
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
        customer.BillAddr = billAddy;

        customer.Active = False;
        System.debug('customer 3' + customer);
        QBCallout.deleteCustomerCall(JSON.serialize(customer, True).replace('"Long_x":', '"Long":') , accId , QBId);

        return JSON.serialize(customer, True).replace('"Long_x":', '"Long":');

    }
}