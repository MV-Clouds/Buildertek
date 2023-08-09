public with sharing class createRFQClass {
	 @AuraEnabled
    public static String RFQList(buildertek__RFQ__c cOrder , List<buildertek__Question__c> selectedRowList){

        cOrder.buildertek__Project__c = selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
        System.debug('Project----->'+cOrder.buildertek__Project__c);
        insert cOrder;

        Map<Id, buildertek__RFQ_Item__c> rfItemMap = new Map<Id, buildertek__RFQ_Item__c>();
        for (buildertek__Question__c option : selectedRowList) {
            buildertek__RFQ_Item__c rfq=new buildertek__RFQ_Item__c();
            rfq.Name = option.Name;
            System.debug('RFQ Description------->'+rfq.Name);
            rfItemMap.put(option.Id, rfq);
            rfq.buildertek__RFQ_Package__c = cOrder.id;
            rfItemMap.put(option.Id, rfq);
        }
        insert rfItemMap.values();

        for (buildertek__Question__c option : selectedRowList){
            option.buildertek__RFQ__c = rfItemMap.get(option.Id).buildertek__RFQ_Package__c;
            option.buildertek__RFQ_Line__c = rfItemMap.get(option.Id).Id;
        }
        update selectedRowList;

        return cOrder.Id;
    }

    @AuraEnabled
    public static List<buildertek__Question__c> getOptionData(String selectionTypeId) {
        
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();        
        optionList = [SELECT Id, Name, buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Change_Order__c, buildertek__Cost__c, buildertek__Quantity__c, buildertek__Upgrade_Costs__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =:selectionTypeId];        
        return optionList;
    }
}