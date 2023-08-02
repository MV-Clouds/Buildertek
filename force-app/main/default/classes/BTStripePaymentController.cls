public without sharing class BTStripePaymentController {

    //public String relatedTo { get; set; }
    public string RecId {get;set;}
    
    public buildertek__Billings__c BTBillings{
        get{
            BTBillings = [SELECT Id, Name,
                          buildertek__Customer_Account__r.buildertek__Email_Address__c,
                          buildertek__Customer_Account__r.Name,
                          buildertek__invoice_number__c,
                          buildertek__Today_Date__c,
                          buildertek__Customer_Account__r.shippingstreet,
                          buildertek__Customer_Account__r.shippingcity,
                          buildertek__Customer_Account__r.shippingstate,
                          buildertek__Customer_Account__r.shippingCountry,
                          buildertek__Customer_Account__r.Phone,
                          buildertek__Customer_Account__r.shippingpostalcode,
                          buildertek__Amount__c,
                          buildertek__Memo__c,
                          buildertek__Project__r.Name,
                          buildertek__Status__c,
                          buildertek__Due_Date__c,
                          buildertek__Tax_Rate__c,
                          buildertek__Total_Amount_Tax__c,
                          buildertek__Receipts__c,
                          buildertek__Balance__c
                          FROM buildertek__Billings__c where id =: RecId];
            return BTBillings;
        }
        set;
    }
    public buildertek__MSA_Settings__c MsaUrl{
        get{
            MsaUrl = [Select id,name,buildertek__Company_Full_Name__c, buildertek__Site_URL__c from buildertek__MSA_Settings__c ];
            return MsaUrl;
        }
        set;
    }
    
}