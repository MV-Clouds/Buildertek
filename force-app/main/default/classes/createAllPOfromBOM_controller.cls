public class createAllPOfromBOM_controller {

    @AuraEnabled
    public static responseWrapper createAllPO(string BOMId){
        responseWrapper returnValue = new responseWrapper();
        try {
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMiD];

            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,
                                                          buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name
                                                          FROM buildertek__Select_Sheet__c 
                                                          WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMiD];
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
                    returnValue.returnMessage = 'Please assign a vendor for each line. all lines not have a vendor assigned to create purchase orders.';
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'error';
                    returnValue.returnMessage = 'All lines with vendor are already assiged with PO.';
                }
                else{

                    
                    Map<Id, Id> BOMlineId_VendorId = new Map<Id, Id>();
                    Map<Id, Id> VenodrId_CostCode = new Map<Id, Id>();
                    Map<Id, Id> VenodrId_Phase = new Map<Id, Id>();
                    Set<String> vendorList = new Set<String>();
                    for(buildertek__Select_Sheet__c line : BOMLines){
                        if(line.buildertek__Vendor__c != null && line.buildertek__Purchase_Order__c == null){
                            vendorList.add(line.buildertek__Vendor__c);   

                            BOMlineId_VendorId.put(line.Id, line.buildertek__Vendor__c);

                            // Get Cost code and Phase value of First BOM Line which match condition for perticulart vendor....
                            if(line.buildertek__Cost_Code__c != null && line.buildertek__Build_Phase__c != null && !VenodrId_CostCode.containsKey(line.buildertek__Vendor__c)){
                                VenodrId_CostCode.put(line.buildertek__Vendor__c, line.buildertek__Cost_Code__c);
                                VenodrId_Phase.put(line.buildertek__Vendor__c, line.buildertek__Build_Phase__c);
                            }
                        }
                    }

                    system.debug('VenodrId_CostCode : ' + VenodrId_Phase);
                    system.debug('VenodrId_Phase : ' + VenodrId_Phase);
                    
                    List<buildertek__Purchase_Order__c> POsToCreate_List = new List<buildertek__Purchase_Order__c>();
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
                            POsToCreate_List.add(POtoCreate);
                        }
                    }
                    
                    if(POsToCreate_List.size() > 0){
                        insert POsToCreate_List;
                    }
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
                    system.debug('no fo create PO Lines ==> ' + POlinesToCreate.size());
        
                    for(buildertek__Select_Sheet__c line: BOMlines){
                        if(line.buildertek__Vendor__c != null && line.buildertek__Purchase_Order__c == null){
                            line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                            line.buildertek__Purchase_Order__c = VendorId_POId.get(line.buildertek__Vendor__c);
                        }
                    }
                    update BOMlines;

                    // ---------------------------------------- Schedule item matching and Mapping Field Logic --------------------------

                    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
                    if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                        buildertek__Schedule__c schedule = [SELECT ID, Name FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                        
                        List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Expected_Start_Date__c,buildertek__Expected_End_Date__c
                                                                            FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: schedule.Id ORDER BY CreatedDate DESC];

                        List<buildertek__Project_Task__c> matchedSchItems = new List<buildertek__Project_Task__c>();
                        Map<Id, buildertek__Project_Task__c> PO_to_matchedSchItems = new Map<Id, buildertek__Project_Task__c>();
                        List<buildertek__Purchase_Order__c> poToUpdate = new List<buildertek__Purchase_Order__c>();

                        for(buildertek__Purchase_Order__c PO : POsToCreate_List){
                            for(buildertek__Project_Task__c SchItem : ScheduleItems){
                                if( SchItem.buildertek__Contractor__c == PO.buildertek__Vendor__c 
                                    && SchItem.buildertek__Phase__c == PO.buildertek__BT_Build_Phase__r.Name && SchItem.buildertek__Cost_Code__c == PO.buildertek__Cost_Code__c 
                                    && !PO_to_matchedSchItems.containsKey(PO.Id))
                                {
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
                                    PO.buildertek__Schedule__c = schedule.Id;
                                    PO.buildertek__Schedule_Item__c = MatchedScheduleItem.Id;
                                    PO.buildertek__Completion__c = MatchedScheduleItem.buildertek__Completion__c;
                                    PO.buildertek__Projected_Start_Date__c = MatchedScheduleItem.buildertek__Expected_Start_Date__c;
                                    PO.buildertek__Projected_Completion_Date__c = MatchedScheduleItem.buildertek__Expected_End_Date__c;
                                    MatchedScheduleItem.buildertek__Purchase_Order__c = PO.Id;
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

    
                    returnValue.state = 'success';
                    returnValue.returnMessage = 'All PO\'s created successfully.';
                }
            }
            else{
                returnValue.state = 'error';
                returnValue.returnMessage = 'Please create atleast on line to create PO.';
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

    public class responseWrapper{
        @AuraEnabled Public string state;
        @AuraEnabled Public string returnMessage;
        @AuraEnabled public List<buildertek__Select_Sheet__c> BOMLines;
        @AuraEnabled public List<String> vendorList;
        @AuraEnabled public string POid;
    }
   
}