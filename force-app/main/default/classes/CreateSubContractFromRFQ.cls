public with sharing class CreateSubContractFromRFQ{
    @AuraEnabled
    public static String createSubContractRec(String recordId){
        Map<Id, buildertek__Contract__c> contractRecords = new Map<Id, buildertek__Contract__c>();
        List<buildertek__Contract_Item__c> contractItems = new List<buildertek__Contract_Item__c>();
        System.debug(recordId);
        System.debug(String.isNotBlank(recordId));
        if (String.isNotBlank(recordId)){
            String awardedStatus = 'Awarded';
            String acceptedStatus = 'Accepted';
            String query = '';
            // query = 'Select Vendor__r.Vendor__c,Vendor__r.Status__c, ' + BT_Utils.getQueryStringForObjectWithAllFields('RFQ__c');
            // query += ',(SELECT ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__RFQ_To_Vendor__c')+' FROM buildertek__RFQ_To_Vendors__r WHERE buildertek__RFQ__c IN : rfqId AND (Status__c = awardedStatus OR Status__c = acceptedStatus)) ';
            // query += ',(Select ' + BT_Utils.getQueryStringForObjectWithAllFields('RFQ_Item__c')+' From RFQ_Items__r)';
            // query += ' From RFQ__c where Id IN: rfqId AND (Status__c = awardedStatus OR Status__c = acceptedStatus)';
            query = 'Select Id, buildertek__Vendor__c,buildertek__Status__c,buildertek__Quote_Amount__c,buildertek__RFQ__c, ';
            query += 'buildertek__RFQ__r.Name, buildertek__RFQ__r.buildertek__Description__c,buildertek__RFQ__r.buildertek__Budget__c, buildertek__RFQ__r.buildertek__Project__c, ';
            query += '(Select ' + BT_Utils.getQueryStringForObjectWithAllFields('buildertek__RFQ_Vendor_Item__c')+' FROM buildertek__Vendor_Items__r) ';
            query += 'FROM buildertek__RFQ_To_Vendor__c ';
            query += 'WHERE buildertek__RFQ__c =: recordId AND (buildertek__Status__c =: awardedStatus OR buildertek__Status__c =: acceptedStatus)';
            
            Id subContractRecordType = BT_Utils.getRecordTypeId('Contract__c', 'Sub Contract');
            System.debug('Id : '+subContractRecordType);
            System.debug('Query::' + query);
            Map<Id, buildertek__RFQ_To_Vendor__c> rfqToSubContract = new Map<Id, buildertek__RFQ_To_Vendor__c>();
            for (buildertek__RFQ_To_Vendor__c rfqToVendorRecords : DataBase.Query(string.escapeSingleQuotes(query))){
                Contract__c contractRec = new Contract__c();
                contractRec.Name = rfqToVendorRecords.buildertek__RFQ__r.Name;
                contractRec.Vendor__c = rfqToVendorRecords.buildertek__Vendor__c;
                contractRec.Description__c = rfqToVendorRecords.buildertek__RFQ__r.buildertek__Description__c;
                contractRec.Budget__c = rfqToVendorRecords.buildertek__RFQ__r.buildertek__Budget__c;
                contractRec.rfq__c = rfqToVendorRecords.buildertek__RFQ__c;
                contractRec.Project__c = rfqToVendorRecords.buildertek__RFQ__r.buildertek__Project__c;
                contractRec.Status__c = rfqToVendorRecords.buildertek__Status__c;
                contractRec.buildertek__Change_Order_Amount__c = rfqToVendorRecords.buildertek__Quote_Amount__c;
                contractRec.Signed_Contract_Date__c = System.today();
                contractRec.RecordTypeId = subContractRecordType;
                rfqToSubContract.put(rfqToVendorRecords.buildertek__Vendor__c, rfqToVendorRecords);
                contractRecords.put(rfqToVendorRecords.buildertek__Vendor__c, contractRec);
            }
            if (Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateAble() && Schema.sObjectType.buildertek__Contract__c.fields.Vendor__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.Budget__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.rfq__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.Project__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.Status__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.Signed_Contract_Date__c.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isCreateable()){
                system.debug('Number : '+contractRecords.values().size());
                insert contractRecords.values();
            } 
            //   system.debug(contractRecords.values());
            //  insert contractRecords.values();
            for (buildertek__RFQ_To_Vendor__c rfqToVendorRecords : rfqToSubContract.values()){
                for (buildertek__RFQ_Vendor_Item__c rfqVendorItems : rfqToVendorRecords.buildertek__Vendor_Items__r){
                    buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
                    contractItem.Name = rfqVendorItems.Name;
                    contractItem.buildertek__Contract__c = contractRecords.get(rfqToVendorRecords.buildertek__Vendor__c).Id;
                    contractItem.buildertek__Unit_Price__c = rfqVendorItems.buildertek__Unit_Price__c;
                    contractItem.buildertek__Item_Name__c = rfqVendorItems.buildertek__Item_Name__c;
                    contractItem.buildertek__Quantity__c = rfqVendorItems.buildertek__Quantity__c;
                    contractItem.buildertek__Cost_Code__c = rfqVendorItems.buildertek__Cost_Code__c;
                    contractItem.buildertek__Description__c = rfqVendorItems.buildertek__Description__c;
                    contractItem.buildertek__Notes__c = rfqVendorItems.buildertek__Vendor_Note__c;
                    contractItems.add(contractItem);
                }
            }
            DMLManager.insertAsUser(contractItems);
            
            if(contractRecords.values()[0] != null){
                return 'Success';
            }
            else{
                System.debug('Error1');
                return 'Error1';
            } 
        } else{
            System.debug('recordId : '+recordId);
            return 'Error';
        }
    }
    
    /*--------------------------------------------------------------------------------------------- */
    
    @AuraEnabled
    public Static ResponseBase CreatePOMethod(string RFQId){
        ResponseBase response = new ResponseBase();
        Map<Id, buildertek__Purchase_Order__c> purchaseOrder = new Map<Id, buildertek__Purchase_Order__c>();
        string recordid = '';
        try{
            List<buildertek__RFQ_To_Vendor__c> RFQ;
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Budget__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Quote__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Due_Date__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Vendor__c.isAccessible()){
                RFQ = [Select Id, Name,buildertek__Rfq__c,buildertek__Rfq__r.Name ,buildertek__Vendor__c, buildertek__Rfq__r.buildertek__Project__c,buildertek__Rfq__r.buildertek__Budget__c,buildertek__Rfq__r.buildertek__Quote__c, (SELECT Id, Name, buildertek__Cost_Code__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, buildertek__Item_Name__c, buildertek__Vendor__c, buildertek__RFQ_Item__c, buildertek__Vendor_Name__c, buildertek__Description__c, buildertek__Budget_Line_Amount__c, buildertek__Vendor_Note__c
                                                                                                                                                                                                                                       FROM buildertek__Vendor_Items__r)
                       FROM buildertek__RFQ_To_Vendor__c
                       WHERE buildertek__RFQ__c = :RFQId AND (buildertek__Status__c =: 'Awarded' OR buildertek__Status__c =: 'Accepted')];
            }
            System.debug('Number of RFQ records : '+RFQ.size());
            if (RFQ.size()>0){
                for (buildertek__RFQ_To_Vendor__c rfqItems : RFQ){
                    buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
                    PO.buildertek__Project__c = rfqItems.buildertek__Rfq__r.buildertek__Project__c;
                    PO.buildertek__Status__c = 'Approved';
                    PO.buildertek__Type__c = 'Sales';
                    PO.buildertek__Vendor__c = rfqItems.buildertek__Vendor__c;
                    PO.buildertek__Budget__c = rfqItems.buildertek__Rfq__r.buildertek__Budget__c;
                    PO.buildertek__Quote__c = rfqItems.buildertek__Rfq__r.buildertek__Quote__c;
                    PO.buildertek__RFQ__c = rfqItems.buildertek__Rfq__c;
                    PO.buildertek__Description__c = rfqItems.buildertek__Rfq__r.Name;
                    purchaseOrder.put(rfqItems.buildertek__Vendor__c, PO);
                }
                if (Schema.sObjectType.buildertek__Purchase_Order__c.isCreateAble() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isCreateAble() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isCreateAble() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Type__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Quote__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isCreateable()){
                    insert purchaseOrder.values();
                }
                //Update the RFQ with the Associate Purchase Order
                // RFQ.buildertek__Associated_Purchase_Order__c = PO.Id;
                // if (Schema.sObjectType.buildertek__RFQ__c.isUpdateable() && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Associated_Purchase_Order__c.isUpdateable()){
                //     update RFQ;
                // }
                List<buildertek__Purchase_Order_Item__c> POLines = new List<buildertek__Purchase_Order_Item__c>();
                // List<buildertek__RFQ_Item__c> RfqItemList;
                // if (Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Cost_Code__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Description__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Product__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Quantity__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Total_Price__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Unit_Price__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Budget_Item__c.isAccessible() && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isAccessible()){
                // 	RfqItemList = [Select Id, Name, Cost_Code__c, Description__c, Product__c, Quantity__c, Total_Price__c, Unit_Price__c, buildertek__Budget_Item__c
                // 	               from buildertek__RFQ_Item__c
                // 	               where buildertek__RFQ_Package__c = :RFQ.Id];
                // }
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
                        POLines.add(arItem);
                    }
                }
                if (Schema.sObjectType.buildertek__Purchase_Order_Item__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Description__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Product__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Quantity__c.isCreateable() && Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__RFQ_Item__c.isCreateable()){
                    
                    insert POLines;
                }
                response.strMessage = 'Success';
                if(recordid != null){
                    system.debug('recordid'+recordid);
                    response.strRecordId = recordid;
                }
                return response;
                
            } else{
                response.strMessage = 'RFQ Status Should be Awarded or Accepted';
                
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