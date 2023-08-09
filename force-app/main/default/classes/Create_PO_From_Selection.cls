public with sharing class Create_PO_From_Selection {

    @AuraEnabled
    public static void createPO(String recordId, List<buildertek__Question__c> selectedRowList) {
        
        List<String> manufacturerIds = new List<String>();
        List<Account> manufacturerList = new List<Account>();

        for (buildertek__Question__c option : selectedRowList) {
            System.debug('Option => '+option);
            if (!manufacturerIds.contains(option.buildertek__Manufacturer__c)) {
                manufacturerIds.add(option.buildertek__Manufacturer__c);
                manufacturerList.add(option.buildertek__Manufacturer__r);
            }
        }

        List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
        for (Account manufacturer : manufacturerList) {
            buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
            System.debug('manufacturer => '+manufacturer);
            po.buildertek__Description__c = manufacturer.Name;
            po.buildertek__Vendor__c = manufacturer.Id;
            if (selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c != null) {
                po.buildertek__Project__c = selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
            }
            poList.add(po);
            System.debug('po => '+po);
        }
        insert poList;

        Map<Id, buildertek__Purchase_Order_Item__c> poItemMap = new Map<Id, buildertek__Purchase_Order_Item__c>();
        for (buildertek__Question__c option : selectedRowList){
            for (buildertek__Purchase_Order__c po : poList) {
                if (option.buildertek__Manufacturer__c == po.buildertek__Vendor__c) {
                    buildertek__Purchase_Order_Item__c poLine = new buildertek__Purchase_Order_Item__c();
                    poLine.buildertek__Purchase_Order__c = po.Id;
                    poLine.Name = option.buildertek__Product__r.Name;
                    poLine.buildertek__Unit_Price__c = option.buildertek__Cost__c;
                    poItemMap.put(option.Id, poLine);
                    System.debug('poLine => '+poLine);
                }
            }
        }
        insert poItemMap.values();

        for (buildertek__Question__c option : selectedRowList){
            for (Id key : poItemMap.keySet()) {
                if (option.Id == key) {
                    option.buildertek__Purchase_Order_Line__c = poItemMap.get(key).Id;
                    option.buildertek__Purchase_Order__c = poItemMap.get(key).buildertek__Purchase_Order__c;
                    System.debug('Update option => '+option);
                }
            }
        }
        update selectedRowList;
        
    }

    @AuraEnabled
    public static List<buildertek__Question__c> getOption(String recordId) {
        List<buildertek__Question__c> optionList = [SELECT Id, Name, buildertek__Selected__c, buildertek__Product__c, buildertek__Product__r.Name , buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Quantity__c, buildertek__Cost__c, buildertek__Purchase_Order__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =: recordId AND buildertek__Selected__c = true AND buildertek__Manufacturer__c != null AND buildertek__Product__c != null AND buildertek__Purchase_Order__c = null];
        System.debug('optionList => '+optionList);
        return optionList;
    }
}