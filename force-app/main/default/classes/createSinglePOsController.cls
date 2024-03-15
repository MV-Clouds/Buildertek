public with sharing class createSinglePOsController {
    
    @AuraEnabled
    public static ResponseWrapper createPOsFromBOM(Id bomId) {
        ResponseWrapper returnValue = new ResponseWrapper();
        try {
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c FROM buildertek__Project_Selection_Sheet_Takeoff__c WHERE Id = :bomId];

            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Tax_Percent__c, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Category__c FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c = :bomId];
            
            if (!BOMLines.isEmpty()) {
                boolean AllBOMlinesAssigedWithPO =  true;
                boolean AllBOMlinesWithoutVendor =  true;
                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Vendor__c != null){
                        AllBOMlinesAssigedWithPO = false;
                    }
                }
                
                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesWithoutVendor = false;
                    }
                }

                if(AllBOMlinesWithoutVendor == true){
                    returnValue.state = 'Error';
                    returnValue.returnMessage = 'Unable to create purchase order. No vendor assigned to available lines.';
                }
                else if(AllBOMlinesAssigedWithPO == true){
                    returnValue.state = 'Error';
                    returnValue.returnMessage = 'All BOM lines are already assiged to PO.';
                } else {
                    List<buildertek__Purchase_Order__c> createPOList = new List<buildertek__Purchase_Order__c>();
                    Map<Id, buildertek__Purchase_Order__c> poMap = new Map<Id, buildertek__Purchase_Order__c>();
                    Map<Id, String> VendorId_Category = new Map<Id, String>();
                    for (buildertek__Select_Sheet__c bomline : BOMLines) {
                        if (bomline.buildertek__Vendor__c != null && bomline.buildertek__Purchase_Order__c == null){
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = bomline.Name;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = bomline.buildertek__Vendor__c;
                            POtoCreate.buildertek__Cost_Code__c = bomline.buildertek__Cost_Code__c;
                            POtoCreate.buildertek__BT_Build_Phase__c = bomline.buildertek__Build_Phase__c;
                            createPOList.add(POtoCreate);
                            poMap.put(bomline.Id, POtoCreate);
                            VendorId_Category.put(bomline.buildertek__Vendor__c, bomline.buildertek__Category__c);

                        }
                    }
                    
                    if (!createPOList.isEmpty()) {
                        insert createPOList;
                        
                        List<Id> createdPOIds = new List<Id>();
                        for(buildertek__Purchase_Order__c PO : createPOList){
                            createdPOIds.add(PO.Id);
                        }

                        List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOIds];
                        
                        List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                        Map<Id, buildertek__Purchase_Order_Item__c> bomIdToPOLineMap = new Map<Id, buildertek__Purchase_Order_Item__c>();
                        
                        for (buildertek__Select_Sheet__c bomline : BOMLines) {
                            if (bomline.buildertek__Vendor__c != null && bomline.buildertek__Purchase_Order__c == null) {
                                buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                                Poline.Name = bomline.Name;
                                Poline.buildertek__Product__c = bomline.buildertek__Product__c;
                                Poline.buildertek__Quantity__c = bomline.buildertek__Quantity__c;
                                Poline.buildertek__Cost_Code__c = bomline.buildertek__Cost_Code__c;
                                Poline.buildertek__Unit_Price__c = bomline.buildertek__BL_UNIT_COST__c;
                                Poline.buildertek__Tax__c = bomline.buildertek__Tax_Percent__c;
                                Poline.buildertek__Purchase_Order__c = poMap.get(bomline.Id).Id;
                                POlinesToCreate.add(Poline);
                                bomIdToPOLineMap.put(bomline.Id, Poline);
                            }
                        }
                        
                        if (POlinesToCreate.size() > 0) {
                            insert POlinesToCreate;
                        }

                        for (buildertek__Select_Sheet__c bomline : BOMLines) {
                            if (bomline.buildertek__Vendor__c != null && bomline.buildertek__Purchase_Order__c == null) {
                                bomline.buildertek__Purchase_Order__c = poMap.get(bomline.Id).Id;
                                bomline.buildertek__Purchase_Order_Line__c = bomIdToPOLineMap.get(bomline.Id).Id;
                            }
                        }
                        update BOMLines;

                        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id, buildertek__Update_Quantity__c, buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
                        System.debug('BOM.buildertek__Project__c: ' + BOM.buildertek__Project__c);
                        if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                            // if "Match BOM line with Schedule item" admin setting is checked true, run match schedule item logic...

                            List<buildertek__Schedule__c> scheduleList = [SELECT ID, buildertek__Description__c, Name FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                            String scheduleId = '';
                            // used FIRST Schedule of Project for matching logic....
                            if(scheduleList.size() > 0){
                                scheduleId = scheduleList[0].Id;
                                System.debug('matched schedule : ' + scheduleList[0].buildertek__Description__c);
                            }
                            List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Start__c,buildertek__Finish__c, buildertek__BT_Category__c FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: scheduleId ORDER BY CreatedDate DESC];

                            Map<Id, buildertek__Project_Task__c> PO_to_matchedSchItems = new Map<Id, buildertek__Project_Task__c>();
                            List<buildertek__Purchase_Order__c> poToUpdate = new List<buildertek__Purchase_Order__c>();

                            if(ScheduleItems.size() > 0){
                                for(buildertek__Purchase_Order__c PO : CreatedPOs){
                                    for(buildertek__Project_Task__c SchItem : ScheduleItems){
                                        String schItemPhaseName = SchItem.buildertek__Phase__c != null ? SchItem.buildertek__Phase__c.toLowercase() : null;
                                        String poPhaseName = PO.buildertek__BT_Build_Phase__r.Name != null ? PO.buildertek__BT_Build_Phase__r.Name.toLowercase() : null;
                                        String Category = VendorId_Category.containsKey(PO.buildertek__Vendor__c) ? VendorId_Category.get(PO.buildertek__Vendor__c) : null;
                                        // Schedule Item Matching logic -- 
                                        // // schedule item contractor == PO phase (first BOM vendor)  removed as per BUIL-3961....
                                        // schedule item phase == PO phase (first BOM phase)
                                        // schedule item cost code == PO cost code (first BOM cost code)
                                        // schedule item category == PO categorty (first BOM category)
                                        // get first schedule items that match above conditions....
                                        if( SchItem.buildertek__Contractor__c == PO.buildertek__Vendor__c
                                            // && schItemPhaseName == poPhaseName 
                                            && SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c 
                                            && SchItem.buildertek__BT_Category__c == Category 
                                            && !PO_to_matchedSchItems.containsKey(PO.Id)) {
                                            PO_to_matchedSchItems.put(PO.Id, SchItem);
                                            poToUpdate.add(PO);
                                        }
                                    }
                                }

                                system.debug('matched Sch Item : ' + PO_to_matchedSchItems.values());
                                system.debug('no of matched Sch Item : ' + PO_to_matchedSchItems.keySet().size());

                                List<buildertek__Project_Task__c> schItemsToUpdate = new List<buildertek__Project_Task__c>();

                                if(poToUpdate.size() > 0){
                                    for(buildertek__Purchase_Order__c PO : poToUpdate){
                                        buildertek__Project_Task__c MatchedScheduleItem = PO_to_matchedSchItems.get(PO.Id);
                                        PO.buildertek__Schedule__c = scheduleId;
                                        PO.buildertek__Schedule_Item__c = MatchedScheduleItem.Id;
                                        PO.buildertek__Completion__c = MatchedScheduleItem.buildertek__Completion__c;
                                        PO.buildertek__Projected_Start_Date__c = MatchedScheduleItem.buildertek__Start__c;
                                        PO.buildertek__Projected_Completion_Date__c = MatchedScheduleItem.buildertek__Finish__c;
                                        MatchedScheduleItem.buildertek__Purchase_Order__c = PO.Id;
                                        if(MatchedScheduleItem.buildertek__Contractor__c != PO.buildertek__Vendor__c){
                                            MatchedScheduleItem.buildertek__Contractor__c = PO.buildertek__Vendor__c;       // added as per BUIL-3961
                                            MatchedScheduleItem.buildertek__Contractor_Resource__c = null;
                                            MatchedScheduleItem.buildertek__Contractor_Resource_1__c = null;
                                            MatchedScheduleItem.buildertek__Contractor_Resource_2__c = null;
                                            MatchedScheduleItem.buildertek__Contractor_Resource_3__c = null;
                                        }

                                        schItemsToUpdate.add(MatchedScheduleItem);
                                    }
                                }
                                
                                system.debug('poToUpdate : ' + poToUpdate);
                                system.debug('schItemsToUpdate ' + schItemsToUpdate);

                                if(poToUpdate.size() > 0){
                                    update poToUpdate;
                                }
                                if(schItemsToUpdate.size() > 0){
                                    update schItemsToUpdate;
                                }
                            }
                        }

                        returnValue.state = 'Success';
                        returnValue.returnMessage = 'All PO\'s created Successfully.';
                        returnValue.BOMLines = BOMLines;
                    } else {
                        returnValue.state = 'Error';
                        returnValue.returnMessage = 'Failed to create any PO.';
                    }   
                }
            } else {
                returnValue.state = 'Error';
                returnValue.returnMessage = 'Please create atleast one line to create a PO.';
            }
            return returnValue;
        } catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'Error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }

    public class ResponseWrapper {
        @AuraEnabled public String state;
        @AuraEnabled public String returnMessage;
        @AuraEnabled public List<buildertek__Select_Sheet__c> BOMLines;
    }
}