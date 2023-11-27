@isTest
public class QBReceiptResponseJSON_Test {
    @isTest
    static void testQBReceiptResponseJSON() {
        String json = '{ "Payment": { "ProjectRef": { "value": "Project1" }, "sparse": false, "PaymentRefNum": "RefNum123", "Line": [ { "LinkedTxn": [ { "TxnId": "TxnId1", "TxnType": "Type1" } ], "Amount": 50.0 } ], "TotalAmt": 100.0, "CustomerRef": { "value": "Customer1" }, "TxnDate": "2023-01-15", "Id": "PaymentId1", "UnappliedAmt": 30.0, "PaymentMethodRef": { "value": "Method1" }, "domain": "Domain1", "MetaData": { "CreateTime": "2023-01-01T00:00:00Z", "LastUpdatedTime": "2023-01-02T00:00:00Z" }, "SyncToken": "Token1" } }';
        QBReceiptResponseJSON receiptres = QBReceiptResponseJSON.parse(json);
        System.assertNotEquals(null, receiptres);
    }
}