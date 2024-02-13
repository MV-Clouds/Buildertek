public with sharing class ImportMasterPurchaseOrderController {

    @AuraEnabled
    public static object getMasterPO(String recordId, String searchKeyword){
        try {
            list<buildertek__Purchase_Order__c> masterPOList;
            String searchString = '%' + searchKeyword + '%';
            masterPOList = [SELECT Id, Name, buildertek__Type__c, buildertek__PO_Total__c , buildertek__Description__c FROM buildertek__Purchase_Order__c 
                                                WHERE buildertek__PO_Type__c = 'Master' AND ID != :recordId AND Name LIKE:searchString ORDER BY Name ASC NULLS Last limit 50000]; 
            return masterPOList;
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

            msg = importMasterPOLinesWithVendorPricing(poIds, recordId);
            return msg;

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
            Set<Id> vendorIds = new Set<Id>();
            Map<Id, Decimal> productCostMap = new Map<Id, Decimal>();
            List<PricebookEntry> pbeList;
            List<buildertek__Purchase_Order__c> masterPOList = [SELECT Id, buildertek__Update_Pricing__c, buildertek__Vendor__c FROM buildertek__Purchase_Order__c WHERE Id IN :poIds AND buildertek__Vendor__c != null AND buildertek__Update_Pricing__c = true];
            if (!masterPOList.isEmpty()) {
                for (buildertek__Purchase_Order__c po : masterPOList) {
                    vendorIds.add(po.buildertek__Vendor__c);
                }
                
                pbeList = [SELECT Id, Product2.buildertek__Vendor__c, Product2Id, buildertek__Unit_Cost__c FROM PricebookEntry WHERE Product2.buildertek__Vendor__c IN :vendorIds AND IsActive = true];
                System.debug('PBEList--> '+ pbeList);
                if (!pbeList.isEmpty()) {
                    for (PricebookEntry pbe : pbeList) {
                        productCostMap.put(pbe.Product2Id, pbe.buildertek__Unit_Cost__c);
                    }
                }
            }
           
            List<buildertek__Purchase_Order_Item__c> insplinelst = [SELECT Id, Name, buildertek__Product__c, buildertek__Department__c, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Tax__c, buildertek__Cost_Code__c, buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c IN :poIds];
            System.debug('insplinelst--> '+ insplinelst);
            for (buildertek__Purchase_Order_Item__c ins : insplinelst) {
                buildertek__Purchase_Order_Item__c newinsp = new buildertek__Purchase_Order_Item__c();
                newinsp.buildertek__Purchase_Order__c = recordId;
                newinsp.Name = ins.Name;
                newinsp.buildertek__Quantity__c = ins.buildertek__Quantity__c;
                newinsp.buildertek__Description__c = ins.buildertek__Description__c;
                newinsp.buildertek__Tax__c = ins.buildertek__Tax__c;
                newinsp.buildertek__Cost_Code__c = ins.buildertek__Cost_Code__c;
                newinsp.buildertek__Department__c = ins.buildertek__Department__c;
                newinsp.buildertek__Product__c = ins.buildertek__Product__c;                    

                if (productCostMap.containsKey(ins.buildertek__Product__c)) {
                    newinsp.buildertek__Unit_Price__c = productCostMap.get(ins.buildertek__Product__c);
                } else {
                    newinsp.buildertek__Unit_Price__c = ins.buildertek__Unit_Price__c;
                }

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

    // public static MessageClass importMasterPOLinesWithoutVendorPricing(List<String> poIds, String recordId) {
    //     MessageClass msg = new MessageClass();
    //     try {
    //         List<buildertek__Purchase_Order_Item__c> newinslst = new List<buildertek__Purchase_Order_Item__c>();
    //         System.debug('poIds---> '+ poIds);
    //         List<buildertek__Purchase_Order_Item__c> insplinelst = [SELECT Id, Name, buildertek__Product__c, buildertek__Department__c, buildertek__Purchase_Order__c, buildertek__Quantity__c, buildertek__Description__c, buildertek__Tax__c, buildertek__Cost_Code__c, buildertek__Unit_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c = :poIds];
    //         System.debug('insplinelst---> '+ insplinelst);

    //         for (buildertek__Purchase_Order_Item__c ins : insplinelst) {
    //             buildertek__Purchase_Order_Item__c newinsp = new buildertek__Purchase_Order_Item__c();
    //             newinsp.buildertek__Purchase_Order__c = recordId;
    //             newinsp.Name = ins.Name;
    //             newinsp.buildertek__Quantity__c = ins.buildertek__Quantity__c;
    //             newinsp.buildertek__Description__c = ins.buildertek__Description__c;
    //             newinsp.buildertek__Tax__c = ins.buildertek__Tax__c;
    //             newinsp.buildertek__Cost_Code__c = ins.buildertek__Cost_Code__c;
    //             newinsp.buildertek__Unit_Price__c = ins.buildertek__Unit_Price__c;
    //             newinsp.buildertek__Department__c = ins.buildertek__Department__c;
    //             newinsp.buildertek__Product__c = ins.buildertek__Product__c;                       

    //             newinslst.add(newinsp);
    //         }
    //         System.debug('POLineList---> ' + newinslst);
    //         if (newinslst.size() > 0) {
    //             insert newinslst;
    //             msg.Status = 'Success';
    //             msg.Message = 'PO Lines Imported Successfully';
    //         } else {
    //             msg.Status = 'Failed';
    //             msg.Message = 'There were no PO Lines for the selected PO(s)';
    //         }
    //         return msg;
    //     } catch (Exception exp) {
    //         msg.Status = 'Failed';
    //         msg.Message = exp.getMessage();
    //         System.debug('error--> ' + exp.getMessage());
    //         System.debug('error line--> ' + exp.getLineNumber());
    //         List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
    //         if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
    //             BT_ExceptionHandler.Store_Exception(exp);
    //         }
    //         return msg;
    //     }
    // }
    
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