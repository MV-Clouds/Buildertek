@isTest
public class QBInvoiceLineResponseJSON_Test {
    @isTest
    static void testQBInvoiceLineResponseJSON() {
        String json = '{ "Item": { "Active": true, "SubItem": false, "ParentRef": { "value": "Parent1", "name": "ParentName1" }, "sparse": false, "SyncToken": "Token1", "Level": 2.0, "Type": "ItemType1", "Name": "ItemName1", "Id": "ItemId1", "domain": "Domain1", "MetaData": { "LastUpdatedTime": "2023-01-02T00:00:00Z", "CreateTime": "2023-01-01T00:00:00Z" }, "FullyQualifiedName": "FullName1" } }';
        QBInvoiceLineResponseJSON InvoiceLineRes = QBInvoiceLineResponseJSON.parse(json);
        System.assertNotEquals(null, InvoiceLineRes);
    }
}