public with sharing class SyncVendorScheduleItem{

    public static vendorsAndScheduleItemsWrapper fetchVendorAndSchedulItemData() {
        
    }

    public class vendorsAndScheduleItemsWrapper{
        @AuraEnabled
        public List<buildertek__Project_Vendors__c> vendorList;
        @AuraEnabled
        public List<buildertek__Project_Task__c> schedulItemList;
    }
}