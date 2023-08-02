public without sharing class RFQRejectController {
    

    public String currentRecordId {get;set;}
    public String getRFQName {get;set;}
    public String getOwnerName {get;set;}

    // public Account acc{get;set;}
    public RFQRejectController() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        if(currentRecordId != null){
            buildertek__RFQ_To_Vendor__c rfqVendor= [Select Id , Name ,buildertek__RFQ__c,  createdBy.Name , buildertek__RFQ__r.Name, buildertek__Status__c From buildertek__RFQ_To_Vendor__c  WHERE Id=:currentRecordId LIMIT 1];
            getRFQName=rfqVendor.buildertek__RFQ__r.Name;
            getOwnerName=rfqVendor.createdBy.Name;
        } 
    }


    public void changeTheStatus() {
        currentRecordId  = ApexPages.CurrentPage().getparameters().get('id');
        System.debug('currentRecordId'+currentRecordId);
        if(currentRecordId != null){
            buildertek__RFQ_To_Vendor__c rfqVendor= [Select Id , Name ,buildertek__RFQ__c,  buildertek__Status__c From buildertek__RFQ_To_Vendor__c  WHERE Id=:currentRecordId LIMIT 1];
            System.debug('rfqVendor'+rfqVendor);
            rfqVendor.buildertek__Status__c ='Rejected';
            update  rfqVendor;
        }
    }
    

}