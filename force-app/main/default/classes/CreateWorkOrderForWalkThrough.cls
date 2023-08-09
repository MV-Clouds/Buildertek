public class CreateWorkOrderForWalkThrough {
    @AuraEnabled
    public static object getWarrantyLines(String recordId){
        List<MasterquoteClass> WarrantyLinesClassList = new List<MasterquoteClass>();
        List<buildertek__Walk_Through_Line_Items__c> quotesList;
        quotesList = [SELECT Id,
                      Name,
                      buildertek__Walk_Through_List__c,
                      buildertek__Description__c,
                      buildertek__Location__c,
                      buildertek__Details__c,
                      buildertek__Area__c,
                      buildertek__Status__c
                      from buildertek__Walk_Through_Line_Items__c 
                      WHERE buildertek__Walk_Through_List__c =:recordId AND buildertek__Status__c = 'Open'
                     ];    
        
        for(buildertek__Walk_Through_Line_Items__c bud : quotesList){
            MasterquoteClass MasterquotesClassRecord = new MasterquoteClass(); 
            MasterquotesClassRecord.quoteRecord = bud;
            MasterquotesClassRecord.budgetCheck = false;
            WarrantyLinesClassList.add(MasterquotesClassRecord);
        }
        return  WarrantyLinesClassList;                                               
    }
    
    @AuraEnabled
    public static  String createWorkOrder(String walkRecId){
         Id walkID ;
        WorkOrder WO =new WorkOrder();
        insert WO;
        
         
        system.debug(walkRecId);
        if(WO.Id != null){
            if(walkRecId != null){
                walkID = Id.valueOf(walkRecId);
                WO.buildertek__Walk_Through__c = walkID;
                system.debug(WO.buildertek__Walk_Through__c);
                buildertek__Walk_Through_List__c walkThrough = [Select Id,Name, buildertek__Project__c FROM buildertek__Walk_Through_List__c WHERE Id =: walkRecId];
                if(walkThrough.buildertek__Project__c != null){
                    WO.buildertek__Project__c = walkThrough.buildertek__Project__c;
                }
                update WO;
            }
               
             
        }
        return String.ValueOf(WO.id);
    }
   
    
    @AuraEnabled
    public static MessageClass CreateWorkOrderLines(List<String> budgetIds, String recordId){
        System.debug('budgetIds--------------------------------'+budgetIds);
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Walk_Through_Line_Items__c> masterquoteList;
            masterquoteList = [SELECT id, 
                               Name, 
                               buildertek__Area__c,
                               buildertek__Description__c,
                               buildertek__Details__c, 
                               buildertek__Location__c,
                               buildertek__Notes__c,
                               buildertek__Status__c,
                               buildertek__Walk_Through_List__c
                               FROM buildertek__Walk_Through_Line_Items__c
                               WHERE Id IN: budgetIds]; 
            system.debug(masterquoteList);
            List<WorkOrderLineItem> WorkOrderItemList =  new List<WorkOrderLineItem>();
            
            List<buildertek__Walk_Through_Line_Items__c> WarrantyItemList =  new List<buildertek__Walk_Through_Line_Items__c>();
            
            if(!masterquoteList.isEmpty()){
                system.debug('working');
                for(buildertek__Walk_Through_Line_Items__c masterquote : masterquoteList){
                    system.debug('working in waranty item loop');
                    WorkOrderLineItem WorkOrderItem = new WorkOrderLineItem();
                    WorkOrderItem.Description = masterquote.buildertek__Description__c;
                    WorkOrderItem.Status = masterquote.buildertek__Status__c;
                    WorkOrderItem.WorkOrderId = recordId;
                    WorkOrderItemList.add(WorkOrderItem);
                    
                    buildertek__Walk_Through_Line_Items__c WarrantyItem = new buildertek__Walk_Through_Line_Items__c();
                    WarrantyItem.buildertek__Field_For_Work_Order__c = recordId;
                    WarrantyItem.Id = masterquote.Id;
                    WarrantyItemList.add(WarrantyItem);
                }   
            }
            system.debug(WorkOrderItemList.size());
             system.debug('WarrantyItemList------------------------------------------'+WarrantyItemList);
            if(WorkOrderItemList.size() > 0 && WarrantyItemList.size() > 0){
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
        public buildertek__Walk_Through_Line_Items__c quoteRecord {get;set;}
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