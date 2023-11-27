@isTest
public class QBCustomerJSON_Test {
    @isTest
    static void testQBCustomerJSON(){
        String json = '{ "QueryResponse": { "Customer": [ { "Taxable": true, "BillAddr": { "Id": "BillAddrId1", "Line1": "BillLine1", "City": "BillCity1", "CountrySubDivisionCode": "US", "PostalCode": "12345", "Lat": "12.34", "Long_x": "56.78", "Country": "Country1" }, "ShipAddr": { "Id": "ShipAddrId1", "Line1": "ShipLine1", "City": "ShipCity1", "CountrySubDivisionCode": "US", "PostalCode": "54321", "Lat": "98.76", "Long_x": "54.32", "Country": "Country2" }, "Job": true, "BillWithParent": true, "ParentRef": { "value": "Parent1" }, "Level": 2, "Balance": 100.0, "BalanceWithJobs": 150.0, "CurrencyRef": { "value": "USD", "name": "US Dollar" }, "PreferredDeliveryMethod": "Email", "IsProject": true, "domain": "Domain1", "sparse": false, "Id": "CustomerId1", "SyncToken": "Token1", "MetaData": { "CreateTime": "2023-01-01T00:00:00Z", "LastUpdatedTime": "2023-01-02T00:00:00Z" }, "FullyQualifiedName": "FullName1", "CompanyName": "Company1", "GivenName": "GivenName1", "FamilyName": "FamilyName1", "DisplayName": "DisplayName1", "PrintOnCheckName": "PrintName1", "Active": true, "PrimaryPhone": { "FreeFormNumber": "123-456-7890" }, "PrimaryEmailAddr": { "Address": "email@example.com" }, "DefaultTaxCodeRef": { "value": "TaxCode1" }, "TaxExemptionReasonId": "ExemptionId1", "ResaleNum": "ResaleNum1", "Notes": "Notes1", "Fax": { "FreeFormNumber": "987-654-3210" } } ], "startPosition": 1, "maxResults": 1 }, "timeString": "2023-01-03T12:34:56Z" }';
        QBCustomerJSON customer = QBCustomerJSON.parse(json);
        System.assertNotEquals(null, customer);
        
    }
}