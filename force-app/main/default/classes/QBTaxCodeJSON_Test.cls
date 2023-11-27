@isTest
public class QBTaxCodeJSON_Test {
    @isTest
    static void testQBTaxCodeJSON(){
    String json = '{ "TaxRateDetails": [ { "RateValue": "8", "TaxApplicableOn": "Sales", "TaxAgencyId": "1", "TaxRateName": "sf" } ], "TaxCode": "sd" }';
    QBTaxCodeJSON tax = QBTaxCodeJSON.parse(json);
    System.assertNotEquals(null, tax);
    System.assertNotEquals(null, tax.TaxRateDetails);
    }
}