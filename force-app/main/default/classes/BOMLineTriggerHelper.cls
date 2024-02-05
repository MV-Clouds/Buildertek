public with sharing class BOMLineTriggerHelper
{
    private static Boolean isExecuting = false;
    public Map<Id, List<Select_Sheet__c>> getBOMLineFromBOMIds(Set<Id> bomIds)
    {
        Map<Id, List<Select_Sheet__c>> mapBOMIdAndBOMLines = new Map<Id, List<Select_Sheet__c>>();
        /* Comment added by Harika, regarding CAES-54 ticket, Date: 01-08-2022*/
        //for(Select_Sheet__c thisBOMLine : [SELECT Id,Selection_Sheet_Takeoff__c,Takeoff_Line__c,Takeoff_Line__r.TL_SERVICE_CATEGORY__c,Takeoff_Line__r.Product_Code__c FROM Select_Sheet__c WHERE Selection_Sheet_Takeoff__c IN : bomIds AND (Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Work Comp' OR Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Ins' OR Takeoff_Line__r.Product_Code__c = '69201198')])
        for(Select_Sheet__c thisBOMLine : [SELECT Id,Selection_Sheet_Takeoff__c,Takeoff_Line__c,Takeoff_Line__r.TL_SERVICE_CATEGORY__c,Takeoff_Line__r.Product_Code__c FROM Select_Sheet__c WHERE Selection_Sheet_Takeoff__c IN : bomIds AND (Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Work Comp' OR Takeoff_Line__r.TL_SERVICE_CATEGORY__c = 'Insurance' OR Takeoff_Line__r.Product_Code__c = '69201198')])
        {
            if(!mapBOMIdAndBOMLines.containsKey(thisBOMLine.Selection_Sheet_Takeoff__c))
            {
                mapBOMIdAndBOMLines.put(thisBOMLine.Selection_Sheet_Takeoff__c, new List<Select_Sheet__c>());
            }
            
            mapBOMIdAndBOMLines.get(thisBOMLine.Selection_Sheet_Takeoff__c).add(thisBOMLine);
        }

        return mapBOMIdAndBOMLines;
    }
   /* public static void afterUpdate(Map<Id, buildertek__Select_Sheet__c> oldTakeOffLineMap, Map<Id, buildertek__Select_Sheet__c> newTakeOffLineMap, 
                           List<buildertek__Select_Sheet__c> oldTakeOffLines, List<buildertek__Select_Sheet__c> newTakeOffLines
                           ){
           list<ID> takeoffLineId = new list<ID>();     
                               Map<Id, buildertek__Project_Takeoff_Lines__c> updates = new Map<Id, buildertek__Project_Takeoff_Lines__c>();
           List<buildertek__Project_Takeoff_Lines__c> selectionsheetlist = new List<buildertek__Project_Takeoff_Lines__c>();
                               List<buildertek__Project_Takeoff_Lines__c> selectionsheetlist1 = new List<buildertek__Project_Takeoff_Lines__c>();
                               for(buildertek__Select_Sheet__c bomlinerec : newTakeOffLines){
                                    takeoffLineId.add(bomlinerec.buildertek__Takeoff_Line__c);   
                               } 
                               selectionsheetlist = [Select id,Name,buildertek__Location__c,
                                                     buildertek__Build_Phase__c,buildertek__Quantity__c,buildertek__TL_SERVICE_CATEGORY__c
                                                     from buildertek__Project_Takeoff_Lines__c where
                                                    ID IN: takeoffLineId];   
                               for(buildertek__Select_Sheet__c takeofflirec: newTakeOffLines){
                                   for(buildertek__Project_Takeoff_Lines__c bomlineRec: selectionsheetlist){
                                       if(takeofflirec.buildertek__Takeoff_Line__c == bomlineRec.id ){
                                          /* bomlineRec.buildertek__Location_Picklist__c = takeofflirec.buildertek__Location__c; 
                                           bomlineRec.buildertek__Build_Phase__c = takeofflirec.buildertek__Build_Phase__c; 
                                           bomlineRec.buildertek__Quantity__c = takeofflirec.buildertek__Quantity__c;
                                           bomlineRec.buildertek__Service_Category__c = takeofflirec.buildertek__TL_SERVICE_CATEGORY__c;*/
                                   /*        bomlineRec.buildertek__Location__c = takeofflirec.buildertek__Location_Picklist__c; 
                                           bomlineRec.buildertek__Build_Phase__c = takeofflirec.buildertek__Build_Phase__c; 
                                           bomlineRec.buildertek__Quantity__c = takeofflirec.buildertek__Quantity__c;
                                           bomlineRec.buildertek__TL_SERVICE_CATEGORY__c = takeofflirec.buildertek__Service_Category__c;
                                           selectionsheetlist1.add(bomlineRec);
                                       }
                                   }
                               }
                               update selectionsheetlist1;
   }*/

    public static void onAfterInsert(List<buildertek__Select_Sheet__c> newBomLineList) {
        try {
            String methodName = 'onAfterInsert';
            Set<Id> bomIds = new Set<Id>();
            for (buildertek__Select_Sheet__c bomLine : newBomLineList) {
                if(bomLine.buildertek__Selection_Sheet_Takeoff__c != null) {
                    bomIds.add(bomLine.buildertek__Selection_Sheet_Takeoff__c);
                }
            }
            if (!bomIds.isEmpty()) {
                updateAmountOnBOM(bomIds, methodName);
                
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void onAfterUpdate(List<buildertek__Select_Sheet__c> newBOMLineList, Map<Id, buildertek__Select_Sheet__c> oldBOMLineMap) {
        try {
            String methodName = 'onAfterUpdate';
            Set<Id> bomIds = new Set<Id>();

            for (buildertek__Select_Sheet__c bomLine : newBOMLineList) {
                buildertek__Select_Sheet__c oldbomLine = oldBOMLineMap.get(bomLine.Id);

                if (bomLine.buildertek__Selection_Sheet_Takeoff__c != oldbomLine.buildertek__Selection_Sheet_Takeoff__c || bomLine.buildertek__Total_Costs__c != oldbomLine.buildertek__Total_Costs__c || bomLine.buildertek__Total_Sales_Price__c != oldbomLine.buildertek__Total_Sales_Price__c) {
                    
                    if(oldbomLine.buildertek__Selection_Sheet_Takeoff__c != null){
                        bomIds.add(oldbomLine.buildertek__Selection_Sheet_Takeoff__c);
                    }
                    
                    if(bomLine.buildertek__Selection_Sheet_Takeoff__c != null){
                        bomIds.add(bomLine.buildertek__Selection_Sheet_Takeoff__c);
                    }
                }
            }

            if (!bomIds.isEmpty()) {
                updateAmountOnBOM(bomIds, methodName);
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void onAfterDelete(List<buildertek__Select_Sheet__c> oldBOMLineList) {
        try {
            String methodName = 'onAfterDelete';
            Set<Id> bomIds = new Set<Id>();
            for (buildertek__Select_Sheet__c bomLine : oldBOMLineList) {
                if(bomLine.buildertek__Selection_Sheet_Takeoff__c != null){
                    bomIds.add(bomLine.buildertek__Selection_Sheet_Takeoff__c);
                }
            }
            updateAmountOnBOM(bomIds, methodName);
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }

    public static void updateAmountOnBOM(Set<Id> BOMIds, String methodName) {
        try {
            Map<Id, AggregateResult> totalAmountMap = new Map<Id, AggregateResult>();
            for (AggregateResult aggregatedResult : [SELECT buildertek__Selection_Sheet_Takeoff__c, SUM(buildertek__Total_Costs__c) totalCost, SUM(buildertek__Total_Sales_Price__c) totalSales FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c IN :BOMIds GROUP BY buildertek__Selection_Sheet_Takeoff__c]){
                Id BOMId = (Id)aggregatedResult.get('buildertek__Selection_Sheet_Takeoff__c');
                totalAmountMap.put(BOMId, aggregatedResult);
            }
            
            List<buildertek__Project_Selection_Sheet_Takeoff__c> bomToUpdate = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
            
            for (Id BOMId :BOMIds) {
                if(totalAmountMap.containsKey(BOMId)) {
                    AggregateResult aggregatedResult = totalAmountMap.get(BOMId);
                    Decimal totalCost = (Decimal)aggregatedResult.get('totalCost');
                    Decimal totalSales = (Decimal)aggregatedResult.get('totalSales');
                    buildertek__Project_Selection_Sheet_Takeoff__c bom = new buildertek__Project_Selection_Sheet_Takeoff__c(Id = BOMId);
                    bom.buildertek__Total_Costs__c = totalCost;
                    bom.buildertek__Total_Sales_Price__c = totalSales;
                    if (methodName == 'onAfterInsert'){
                        bom.buildertek__Status__c = 'Open';
                    }
                    bomToUpdate.add(bom);
                } else {
                    buildertek__Project_Selection_Sheet_Takeoff__c bom = new buildertek__Project_Selection_Sheet_Takeoff__c(Id = BOMId);
                    bom.buildertek__Total_Costs__c = 0;
                    bom.buildertek__Total_Sales_Price__c = 0;
                    if (methodName == 'onAfterInsert'){
                        bom.buildertek__Status__c = 'Open';
                    }
                    bomToUpdate.add(bom);
                }
            }

            System.debug('bomToUpdate: ' + bomToUpdate);
            if (!bomToUpdate.isEmpty()) {
                update bomToUpdate;
            }

        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }
    
    public static void updateStatusOnBOM(List<buildertek__Select_Sheet__c> bomLineIds) {
        if (!isExecuting) {
            isExecuting = true;
            try {
                Set<Id> bomIds = new Set<Id>();
                // For fetching all the BOM Ids
                for (buildertek__Select_Sheet__c bomLine : bomLineIds) {
                    if(bomLine.buildertek__Selection_Sheet_Takeoff__c != null){
                        bomIds.add(bomLine.buildertek__Selection_Sheet_Takeoff__c);
                    }
                }
                if (!bomIds.isEmpty()) {
                    List<buildertek__Select_Sheet__c> bomLines = [SELECT Id, Name, buildertek__Purchase_Order__c, buildertek__Selection_Sheet_Takeoff__c FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c IN :bomIds];
                    // Creating a map of BOM Id and count of POs
                    Map<Id, Integer> bomIdToPoCountMap = new Map<Id, Integer>();
                    for (buildertek__Select_Sheet__c bomLine : bomLines) {
                        Id bomId = bomLine.buildertek__Selection_Sheet_Takeoff__c;
                        
                        if (!bomIdToPoCountMap.containsKey(bomId)) {
                            bomIdToPoCountMap.put(bomId, 0);
                        }

                        bomIdToPoCountMap.put(bomId, bomIdToPoCountMap.get(bomId) + (bomLine.buildertek__Purchase_Order__c != null ? 1 : 0));
                    }
            
                    List<buildertek__Project_Selection_Sheet_Takeoff__c> updatedBOMs = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
                    // Updating the status of BOMs
                    for (Id bomId : bomIdToPoCountMap.keySet()) {
                        Integer poCount = bomIdToPoCountMap.get(bomId);
                        buildertek__Project_Selection_Sheet_Takeoff__c updatedBOM = new buildertek__Project_Selection_Sheet_Takeoff__c(Id = bomId);

                        if (poCount <= 0) {
                            updatedBOM.buildertek__Status__c = 'Open';
                        } else if (poCount == bomLines.size()) {
                            updatedBOM.buildertek__Status__c = 'Ordered';
                        } else {
                            updatedBOM.buildertek__Status__c = 'Partially Ordered';
                        }
                        updatedBOMs.add(updatedBOM);
                    }
                    // Updating the status of BOMs which are not present in bomIdToPoCountMap
                    Set<Id> bomIdsWithoutCount = bomIds.clone();
                    bomIdsWithoutCount.removeAll(bomIdToPoCountMap.keySet());
                    for (Id bomId : bomIdsWithoutCount) {
                        buildertek__Project_Selection_Sheet_Takeoff__c updatedBOM = new buildertek__Project_Selection_Sheet_Takeoff__c(Id = bomId);
                        updatedBOM.buildertek__Status__c = 'Open';
                        updatedBOMs.add(updatedBOM);
                    }

                    if (!updatedBOMs.isEmpty()) {
                        update updatedBOMs;
                    }
                }
            } catch (Exception ex) {
                System.debug('Error: ' + ex.getMessage());
                List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c LIMIT 1];
                
                if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c) {
                    BT_ExceptionHandler.Store_Exception(ex);
                }
            } finally {
                isExecuting = false;
            }
        }
    }
    
}