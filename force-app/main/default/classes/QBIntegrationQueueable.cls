public with sharing class QBIntegrationQueueable{

    public static void QBIntegrationMethod(Id Sales_invoice_Id){
        try {
            buildertek__Billings__c SI = [SELECT Id, Name, buildertek__Customer_Account__c, buildertek__QBO_ID__c FROM buildertek__Billings__c WHERE Id =: Sales_invoice_Id LIMIT 1];
            Account acc = new Account();
            if(SI.buildertek__Customer_Account__c != null){
                acc = [SELECT Id, Name, buildertek__QBO_ID__c FROM Account WHERE Id =: SI.buildertek__Customer_Account__c limit 1];
            }
            List<buildertek__Billable_Lines__c> SILine = [SELECT Id, Name, buildertek__Billings__c,buildertek__QBO_ID__c FROM buildertek__Billable_Lines__c WHERE buildertek__Billings__c =: Sales_invoice_Id];

            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt];
            String EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/customer?minorversion=' + QBMetadata.buildertek__minorversion__c;            

            if(acc.buildertek__QBO_ID__c == null && acc != null){
                String JSONBody = QBMap.mapAccountData(acc, 1);
                HttpResponse Response = QBCallOutService.QBCallOutServiceWithoutNameCred(EndPoint , JSONBody);
                if(Response.getStatus() == '200'){
                    String JSONBody2 = QBMap.MapInvoiceData(SI);
                    HttpResponse Response2 = QBCallOutService.QBCallOutServiceWithoutNameCred(EndPoint, JSONBody2);
                    if(Response.getStatus() == '200'){
                        // Write a logic for Sales Invoice line itegration....
    
                        // Write a logic to update buildertek__QBO_ID__c Field on Sales invoice...
                    }
                    else{
                        // Write a logic for Sales Invoice line itegration....
                    }
                }
                else{
                    // Store Bad Response in Custome Object...
                }
            }
            else{
                

            }

        } catch (Exception e) {
            System.debug('Error in QBIntegrationMethod ..' + e.getMessage());
        }
    }


}