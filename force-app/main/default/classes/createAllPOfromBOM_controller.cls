public class createAllPOfromBOM_controller {

    @AuraEnabled
    public static responseWrapper createAllPO(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try {
            System.debug('BOMId ==> ' + BOMId);

            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMId];

            System.debug('BOM ==> ' + BOM);

            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,
                                                          buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                          FROM buildertek__Select_Sheet__c 
                                                          WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMId];
            if(BOMLines.size() > 0){

                boolean AllBOMlinesAssigesWithPO =  true;
                boolean AllBOMlinesNotHaveVendor =  true;
                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Vendor__c != null){
                        AllBOMlinesAssigesWithPO = false;
                    }
                }
                
                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesNotHaveVendor = false;
                    }
                }

                if(AllBOMlinesNotHaveVendor == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'Unable to create a PO. There are no vendors assigned to any PO lines.';               
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All PO lines are already assiged to a PO.';    
                }
                else{

                    
                    Map<Id, Id> BOMlineId_VendorId = new Map<Id, Id>();
                    Map<Id, Id> VenodrId_CostCode = new Map<Id, Id>();
                    Map<Id, Id> VenodrId_Phase = new Map<Id, Id>();
                    Map<Id, String> VenodrId_Category = new Map<Id, String>();
                    Set<String> vendorList = new Set<String>();
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Vendor__c != null && line.buildertek__Purchase_Order__c == null){
                            vendorList.add(line.buildertek__Vendor__c);   

                            BOMlineId_VendorId.put(line.Id, line.buildertek__Vendor__c);

                            // Get Cost code and Phase value of First BOM Line which match condition for perticulart vendor....
                            if(line.buildertek__Cost_Code__c != null && line.buildertek__Build_Phase__c != null && line.buildertek__Category__c != null && !VenodrId_CostCode.containsKey(line.buildertek__Vendor__c)){
                                VenodrId_CostCode.put(line.buildertek__Vendor__c, line.buildertek__Cost_Code__c);
                                VenodrId_Phase.put(line.buildertek__Vendor__c, line.buildertek__Build_Phase__c);
                                VenodrId_Category.put(line.buildertek__Vendor__c, line.buildertek__Category__c);
                            }
                        }
                    }
                    Map<String, Id> recordTypeMap = new Map<String, Id>();
                    for (Schema.RecordTypeInfo rt : buildertek__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
                    }

                    Id standardPurchaseOrderRecordTypeId = recordTypeMap.get('Standard');
                    
                    system.debug('VenodrId_CostCode : ' + VenodrId_Phase);
                    system.debug('VenodrId_Phase : ' + VenodrId_Phase);
                    system.debug('VenodrId_Category : ' + VenodrId_Category);
                    
                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();
                    List<Id> createdPOsIds = new List<Id>();
                    if(vendorList.size() > 0){
                        for(String VendorId : vendorList){
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = VendorId;
                            POtoCreate.buildertek__Cost_Code__c = VenodrId_CostCode.containsKey(VendorId) ? VenodrId_CostCode.get(VendorId) : null;      // Assign cost code...
                            POtoCreate.buildertek__BT_Build_Phase__c = VenodrId_Phase.containsKey(VendorId) ? VenodrId_Phase.get(VendorId) : null;    // Assign Phase...
                            POtoCreate.RecordTypeId = standardPurchaseOrderRecordTypeId;
                            POsToCreate_List.add(POtoCreate);
                            
                        }
                    }
                    
                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }

                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        createdPOsIds.add(PO.Id);
                    }
                    List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOsIds];

                    system.debug('no of create POs ==> ' + POsToCreate_List.size());
                    
                    Map<Id, Id> VendorId_POId = new Map<Id, Id>();
                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        VendorId_POId.put(PO.buildertek__Vendor__c, PO.Id);
                    }
                    system.debug('VendorId_POId ==> ' + VendorId_POId);
                    
                    List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                    Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();
                    
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Vendor__c != null && line.buildertek__Purchase_Order__c == null){
                            buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                            Poline.Name = line.Name;
                            Poline.buildertek__Product__c = line.buildertek__Product__c;
                            Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                            Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                            Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;
                            Poline.buildertek__Purchase_Order__c = VendorId_POId.get(line.buildertek__Vendor__c);
                            POlinesToCreate.add(Poline);
                            LineId_POlines.put(line.Id, Poline);
                        }
                    }
                    
                    if(POlinesToCreate.size() > 0){
                        insert POlinesToCreate;
                    }
                    system.debug('no of create PO Lines ==> ' + POlinesToCreate.size());
        
                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Vendor__c != null && line.buildertek__Purchase_Order__c == null){
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = VendorId_POId.get(line.buildertek__Vendor__c);
                        }
                    }
                    update BOMlines;

                    // ---------------------------------------- Schedule item matching and Mapping Field Logic --------------------------

                    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
                    // if "Match BOM line with Schedule item" admin setting is checked true, run match schedule item logic...
                    if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                        List<buildertek__Schedule__c> scheduleList = [SELECT ID,buildertek__Description__c, Name FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                        String scheduleId = '';
                        // used FIRST Schedule of Project for matching logic....
                        if(scheduleList.size() > 0){
                            scheduleId = scheduleList[0].Id;
                            System.debug('matched schedule : ' + scheduleList[0].buildertek__Description__c);
                        }
                        List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Start__c,buildertek__Finish__c, buildertek__BT_Category__c
                                                                            FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: scheduleId  ORDER BY CreatedDate DESC];

                        Map<Id, buildertek__Project_Task__c> PO_to_matchedSchItems = new Map<Id, buildertek__Project_Task__c>();
                        List<buildertek__Purchase_Order__c> poToUpdate = new List<buildertek__Purchase_Order__c>();

                        if(ScheduleItems.size() > 0){
                                for(buildertek__Purchase_Order__c PO : CreatedPOs){
                                    for(buildertek__Project_Task__c SchItem : ScheduleItems){
                                        String schItemPhaseName = SchItem.buildertek__Phase__c != null ? SchItem.buildertek__Phase__c.toLowercase() : null;
                                        String poPhaseName = PO.buildertek__BT_Build_Phase__r.Name != null ? PO.buildertek__BT_Build_Phase__r.Name.toLowercase() : null;
                                        String Category = VenodrId_Category.containsKey(PO.buildertek__Vendor__c) ? VenodrId_Category.get(PO.buildertek__Vendor__c) : null;
                                        // Schedule Item Matching logic -- 
                                        // // schedule item contractor == PO phase (first BOM vendor)  removed as per BUIL-3961....
                                        // schedule item phase == PO phase (first BOM phase)
                                        // schedule item cost code == PO cost code (first BOM cost code)
                                        // schedule item category == PO categorty (first BOM category)
                                        // get first schedule items that match above conditions....
                                        List<Id> matchedSchItems = new List<Id>();

                                        if( SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c //SchItem.buildertek__Contractor__c == PO.buildertek__Vendor__c
                                            // && schItemPhaseName == poPhaseName 
                                            //&& SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c 
                                            && SchItem.buildertek__BT_Category__c == Category 
                                            && !PO_to_matchedSchItems.containsKey(PO.Id)
                                            && !matchedSchItems.contains(SchItem.Id))
                                        {
                                            PO_to_matchedSchItems.put(PO.Id, SchItem);
                                            poToUpdate.add(PO);
                                            matchedSchItems.add(SchItem.Id);

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
                                            // poToUpdate.add(PO);
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

                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                }
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'You must create at least one PO line in order to create a PO.';
            }

            return returnValue;
            
        } catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }

    @AuraEnabled
    public static responseWrapper createAllPOWithCostCode(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try {
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMId];

            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,
                                                          buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                          FROM buildertek__Select_Sheet__c 
                                                          WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMId];
            
            if(BOMLines.size() > 0){
                boolean AllBOMlinesAssigesWithPO =  true;
                boolean AllBOMlinesNotHaveCostCode =  true;
                boolean AllBOMlinesNotHaveVendor =  true;

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Cost_Code__c != null){
                        AllBOMlinesAssigesWithPO = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Cost_Code__c != null){
                        AllBOMlinesNotHaveCostCode = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesNotHaveVendor = false;
                    }
                }

                if(AllBOMlinesNotHaveCostCode == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'We were unable to create a PO. No cost codes were assigned to an available line.';
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All PO lines have already been assiged to a PO.';
                }else if(AllBOMlinesNotHaveVendor == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'Unable to create a PO. There are no vendors assigned to any PO lines.';
                }
                else{
                    Map<String, Id> recordTypeMap = new Map<String, Id>();
                    for (Schema.RecordTypeInfo rt : buildertek__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
                    }

                    Id standardPurchaseOrderRecordTypeId = recordTypeMap.get('Standard');

                    Map<String, Id> CostCodeVendorId_BOMLineId = new Map<String, Id>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Cost_Code__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Cost_Code__c + '_' + line.buildertek__Vendor__c;
                            CostCodeVendorId_BOMLineId.put(key, line.Id);
                        }
                    }

                    Map<String, Id> CostCodeVendorId_CategoryId = new Map<String, Id>();
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Cost_Code__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Cost_Code__c + '_' + line.buildertek__Vendor__c;
                            if(line.buildertek__Category__c != null ){
                                if(!CostCodeVendorId_CategoryId.containsKey(key)){
                                    CostCodeVendorId_CategoryId.put(key, line.buildertek__Category__c);
                                }
                            }
                        }
                    }

                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();
                    if(CostCodeVendorId_BOMLineId.size() > 0){
                        for(String key : CostCodeVendorId_BOMLineId.keySet()){
                            List<String> keyList = key.split('_');
                            String CostCode = keyList[0];
                            String VendorId = keyList[1];
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = VendorId;
                            POtoCreate.buildertek__Cost_Code__c = CostCode;
                            POtoCreate.buildertek__Category__c = CostCodeVendorId_CategoryId.get(key);
                            POtoCreate.RecordTypeId = standardPurchaseOrderRecordTypeId;
                            POsToCreate_List.add(POtoCreate);
                        }
                    }

                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }

                    //itetate through the CostCodeVendorId_BOMLineId map and create PO lines for each PO
                    List<Id> createdPOsIds = new List<Id>();
                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        createdPOsIds.add(PO.Id);
                    }

                    List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name, buildertek__Category__c  FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOsIds];

                    Map<String, Id> CostCodeVendorId_POId = new Map<String, Id>();

                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        String key = PO.buildertek__Cost_Code__c + '_' + PO.buildertek__Vendor__c;
                        CostCodeVendorId_POId.put(key, PO.Id);
                    }

                    List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                    Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Cost_Code__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Cost_Code__c + '_' + line.buildertek__Vendor__c;
                            buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                            Poline.Name = line.Name;
                            Poline.buildertek__Product__c = line.buildertek__Product__c;
                            Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                            Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                            Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;
                            Poline.buildertek__Purchase_Order__c = CostCodeVendorId_POId.get(key);
                            POlinesToCreate.add(Poline);
                            LineId_POlines.put(line.Id, Poline);
                        }
                    }

                    if(POlinesToCreate.size() > 0){
                        insert POlinesToCreate;
                    }

                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Cost_Code__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Cost_Code__c + '_' + line.buildertek__Vendor__c;
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = CostCodeVendorId_POId.get(key);
                        }
                    }

                    update BOMlines;

                    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
                    // if "Match BOM line with Schedule item" admin setting is checked true, run match schedule item logic...
                    if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                        List<buildertek__Schedule__c> scheduleList = [SELECT ID,buildertek__Description__c, Name FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                        String scheduleId = '';
                        // used FIRST Schedule of Project for matching logic....
                        if(scheduleList.size() > 0){
                            scheduleId = scheduleList[0].Id;
                            System.debug('matched schedule : ' + scheduleList[0].buildertek__Description__c);
                        }
                        List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Start__c,buildertek__Finish__c, buildertek__BT_Category__c
                                                                            FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: scheduleId  ORDER BY CreatedDate DESC];

                        Map<Id, buildertek__Project_Task__c> PO_to_matchedSchItems = new Map<Id, buildertek__Project_Task__c>();
                        List<buildertek__Purchase_Order__c> poToUpdate = new List<buildertek__Purchase_Order__c>();
                        List<Id> matchedSchItems = new List<Id>();

                        if(ScheduleItems.size() > 0){
                                for(buildertek__Purchase_Order__c PO : CreatedPOs){
                                    for(buildertek__Project_Task__c SchItem : ScheduleItems){
                                        String schItemPhaseName = SchItem.buildertek__Phase__c != null ? SchItem.buildertek__Phase__c.toLowercase() : null;
                                        String poPhaseName = PO.buildertek__BT_Build_Phase__r.Name != null ? PO.buildertek__BT_Build_Phase__r.Name.toLowercase() : null;
                                        String key = PO.buildertek__Cost_Code__c + '_' + PO.buildertek__Vendor__c;
                                        String Category = PO.buildertek__Category__c;

                                        if( SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c 
                                            && SchItem.buildertek__BT_Category__c == Category 
                                            && !PO_to_matchedSchItems.containsKey(PO.Id)
                                            && !matchedSchItems.contains(SchItem.Id))
                                        {
                                            PO_to_matchedSchItems.put(PO.Id, SchItem);
                                            poToUpdate.add(PO);
                                            matchedSchItems.add(SchItem.Id);
                                            // Integer index =  ScheduleItems.indexOf(SchItem);
                                            // ScheduleItems.remove(index);
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

                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                    
                }

                
                
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'You must create at least one PO line in order to create a PO.';

            }
            return returnValue;
        }
        catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }

    @AuraEnabled
    public static responseWrapper createAllPOWithTradeType(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try{
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMId];
            
            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, buildertek__Trade_Type__c,
                                                            buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                            FROM buildertek__Select_Sheet__c 
                                                            WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMId];

            if(BOMLines.size() > 0){
                boolean AllBOMlinesAssigesWithPO = true;
                boolean AllBOMlinesNotHaveTradeType = true;
                boolean AllBOMlinesNotHaveVendor = true;

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Trade_Type__c != null){
                        AllBOMlinesAssigesWithPO = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Trade_Type__c != null){
                        AllBOMlinesNotHaveTradeType = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesNotHaveVendor = false;
                    }
                }

                if(AllBOMlinesNotHaveTradeType == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'We are unable to create purchase order. No trade types have been assigned to an available line.';
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All PO lines have been assiged to a PO.';
                }else if(AllBOMlinesNotHaveVendor == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'Unable to create a PO. There are no vendors assigned to any PO lines.';
                }
                else{
                    Map<String, Id> recordTypeMap = new Map<String, Id>();
                    for (Schema.RecordTypeInfo rt : buildertek__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
                    }

                    Id standardPurchaseOrderRecordTypeId = recordTypeMap.get('Standard');

                    Map<String, Id> TradeTypeVendorId_BOMLineId = new Map<String, Id>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Trade_Type__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Trade_Type__c + '_' + line.buildertek__Vendor__c;
                            TradeTypeVendorId_BOMLineId.put(key, line.Id);
                        }
                    }

                    //create a map of TradeTypeVendorId and CostCode
                    Map<String, String> TradeTypeVendorId_CostCode = new Map<String, String>();
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Trade_Type__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Trade_Type__c + '_' + line.buildertek__Vendor__c;
                            if(line.buildertek__Cost_Code__c != null){
                                if(!TradeTypeVendorId_CostCode.containsKey(key)){
                                    TradeTypeVendorId_CostCode.put(key, line.buildertek__Cost_Code__c);
                                }
                            }
                        }
                    }

                    //create a map of TradeTypeVendorId and Category
                    Map<String, Id> TradeTypeVendorId_Category = new Map<String, Id>();
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Trade_Type__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Trade_Type__c + '_' + line.buildertek__Vendor__c;
                            if(line.buildertek__Category__c != null){
                                if(!TradeTypeVendorId_Category.containsKey(key)){
                                    TradeTypeVendorId_Category.put(key, line.buildertek__Category__c);
                                }
                            }
                        }
                    }



                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();
                    if(TradeTypeVendorId_BOMLineId.size() > 0){
                        for(String key : TradeTypeVendorId_BOMLineId.keySet()){
                            List<String> keyList = key.split('_');
                            String TradeType = keyList[0];
                            String VendorId = keyList[1];
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = VendorId;
                            POtoCreate.buildertek__Trade_Type__c = TradeType;
                            POtoCreate.buildertek__Cost_Code__c = TradeTypeVendorId_CostCode.get(key);
                            POtoCreate.buildertek__Category__c = TradeTypeVendorId_Category.get(key);
                            POtoCreate.RecordTypeId = standardPurchaseOrderRecordTypeId;
                            POsToCreate_List.add(POtoCreate);
                        }
                    }

                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }

                    //itetate through the TradeTypeVendorId_BOMLineId map and create PO lines for each PO
                    List<Id> createdPOsIds = new List<Id>();
                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        createdPOsIds.add(PO.Id);
                    }

                    List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOsIds];

                    Map<String, Id> TradeTypeVendorId_POId = new Map<String, Id>();

                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        String key = PO.buildertek__Trade_Type__c + '_' + PO.buildertek__Vendor__c;
                        TradeTypeVendorId_POId.put(key, PO.Id);
                    }

                    List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                    Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Trade_Type__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Trade_Type__c + '_' + line.buildertek__Vendor__c;
                            buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                            Poline.Name = line.Name;
                            Poline.buildertek__Product__c = line.buildertek__Product__c;
                            Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                            Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                            Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;
                            Poline.buildertek__Purchase_Order__c = TradeTypeVendorId_POId.get(key);
                            POlinesToCreate.add(Poline);
                            LineId_POlines.put(line.Id, Poline);
                        }
                    }

                    if(POlinesToCreate.size() > 0){
                        insert POlinesToCreate;
                    }

                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Trade_Type__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Trade_Type__c + '_' + line.buildertek__Vendor__c;
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = TradeTypeVendorId_POId.get(key);
                        }
                    }

                    update BOMlines;

                    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
                    // if "Match BOM line with Schedule item" admin setting is checked true, run match schedule item logic...
                    if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                        List<buildertek__Schedule__c> scheduleList = [SELECT ID,buildertek__Description__c, Name FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                        String scheduleId = '';
                        // used FIRST Schedule of Project for matching logic....
                        if(scheduleList.size() > 0){
                            scheduleId = scheduleList[0].Id;
                            System.debug('matched schedule : ' + scheduleList[0].buildertek__Description__c);
                        }
                        List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Start__c,buildertek__Finish__c, buildertek__BT_Category__c
                                                                            FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: scheduleId  ORDER BY CreatedDate DESC];

                        Map<Id, buildertek__Project_Task__c> PO_to_matchedSchItems = new Map<Id, buildertek__Project_Task__c>();
                        List<buildertek__Purchase_Order__c> poToUpdate = new List<buildertek__Purchase_Order__c>();
                        List<Id> matchedSchItems = new List<Id>();

                        if(ScheduleItems.size() > 0){
                                for(buildertek__Purchase_Order__c PO : CreatedPOs){
                                    for(buildertek__Project_Task__c SchItem : ScheduleItems){
                                        String schItemPhaseName = SchItem.buildertek__Phase__c != null ? SchItem.buildertek__Phase__c.toLowercase() : null;
                                        String poPhaseName = PO.buildertek__BT_Build_Phase__r.Name != null ? PO.buildertek__BT_Build_Phase__r.Name.toLowercase() : null;
                                        String key = PO.buildertek__Trade_Type__c + '_' + PO.buildertek__Vendor__c;
                                        String Category = TradeTypeVendorId_Category.get(key);


                                        if( SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c 
                                            && SchItem.buildertek__BT_Category__c == Category 
                                            && !PO_to_matchedSchItems.containsKey(PO.Id)
                                            && !matchedSchItems.contains(SchItem.Id))
                                        {
                                            PO_to_matchedSchItems.put(PO.Id, SchItem);
                                            poToUpdate.add(PO);
                                            matchedSchItems.add(SchItem.Id);
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
                                            // poToUpdate.add(PO);
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

                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                }
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'Please create atleast one line to create PO.';
            }
            return returnValue;

        }catch(Exception e){
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }

    @AuraEnabled
    public static responseWrapper createAllPOWithBuildPhase(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try{
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMId];
            
            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, buildertek__Trade_Type__c,
                                                            buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                            FROM buildertek__Select_Sheet__c 
                                                            WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMId];

            if(BOMLines.size() > 0){
                boolean AllBOMlinesAssigesWithPO = true;
                boolean AllBOMlinesNotHaveBuildPhase = true;
                boolean AllBOMlinesNotHaveVendor = true;

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Build_Phase__c != null){
                        AllBOMlinesAssigesWithPO = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Build_Phase__c != null){
                        AllBOMlinesNotHaveBuildPhase = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesNotHaveVendor = false;
                    }
                }

                if(AllBOMlinesNotHaveBuildPhase == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'We are unable to create a purchase order. No build phase was assigned to an available line.';
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All PO lines have been assiged to a PO.';
                }else if(AllBOMlinesNotHaveVendor == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'We are unable to create a PO. There are no vendors assigned to any PO lines.';
                }
                else{
                    Map<String, Id> recordTypeMap = new Map<String, Id>();
                    for (Schema.RecordTypeInfo rt : buildertek__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
                    }

                    Id standardPurchaseOrderRecordTypeId = recordTypeMap.get('Standard');

                    Map<String, Id> BuildPhaseVendorId_BOMLineId = new Map<String, Id>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Build_Phase__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Build_Phase__c + '_' + line.buildertek__Vendor__c;
                            BuildPhaseVendorId_BOMLineId.put(key, line.Id);
                        }
                    }

                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();
                    if(BuildPhaseVendorId_BOMLineId.size() > 0){
                        for(String key : BuildPhaseVendorId_BOMLineId.keySet()){
                            List<String> keyList = key.split('_');
                            String BuildPhase = keyList[0];
                            String VendorId = keyList[1];
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = VendorId;
                            POtoCreate.buildertek__BT_Build_Phase__c = BuildPhase;
                            POtoCreate.RecordTypeId = standardPurchaseOrderRecordTypeId;
                            POsToCreate_List.add(POtoCreate);
                        }
                    }

                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }

                    //itetate through the BuildPhaseVendorId_BOMLineId map and create PO lines for each PO
                    List<Id> createdPOsIds = new List<Id>();
                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        createdPOsIds.add(PO.Id);
                    }

                    List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOsIds];

                    Map<String, Id> BuildPhaseVendorId_POId = new Map<String, Id>();

                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        String key = PO.buildertek__BT_Build_Phase__c + '_' + PO.buildertek__Vendor__c;
                        BuildPhaseVendorId_POId.put(key, PO.Id);
                    }

                    List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                    Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Build_Phase__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Build_Phase__c + '_' + line.buildertek__Vendor__c;
                            buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                            Poline.Name = line.Name;
                            Poline.buildertek__Product__c = line.buildertek__Product__c;
                            Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                            Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                            Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;
                            Poline.buildertek__Purchase_Order__c = BuildPhaseVendorId_POId.get(key);
                            POlinesToCreate.add(Poline);
                            LineId_POlines.put(line.Id, Poline);
                        }
                    }

                    if(POlinesToCreate.size() > 0){
                        insert POlinesToCreate;
                    }

                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Build_Phase__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Build_Phase__c + '_' + line.buildertek__Vendor__c;
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = BuildPhaseVendorId_POId.get(key);
                        }
                    }

                    update BOMlines;

                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                }
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'Please create atleast one line to create PO.';
            }
            return returnValue;
        }
        catch(Exception e){
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }

    @AuraEnabled
    //createAllPOWithCategory
    public static responseWrapper createAllPOWithCategory(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try{
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMId];
            
            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, buildertek__Trade_Type__c,
                                                            buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                            FROM buildertek__Select_Sheet__c 
                                                            WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMId];

            if(BOMLines.size() > 0){
                boolean AllBOMlinesAssigesWithPO = true;
                boolean AllBOMlinesNotHaveCategory = true;
                boolean AllBOMlinesNotHaveVendor = true;

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Purchase_Order__c == null && line.buildertek__Category__c != null){
                        AllBOMlinesAssigesWithPO = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Category__c != null){
                        AllBOMlinesNotHaveCategory = false;
                    }
                }

                for(buildertek__Select_Sheet__c line : BOMLines){
                    if(line.buildertek__Vendor__c != null){
                        AllBOMlinesNotHaveVendor = false;
                    }
                }

                if(AllBOMlinesNotHaveCategory == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'Unable to create purchase order. No category assigned to available lines.';
                }

                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All PO lines have been assiged to a PO.';
                }else if(AllBOMlinesNotHaveVendor == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'We are unable to create a PO. There are no vendors assigned to any PO lines.';
                }
                else{
                    Map<String, Id> recordTypeMap = new Map<String, Id>();
                    for (Schema.RecordTypeInfo rt : buildertek__Purchase_Order__c.SObjectType.getDescribe().getRecordTypeInfos()) {
                        recordTypeMap.put(rt.getName(), rt.getRecordTypeId());
                    }

                    Id standardPurchaseOrderRecordTypeId = recordTypeMap.get('Standard');

                    Map<String, Id> CategoryVendorId_BOMLineId = new Map<String, Id>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Category__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Category__c + '_' + line.buildertek__Vendor__c;
                            CategoryVendorId_BOMLineId.put(key, line.Id);
                        }
                    }

                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();

                    if(CategoryVendorId_BOMLineId.size() > 0){
                        for(String key : CategoryVendorId_BOMLineId.keySet()){
                            List<String> keyList = key.split('_');
                            String Category = keyList[0];
                            String VendorId = keyList[1];
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = VendorId;
                            POtoCreate.buildertek__Category__c = Category;
                            POtoCreate.RecordTypeId = standardPurchaseOrderRecordTypeId;
                            POsToCreate_List.add(POtoCreate);
                        }
                    }

                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }

                    //itetate through the CategoryVendorId_BOMLineId map and create PO lines for each PO
                    List<Id> createdPOsIds = new List<Id>();
                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        createdPOsIds.add(PO.Id);
                    }

                    List<buildertek__Purchase_Order__c> CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID IN : createdPOsIds];

                    Map<String, Id> CategoryVendorId_POId = new Map<String, Id>();

                    for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                        String key = PO.buildertek__Category__c + '_' + PO.buildertek__Vendor__c;
                        CategoryVendorId_POId.put(key, PO.Id);
                    }

                    List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
                    Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();

                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Category__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Category__c + '_' + line.buildertek__Vendor__c;
                            buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                            Poline.Name = line.Name;
                            Poline.buildertek__Product__c = line.buildertek__Product__c;
                            Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                            Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                            Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;
                            Poline.buildertek__Purchase_Order__c = CategoryVendorId_POId.get(key);
                            POlinesToCreate.add(Poline);
                            LineId_POlines.put(line.Id, Poline);
                        }
                    }

                    if(POlinesToCreate.size() > 0){
                        insert POlinesToCreate;
                    }

                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Category__c != null && line.buildertek__Purchase_Order__c == null){
                            String key = line.buildertek__Category__c + '_' + line.buildertek__Vendor__c;
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = CategoryVendorId_POId.get(key);
                        }
                    }

                    update BOMlines;

                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                }
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'Please create atleast on line to create PO.';
            }
            return returnValue;
        }
        catch(Exception e){
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = 'Something went wrong!';
            return returnValue;
        }
    }


    public class responseWrapper{
        @AuraEnabled Public string state;
        @AuraEnabled Public string returnMessage;
        @AuraEnabled public List<buildertek__Select_Sheet__c> BOMLines;
        @AuraEnabled public List<String> vendorList;
        @AuraEnabled public string POid;
    }
   
}