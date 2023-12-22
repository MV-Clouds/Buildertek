public with sharing class CreateQuoteFromBOMController {
    
    @AuraEnabled
    public static string createQuote(String recordId) {
        
        try {            
            List<buildertek__Select_Sheet__c> BOMLineList = [SELECT Id, Name, buildertek__Product__c, buildertek__Product_Name__c, buildertek__Quantity__c, buildertek__BL_MARKUP__c, buildertek__BL_UNIT_COST__c, buildertek__Vendor__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Selection_Sheet_Takeoff__r.buildertek__Name__c FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c = :RecordId];
            
            List<buildertek__Quote_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Quote_Line_Group__c];
            
            Map<String, buildertek__Quote_Line_Group__c> groupMap = new Map<String, buildertek__Quote_Line_Group__c>();

            for (buildertek__Quote_Line_Group__c phaseGroup : groupList) {
                groupMap.put(phaseGroup.Name, phaseGroup);
            }
            
            if(groupMap.get('No Grouping') == null){
                buildertek__Quote_Line_Group__c noGroup = new buildertek__Quote_Line_Group__c();
                noGroup.Name = 'No Grouping';
                insert noGroup;
                groupMap.put(noGroup.Name, noGroup);
            }

            if (BOMLineList.size() > 0) {
                buildertek__Quote__c quote = new buildertek__Quote__c();
                quote.buildertek__Bill_of_Material__c = recordId;
                quote.Name = BOMLineList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Name__c;
                insert quote;
                
                List<buildertek__Quote_Item__c> quoteLineList = new List<buildertek__Quote_Item__c>();

                for (buildertek__Select_Sheet__c BOMLine : BOMLineList) {
                    buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                    quoteLine.buildertek__Quote__c = quote.Id;
                    quoteLine.buildertek__Product__c = BOMLine.buildertek__Product__c;
                    quoteLine.Name = BOMLine.buildertek__Product_Name__c;
                    quoteLine.buildertek__Item_Name__c = BOMLine.buildertek__Product_Name__c;
                    quoteLine.buildertek__Description__c = BOMLine.buildertek__Product_Name__c;
                    quoteLine.buildertek__Quantity__c = BOMLine.buildertek__Quantity__c;
                    quoteLine.buildertek__Markup__c = BOMLine.buildertek__BL_MARKUP__c;
                    quoteLine.buildertek__Unit_Cost__c = BOMLine.buildertek__BL_UNIT_COST__c;
                    quoteLine.buildertek__Vendor__c = BOMLine.buildertek__Vendor__c;
                    quoteLine.buildertek__Build_Phase__c = BOMLine.buildertek__Build_Phase__c;
                    if (groupMap.get(BOMLine.buildertek__Build_Phase__r.Name) != null){
                        quoteLine.buildertek__Grouping__c = groupMap.get(BOMLine.buildertek__Build_Phase__r.Name).Id;
                    } else{
                        quoteLine.buildertek__Grouping__c = groupMap.get('No Grouping').Id;
                    }

                    quoteLineList.add(quoteLine);
                }
                if (quoteLineList.size() > 0){
                    insert quoteLineList;
                }

                return quote.Id;   
            }
            return null;

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c limit 1];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }
           
}