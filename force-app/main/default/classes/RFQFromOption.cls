public with sharing class RFQFromOption {
    @AuraEnabled
    public static String RFQFrom_Option(buildertek__RFQ__c rfq, String optionId) {
        System.debug('Start-----------');        

        buildertek__Question__c optionList = new buildertek__Question__c();
        optionList = [SELECT Id , Name,buildertek__RFQ__c, buildertek__Manufacturer__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c WHERE Id =: optionId]; 
              
        rfq.buildertek__Project__c = optionList.buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
        insert rfq;

        buildertek__RFQ_Item__c rfItemMap = new buildertek__RFQ_Item__c();
        rfItemMap.buildertek__RFQ_Package__c=rfq.id;
        rfItemMap.name = optionList.Name;
        rfItemMap.buildertek__Vendor__c = optionList.buildertek__Manufacturer__c;
        insert rfItemMap;

        optionList.buildertek__RFQ__c = rfq.Id;
        optionList.buildertek__RFQ_Line__c = rfItemMap.Id;
        update optionList;

        return rfq.Id;

    }
    @AuraEnabled
    public static buildertek__Question__c get_option(String recordId){
        buildertek__Question__c option = [SELECT Id , Name, buildertek__RFQ__c, buildertek__RFQ_Line__c FROM buildertek__Question__c WHERE Id =: recordId];
        return option;
    }

}