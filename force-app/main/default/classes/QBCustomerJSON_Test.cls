@isTest
public class QBCustomerJSON_Test {
    @isTest
    static void testQBCustomerJSON(){
        String json = '{"FullyQualifiedName": "QB Test Acc", "PrimaryEmailAddr": {"Address": "test@example.com"}, "DisplayName": "QB Test Acc", "PrimaryPhone": {"FreeFormNumber": "(987) 654-3210"}, "BillAddr": {"CountrySubDivisionCode": "CA", "City": "BillingCity", "PostalCode": "54321", "Line1": "Line1", "Country": "BillingCountry"}, "ShipAddr": {"CountrySubDivisionCode": "CA", "City": "TestCity", "PostalCode": "12345", "Line1": "Line1", "Country": "TestCountry"} }';

        QBCustomerJSON customer = QBCustomerJSON.parse(json);
        System.assertNotEquals(null, customer);
        
    }
}