public without sharing class importPOLinesFromCsvController {
    private static Map<String, Set<String>> validPicklistValues = new Map<String, Set<String>>();

    @AuraEnabled
    public static String importPOLines(String poId, String csvData) {
        List<poLineFieldWrapper> poLineWrappers = (List<poLineFieldWrapper>) JSON.deserialize(csvData, List<poLineFieldWrapper>.class);
        try {
            // Fetch existing Cost Codes, Trade Types, and Categories
            Map<String, buildertek__Cost_Codes__c> existingCostCodeMap = new Map<String, buildertek__Cost_Codes__c>();
            for (buildertek__Cost_Codes__c costCodeRec : [SELECT Id, Name FROM buildertek__Cost_Codes__c]) {
                existingCostCodeMap.put(costCodeRec.Name, costCodeRec);
            }

            Map<String, buildertek__Trade_Type__c> existingTradeTypeMap = new Map<String, buildertek__Trade_Type__c>();
            for (buildertek__Trade_Type__c tradeTypeRec : [SELECT Id, Name FROM buildertek__Trade_Type__c]) {
                existingTradeTypeMap.put(tradeTypeRec.Name, tradeTypeRec);
            }

            Map<String, buildertek__Category__c> existingCategoryMap = new Map<String, buildertek__Category__c>();
            for (buildertek__Category__c categoryRec : [SELECT Id, Name FROM buildertek__Category__c]) {
                existingCategoryMap.put(categoryRec.Name, categoryRec);
            }

            List<buildertek__Purchase_Order_Item__c> poLinesToInsert = new List<buildertek__Purchase_Order_Item__c>();
            for (poLineFieldWrapper wrapper : poLineWrappers) {
                buildertek__Purchase_Order_Item__c poLine = new buildertek__Purchase_Order_Item__c();
                poLine.buildertek__Purchase_Order__c = poId;
                poLine.Name = wrapper.POLineName;
                poLine.buildertek__Description__c = wrapper.Description;
                poLine.buildertek__Quantity__c = wrapper.Quantity;
                poLine.buildertek__Unit_Price__c = wrapper.UnitPrice;
                poLine.buildertek__Tax__c = wrapper.TaxRate;

                if (existingCostCodeMap.containsKey(wrapper.CostCode)) {
                    poLine.buildertek__Cost_Code__c = existingCostCodeMap.get(wrapper.CostCode).Id;
                } else {
                    poLine.buildertek__Cost_Code__c = null;
                }

                if (existingTradeTypeMap.containsKey(wrapper.TradeType)) {
                    poLine.buildertek__BT_Trade_Type__c = existingTradeTypeMap.get(wrapper.TradeType).Id;
                } else {
                    poLine.buildertek__BT_Trade_Type__c = null;
                }

                if (existingCategoryMap.containsKey(wrapper.Section)) {
                    poLine.buildertek__BT_Category__c = existingCategoryMap.get(wrapper.Section).Id;
                } else {
                    poLine.buildertek__BT_Category__c = null;
                }

                if (isValidPicklistValue('buildertek__Cost_Type__c', wrapper.CostType)) {
                    poLine.buildertek__Cost_Type__c = wrapper.CostType;
                } else {
                    poLine.buildertek__Cost_Type__c = null;
                }

                poLinesToInsert.add(poLine);
            }

            if (!poLinesToInsert.isEmpty()) {
                insert poLinesToInsert;
            }

            return 'Success';
        } catch (Exception e) {
            throw new AuraHandledException('Error while importing PO Lines: ' + e.getMessage());
        }
    }

    private static Boolean isValidPicklistValue(String fieldApiName, String value) {
        if (!validPicklistValues.containsKey(fieldApiName)) {
            validPicklistValues.put(fieldApiName, fetchValidPicklistValues(fieldApiName));
        }

        return validPicklistValues.get(fieldApiName).contains(value);
    }

    private static Set<String> fetchValidPicklistValues(String fieldApiName) {
        Set<String> validValues = new Set<String>();
        List<Schema.PicklistEntry> picklistValues = Schema.SObjectType.buildertek__Purchase_Order_Item__c.fields.getMap()
            .get(fieldApiName)
            .getDescribe()
            .getPicklistValues();

        for (Schema.PicklistEntry picklistEntry : picklistValues) {
            if (picklistEntry.isActive()) {
                validValues.add(picklistEntry.getValue());
            }
        }

        return validValues;
    }

    public class poLineFieldWrapper {
        @AuraEnabled
        public String POLineName;
        
        @AuraEnabled
        public String Description;
        
        @AuraEnabled
        public Decimal Quantity;
        
        @AuraEnabled
        public Decimal UnitPrice;

        @AuraEnabled
        public Decimal TaxRate;

        @AuraEnabled
        public String CostCode;

        @AuraEnabled
        public String TradeType;

        @AuraEnabled
        public String CostType;

        @AuraEnabled
        public String Section;
    }
}