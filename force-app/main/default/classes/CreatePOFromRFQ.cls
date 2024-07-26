public with sharing class CreatePOFromRFQ{
    @AuraEnabled
    public Static ResponseBase CreatePOMethod(string RFQId){
        ResponseBase response = new ResponseBase();
        Map<Id, buildertek__Purchase_Order__c> purchaseOrder = new Map<Id, buildertek__Purchase_Order__c>();
        string recordid = '';
        try{
            // List<buildertek__RFQ__c> RFQ =[Select Id,Name,buildertek__Project__c,buildertek__Vendor__c,buildertek__Budget__c,buildertek__Added_to_Quote__c FROM buildertek__RFQ__c WHERE Id=:RFQId];
            // String standardRecordId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'buildertek__Purchase_Order__c' AND Name = 'Standard' limit 1].Id;

            //     buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
            //     PO.buildertek__Project__c = RFQ[0].buildertek__Project__c;
            //     PO.buildertek__Status__c = 'Approved';
            //     PO.buildertek__Type__c = 'Sales';
            //     PO.buildertek__Vendor__c = RFQ[0].buildertek__Vendor__c;
            //     PO.buildertek__Budget__c = RFQ[0].buildertek__Budget__c;
            //     PO.buildertek__Quote__c = RFQ[0].buildertek__Quote__c;
            //     PO.buildertek__RFQ__c = RFQ[0];
            //     PO.buildertek__Description__c = RFQ[0].Name;
            //     PO.RecordTypeId = standardRecordId;
            //     insert PO;
                      
            List<buildertek__RFQ_To_Vendor__c> RFQ;
            
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Budget__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Quote__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Due_Date__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible() && 
                Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Anticipated_Finish_Date__c.isAccessible() &&                 
                Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Vendor__c.isAccessible()){

                RFQ = [Select Id, Name,buildertek__Rfq__c,buildertek__Rfq__r.Name ,buildertek__Vendor__c, 
                        buildertek__Rfq__r.buildertek__Project__c,buildertek__Rfq__r.buildertek__Budget__c,
                        buildertek__Anticipated_Start_Date__c,buildertek__Anticipated_Finish_Date__c, buildertek__Estimated_Work_Rollup__c,
                        buildertek__Rfq__r.buildertek__Quote__c, buildertek__Rfq__r.buildertek__Trade_Type__c,
                        buildertek__Rfq__r.buildertek__Associated_Purchase_Order__c, (SELECT Id, Name, buildertek__Cost_Code__c, 
                                                                                        buildertek__Quantity__c, buildertek__Unit_Price__c, 
                                                                                        buildertek__Total_Price__c, buildertek__Item_Name__c, 
                                                                                        buildertek__Vendor__c, buildertek__RFQ_Item__c, 
                                                                                        buildertek__Vendor_Name__c, buildertek__Description__c, 
                                                                                        buildertek__Budget_Line_Amount__c, buildertek__Vendor_Note__c, buildertek__RFQ_Item__r.buildertek__Product__c, buildertek__RFQ_Item__r.buildertek__BT_Category__c, buildertek__RFQ_Item__r.buildertek__Trade_Type__c
                                                                                      FROM buildertek__Vendor_Items__r)
                       FROM buildertek__RFQ_To_Vendor__c
                       WHERE buildertek__RFQ__c = :RFQId AND (buildertek__Status__c =: 'Awarded' OR buildertek__Status__c =: 'Accepted')];
            }
            
            if(RFQ.size() > 0 && RFQ[0].buildertek__Rfq__r.buildertek__Associated_Purchase_Order__c!=null){
                response.strMessage = 'PO already Created';
                
                return response;
            }

            System.debug('Number of RFQ records : '+RFQ.size());
            
            String standardRecordId = [SELECT Id, Name FROM RecordType WHERE SobjectType = 'buildertek__Purchase_Order__c' AND Name = 'Standard' limit 1].Id;
            
            if (RFQ.size()>0){
            
                for (buildertek__RFQ_To_Vendor__c rfqItems : RFQ){
                    buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
                    PO.buildertek__Project__c = rfqItems.buildertek__Rfq__r.buildertek__Project__c;
                    PO.buildertek__Status__c = 'Open';
                    PO.buildertek__Type__c = 'Sales';
                    PO.buildertek__Trade_Type__c = rfqItems.buildertek__Rfq__r.buildertek__Trade_Type__c;
                    PO.buildertek__Vendor__c = rfqItems.buildertek__Vendor__c;
                    PO.buildertek__Budget__c = rfqItems.buildertek__Rfq__r.buildertek__Budget__c;
                    PO.buildertek__Quote__c = rfqItems.buildertek__Rfq__r.buildertek__Quote__c;
                    PO.buildertek__RFQ__c = rfqItems.buildertek__Rfq__c;
                    PO.buildertek__Description__c = rfqItems.buildertek__Rfq__r.Name;
                    PO.buildertek__Estimated_Start_Date__c = rfqItems.buildertek__Anticipated_Start_Date__c;
                    PO.buildertek__Estimated_Completion_Date__c = rfqItems.buildertek__Anticipated_Finish_Date__c;                                         
                    PO.buildertek__Description__c = rfqItems.buildertek__Rfq__r.Name;                                        
                    PO.RecordTypeId = standardRecordId;
                    purchaseOrder.put(rfqItems.buildertek__Vendor__c, PO);
                }
                
                if (Schema.sObjectType.buildertek__Purchase_Order__c.isCreateAble() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateAble() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isCreateAble() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Type__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Quote__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Estimated_Start_Date__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Estimated_Completion_Date__c.isCreateable()){    
                    insert purchaseOrder.values();
                }
                
                //Update the RFQ with the Associate Purchase Order
                String poId = [SELECT Id FROM buildertek__Purchase_Order__c WHERE buildertek__RFQ__c = :RFQId LIMIT 1].Id;
                System.debug(poId);
                 RFQ[0].buildertek__Rfq__r.buildertek__Associated_Purchase_Order__c = poId;
                 System.debug(RFQ[0].buildertek__Rfq__r.buildertek__Associated_Purchase_Order__c);
                 if (Schema.sObjectType.buildertek__RFQ__c.isUpdateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Associated_Purchase_Order__c.isUpdateable()){
                    update RFQ[0].buildertek__Rfq__r;
                 }
                 
                List<buildertek__Purchase_Order_Item__c> POLines = new List<buildertek__Purchase_Order_Item__c>();
               
                for (buildertek__RFQ_To_Vendor__c rfqItems : RFQ){
                    for (buildertek__RFQ_Vendor_Item__c RfqItem : rfqItems.buildertek__Vendor_Items__r){
                        buildertek__Purchase_Order_Item__c arItem = new buildertek__Purchase_Order_Item__c();
                        arItem.buildertek__Purchase_Order__c = purchaseOrder.get(rfqItems.buildertek__Vendor__c).Id;
                        recordid = purchaseOrder.get(rfqItems.buildertek__Vendor__c).Id;
                        arItem.Name = RfqItem.Name;
                        arItem.Cost_Code__c = RfqItem.Cost_Code__c;
                        arItem.Description__c = RfqItem.Description__c;
                        arItem.Unit_Price__c = RfqItem.Unit_Price__c;
                        arItem.Quantity__c = RfqItem.Quantity__c;
                        arItem.buildertek__RFQ_Item__c = RfqItem.buildertek__RFQ_Item__c;
                        arItem.buildertek__Product__c = RfqItem.buildertek__RFQ_Item__r.buildertek__Product__c;
                        arItem.buildertek__BT_Trade_Type__c = RfqItem.buildertek__RFQ_Item__r.buildertek__Trade_Type__c;
                        arItem.buildertek__BT_Category__c = RfqItem.buildertek__RFQ_Item__r.buildertek__BT_Category__c;
                        POLines.add(arItem);
                    }
                }
                
                if (Schema.sObjectType.buildertek__Purchase_Order_Item__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Cost_Code__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Description__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Product__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Unit_Price__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Quantity__c.isCreateable() && 
                        Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__RFQ_Item__c.isCreateable()){
                    
                    insert POLines;
                }
                response.strMessage = 'Success';
                if(recordid != null){
                    system.debug('recordid'+recordid);
                    response.strRecordId = recordid;
                }
                return response;
                
            } else{
                response.strMessage = 'Vendor RFQ Status Should be Awarded or Accepted';
                
                return response;
            }
        } catch (Exception ex){
            system.debug(ex + ' ex.getMessage() ' + ex.getMessage());
            system.debug(' ex.getMessage() ' + ex.getLineNumber());
            response.strMessage = ex.getMessage();
            return response;
        }
    }
    
    public virtual class ResponseBase{
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String strMessage;
        @AuraEnabled
        public String strRecordId;
        
    }
}