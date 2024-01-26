public class createPOfromBOM_controller {


    @AuraEnabled
    public static responseWrapper getBOMlines(String BOMiD){
        responseWrapper returnValue = new responseWrapper();
        try {
            system.debug('BOMiD : ' + BOMiD);
        List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name
                                                      FROM buildertek__Select_Sheet__c 
                                                      WHERE buildertek__Selection_Sheet_Takeoff__c =: BOMiD];
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
					jsonPart += '"label":"' + f.getLabel()+'",';
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

                                
            List<buildertek__Select_Sheet__c> BOMlines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name,
                                                                  buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c
                                                          FROM buildertek__Select_Sheet__c 
                                                          WHERE Id IN : slectedLinesId];

            String VendorId;
            if(BOMlines.size() > 0){
                // All BOM lines have same Vendors...
                VendorId = BOMlines[0].buildertek__Vendor__c;
            }

            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
            POtoCreate.buildertek__Description__c = BOM.buildertek__Name__c;
            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
            POtoCreate.buildertek__Status__c = 'Open';
            POtoCreate.buildertek__Vendor__c = VendorId;
            insert POtoCreate;

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
                    Poline.buildertek__Purchase_Order__c = POtoCreate.Id;
                    
                    POlinesToCreate.add(Poline);
                    LineId_POlines.put(line.Id, Poline);
                }
            }

            if(POlinesToCreate.size() > 0){
                insert POlinesToCreate;
            }

            for(buildertek__Select_Sheet__c line: BOMlines){
                line.buildertek__Purchase_Order_Line__c = LineId_POlines.get(line.Id).Id;
                line.buildertek__Purchase_Order__c = POtoCreate.Id;
            }

            update BOMlines;
            
            returnValue.state = 'success';
            returnValue.POid = POtoCreate.Id;
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


    public class responseWrapper{
        @AuraEnabled Public string state;
        @AuraEnabled Public string returnMessage;
        @AuraEnabled public List<buildertek__Select_Sheet__c> BOMLines;
        @AuraEnabled public List<String> vendorList;
        @AuraEnabled public String FieldSetValues;
        @AuraEnabled public string POid;
    }
   
}