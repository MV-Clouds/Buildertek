public class createPOfromBOM_controller {


    @AuraEnabled
    public static responseWrapper getBOMlines(String BOMiD){
        responseWrapper returnValue = new responseWrapper();
        try {
            system.debug('BOMiD : ' + BOMiD);
        List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Tax_Percent__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Category__c
                                                      FROM buildertek__Select_Sheet__c 
                                                      WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMiD ORDER BY buildertek__Vendor__r.Name ASC NULLS LAST, Name ASC];
        Set<String> vendorList = new Set<String>();

        if(BOMLines.size() > 0){
            for(buildertek__Select_Sheet__c line : BOMLines){
                if(line.buildertek__Vendor__r.Name != null){
                    vendorList.add(line.buildertek__Vendor__r.Name);
                }
                else{
                    vendorList.add('No Vendor');
                }
            }
        }

        returnValue.state = 'success';
        returnValue.BOMLines = BOMLines;
        returnValue.vendorList = new List<String>(vendorList);
        return returnValue;
        } catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = e.getMessage();
            return returnValue;
        }
    }

    @AuraEnabled
    public static responseWrapper getFieldSetValues(){
        responseWrapper returnValue = new responseWrapper();
        try {

            String ObjectName = 'buildertek__Select_Sheet__c';
            String FieldSetName = 'buildertek__create_PO_from_BOM';
            String result = '';
            List<String> pickListValuesList = new List<String>();
            SObjectType objToken = Schema.getGlobalDescribe().get(ObjectName);
            Schema.DescribeSObjectResult d = objToken.getDescribe();
            Map<String, Schema.FieldSet> FsMap = d.fieldSets.getMap();
            if (FsMap.containsKey(FieldSetName)){
                for (Schema.FieldSetMember f : FsMap.get(FieldSetName).getFields()){
                    if (result != ''){
                        result += ',';
                    }
                    String jsonPart = '{';
                    jsonPart += '"label":"' +( String.valueOf(f.getFieldPath()) == 'Name' ? 'BOM Line' : f.getLabel() )+'",'; // changes for BUIL-3953, to change field label...
                    jsonPart += '"required":"' + (f.getDBRequired() || f.getRequired())+'",';
                    jsonPart += '"type":"' + (f.getType())+'",';
                    jsonPart += '"name":"' + f.getFieldPath()+'"';
                    
                    if (String.valueOf(f.getType()) == 'PICKLIST'){
                        pickListValuesList = getDropDown(ObjectName, String.valueOf(f.getFieldPath()));
                        jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
                    }
                    jsonPart += '}';
                    result += jsonPart;

                }
            }

            returnValue.state = 'success';
            returnValue.FieldSetValues = '[' + result + ']';
            return returnValue;

        } catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            returnValue.returnMessage = e.getMessage();
            return returnValue;
        }
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }


    @AuraEnabled
    public static responseWrapper createPOfromBOM(String BOMiD, List<String> slectedLinesId){
        responseWrapper returnValue = new responseWrapper();
        try {

            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c
                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                  WHERE Id =: BOMiD];

                                
            List<buildertek__Select_Sheet__c> BOMlines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Tax_Percent__c,buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,
                                                                  buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Category__c
                                                          FROM buildertek__Select_Sheet__c 
                                                          WHERE Id IN : slectedLinesId];

            String VendorId;
            String CostCode;
            String Phase;
            String Category;
            Boolean assign_flag = true;

            // if cost code, phase and category are not null. Assign first BOM line's Cost code, phase and category to newly created PO.
            for(buildertek__Select_Sheet__c line : BOMlines){
                VendorId = line.buildertek__Vendor__c;
                if(line.buildertek__Cost_Code__c != null && line.buildertek__Build_Phase__c != null &&line.buildertek__Category__c != null && assign_flag == true){
                    CostCode = line.buildertek__Cost_Code__c;
                    Phase = line.buildertek__Build_Phase__c;
                    Category = line.buildertek__Category__c;
                    assign_flag = false;
                }
            }

            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
            POtoCreate.buildertek__Status__c = 'Open';
            POtoCreate.buildertek__Vendor__c = VendorId;
            POtoCreate.buildertek__BT_Build_Phase__c = Phase;
            POtoCreate.buildertek__Cost_Code__c = CostCode;
            insert POtoCreate;

            system.debug('created PO : ' + POtoCreate.Id);
            buildertek__Purchase_Order__c CreatedPOs = [SELECT Id, Name,buildertek__Project__c,buildertek__Bill_of_Material__c,buildertek__Vendor__c,buildertek__Cost_Code__c,buildertek__BT_Build_Phase__c,buildertek__BT_Build_Phase__r.Name FROM buildertek__Purchase_Order__c WHERE ID =: POtoCreate.Id LIMIT 1];

            List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
            Map<Id, buildertek__Purchase_Order_Item__c> LineId_POlines = new Map<Id, buildertek__Purchase_Order_Item__c>();

            if(BOMlines.size() > 0){
                for(buildertek__Select_Sheet__c line: BOMlines){
                    buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                    Poline.Name = line.Name;
                    Poline.buildertek__Product__c = line.buildertek__Product__c;
                    Poline.buildertek__Quantity__c = line.buildertek__Quantity__c;
                    Poline.buildertek__Cost_Code__c = line.buildertek__Cost_Code__c;
                    Poline.buildertek__Unit_Price__c = line.buildertek__BL_UNIT_COST__c;                   
                    Poline.buildertek__Tax__c = line.buildertek__Tax_Percent__c;                                        
                    Poline.buildertek__Purchase_Order__c = CreatedPOs.Id;
                    
                    POlinesToCreate.add(Poline);
                    LineId_POlines.put(line.Id, Poline);
                }
            }

            if(POlinesToCreate.size() > 0){
                insert POlinesToCreate;
            }

            for(buildertek__Select_Sheet__c line: BOMlines){
                line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                line.buildertek__Purchase_Order__c = CreatedPOs.Id;
            }

            update BOMlines;

            buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c, buildertek__Match_BOM_Lines_with_Schedule_Items__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings' LIMIT 1];
            // if "Match BOM line with Schedule item" admin setting is checked true, run match schedule item logic...
            if(adminInterfaceNodeConfigurations.buildertek__Match_BOM_Lines_with_Schedule_Items__c == true){
                List<buildertek__Schedule__c> scheduleList = [SELECT ID, Name, buildertek__Description__c FROM buildertek__Schedule__c WHERE buildertek__Project__c =: BOM.buildertek__Project__c ORDER BY CreatedDate DESC LIMIT 1];
                String scheduleId = '';
                                if(scheduleList.size() > 0){
                    scheduleId = scheduleList[0].Id;
                    System.debug('matched schedule : ' + scheduleList[0].buildertek__Description__c);
                }
                
                List<buildertek__Project_Task__c> ScheduleItems = [SELECT Id, Name, buildertek__Schedule__c,buildertek__Contractor__c, buildertek__Cost_Code__c,buildertek__Phase__c, buildertek__Completion__c,buildertek__Start__c,buildertek__Finish__c,buildertek__BT_Category__c
                                                                    FROM buildertek__Project_Task__c WHERE buildertek__Schedule__c =: scheduleId ORDER BY CreatedDate DESC];

                                                                                
                if(ScheduleItems.size() > 0){
                    List<buildertek__Project_Task__c> matchedSchItems = new List<buildertek__Project_Task__c>();
                    for(buildertek__Project_Task__c SchItem : ScheduleItems){
                        String schItemPhaseName = SchItem.buildertek__Phase__c != null ? SchItem.buildertek__Phase__c.toLowercase() : null;
                        String poPhaseName = CreatedPOs.buildertek__BT_Build_Phase__r.Name != null ? CreatedPOs.buildertek__BT_Build_Phase__r.Name.toLowercase() : null;
                        System.debug('Phase : ' + poPhaseName +' Vs '+ schItemPhaseName);
                        System.debug('Cost Code : ' + CreatedPOs.buildertek__Cost_Code__c  +' Vs '+ SchItem.buildertek__Cost_Code__c);
                        // Matching logic -- 
                        // // schedule item contractor == PO phase (first BOM vendor)  removed as per BUIL-3961....
                        // schedule item phase == PO phase (first BOM phase)
                        // schedule item cost code == PO cost code (first BOM cost code)
                        // schedule item category == PO categorty (first BOM category)
                        if( SchItem.buildertek__Contractor__c == CreatedPOs.buildertek__Vendor__c
                            // && schItemPhaseName == poPhaseName 
                            && SchItem.buildertek__Cost_Code__c == CreatedPOs.buildertek__Cost_Code__c 
                            && SchItem.buildertek__BT_Category__c == Category
                            && matchedSchItems.size() == 0)
                        {
                            // Collect first matched schedule item in list....
                            matchedSchItems.add(SchItem);
                        }
                    }
                    system.debug('matched Sch Item : ' + matchedSchItems);
                    system.debug('no of matched Sch Item : ' + matchedSchItems.size());
    
    
                    if(matchedSchItems.size() > 0){
                        buildertek__Project_Task__c MatchedScheduleItem = matchedSchItems[0];
                        // use first matched schedule item for matching logic...
                        CreatedPOs.buildertek__Schedule__c = scheduleId;
                        CreatedPOs.buildertek__Schedule_Item__c = MatchedScheduleItem.Id;
                        CreatedPOs.buildertek__Completion__c = MatchedScheduleItem.buildertek__Completion__c;
                        CreatedPOs.buildertek__Projected_Start_Date__c = MatchedScheduleItem.buildertek__Start__c;
                        CreatedPOs.buildertek__Projected_Completion_Date__c = MatchedScheduleItem.buildertek__Finish__c;
                        MatchedScheduleItem.buildertek__Purchase_Order__c = CreatedPOs.Id;
                        if(MatchedScheduleItem.buildertek__Contractor__c != CreatedPOs.buildertek__Vendor__c){
                            MatchedScheduleItem.buildertek__Contractor__c = CreatedPOs.buildertek__Vendor__c;       // added as per BUIL-3961
                            MatchedScheduleItem.buildertek__Contractor_Resource__c = null;
                            MatchedScheduleItem.buildertek__Contractor_Resource_1__c = null;
                            MatchedScheduleItem.buildertek__Contractor_Resource_2__c = null;
                            MatchedScheduleItem.buildertek__Contractor_Resource_3__c = null;
                        }

                        update MatchedScheduleItem;
                        update CreatedPOs;
                    }
                }
            }

            
            returnValue.state = 'success';
            returnValue.POid = POtoCreate.Id;
            return returnValue;
        } catch (Exception e) {
            System.debug('Error in getBOMlines ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString() + ' getTypeName : ' + e.getTypeName());
            if(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')){
                Integer occurence = e.getMessage().indexOf('FIELD_CUSTOM_VALIDATION_EXCEPTION,') + 34; // add 34 to remove 'FIELD_CUSTOM_VALIDATION_EXCEPTION' string...
                String errorMessage = e.getMessage().mid(occurence, e.getMessage().length());
                occurence = errorMessage.lastIndexOf(':');
                errorMessage = errorMessage.mid(0, occurence);
                returnValue.returnMessage = errorMessage;
                returnValue.isCustomeValidation = true;
            }
            else{
                returnValue.returnMessage = e.getMessage();
                returnValue.isCustomeValidation = false;

            }

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'error';
            return returnValue;
        }
    }


    public class responseWrapper{
        @AuraEnabled Public string state;
        @AuraEnabled Public string returnMessage;
        @AuraEnabled Public Boolean isCustomeValidation;
        @AuraEnabled public List<buildertek__Select_Sheet__c> BOMLines;
        @AuraEnabled public List<String> vendorList;
        @AuraEnabled public String FieldSetValues;
        @AuraEnabled public string POid;
    }
   
}