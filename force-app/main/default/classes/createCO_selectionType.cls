public with sharing class createCO_selectionType {
    public createCO_selectionType() {

    }

    // @AuraEnabled
    // public static String changeOptionList(buildertek__Change_Order__c cOrder, String selectionTypeId){
    //     Integer sizeOfList;
    //     String project = '';
    //     List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
    //     Map<Id, Buildertek__Change_Order_Item__c> coItemMap = new Map<Id, Buildertek__Change_Order_Item__c>();
        
    //     optionList = [SELECT Id, Name, buildertek__Change_Order__c, buildertek__Quantity__c, buildertek__Upgrade_Costs__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =:selectionTypeId and buildertek__Upgrade__c = true AND buildertek__Change_Order__c = null];
        
    //     sizeOfList = optionList.size();
    //     if (sizeOfList > 0) {

    //         buildertek__Change_Order__c changeOrder = new buildertek__Change_Order__c();
    //         changeOrder.Name = cOrder.Name;
    //         changeOrder.buildertek__Details__c = cOrder.buildertek__Details__c;
    //         changeOrder.buildertek__Due_Date__c = cOrder.buildertek__Due_Date__c;
    //         changeOrder.buildertek__Status__c = 'Pending';
    //         changeOrder.buildertek__Type__c = 'Customer';
    //         changeOrder.buildertek__Date_Created__c = System.today();
    //         changeOrder.buildertek__Project__c = optionList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
    //         insert changeOrder;

    //         for (buildertek__Question__c option : optionList) {
    //             buildertek__Change_Order_Item__c changeOrderItem = new buildertek__Change_Order_Item__c();
    //             changeOrderItem.Name = option.Name;
    //             changeOrderItem.buildertek__Quantity__c = option.buildertek__Quantity__c;
    //             changeOrderItem.buildertek__Unit_Price__c = option.buildertek__Upgrade_Costs__c;
    //             changeOrderItem.buildertek__Change_Order__c = changeOrder.Id;
    //             coItemMap.put(option.Id, changeOrderItem);
    //         }
    //         insert coItemMap.values();

    //         for (buildertek__Question__c option2 : optionList) {
    //             option2.buildertek__Change_Order_Line__c = coItemMap.get(option2.Id).Id;
    //             option2.buildertek__Change_Order__c = changeOrder.Id;
    //         }
    //         update optionList;
    //         return changeOrder.Id;
    //     } else {
    //         return 'Error';
    //     }
    // }

    @AuraEnabled
    public static String createCO(buildertek__Change_Order__c coData, List<buildertek__Question__c> selectedRowList){
        coData.buildertek__Date_Created__c = Date.Today();
        coData.buildertek__Project__c = selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
        coData.buildertek__Status__c = 'Pending';
        coData.buildertek__Type__c = 'Customer';
        System.debug('coData project :: '+coData.buildertek__project__c);
        insert coData;

        Map<Id, buildertek__Change_Order_Item__c> coItemMap = new Map<Id, buildertek__Change_Order_Item__c>();

        for (buildertek__Question__c option : selectedRowList) {
            buildertek__Change_Order_Item__c coItem = new buildertek__Change_Order_Item__c();
            coItem.Name = option.Name;
            coItem.buildertek__Quantity__c = option.buildertek__Quantity__c ;
            // coItem.buildertek__Unit_Price__c = option.buildertek__Upgrade_Costs__c;
            coItem.buildertek__Unit_Price__c = option.buildertek__Total_Cost_Per_Unit__c;
            coItem.buildertek__Markup__c=option.buildertek__Markup__c;
            coItem.buildertek__Change_Order__c = coData.Id;
            coItemMap.put(option.Id, coItem);
        }
        insert coItemMap.values();

        for (buildertek__Question__c option : selectedRowList){
            option.buildertek__Change_Order__c = coItemMap.get(option.Id).buildertek__Change_Order__c;
            option.buildertek__Change_Order_Line__c = coItemMap.get(option.Id).Id;
        }
        update selectedRowList;

        return coData.Id;
    }

    @AuraEnabled
    public static List<buildertek__Question__c> getOptionData(String selectionTypeId) {
        
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
        
        optionList = [SELECT Id, buildertek__Total_Sales_Price__c, buildertek__Markup__c, buildertek__Total_Cost__c, Name, buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Change_Order__c, buildertek__Total_Cost_Per_Unit__c , buildertek__Cost__c, 
                        buildertek__Quantity__c, buildertek__Upgrade_Costs__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c 
                        FROM buildertek__Question__c WHERE buildertek__Question_Group__c =:selectionTypeId and buildertek__Upgrade__c = true AND buildertek__Change_Order__c = null];
        
        return optionList;
    }

    @AuraEnabled
    public static List<buildertek__Question__c> getOptionAllData(String selectionTypeId) {
        
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
        
        optionList = [SELECT Id, buildertek__Total_Cost_Per_Unit__c, buildertek__Total_Cost__c, buildertek__Total_Sales_Price__c, buildertek__Markup__c, Name, buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Change_Order__c, buildertek__Cost__c, 
                        buildertek__Quantity__c, buildertek__Upgrade_Costs__c, buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c 
                        FROM buildertek__Question__c WHERE buildertek__Question_Group__c =:selectionTypeId AND buildertek__Change_Order__c = null];
        
        return optionList;
    }
}