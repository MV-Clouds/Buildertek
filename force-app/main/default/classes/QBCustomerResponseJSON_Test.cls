@isTest
public class QBCustomerResponseJSON_Test {
    @isTest
    static void testQBCustomerResponseJSON() {
        String json = '{"Customer": {"Taxable": true, "BillAddr": {"Id": "395", "Line1": "Line1", "City": "BillingCity", "Country": "BillingCountry", "CountrySubDivisionCode": "CA", "PostalCode": "54321"}, "ShipAddr": {"Id": "396", "Line1": "Line1", "City": "TestCity", "Country": "TestCountry", "CountrySubDivisionCode": "CA", "PostalCode": "12345"}, "Job": false, "BillWithParent": false, "Balance": 0, "BalanceWithJobs": 0, "CurrencyRef": {"value": "USD", "name": "United States Dollar"}, "PreferredDeliveryMethod": "Print", "IsProject": false, "domain": "QBO", "sparse": false, "Id": "178", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-27T02:04:21-08:00", "LastUpdatedTime": "2023-11-27T02:04:21-08:00"}, "FullyQualifiedName": "QB Test Acc", "DisplayName": "QB Test Acc", "PrintOnCheckName": "QB Test Accdf", "Active": true, "PrimaryPhone": {"FreeFormNumber": "(987) 654-3210"}, "PrimaryEmailAddr": {"Address": "test@example.com"}, "DefaultTaxCodeRef": {"value": "7"}}, "time": "2023-11-27T02:04:21.172-08:00"}';
        QBCustomerResponseJSON customerres = QBCustomerResponseJSON.parse(json);
        System.assertNotEquals(null, customerres);
    }
}