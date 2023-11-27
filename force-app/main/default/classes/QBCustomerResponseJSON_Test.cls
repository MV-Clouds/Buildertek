@isTest
public class QBCustomerResponseJSON_Test {
    @isTest
    static void testQBCustomerResponseJSON() {
        String json = '{ "Customer": { "Taxable": true, "Job": false, "BillWithParent": true, "Balance": 100.0, "BalanceWithJobs": 150.0, "CurrencyRef": { "value": "USD", "name": "US Dollar" }, "PreferredDeliveryMethod": "Email", "IsProject": false, "domain": "Domain1", "sparse": false, "Id": "CustomerId1", "SyncToken": "Token1", "MetaData": { "CreateTime": "2023-01-01T00:00:00Z", "LastUpdatedTime": "2023-01-02T00:00:00Z" }, "GivenName": "GivenName1", "FamilyName": "FamilyName1", "FullyQualifiedName": "FullName1", "CompanyName": "Company1", "DisplayName": "DisplayName1", "PrintOnCheckName": "PrintName1", "Active": true, "PrimaryEmailAddr": { "Address": "email@example.com" }, "DefaultTaxCodeRef": { "value": "TaxCode1" } }, "times": "2023-01-03T12:34:56Z" }';
        QBCustomerResponseJSON customerres = QBCustomerResponseJSON.parse(json);
        System.assertNotEquals(null, customerres);
    }
}