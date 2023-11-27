@isTest
public class QBInvoiceResponseJSON_Test {
    @isTest
    static void testQBInvoiceResponseJSON(){
        String json = '{ "Invoice": { "SyncToken": "Token123", "ShipAddr": { "City": "City1", "Line1": "Line1", "PostalCode": "12345", "CountrySubDivisionCode": "US", "Id": "Addr1" }, "TxnTaxDetail": { "TotalTax": 10.0 }, "EmailStatus": "Sent", "CustomerRef": { "name": "Customer1", "value": "C1" }, "Deposit": 50.0, "Balance": 100.0, "ProjectRef": { "value": "Project1" }, "sparse": false, "DocNumber": "123", "BillAddr": { "City": "BillCity", "Lat": "12.34", "CountrySubDivisionCode": "US", "PostalCode": "54321", "Id": "BillAddr1", "Line1": "BillLine1" }, "ApplyTaxAfterDiscount": true, "MetaData": { "LastUpdatedTime": "2023-01-02T00:00:00Z", "CreateTime": "2023-01-01T00:00:00Z" }, "DueDate": "2023-02-01", "TotalAmt": 150.0, "Line": [ { "Id": "Line1", "SalesItemLineDetail": { "ItemRef": { "value": "Item1", "name": "ItemName1" }, "TaxCodeRef": { "value": "TaxCode1" } }, "DetailType": "SalesItemLine", "Amount": 75.0, "LineNum": 1.0 } ], "PrintStatus": "Printed", "CustomField": [ { "DefinitionId": "DefId1", "Name": "FieldName1", "Type": "Text" } ], "domain": "Domain1", "Id": "InvId1", "TxnDate": "2023-01-15" } }';
        QBInvoiceResponseJSON InvoiceRes = QBInvoiceResponseJSON.parse(json);
        System.assertNotEquals(null, InvoiceRes);
    }
}