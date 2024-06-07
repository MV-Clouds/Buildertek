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
    public static String importWalkThroughFromMaster(String importWT, String WTId) {
        try {
            List<buildertek__Walk_Through_Line_Items__c> walkThroughLineItems = [SELECT Id, Name, buildertek__Walk_Through_List__c, buildertek__Description__c, buildertek__Details__c, buildertek__Status__c, buildertek__Notes__c, buildertek__Location__c, buildertek__Area__c, buildertek__Field_For_Work_Order__c, buildertek__Needs_new_carpet__c, buildertek__Needs_new_paint__c, buildertek__Needs_new_trim__c, buildertek__Requires_sheet_rock_repair__c, buildertek__Needs_structural_repair__c, buildertek__Window_s_need_replaced__c, buildertek__BT_RFQ_Line__c, buildertek__Product__c, buildertek__Trade_Type__c, buildertek__Anticipated_Start_Date__c, buildertek__Anticipated_Finish_Date__c, buildertek__BT_Category__c, buildertek__BT_Cost_Code__c, buildertek__Quantity__c, buildertek__Price__c, buildertek__Price_Book__c, buildertek__Total_Price__c, buildertek__SharinPix_Tag__c, buildertek__SharinPix_Token__c, buildertek__Walk_Through_List__r.buildertek__Sections__c, buildertek__Walk_Through_List__r.buildertek__Instructions__c, buildertek__Walk_Through_List__r.buildertek__Type__c 
            FROM buildertek__Walk_Through_Line_Items__c WHERE buildertek__Walk_Through_List__c = :importWT];

            List<buildertek__Walk_Through_Line_Items__c> newWalkThroughLineItems = new List<buildertek__Walk_Through_Line_Items__c>();
            for (buildertek__Walk_Through_Line_Items__c lineItem : walkThroughLineItems) {
                //* Clone the line item and set the new Walk Through List Id
                buildertek__Walk_Through_Line_Items__c newLineItem = lineItem.clone(false, true);
                newLineItem.buildertek__Walk_Through_List__c = WTId;
                newWalkThroughLineItems.add(newLineItem);
            }

            if (!newWalkThroughLineItems.isEmpty()) {
                insert newWalkThroughLineItems;
            }

            buildertek__Walk_Through_List__c walkThrough = [SELECT Id, buildertek__Sections__c, buildertek__Type__c, buildertek__Instructions__c FROM buildertek__Walk_Through_List__c WHERE Id = :WTId];

            if (!walkThroughLineItems.isEmpty()) {
                walkThrough.buildertek__Sections__c = walkThroughLineItems[0].buildertek__Walk_Through_List__r.buildertek__Sections__c;
                walkThrough.buildertek__Instructions__c = walkThroughLineItems[0].buildertek__Walk_Through_List__r.buildertek__Instructions__c;
            } else {
                buildertek__Walk_Through_List__c sourceWT = [SELECT buildertek__Sections__c, buildertek__Instructions__c FROM buildertek__Walk_Through_List__c WHERE Id = :importWT];
                walkThrough.buildertek__Sections__c = sourceWT.buildertek__Sections__c;
                walkThrough.buildertek__Instructions__c = sourceWT.buildertek__Instructions__c;
            }

            walkThrough.buildertek__Type__c = 'Master';
            update walkThrough;

            return 'Success';
        } catch (DmlException dmlEx) {
            String errorMessage = 'Error: ' + dmlEx.getDmlMessage(0);
            System.debug('DML Error: ' + errorMessage);
            return errorMessage;
        } catch (Exception ex) {
            String errorMessage = 'Error: Walk Through Import Failed: ' + ex.getMessage();
            System.debug('Error: ' + errorMessage);
            BT_ExceptionHandler.Store_Exception(ex);
            return errorMessage;
        }
    }

}