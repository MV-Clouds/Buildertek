public with sharing class walkthroughlinetriggerhandler {
    private static Boolean isExecuting = false;

    public static void onAfterInsert(List<buildertek__Walk_Through_Line_Items__c> newWalkThroughLineItems) {
        if (!isExecuting) {
            isExecuting = true;
            Set<Id> rfqLineIds = new Set<Id>();
            try {
                for (buildertek__Walk_Through_Line_Items__c walkThroughLineItem : newWalkThroughLineItems) {
                    if (walkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                        rfqLineIds.add(walkThroughLineItem.buildertek__BT_RFQ_Line__c);
                    }
                }
                
                Map<Id, buildertek__RFQ_Item__c> rfqLinesMap = new Map<Id, buildertek__RFQ_Item__c>([
                    SELECT Id, buildertek__BT_Walk_Through_Line_Item__c
                    FROM buildertek__RFQ_Item__c
                    WHERE Id IN :rfqLineIds
                ]);
                
                List<buildertek__RFQ_Item__c> rfqLinesToUpdate = new List<buildertek__RFQ_Item__c>();
                for (buildertek__Walk_Through_Line_Items__c walkThroughLineItem : newWalkThroughLineItems) {
                    if (walkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                        buildertek__RFQ_Item__c rfqLine = rfqLinesMap.get(walkThroughLineItem.buildertek__BT_RFQ_Line__c);
                        if (rfqLine != null) {
                            rfqLine.buildertek__BT_Walk_Through_Line_Item__c = walkThroughLineItem.Id;
                            rfqLinesToUpdate.add(rfqLine);
                        }
                    }
                }
                if (!rfqLinesToUpdate.isEmpty()) {
                    update rfqLinesToUpdate;
                }

                List<buildertek__Walk_Through_Line_Items__c> removeRfqFromWalkThroughLineList = [SELECT Id, buildertek__BT_RFQ_Line__c FROM buildertek__Walk_Through_Line_Items__c WHERE Id NOT IN :newWalkThroughLineItems AND buildertek__BT_RFQ_Line__c IN :rfqLineIds];
                if(!removeRfqFromWalkThroughLineList.isEmpty()){
                    for(buildertek__Walk_Through_Line_Items__c walkThroughLineItem : removeRfqFromWalkThroughLineList){
                        walkThroughLineItem.buildertek__BT_RFQ_Line__c = null;
                    }
                    update removeRfqFromWalkThroughLineList;
                }
                
            } catch (Exception e) {
                List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
            } finally {
                isExecuting = false;
            }
        }
    }
    
    public static void onAfterUpdate(List<buildertek__Walk_Through_Line_Items__c> updatedWalkThroughLineItems, Map<Id, buildertek__Walk_Through_Line_Items__c> oldWalkThroughLineItemsMap) {
        if (!isExecuting) {
            isExecuting = true;
            Set<Id> rfqLineIdsToUpdate = new Set<Id>();
            Map<Id, Id> rfqLineItemMap = new Map<Id, Id>();
            
            try {
                for (buildertek__Walk_Through_Line_Items__c updatedWalkThroughLineItem : updatedWalkThroughLineItems) {
                    buildertek__Walk_Through_Line_Items__c oldWalkThroughLineItem = oldWalkThroughLineItemsMap.get(updatedWalkThroughLineItem.Id);
                    
                    if (updatedWalkThroughLineItem.buildertek__BT_RFQ_Line__c != oldWalkThroughLineItem.buildertek__BT_RFQ_Line__c) {
                        if (updatedWalkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                            rfqLineIdsToUpdate.add(updatedWalkThroughLineItem.buildertek__BT_RFQ_Line__c);
                            rfqLineItemMap.put(updatedWalkThroughLineItem.buildertek__BT_RFQ_Line__c, updatedWalkThroughLineItem.Id);
                        }
                        if (oldWalkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                            rfqLineIdsToUpdate.add(oldWalkThroughLineItem.buildertek__BT_RFQ_Line__c);
                            rfqLineItemMap.put(oldWalkThroughLineItem.buildertek__BT_RFQ_Line__c, null);
                        }
                    }
                }

                Map<Id, buildertek__RFQ_Item__c> rfqLinesMap = new Map<Id, buildertek__RFQ_Item__c>([
                    SELECT Id, buildertek__BT_Walk_Through_Line_Item__c
                    FROM buildertek__RFQ_Item__c
                    WHERE Id IN :rfqLineIdsToUpdate
                ]);
                
                List<buildertek__RFQ_Item__c> rfqLinesToUpdate = new List<buildertek__RFQ_Item__c>();
                for (Id rfqLineId : rfqLineIdsToUpdate) {
                    buildertek__RFQ_Item__c rfqLine = rfqLinesMap.get(rfqLineId);
                    if (rfqLine != null) {
                        rfqLine.buildertek__BT_Walk_Through_Line_Item__c = rfqLineItemMap.get(rfqLineId);
                        rfqLinesToUpdate.add(rfqLine);
                    }
                }
                if (!rfqLinesToUpdate.isEmpty()) {
                    update rfqLinesToUpdate;
                }

                List<buildertek__Walk_Through_Line_Items__c> removeRfqFromWalkThroughLineList = [SELECT Id, buildertek__BT_RFQ_Line__c FROM buildertek__Walk_Through_Line_Items__c WHERE Id NOT IN :updatedWalkThroughLineItems AND buildertek__BT_RFQ_Line__c IN :rfqLineIdsToUpdate];
                if(!removeRfqFromWalkThroughLineList.isEmpty()){
                    for(buildertek__Walk_Through_Line_Items__c walkThroughLineItem : removeRfqFromWalkThroughLineList){
                        walkThroughLineItem.buildertek__BT_RFQ_Line__c = null;
                    }
                    update removeRfqFromWalkThroughLineList;
                }
            } catch (Exception e) {
                List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                } 
            } finally {
                isExecuting = false;
            }
        }
    }                   

    public static void onAfterDelete(List<buildertek__Walk_Through_Line_Items__c> deletedWalkThroughLineItems) {
        if (!isExecuting) {
            isExecuting = true;
            Set<Id> rfqLineIds = new Set<Id>();
            
            try {
                for (buildertek__Walk_Through_Line_Items__c deletedWalkThroughLineItem : deletedWalkThroughLineItems) {
                    if (deletedWalkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                        rfqLineIds.add(deletedWalkThroughLineItem.buildertek__BT_RFQ_Line__c);
                    }
                }
                
                Map<Id, buildertek__RFQ_Item__c> rfqLinesMap = new Map<Id, buildertek__RFQ_Item__c>([
                    SELECT Id, buildertek__BT_Walk_Through_Line_Item__c
                    FROM buildertek__RFQ_Item__c
                    WHERE Id IN :rfqLineIds
                ]);
                
                List<buildertek__RFQ_Item__c> rfqLinesToUpdate = new List<buildertek__RFQ_Item__c>();
                for (buildertek__Walk_Through_Line_Items__c deletedWalkThroughLineItem : deletedWalkThroughLineItems) {
                    if (deletedWalkThroughLineItem.buildertek__BT_RFQ_Line__c != null) {
                        buildertek__RFQ_Item__c rfqLine = rfqLinesMap.get(deletedWalkThroughLineItem.buildertek__BT_RFQ_Line__c);
                        if (rfqLine != null) {
                            rfqLine.buildertek__BT_Walk_Through_Line_Item__c = null;
                            rfqLinesToUpdate.add(rfqLine);
                        }
                    }
                }
                
                if (!rfqLinesToUpdate.isEmpty()) {
                    update rfqLinesToUpdate;
                }
            } catch (Exception e) {
                List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
            } finally {
                isExecuting = false;
            }
        }
    }
}