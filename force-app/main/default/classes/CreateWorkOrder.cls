public with sharing class CreateWorkOrder {
    @AuraEnabled
    public static object getWarrantyLines(String recordId){
        List<MasterquoteClass> WarrantyLinesClassList = new List<MasterquoteClass>();
        List<buildertek__Warranty_Item__c> quotesList;
        quotesList = [SELECT Id,
                      Name,buildertek__Warranty__r.Name,
                      buildertek__Description__c,
                      buildertek__Date_Submitted__c,
                      buildertek__Contractor_Account__r.Name
                      from buildertek__Warranty_Item__c 
                      WHERE buildertek__Warranty__c =:recordId AND buildertek__Field_For_Work_Order__c = NULL
                     ];    
        
        for(buildertek__Warranty_Item__c bud : quotesList){
            MasterquoteClass MasterquotesClassRecord = new MasterquoteClass(); 
            MasterquotesClassRecord.quoteRecord = bud;
            MasterquotesClassRecord.budgetCheck = false;
            WarrantyLinesClassList.add(MasterquotesClassRecord);
        }
        return  WarrantyLinesClassList;                                               
    }
    
    @AuraEnabled
    public static  String createWorkOrder(String warrantyRecId){
        Id warrantyID ;
        WorkOrder WO =new WorkOrder();
        system.debug(warrantyRecId);
        insert WO;
        if(WO.Id != null){
            if(warrantyRecId != null){
                warrantyID = Id.valueOf(warrantyRecId);
                WO.buildertek__Warranty__c = warrantyID;
                buildertek__Warranty__c waranty = [Select Id,Name, buildertek__Project__c FROM buildertek__Warranty__c WHERE Id =: warrantyRecId];
                if(waranty.buildertek__Project__c != null){
                    WO.buildertek__Project__c = waranty.buildertek__Project__c;
                }
                update WO;
            }
        }
        return String.ValueOf(WO.id);
        
    }    
    
    
    @AuraEnabled
    public static MessageClass CreateWorkOrderLines(List<String> budgetIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Warranty_Item__c> masterquoteList;
            masterquoteList = [SELECT id, 
                               Name, 
                               buildertek__Auto_Number__c,
                               buildertek__Category__c,
                               buildertek__Contractor_Account__c, 
                               buildertek__Contractor_Resource__c,
                               buildertek__Date_Submitted__c,
                               buildertek__Description__c,
                               buildertek__Details__c,
                               buildertek__Internal_Resource__c,
                               buildertek__Location__c,
                               //  buildertek__Notes__c,
                               buildertek__Project__c,
                               buildertek__Purchase_Order__c,
                               buildertek__Service_Request__c,
                               buildertek__Status__c,
                               buildertek__Type__c,
                               buildertek__Warranty__c,
                               buildertek__Work_Date__c
                               FROM buildertek__Warranty_Item__c
                               WHERE Id IN: budgetIds AND buildertek__Field_For_Work_Order__c = NULL]; 
            system.debug(masterquoteList);
            List<WorkOrderLineItem> WorkOrderItemList =  new List<WorkOrderLineItem>();
          
            List<buildertek__Warranty_Item__c> WarrantyItemList =  new List<buildertek__Warranty_Item__c>();
            
            if(!masterquoteList.isEmpty()){
                system.debug('working');
                for(buildertek__Warranty_Item__c masterquote : masterquoteList){
                    system.debug('working in waranty item loop');
                    WorkOrderLineItem WorkOrderItem = new WorkOrderLineItem();
                    WorkOrderItem.Description = masterquote.buildertek__Description__c;
                    WorkOrderItem.Status = masterquote.buildertek__Status__c;
                    WorkOrderItem.WorkOrderId = recordId;
                    WorkOrderItemList.add(WorkOrderItem);
                    
                    buildertek__Warranty_Item__c WarrantyItem = new buildertek__Warranty_Item__c();
                    WarrantyItem.buildertek__Field_For_Work_Order__c = recordId;
                    WarrantyItem.Id = masterquote.Id;
                    WarrantyItemList.add(WarrantyItem);
                }   
            }
            system.debug(WorkOrderItemList.size());
            if(WorkOrderItemList.size() > 0){
                system.debug(WorkOrderItemList);
                
                insert WorkOrderItemList;
                
                update WarrantyItemList;
                
                msg.Status = 'Success';
                msg.Message = 'Work Order Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Warranty Lines for the selected Quote';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
    public class MasterquoteClass{
        @AuraEnabled
        public buildertek__Warranty_Item__c quoteRecord {get;set;}
        @AuraEnabled
        public buildertek__Master_Budget__c masterBudgetRecord {get;set;}
        @AuraEnabled
        public boolean budgetCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    }
}