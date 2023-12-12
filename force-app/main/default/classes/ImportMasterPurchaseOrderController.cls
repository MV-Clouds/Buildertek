public with sharing class ImportMasterPurchaseOrderController {

    @AuraEnabled
    public static object getMasterPO(){
        try {
            list<buildertek__Purchase_Order__c> masterPOList;

            masterPOList = [SELECT Id, Name, buildertek__Type__c, buildertek__PO_Total__c , buildertek__Description__c FROM buildertek__Purchase_Order__c 
                                                WHERE buildertek__PO_Type__c = 'Master'
                                                ORDER BY Name
                                                ASC limit 50000]; 
                                                
            if (masterPOList.size() > 0) {
                return masterPOList;
            }  

            return null;   
        } catch (Exception e) {
            System.debug('Error--> '+e.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }                                      
    }
    
    @AuraEnabled
    public static MessageClass checkUpdatePricingField(List<String> poIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__Purchase_Order__c> updatePricingValue = [SELECT Id, buildertek__Update_Pricing__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId];
            List<buildertek__Purchase_Order__c> getMasterPO = [SELECT Id, Name, buildertek__Tax__c, buildertek__Cost_Code__c, buildertek__Trade_Type__c, buildertek__PO_Type__c, buildertek__Update_Pricing__c FROM buildertek__Purchase_Order__c WHERE Id IN :poIds ORDER BY Name ASC];
            System.debug('getMasterPO---> '+getMasterPO);

            if (!getMasterPO.isEmpty()) {
                buildertek__Purchase_Order__c updatepofields = new buildertek__Purchase_Order__c();
                updatepofields.Id = recordId;
                updatepofields.buildertek__PO_Type__c = getMasterPO[0].buildertek__PO_Type__c;
                updatepofields.buildertek__Tax__c = getMasterPO[0].buildertek__Tax__c;
                updatepofields.buildertek__Cost_Code__c = getMasterPO[0].buildertek__Cost_Code__c;
                updatepofields.buildertek__Trade_Type__c = getMasterPO[0].buildertek__Trade_Type__c;
                
                update updatepofields;
                System.debug('updatepofields---> '+updatepofields);
            }

            if(updatePricingValue[0].buildertek__Update_Pricing__c == true){
                System.debug('Check is True');
                msg = importMasterPOLinesWithVendorPricing(poIds, recordId);
                return msg;
            }
            else {
                System.debug('Check is False');
                msg = importMasterPOLinesWithoutVendorPricing(poIds, recordId);
                return msg;
            } 
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    public static MessageClass importMasterPOLinesWithVendorPricing(List<String> poIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__Purchase_Order_Item__c> newinslst = new List<buildertek__Purchase_Order_Item__c>();

            for (String poId : poIds) {
                // Get the vendor for the current PO
                List<buildertek__Purchase_Order__c> po = [SELECT Id, buildertek__Vendor__c FROM buildertek__Purchase_Order__c WHERE Id =: poId AND buildertek__Vendor__c != null];
                
                // Get the UnitCost from PriceBookEntry for the Product of the Vendor
                List<Product2> productRec;
                List<PricebookEntry> pbeList;
                if (!po.isEmpty()) {
                    productRec = [SELECT Id, buildertek__Vendor__c FROM Product2 WHERE buildertek__Vendor__c =: po[0].buildertek__Vendor__c AND IsActive = true ORDER BY CreatedDate Desc];  
                }
                if (!productRec.isEmpty()) {
                    pbeList = [SELECT Id, buildertek__Unit_Cost__c FROM PricebookEntry WHERE Product2Id =: productRec[0].Id AND IsActive = true ORDER BY CreatedDate Desc];
                }
                List<buildertek__Purchase_Order_Item__c> insplinelst = [SELECT Id, Name, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Tax__c, buildertek__Cost_Code__c, buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c = :poId];

                System.debug('POList--> '+ po);
                System.debug('ProductList--> '+ productRec);
                System.debug('PBEList--> '+ pbeList);

                for (buildertek__Purchase_Order_Item__c ins : insplinelst) {
                    buildertek__Purchase_Order_Item__c newinsp = new buildertek__Purchase_Order_Item__c();
                    newinsp.buildertek__Purchase_Order__c = recordId;
                    newinsp.Name = ins.Name;
                    newinsp.buildertek__Quantity__c = ins.buildertek__Quantity__c;
                    newinsp.buildertek__Description__c = ins.buildertek__Description__c;
                    newinsp.buildertek__Tax__c = ins.buildertek__Tax__c;
                    newinsp.buildertek__Cost_Code__c = ins.buildertek__Cost_Code__c;

                    // Check if there is a product for the vendor
                    if (pbeList != null && !pbeList.isEmpty() && pbeList[0].buildertek__Unit_Cost__c != null) {
                        // If there is a product, use its unit cost
                        newinsp.buildertek__Unit_Price__c = pbeList[0].buildertek__Unit_Cost__c;
                    } else {
                        // If there is no product, use the unit cost from the Master PO Line
                        newinsp.buildertek__Unit_Price__c = ins.buildertek__Unit_Price__c;
                    }

                    newinslst.add(newinsp);
                }
            }
            System.debug('POLineList---> ' + newinslst);
            if (newinslst.size() > 0) {
                insert newinslst;
                msg.Status = 'Success';
                msg.Message = 'PO Lines Imported Successfully';
            } else {
                msg.Status = 'Failed';
                msg.Message = 'There were no PO Lines for the selected PO(s)';
            }
            return msg;
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }

    public static MessageClass importMasterPOLinesWithoutVendorPricing(List<String> poIds, String recordId) {
        MessageClass msg = new MessageClass();
        try {
            List<buildertek__Purchase_Order_Item__c> newinslst = new List<buildertek__Purchase_Order_Item__c>();
            System.debug('poIds---> '+ poIds);
            List<buildertek__Purchase_Order_Item__c> insplinelst = [SELECT Id, Name, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Tax__c, buildertek__Cost_Code__c, buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c = :poIds];
            System.debug('insplinelst---> '+ insplinelst);

            for (buildertek__Purchase_Order_Item__c ins : insplinelst) {
                buildertek__Purchase_Order_Item__c newinsp = new buildertek__Purchase_Order_Item__c();
                newinsp.buildertek__Purchase_Order__c = recordId;
                newinsp.Name = ins.Name;
                newinsp.buildertek__Quantity__c = ins.buildertek__Quantity__c;
                newinsp.buildertek__Description__c = ins.buildertek__Description__c;
                newinsp.buildertek__Tax__c = ins.buildertek__Tax__c;
                newinsp.buildertek__Cost_Code__c = ins.buildertek__Cost_Code__c;
                newinsp.buildertek__Unit_Price__c = ins.buildertek__Unit_Price__c;

                newinslst.add(newinsp);
            }
            System.debug('POLineList---> ' + newinslst);
            if (newinslst.size() > 0) {
                insert newinslst;
                msg.Status = 'Success';
                msg.Message = 'PO Lines Imported Successfully';
            } else {
                msg.Status = 'Failed';
                msg.Message = 'There were no PO Lines for the selected PO(s)';
            }
            return msg;
        } catch (Exception exp) {
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();
            System.debug('error--> ' + exp.getMessage());
            System.debug('error line--> ' + exp.getLineNumber());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(exp);
            }
            return msg;
        }
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 

    @AuraEnabled
    public static string getcurrency(){
       return UserInfo.getDefaultCurrency();
    }
}