public class InvoiceWithChangeOrdersController {
  public String billingId {get;set;}
    public double totalAmount {get;set;}
    public Map<Id,buildertek__Billable_Lines__c> billableMap {get;set;}
    public Map<Id,buildertek__Billings__c> relatedToMap {get;set;}
    public List<String> testString{get;set;}

    public List<buildertek__Change_Order__c> getchangeOrder(){
        testString = new List<String>();
        for(integer i=0;i<10;i++)  testString.add('test');
        
        List<buildertek__Change_Order__c> changeOrderList = new List<buildertek__Change_Order__c>();
        if(billingId != '' || billingId != null){
            List<buildertek__Billings__c> billingObj = [SELECT Id, Name, buildertek__Change_Order__c, buildertek__Project__c, CreatedDate FROM buildertek__Billings__c WHERE Id=: billingId];
            if(billingObj.size() > 0){
                changeOrderList= [SELECT Id, Name, buildertek__Project__c,buildertek__Status__c, buildertek__CO_Number__c,buildertek__Change_Order_No__c, buildertek__Total_Amount__c, CreatedDate FROM buildertek__Change_Order__c WHERE buildertek__Project__c = : billingObj[0].buildertek__Project__c AND buildertek__Status__c IN('Paid','Customer Approved','Partially Paid')ORDER BY CreatedDate DESC];
                if(changeOrderList.size() > 0){
                    totalAmount = 0;
                    for(buildertek__Change_Order__c obj : changeOrderList){
                         totalAmount += obj.buildertek__Total_Amount__c;
                    }
                }
            }
        }
        return changeOrderList;
    }

    public buildertek__Billings__c getbillingObj(){
        buildertek__Billings__c relatedTo = new buildertek__Billings__c();
        if(billingId != null || billingId != ''){
            relatedTo = [SELECT Id, buildertek__Customer_Account__c, Name,buildertek__Today_Date__c,buildertek__Amount__c,buildertek__Tax_Rate__c, buildertek__invoice_number__c, buildertek__Receipts__c, buildertek__Balance__c, buildertek__Total_Amount_Tax__c, buildertek__Memo__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Status__c, buildertek__Due_Date__c, buildertek__Customer_Account__r.Name, buildertek__Customer_Account__r.shippingstreet, buildertek__Customer_Account__r.shippingcity, buildertek__Customer_Account__r.shippingstate, buildertek__Customer_Account__r.shippingpostalcode, buildertek__Customer_Account__r.shippingCountry, buildertek__Customer_Account__r.Phone, (SELECT Id,buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total__c FROM buildertek__Billable_Lines__r)   FROM buildertek__Billings__c WHERE Id =: billingId];
        }
        return relatedTo;
    }
}