public with sharing class BT_ImportMasterWalkThroughController {
    
    @AuraEnabled
    public static List<buildertek__Walk_Through_List__c> getMasterWalkThroughDetails(String searchKey) {
        try {
            String query = 'SELECT Id, Name, buildertek__Description__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Total_Price__c FROM buildertek__Walk_Through_List__c WHERE buildertek__Type__c = \'Master\'';
                        
            if (!String.isBlank(searchKey)) {
                searchKey = '%' + searchKey + '%';
                query += ' AND (Name LIKE :searchKey OR buildertek__Description__c LIKE :searchKey)';
            }
            
            query += ' ORDER BY buildertek__Description__c';
            
            List<buildertek__Walk_Through_List__c> walkthroughList = Database.query(query);
            return walkthroughList;
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
        return null;
    }
    
    @AuraEnabled
    public static String importWalkThroughFromMaster(List<String> importWT, String WTId) {
        try {
            List<buildertek__Walk_Through_Line_Items__c> walkThroughLineItems = [SELECT Id, Name, buildertek__Walk_Through_List__c, buildertek__Description__c, buildertek__Details__c, buildertek__Status__c, buildertek__Notes__c, buildertek__Location__c, buildertek__Area__c, buildertek__Field_For_Work_Order__c, buildertek__Needs_new_carpet__c, buildertek__Needs_new_paint__c, buildertek__Needs_new_trim__c, buildertek__Requires_sheet_rock_repair__c, buildertek__Needs_structural_repair__c, buildertek__Window_s_need_replaced__c, buildertek__BT_RFQ_Line__c, buildertek__Product__c, buildertek__Trade_Type__c, buildertek__Anticipated_Start_Date__c, buildertek__Anticipated_Finish_Date__c, buildertek__BT_Category__c, buildertek__BT_Cost_Code__c, buildertek__Quantity__c, buildertek__Price__c, buildertek__Price_Book__c, buildertek__Total_Price__c, buildertek__SharinPix_Tag__c, buildertek__SharinPix_Token__c FROM buildertek__Walk_Through_Line_Items__c WHERE buildertek__Walk_Through_List__c IN :importWT];

            List<buildertek__Walk_Through_Line_Items__c> newWalkThroughLineItems = new List<buildertek__Walk_Through_Line_Items__c>();
            for (buildertek__Walk_Through_Line_Items__c lineItem : walkThroughLineItems) {
                buildertek__Walk_Through_Line_Items__c newLineItem = new buildertek__Walk_Through_Line_Items__c();
                newLineItem.buildertek__Walk_Through_List__c = WTId;
                newLineItem.buildertek__Description__c = lineItem.buildertek__Description__c;
                newLineItem.buildertek__Details__c = lineItem.buildertek__Details__c;
                newLineItem.buildertek__Status__c = lineItem.buildertek__Status__c;
                newLineItem.buildertek__Notes__c = lineItem.buildertek__Notes__c;
                newLineItem.buildertek__Location__c = lineItem.buildertek__Location__c;
                newLineItem.buildertek__Area__c = lineItem.buildertek__Area__c;
                newLineItem.buildertek__Field_For_Work_Order__c = lineItem.buildertek__Field_For_Work_Order__c;
                newLineItem.buildertek__Needs_new_carpet__c = lineItem.buildertek__Needs_new_carpet__c;
                newLineItem.buildertek__Needs_new_paint__c = lineItem.buildertek__Needs_new_paint__c;
                newLineItem.buildertek__Needs_new_trim__c = lineItem.buildertek__Needs_new_trim__c;
                newLineItem.buildertek__Requires_sheet_rock_repair__c = lineItem.buildertek__Requires_sheet_rock_repair__c;
                newLineItem.buildertek__Needs_structural_repair__c = lineItem.buildertek__Needs_structural_repair__c;
                newLineItem.buildertek__Window_s_need_replaced__c = lineItem.buildertek__Window_s_need_replaced__c;
                newLineItem.buildertek__BT_RFQ_Line__c = lineItem.buildertek__BT_RFQ_Line__c;
                newLineItem.buildertek__Product__c = lineItem.buildertek__Product__c;
                newLineItem.buildertek__Trade_Type__c = lineItem.buildertek__Trade_Type__c;
                newLineItem.buildertek__Anticipated_Start_Date__c = lineItem.buildertek__Anticipated_Start_Date__c;
                newLineItem.buildertek__Anticipated_Finish_Date__c = lineItem.buildertek__Anticipated_Finish_Date__c;
                newLineItem.buildertek__BT_Category__c = lineItem.buildertek__BT_Category__c;
                newLineItem.buildertek__BT_Cost_Code__c = lineItem.buildertek__BT_Cost_Code__c;
                newLineItem.buildertek__Quantity__c = lineItem.buildertek__Quantity__c != null ? lineItem.buildertek__Quantity__c : 0;
                newLineItem.buildertek__Price__c = lineItem.buildertek__Price__c;
                newLineItem.buildertek__Price_Book__c = lineItem.buildertek__Price_Book__c;
                newLineItem.buildertek__SharinPix_Tag__c = lineItem.buildertek__SharinPix_Tag__c;
                newLineItem.buildertek__SharinPix_Token__c = lineItem.buildertek__SharinPix_Token__c;
                newWalkThroughLineItems.add(newLineItem);
            }

            if (newWalkThroughLineItems.size() > 0){
                insert newWalkThroughLineItems;
            }

            return 'Success';
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            BT_ExceptionHandler.Store_Exception(ex);
            return 'Error: Walk Through Import Failed: ' + ex.getMessage();
        }
    }

}