public with sharing class createWorkOrderController {
    
    @AuraEnabled
    public static ResponseWrapper createWorkOrder(Id poId) {
        ResponseWrapper returnValue = new ResponseWrapper();
        try {
            buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Description__c, buildertek__Work_Order__c, buildertek__Status__c, buildertek__Project__c FROM buildertek__Purchase_Order__c WHERE Id = :poId LIMIT 1];
            
            List<buildertek__Purchase_Order_Item__c> poItemList = [SELECT Id, Name, buildertek__Product__c, buildertek__Discount__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c, buildertek__Purchase_Order__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c = :poId];
            
            if (poItemList.isEmpty()) {
                returnValue.state = 'Error';
                returnValue.returnMessage = 'No Purchase Order Items found!';
                return returnValue;
            }
            if (po.buildertek__Work_Order__c != null) {
                returnValue.state = 'Error';
                returnValue.returnMessage = 'Work Order already created for this Purchase Order!';
                return returnValue;
            }
            WorkOrder wo = new WorkOrder();
            wo.Description = po.buildertek__Description__c;
            wo.Subject = po.Name;
            wo.buildertek__Project__c = po.buildertek__Project__c;
            wo.buildertek__BT_Purchase_Order__c = po.Id;
            insert wo;
            
            po.buildertek__Work_Order__c = wo.Id;
            update po;

            List<WorkOrderLineItem> workOrderLineList = new List<WorkOrderLineItem>();
            for (buildertek__Purchase_Order_Item__c poItem : poItemList) {
                WorkOrderLineItem woItem = new WorkOrderLineItem();
                woItem.WorkOrderId = wo.Id;
                // woItem.Product2Id = poItem.buildertek__Product__c;
                // if (poItem.buildertek__Product__c != null) {
                //     woItem.Discount = poItem.buildertek__Discount__c;
                //     woItem.Quantity = poItem.buildertek__Quantity__c;
                //     woItem.UnitPrice = poItem.buildertek__Unit_Price__c;
                // }
                workOrderLineList.add(woItem);
            }
            
            if (!workOrderLineList.isEmpty()) {
                insert workOrderLineList;
            }
            
            returnValue.state = 'Success';
            returnValue.returnMessage = 'Work Order created successfully!';
        } catch (Exception e) {
            System.debug('Error in createWorkOrder ..' + e.getMessage() + '\n' + e + '\n Exception line no : ' + e.getLineNumber() + '--->' + e.getStackTraceString());
            
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(e);
            }
            returnValue.state = 'Error';
            returnValue.returnMessage = 'There was an issue creating the Work Order! Please contact your System Administrator.';
        }
        return returnValue;
    }

    public class ResponseWrapper {
        @AuraEnabled public String state;
        @AuraEnabled public String returnMessage;
    }
}