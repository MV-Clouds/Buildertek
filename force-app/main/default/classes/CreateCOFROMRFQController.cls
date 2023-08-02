public with sharing class CreateCOFROMRFQController {
    @AuraEnabled
    public Static ResponseBase CreateCOMethod(string rfqId){
        ResponseBase response = new ResponseBase();
         try {
            buildertek__RFQ__c RFQ;
            if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible() 
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Budget__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Quote__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Due_Date__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Vendor__c.isAccessible()){
                                            RFQ= [Select Id, Name, 
                                                buildertek__Project__c,
                                                buildertek__Budget__c,
                                                buildertek__Quote__c,
                                                buildertek__Due_Date__c, 
                                                buildertek__Status__c,                                              
                                                buildertek__Vendor__r.buildertek__Vendor__c,
                                                buildertek__Vendor__c 
                                                from buildertek__RFQ__c where Id =: rfqId]; 
            }
            if(RFQ.buildertek__Status__c == 'Awarded' || RFQ.buildertek__Status__c == 'Accepted'){
                buildertek__Change_Order__c co = new buildertek__Change_Order__c();
                co.Name = RFQ.Name;
                co.buildertek__RFQ__c = RFQ.id;
                co.buildertek__Budget__c = RFQ.budget__c;
                co.buildertek__Project__c = RFQ.Project__c;
                co.buildertek__Customer_Account__c = RFQ.vendor__r.buildertek__Vendor__c;
                if(Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__RFQ__c.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isCreateable() ){
                insert co;
    			}
                List<Change_Order_Item__c> coItems = new List<Change_Order_Item__c>();
                List<buildertek__RFQ_Item__c> rfqItemList;
                if(Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Cost_Code__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Description__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Product__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Quantity__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Total_Price__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.Unit_Price__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Budget_Item__c.isAccessible()
                    && Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__RFQ_Package__c.isAccessible()){
                    rfqItemList = [Select Id, 
                                            Name,
                                            Cost_Code__c,
                                            Description__c,
                                            Product__c,
                                            Quantity__c,
                                            Total_Price__c,
                                            Unit_Price__c ,
                                            buildertek__Budget_Item__c
                                            from buildertek__RFQ_Item__c 
                                            where buildertek__RFQ_Package__c =:RFQ.Id];
                }
                for(buildertek__RFQ_Item__c RfqItem : rfqItemList){
                                                                    
                     Change_Order_Item__c coItem = new Change_Order_Item__c();
                     coItem.Name = RfqItem.Name;
                     coItem.buildertek__Change_Order__c = co.Id;
                     coItem.buildertek__Description__c = RfqItem.Description__c;
                     coItem.buildertek__Budget_Item__c = RfqItem.buildertek__Budget_Item__c;
                     coItem.buildertek__Quantity__c = RfqItem.buildertek__Quantity__c;
                     coItem.buildertek__Cost_Code__c = RfqItem.Cost_Code__c;
                     coItem.buildertek__Unit_Price__c = RfqItem.Unit_Price__c;
                     coItems.add(coItem);
                }
                if(coItems.size() > 0){
                if(Schema.sObjectType.Change_Order_Item__c.isCreateable() &&
                    Schema.sObjectType.Change_Order_Item__c.fields.Name.isCreateable() &&
                    Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Change_Order__c.isCreateable() &&
        			Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Description__c.isCreateable() &&
        			Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable()&&
        			Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
        			Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Cost_Code__c.isCreateable() &&
        			Schema.sObjectType.Change_Order_Item__c.fields.buildertek__Unit_Price__c.isCreateable() ){
                    insert coItems;    
        		  }
                }
                response.strMessage = 'Success';
                response.strRecordId = co.Id;
                return response;
            }else{
                response.strMessage = 'RFQ Status Should be Awarded or Accepted';
                return response; 
            }
         }catch(Exception exp){
             response.strMessage = exp.getMessage();
             return response;
         }
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }
}