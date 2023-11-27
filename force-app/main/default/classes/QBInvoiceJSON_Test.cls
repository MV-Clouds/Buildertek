@isTest
public class QBInvoiceJSON_Test {
    @isTest
    static void testQBInvoiceJSON() {
        String json = '{"Invoice":{"TxnTaxDetail":{"TotalTax":0.0,"TxnTaxCodeRef":{"value":"NON"},"TaxLine":[{"TaxLineDetail":{"TaxRateRef":{"value":"NON"},"PercentBased":true,"TaxPercent":0.0,"NetAmountTaxable":0.0},"DetailType":"TaxLineDetail","Amount":0.0}]},"LinkedTxn":[],"Balance":100.0,"CustomerRef":{"name":"Test Customer","value":"123"},"Deposit":0.0,"SyncToken":"0","ProjectRef":{"value":"456"},"BillEmail":{"Address":"test@test.com"},"CustomerMemo":{"value":"Thank you for your business and have a great day!"},"ShipAddr":{"City":"San Francisco","Line1":"123 Main Street","PostalCode":"94111","CountrySubDivisionCode":"CA","Lat":"37.7749295","Id":"789"},"sparse":false,"EmailStatus":"NotSet","DocNumber":"INV-0001","BillAddr":{"Line1":"123 Main Street","Line2":"Suite 100","Lat":"37.7749295","Line3":"","Id":"789","Line4":""},"ApplyTaxAfterDiscount":false,"MetaData":{"CreateTime":"2023-10-10T00:00:00-07:00","LastUpdatedTime":"2023-10-10T00:00:00-07:00"},"DueDate":"2023-10-31","TotalAmt":100.0,"SalesTermRef":{"value":"1"},"Line":[{"Id":"1","SalesItemLineDetail":{"ItemRef":{"value":"1","name":"Test Item"},"Qty":1.0,"UnitPrice":100.0,"TaxCodeRef":{"value":"NON"}},"LineNum":1.0,"Amount":100.0,"DetailType":"SalesItemLineDetail","Description":"Test Item"}],"PrintStatus":"NotSet","CustomField":[{"DefinitionId":"1","Type":"StringType","Name":"CustomField1","StringValue":"ABC"}],"domain":"QBO","Id":"1","TxnDate":"2023-10-10"}}';
        QBInvoiceJSON invoice = QBInvoiceJSON.parse(json);
        System.assertNotEquals(null, invoice);
        System.assertNotEquals(null, invoice.Invoice);
        }
}