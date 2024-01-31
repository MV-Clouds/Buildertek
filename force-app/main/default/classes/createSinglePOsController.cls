public with sharing class createSinglePOsController {
    
    @AuraEnabled
    public static ResponseWrapper createPOsFromBOM(Id bomId) {
        ResponseWrapper returnValue = new ResponseWrapper();
        try {
            buildertek__Project_Selection_Sheet_Takeoff__c BOM = [SELECT Id, Name, buildertek__Name__c, buildertek__Takeoff__c, buildertek__Project__c FROM buildertek__Project_Selection_Sheet_Takeoff__c WHERE Id = :bomId];

            List<buildertek__Select_Sheet__c> BOMLines = [SELECT Id, Name, buildertek__Selection_Sheet_Takeoff__c, buildertek__Vendor__c, buildertek__Vendor__r.Name, buildertek__Purchase_Order__c, buildertek__Purchase_Order__r.Name, buildertek__Purchase_Order_Line__c, buildertek__Quantity__c, buildertek__Total_Sales_Price__c, buildertek__Total_Costs__c, buildertek__BL_UNIT_COST__c, buildertek__BT_Price_Book__c, buildertek__BT_Price_Book__r.Name, buildertek__Product__c, buildertek__Product__r.Name, buildertek__Cost_Code__c FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c = :bomId];
            
            if (!BOMLines.isEmpty()) {
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
                    returnValue.state = 'Warning';
                    returnValue.returnMessage = 'No lines have vendors assigned to create purchase order.';
                }
                else if(AllBOMlinesAssigesWithPO == true){
                    returnValue.state = 'Warning';
                    returnValue.returnMessage = 'Unable to create purchase order. No vendor assigned to available lines.';
                } else {
                    List<buildertek__Purchase_Order__c> createPOList = new List<buildertek__Purchase_Order__c>();
                    Map<Id, buildertek__Purchase_Order__c> poMap = new Map<Id, buildertek__Purchase_Order__c>();
                    for (buildertek__Select_Sheet__c bomline : BOMLines) {
                        if (bomline.buildertek__Vendor__c != null && bomline.buildertek__Purchase_Order__c == null){
                            buildertek__Purchase_Order__c POtoCreate = new buildertek__Purchase_Order__c();
                            POtoCreate.buildertek__Description__c = bomline.Name;
                            POtoCreate.buildertek__Project__c = BOM.buildertek__Project__c;
                            POtoCreate.buildertek__Bill_of_Material__c = BOM.Id;
                            POtoCreate.buildertek__Status__c = 'Open';
                            POtoCreate.buildertek__Vendor__c = bomline.buildertek__Vendor__c;
                            POtoCreate.buildertek__Cost_Code__c = bomline.buildertek__Cost_Code__c;
                            createPOList.add(POtoCreate);
                            poMap.put(bomline.Id, POtoCreate);
                        }
                    }
                    
                    if (!createPOList.isEmpty()) {
                        insert createPOList;
                        returnValue.state = 'Success';
                        returnValue.returnMessage = 'All PO\'s created Successfully.';
                        returnValue.BOMLines = BOMLines;
                        for (buildertek__Select_Sheet__c bomline : BOMLines) {
                            if (bomline.buildertek__Vendor__c != null && bomline.buildertek__Purchase_Order__c == null) {
                                bomline.buildertek__Purchase_Order__c = poMap.get(bomline.Id).Id;
                            }
                        }
                        update BOMLines;
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