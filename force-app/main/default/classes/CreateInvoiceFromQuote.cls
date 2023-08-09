public with sharing class CreateInvoiceFromQuote {
    @AuraEnabled
    public Static ResponseBase CreateInvoiceMethod(string QuoteId){
        ResponseBase response = new ResponseBase();
        try {
            buildertek__Quote__c quoteRec;
            /* if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Change_Order_Amount__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Change_Order__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Status__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Tax_Rate__c.isAccessible()){*/
                                        quoteRec= [select Id, 
                                                 Name, 
                                                 buildertek__Project__c, 
                                                 buildertek__Tax__c,
                                                 buildertek__Status__c 
                                                 from buildertek__Quote__c 
                                                 where Id =: QuoteId];
               // }
            buildertek__Billings__c AR = new buildertek__Billings__c();
            AR.buildertek__Project__c = quoteRec.buildertek__Project__c;
            AR.buildertek__Status__c = 'Open';
          //  AR.buildertek__Customer_Account__c = quoteRec.buildertek__Vendor__c;
           // AR.Change_order__c = quoteRec.buildertek__Change_Order__c;
            AR.Tax_Rate__c = quoteRec.buildertek__Tax__c;
           // AR.buildertek__Approved_CO__c = quoteRec.buildertek__Change_Order_Amount__c;
            Ar.Name = quoteRec.Name;
            Ar.buildertek__Quote__c = quoteRec.Id;
           /* if(Schema.sObjectType.Billings__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Project__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Status__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Customer_Account__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Change_order__c.isCreateable()&&
            Schema.sObjectType.Billings__c.fields.Tax_Rate__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Approved_CO__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Name.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Contract__c.isCreateable()){*/
            insert AR;
           // }
            
            List<Billable_Lines__c> arLines = new List<Billable_Lines__c>();
            List<buildertek__Quote_Item__c> quoteItemList;
           /* if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Cost_Code__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Description__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Item_Name__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Product__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Quantity__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Unit_Price__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isAccessible()){*/
                quoteItemList =  [select Id, 
                                         Name,
                                         buildertek__Cost_Code__c,
                                         buildertek__Description__c,
                                         buildertek__Item_Name__c,
                                         buildertek__Product__c,
                                         buildertek__Quantity__c,
                                         buildertek__Unit_Price__c,
                                         buildertek__Status__c,
                                         buildertek__Notes__c,buildertek__Net_Unit__c
                                         from buildertek__Quote_Item__c 
                                         where buildertek__Quote__c =: QuoteId and buildertek__Status__c = 'Accept'];   
           // }
            for(buildertek__Quote_Item__c quoteItem : quoteItemList){
                
                Billable_Lines__c arItem = new Billable_Lines__c();
                
                arItem.buildertek__Billings__c = AR.Id;
                arItem.buildertek__Line_Title__c = quoteItem.buildertek__Item_Name__c;
                arItem.buildertek__Cost_Code__c = quoteItem.buildertek__Cost_Code__c;
                arItem.Description__c = quoteItem.Name;
                //arItem.buildertek__Description__c = quoteItem.buildertek__Description__c;
                arItem.buildertek__Product__c = quoteItem.buildertek__Product__c;
                arItem.buildertek__Unit_Price__c = quoteItem.buildertek__Net_Unit__c;
                arItem.buildertek__Quantity__c = quoteItem.buildertek__Quantity__c;
                arItem.buildertek__Notes__c = quoteItem.buildertek__Notes__c;
                arItem.buildertek__Quote_Line__c = quoteItem.Id;
                arLines.add(arItem);
            }
             /*if(Schema.sObjectType.Billable_Lines__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Billings__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Line_Title__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Description__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Cost_Code__c.isCreateable()&&
            Schema.sObjectType.Billable_Lines__c.fields.Product__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Contract_Line__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Quantity__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Unit_Price__c.isCreateable()){*/
            insert arLines;
            //}
            response.strMessage = 'Success';
            response.strRecordId = AR.Id;
            
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