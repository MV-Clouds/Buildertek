public with sharing class CreateQuoteFromRFQ {
    @AuraEnabled
    public Static ResponseBase CreateQuote(string RFQId){
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
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Status__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_To_Vendor__c.fields.buildertek__Vendor__c.isAccessible()
				
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.Id.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.Name.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Cost_Code__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Product__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Quantity__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Total_Price__c.isAccessible()
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Unit_Price__c.isAccessible() 
				&& Schema.sObjectType.buildertek__RFQ_Item__c.fields.buildertek__Budget_Item__c.isAccessible()){
                    RFQ= [Select Id, Name, 
                        buildertek__Project__c,
                        buildertek__Budget__c,
                        buildertek__Quote__c,
                        buildertek__Due_Date__c, 
                        buildertek__Status__c,                                              
                        buildertek__Vendor__r.buildertek__Vendor__c,
                        buildertek__Vendor__c,
              			(Select Id, Name,
                         buildertek__Cost_Code__c,
                         buildertek__Description__c,
                         buildertek__Product__c,
                         buildertek__Quantity__c,
                         buildertek__Total_Price__c,
                         buildertek__Unit_Price__c ,
                         buildertek__Budget_Item__c
                         from buildertek__RFQ_Items__r)
                        from buildertek__RFQ__c where Id =: RFQId];
                        
				}
            Map<Id, RFQ__c> rfqMap = new Map<Id, RFQ__c>();
            rfqMap.put(RFQId, RFQ);
            response.strMessage = 'Success';
            response.strRecordId = QuoteDAO.createQuoteFromRFQ(rfqMap);
            
            return response;
             
           
        } 
        catch(Exception ex){
            system.debug(ex + ' ex.getMessage() ' + ex.getMessage());
            response.strMessage = ex.getMessage();
            return response;
        }
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }

}