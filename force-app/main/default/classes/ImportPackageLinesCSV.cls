public with sharing class ImportPackageLinesCSV {
    @AuraEnabled
    public static string insertData(String recordId, String strFileData){
        String returnresponse = '';
        system.debug('strFileData::::::'+strFileData);
        List<buildertek__Package_Line__c> schItemToInsert = new List<buildertek__Package_Line__c>();
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strFileData, List<fieldWrapper>.class);
        Map<String, String> myMap = new Map<String, String>();
        Map<String, Decimal> durationMap = new Map<String, Decimal>();
        set<String> tradeTypeName = new set<String>();
        set<String> productTypeName = new set<String>();
        set<String> categoryName = new set<String>();
        system.debug(datalist);
        for (fieldWrapper wrapper : datalist){
            System.debug('wrapper::'+wrapper);
            if (wrapper.TradeType != null && String.isNotBlank(wrapper.TradeType) &&
                wrapper.ProductType != null && String.isNotBlank(wrapper.ProductType) &&
                wrapper.Category != null && String.isNotBlank(wrapper.Category)){
                    tradeTypeName.add(wrapper.TradeType);
                    productTypeName.add(wrapper.ProductType);
                    categoryName.add(wrapper.Category);
                }
        }
        Map<String,String> mapTradeTypeId = new Map<String,String>();
        List<buildertek__Trade_Type__c> tradeTypeRecList = [SELECT Id, Name FROM buildertek__Trade_Type__c WHERE Name IN:tradeTypeName];
        if(tradeTypeRecList.size()>0){
            for(buildertek__Trade_Type__c tradetype :tradeTypeRecList){
                mapTradeTypeId.put(tradetype.Name,tradetype.Id);
            }
        }
        
        Map<String,String> mapCategoryId = new Map<String,String>();
        List<buildertek__Category__c> categoryRecList = [SELECT Id, Name FROM buildertek__Category__c WHERE Name  IN:categoryName];
        if(categoryRecList.size()>0){
            for(buildertek__Category__c category :categoryRecList){
                mapCategoryId.put(category.Name,category.Id);
            }
        }
        
        Map<String,String> mapProductTypeId = new Map<String,String>();
        system.debug(productTypeName);
        List<buildertek__Product_Type__c> productTypeRecList = [SELECT Id, Name FROM buildertek__Product_Type__c WHERE Name IN:productTypeName];
        system.debug(productTypeRecList);
        if(productTypeRecList.size()>0){
            for(buildertek__Product_Type__c producttype :productTypeRecList){
                mapProductTypeId.put(producttype.Name,producttype.Id);
            }
        }
       	system.debug(mapProductTypeId);
        for (fieldWrapper wrapper : datalist){
            System.debug('wrapper::'+wrapper);
            buildertek__Package_Line__c schItem = new buildertek__Package_Line__c();
            schItem.buildertek__Package_Name__c = recordId;
            schItem.buildertek__Trade_Type__c = mapTradeTypeId.get(wrapper.TradeType);
            schItem.buildertek__Category__c = mapCategoryId.get(wrapper.Category);
            schItem.buildertek__Product_Type__c = mapProductTypeId.get(wrapper.ProductType);
            schItem.buildertek__Location__c = wrapper.Location;
            schItem.buildertek__Quantity__c = wrapper.Quantity;
            schItem.buildertek__UOM__c = wrapper.UOM;
            //schItem.buildertek__Required_Completion_Date__c = Date.valueOf(wrapper.StartDate).addDays(Integer.valueOf(wrapper.Duration));
            schItemToInsert.add(schItem);
        }
        system.debug('@@@ schItemToInsert = ' + schItemToInsert);
        if (schItemToInsert.size() > 0){
            try{
                if (Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__Trade_Type__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__Category__c.isCreateable() &&
                     Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__Product_Type__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__Location__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__Quantity__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Package_Line__c.fields.buildertek__UOM__c.isCreateable() ){
                        insert schItemToInsert;
                    }
                returnresponse = 'SUCCESS';
            } catch (Exception e){
                System.debug('Error::' + e.getMessage());
                System.debug('Error::' + e.getLineNumber());
                returnresponse = 'ERROR';
            }
        }
        return returnresponse;
    }
    
    public class fieldWrapper{
        public String TradeType;
        public String Category;
        public String ProductType;
        public String Location;
        public Integer Quantity;
        public String UOM;
    }
}