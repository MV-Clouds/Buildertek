public with sharing class MassUpdateVendorReview {
    
    @AuraEnabled
    public static List<buildertek__Vendor_Review_Lines__c> fetchVendorReviewLines(String vendorReviewId) {
        return [SELECT Id, Name, buildertek__Score__c, buildertek__Rating__c, buildertek__Weighting__c FROM buildertek__Vendor_Review_Lines__c WHERE buildertek__Contract_Review__c = :vendorReviewId ORDER BY Name ASC];
    }

    @AuraEnabled
    public static String updateVendorReviewLines(List<buildertek__Vendor_Review_Lines__c> insertVRL, List<buildertek__Vendor_Review_Lines__c> deleteVRL){   
        List<buildertek__Vendor_Review_Lines__c> toInsert = new List<buildertek__Vendor_Review_Lines__c>();
        List<buildertek__Vendor_Review_Lines__c> toUpdate = new List<buildertek__Vendor_Review_Lines__c>();
        List<buildertek__Vendor_Review_Lines__c> toDelete = new List<buildertek__Vendor_Review_Lines__c>();

        for (buildertek__Vendor_Review_Lines__c vrl : insertVRL) {
                if (vrl.Id == null) {
                    toInsert.add(vrl);
                } else {
                    toUpdate.add(vrl);
                }
        }

        for (buildertek__Vendor_Review_Lines__c vrl : deleteVRL) {
                toDelete.add(vrl);
        }

        try {
            if (!toInsert.isEmpty()) {
                insert toInsert;
            }

            if (!toUpdate.isEmpty()) {
                update toUpdate;
            }

            if (!toDelete.isEmpty()) {
                delete toDelete;
            }
            
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return 'Error';
        }
        return 'Success';
    }
}