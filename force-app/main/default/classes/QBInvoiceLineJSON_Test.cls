@isTest
public class QBInvoiceLineJSON_Test {
    @isTest
    static void testQBInvoiceLineJSON() {
        String json = '{ "times": "2023-01-01T00:00:00Z", "Id": "LineId1", "domain": "Domain1", "sparse": false, "SyncToken": "Token1", "MetaData": { "CreateTime": "2023-01-01T00:00:00Z", "LastUpdatedTime": "2023-01-02T00:00:00Z" }, "Name": "LineName1", "Description": "LineDesc1", "PurchaseDesc": "PurchaseDesc1", "PurchaseCost": 50.0, "Active": true, "FullyQualifiedName": "FullyQualified1", "ExpenseAccountRef": { "value": "ExpAcc1", "name": "ExpAccName1" }, "AssetAccountRef": { "value": "AssetAcc1", "name": "AssetAccName1" }, "TrackQtyOnHand": true, "Taxable": true, "UnitPrice": 25.0, "Type": "ItemType1", "IncomeAccountRef": { "value": "IncomeAcc1", "name": "IncomeAccName1" }, "QtyOnHand": 100.0, "InvStartDate": "2023-01-15" }';
        QBInvoiceLineJSON invoiceline = QBInvoiceLineJSON.parse(json);
        System.assertNotEquals(null, invoiceline);
        System.assertNotEquals(null, invoiceline.times);
        }
}