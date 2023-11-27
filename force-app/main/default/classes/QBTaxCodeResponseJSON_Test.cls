@isTest
public class QBTaxCodeResponseJSON_Test {
    @isTest
    static void QBTaxCodeResponseJSONTest() {
        String json = '{ "TaxRateDetails": [ { "TaxRateName": "RateName1", "TaxRateId": "RateId1", "RateValue": 8.0, "TaxAgencyId": "AgencyId1", "TaxApplicableOn": "Sales" } ], "TaxCode": "Code1", "TaxCodeId": "CodeId1" }';
        QBTaxCodeResponseJSON receiptres = QBTaxCodeResponseJSON.parse(json);
        System.assertNotEquals(null, receiptres);
    }
}