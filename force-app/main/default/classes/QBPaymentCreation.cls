public without sharing class QBPaymentCreation {
    
    @future(callout=true)
    public static Void CreateQBPayment(string receiptID){
        try {
            System.debug('receiptID : ' + receiptID);
            buildertek__Receipt__c receipt = [SELECT Id, Name, buildertek__Amount__c FROM buildertek__Receipt__c WHERE Id =: receiptID LIMIT 1];
            Boolean Get_Access_Token = true;
            buildertek__QuickBooks_Setting__mdt QBMetadata = [SELECT Id, DeveloperName,buildertek__Base_Url__c, buildertek__minorversion__c, MasterLabel, buildertek__Access_Token__c, buildertek__Client_Id__c, buildertek__Client_Secret__c, buildertek__Refresh_Token__c, buildertek__Scope__c, buildertek__Company_Id__c FROM buildertek__QuickBooks_Setting__mdt LIMIT 1];
            String Payment_EndPoint = QBMetadata.buildertek__Base_Url__c + '/v3/company/' + QBMetadata.buildertek__Company_Id__c + '/payment?minorversion=' + QBMetadata.buildertek__minorversion__c;            
            String Payment_RequestBody = QBMap.mapReceipt_PaymetData_Hard(receipt);
            system.debug('JSON Body >>' +  Payment_RequestBody);
            HttpResponse Payment_Response = QBCallOutService.QBCallOutServiceWithoutNameCred(Payment_EndPoint , Payment_RequestBody, Get_Access_Token);
            system.debug('Customer API Status Code >> ' + Payment_Response.getStatusCode());

        } catch (Exception e) {
            System.debug('Error in CreateQBPayment  :: ' + e.getMessage() +'\n' + e + '\n Line No : '+ e.getLineNumber());
        }
    }
}