public with sharing class CreateAssestHistoryController {

    @AuraEnabled
    public static String CreateAssetHistoryRecord(buildertek__Asset_History__c AssetHistory){
        System.debug('AssetHistory: ' + AssetHistory);
        try{
            insert AssetHistory;
            return AssetHistory.Id;
        }catch(Exception e){
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static buildertek__Asset_History__c getPreviousAssetHistory(String assetId){
        List<buildertek__Asset_History__c> assetHistory = [SELECT Id, Name, buildertek__Asset_Manager__c, buildertek__Date_off_Job__c FROM buildertek__Asset_History__c WHERE buildertek__Asset_Manager__c = :assetId ORDER BY Name DESC LIMIT 1];
        System.debug('assetHistory: ' + assetHistory);
        if(assetHistory.size() > 0){
            if(assetHistory[0].buildertek__Date_off_Job__c == null){
                return assetHistory[0];
            }
        }
        return null;
    }

    @AuraEnabled
    public static String UpdateAssetHistoryRecord(buildertek__Asset_History__c PreviousAssetHistory){
        System.debug('PreviousAssetHistory: ' + PreviousAssetHistory);
        try{
            update PreviousAssetHistory;
            return PreviousAssetHistory.Id;
        }catch(Exception e){
            return 'error ' + e.getMessage();
        }
    }


}