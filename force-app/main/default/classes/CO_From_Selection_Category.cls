public with sharing class CO_From_Selection_Category {

    @AuraEnabled
    public static List<wrapper> getOption(String recordId, Boolean upgraded) {
        List<wrapper> wpList = new List<wrapper>();
        List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
        if (upgraded == true) {
            optionList = [SELECT Id, Name, buildertek__Upgrade__c, buildertek__Upgrade_Costs__c, buildertek__Change_Order__c, 
                            buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Quantity__c, buildertek__Cost__c, 
                            buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c, 
                            buildertek__Question_Group__c, buildertek__Question_Group__r.Name FROM buildertek__Question__c
                            WHERE buildertek__Question_Group__r.buildertek__Section__c =: recordId AND buildertek__Upgrade__c = true 
                            AND buildertek__Change_Order__c = null];

        } else {
            optionList = [SELECT Id, Name, buildertek__Upgrade__c, buildertek__Upgrade_Costs__c, buildertek__Change_Order__c, 
                            buildertek__Manufacturer__c, buildertek__Manufacturer__r.Name, buildertek__Quantity__c, buildertek__Cost__c, 
                            buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c,
                            buildertek__Question_Group__c, buildertek__Question_Group__r.Name FROM buildertek__Question__c 
                            WHERE buildertek__Question_Group__r.buildertek__Section__c =: recordId AND buildertek__Change_Order__c = null];
        }

        System.debug('optionList => '+optionList);

        string orgCurr = UserInfo.getDefaultCurrency();

        String vendorId = recordId;
        for (buildertek__Question__c option : optionList) {
            if (vendorId != option.buildertek__Question_Group__c) {
                wrapper wp = new wrapper();

                buildertek__Question_Group__c selectionType = new buildertek__Question_Group__c();
                selectionType.Id = option.buildertek__Question_Group__c;
                selectionType.Name = option.buildertek__Question_Group__r.Name;
                wp.selectionTypeData = selectionType;
                wp.orgCurr = orgCurr;
                wp.selected = false;
                wpList.add(wp);
                vendorId = option.buildertek__Question_Group__c;
            } 
        }

        for (wrapper wpData : wpList) {
            List<optionData> optionDataList = new List<optionData>();
            for (buildertek__Question__c option : optionList) {
                if (wpData.selectionTypeData.Id == option.buildertek__Question_Group__c) {
                    optionData optionData = new optionData();
                    optionData.option = option;
                    optionData.selected = false;
                    optionDataList.add(optionData);
                }
            }
            wpData.optionDataList = optionDataList;   
        }

        return wpList;
    }

    @AuraEnabled
    public static String createCO(buildertek__Change_Order__c coData, List<buildertek__Question__c> selectedRowList){
        coData.buildertek__Date_Created__c = Date.Today();
        coData.buildertek__Project__c = selectedRowList[0].buildertek__Question_Group__r.buildertek__Section__r.buildertek__Selection__r.buildertek__Project__c;
        coData.buildertek__Status__c = 'Pending';
        coData.buildertek__Type__c = 'Customer';
        insert coData;

        Map<Id, buildertek__Change_Order_Item__c> coItemMap = new Map<Id, buildertek__Change_Order_Item__c>();

        for (buildertek__Question__c option : selectedRowList) {
            buildertek__Change_Order_Item__c coItem = new buildertek__Change_Order_Item__c();
            coItem.Name = option.Name;
            coItem.buildertek__Quantity__c = option.buildertek__Quantity__c ;
            coItem.buildertek__Unit_Price__c = option.buildertek__Upgrade_Costs__c;
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

    public class wrapper{
        @AuraEnabled
        public List<optionData> optionDataList{get;set;}

        @AuraEnabled
        public buildertek__Question_Group__c selectionTypeData{get;set;}

        @AuraEnabled 
        public String orgCurr{get;set;}

        @AuraEnabled
        public Boolean selected{get;set;}
    }

    public class optionData{
        @AuraEnabled
        public buildertek__Question__c option{get;set;}

        @AuraEnabled
        public Boolean selected{get;set;}
    }
    
}