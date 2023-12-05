@isTest
// global class QBMockTest implements HttpCalloutMock {
//     global HTTPResponse respond(HTTPRequest req) {
//         HttpResponse res = new HttpResponse();
//         res.setHeader('Content-Type','application/json');
//         res.setBody('{"Customer": {"Taxable": true, "BillAddr": {"Id": "395", "Line1": "Line1", "City": "BillingCity", "Country": "BillingCountry", "CountrySubDivisionCode": "CA", "PostalCode": "54321"}, "ShipAddr": {"Id": "396", "Line1": "Line1", "City": "TestCity", "Country": "TestCountry", "CountrySubDivisionCode": "CA", "PostalCode": "12345"}, "Job": false, "BillWithParent": false, "Balance": 0, "BalanceWithJobs": 0, "CurrencyRef": {"value": "USD", "name": "United States Dollar"}, "PreferredDeliveryMethod": "Print", "IsProject": false, "domain": "QBO", "sparse": false, "Id": "178", "SyncToken": "0", "MetaData": {"CreateTime": "2023-11-27T02:04:21-08:00", "LastUpdatedTime": "2023-11-27T02:04:21-08:00"}, "FullyQualifiedName": "QB Test Acc", "DisplayName": "QB Test Acc", "PrintOnCheckName": "QB Test Accdf", "Active": true, "PrimaryPhone": {"FreeFormNumber": "(987) 654-3210"}, "PrimaryEmailAddr": {"Address": "test@example.com"}, "DefaultTaxCodeRef": {"value": "7"}}, "time": "2023-11-27T02:04:21.172-08:00"}');
//         res.setStatusCode(200);
//         return res;
//     }
//     @isTest
global class QBMockTest implements HttpCalloutMock {
		public Integer code;
		public String status;
		public String Body;

		global QBMockTest(Integer code, String body) {
			this.code = code;
			this.Body = body;
		}

	    global HTTPResponse respond(HTTPRequest req) {
	        HttpResponse resp = new HttpResponse();
            resp.setHeader('Content-Type','application/json');
			resp.setStatusCode(code);
			resp.setBody(Body);
			return resp;
	    }
}