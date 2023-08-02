@RestResource(urlmapping='/restGetPurchaseOrderDetailsByPOName/*')

global with sharing class restGetPoOrderDetailsByPoName
{

@HttpGet

global static Purchase_Order__c PODetailsByName()
{

RestResponse res=RestContext.response;
RestRequest req=RestContext.request;
String poName=req.requestURI.substring(req.requestURI.lastindexOf('/')+1);
System.debug('PO Name:'+poName);
Purchase_Order__c result = [select name, status__c, PO_Total__c, Paid_Amount__c, PO_Balance__c, Project__r.Name, Vendor__r.Name from Purchase_Order__c where Name =: poName];
return result;
}

}