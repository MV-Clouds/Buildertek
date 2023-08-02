global without sharing class RejectRFQStatusController {
    global string rfqId;
    global void setrelatedToId(string Id){
        this.rfqId = Id;
    }
    global string getrelatedToId( ){
        return rfqId;
    }

    @RemoteAction
    public static void changeRFQStatus(String rfqRecId){
        buildertek__RFQ_To_Vendor__c rfqVendorList=[Select Id , Name , buildertek__RFQ__c  From buildertek__RFQ_To_Vendor__c where Id=:rfqRecId LIMIT 1];
        rfqVendorList.buildertek__Status__c='Rejected';
        update rfqVendorList;

    }

}