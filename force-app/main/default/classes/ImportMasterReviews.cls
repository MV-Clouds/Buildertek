public with sharing class ImportMasterReviews{
    @AuraEnabled
    public static object getMasterReviews(String recordId, String searchKeyword){
        list<buildertek__Vendor_Review__c> masterReviewList;
        String searchString = '%' + searchKeyword + '%';
        If (Schema.sObjectType.buildertek__Vendor_Review__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Vendor_Review__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Vendor_Review__c.fields.buildertek__Type__c.isAccessible() && Schema.sObjectType.buildertek__Vendor_Review__c.fields.buildertek__Total_Score__c.isAccessible()){
            masterReviewList = [SELECT Id, Name, buildertek__Type__c, buildertek__Project__r.Name, buildertek__Total_Score__c
                                from buildertek__Vendor_Review__c
                                WHERE buildertek__Type__c = 'Master' AND Name LIKE:searchString AND ID != :recordId
                                ORDER BY Name ASC
                                limit 50000];
        }
        System.debug('masterReviewList--->>>' + masterReviewList);
        List<MasterReviewsClass> MasterReviewsClassList = new List<MasterReviewsClass>();
        for (buildertek__Vendor_Review__c masterVendorReview : masterReviewList){
            MasterReviewsClass MasterReviewsClassRecord = new MasterReviewsClass();
            MasterReviewsClassRecord.masterReviewRecord = masterVendorReview;
            MasterReviewsClassRecord.reviewCheck = false;
            MasterReviewsClassList.add(MasterReviewsClassRecord);
        }

        return MasterReviewsClassList;
    }

    @AuraEnabled
    public static MessageClass importMasterReviewLines(List<String> reviewIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Vendor_Review_Lines__c> vendorReviewItemList;

            vendorReviewItemList = [SELECT Id, Name, buildertek__Contract_Review__c, buildertek__Notes__c, buildertek__Rating__c, buildertek__Score__c, buildertek__Weighting__c FROM buildertek__Vendor_Review_Lines__c WHERE buildertek__Contract_Review__c IN:reviewIds];

            List<buildertek__Vendor_Review_Lines__c> vendorReviewItemToInsertList = new List<buildertek__Vendor_Review_Lines__c>();

            if (!vendorReviewItemList.isEmpty()){
                for (buildertek__Vendor_Review_Lines__c reviewItem : vendorReviewItemList){
                    buildertek__Vendor_Review_Lines__c vendorReviewItemToInsert = new buildertek__Vendor_Review_Lines__c();
                    vendorReviewItemToInsert.Name = reviewItem.Name;
                    vendorReviewItemToInsert.buildertek__Contract_Review__c = recordId;
                    vendorReviewItemToInsert.buildertek__Notes__c = reviewItem.buildertek__Notes__c;
                    vendorReviewItemToInsert.buildertek__Rating__c = reviewItem.buildertek__Rating__c;
                    vendorReviewItemToInsert.buildertek__Weighting__c = reviewItem.buildertek__Weighting__c;
                    vendorReviewItemToInsertList.add(vendorReviewItemToInsert);
                }
            }

            if (vendorReviewItemToInsertList.size() > 0){
                insert vendorReviewItemToInsertList;

                msg.Status = 'Success';
                msg.Message = 'Vendor Review Lines Imported Successfully';
            } else{
                msg.Status = 'Success';
                msg.Message = 'You have imported a Master Vendor Review which has no Vendor Review Lines.';
            }
            return msg;
        } catch (Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            return msg;
        }
    }

    @AuraEnabled
    public static string CheckUserAccess(String AccessType){
        switch  on AccessType{
            when 'Create'{
                if (Schema.sObjectType.buildertek__Vendor_Review_Lines__c.isCreateable()){
                    return 'True';
                } else{
                    return 'False';
                }
            }
            when 'Update'{
                if (Schema.sObjectType.buildertek__Vendor_Review_Lines__c.isUpdateable()){
                    return 'True';
                } else{
                    return 'False';
                }
            }
            when 'Delete'{
                if (Schema.sObjectType.buildertek__Vendor_Review_Lines__c.isDeletable()){
                    return 'True';
                } else{
                    return 'False';
                }
            }
            when else{
                return null;
            }
        }
    }

    public class MasterReviewsClass{
        @AuraEnabled
        public buildertek__Vendor_Review__c masterReviewRecord{ get; set; }

        @AuraEnabled
        public boolean reviewCheck{ get; set; }

    }

    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public string Message{ get; set; }
    }
}