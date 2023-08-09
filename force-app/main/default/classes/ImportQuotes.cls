public with sharing class ImportQuotes {
    /**/
    @AuraEnabled
    public static object getMasterQuotes(){
        List<buildertek__Quote__c> quotesList;
        if(Schema.sObjectType.buildertek__Quote__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Grand_Total__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Type__c.isAccessible()
            && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
            
            quotesList = [SELECT Id,
                                Name,
                                buildertek__Quote_Amount__c,
                                buildertek__Grand_Total__c,
                                buildertek__Project__r.Name,
                                buildertek__Type__c
                                FROM buildertek__Quote__c 
                                ORDER By Name ASC
                                LIMIT 50000];    
        }
            
        
        List<MasterQuotesClass> MasterQuotesClassList = new List<MasterQuotesClass>();
        
        for(buildertek__Quote__c qut : quotesList){
            MasterQuotesClass MasterQuotesClassRecord = new MasterQuotesClass(); 
            MasterQuotesClassRecord.quoteRecord = qut;
            MasterQuotesClassRecord.quoteCheck = false;
            MasterQuotesClassList.add(MasterQuotesClassRecord);
        }
        list<buildertek__Master_Quote__c> masterQuoteList;
        if(Schema.sObjectType.buildertek__Master_Quote__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.buildertek__Type__c.isAccessible()){
            
            masterQuoteList = [select id, 
                                        Name, 
                                        buildertek__Type__c 
                                        from buildertek__Master_Quote__c 
                                        ORDER BY Name 
                                        ASC limit 50000];    
        }
        
                                                                        
        for(buildertek__Master_Quote__c masterQuote : masterQuoteList){
            MasterQuotesClass MasterQuotesClassRecord = new MasterQuotesClass(); 
            MasterQuotesClassRecord.masterQuoteRecord = masterQuote;
            MasterQuotesClassRecord.quoteCheck = false;
            MasterQuotesClassList.add(MasterQuotesClassRecord);
        }
        return  MasterQuotesClassList;                                               
    }
    
    @AuraEnabled
    public static MessageClass importMasterQuoteLines(List<String> quoteIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Quote_Item__c> quoteItemList;
            if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Additional_Discount__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Description__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Applied_Markup__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Vendor__c.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible()){
                                            quoteItemList = [SELECT Id,
                                                                Name,
                                                                buildertek__Cost_Code__c,
                                                                buildertek__Additional_Discount__c,
                                                                buildertek__Description__c,
                                                                buildertek__Applied_Markup__c,
                                                                buildertek__Grouping__c,
                                                                buildertek__Markup__c,
                                                                buildertek__Product__c,
                                                                buildertek__Quantity__c,
                                                                buildertek__Unit_Cost__c,
                                                                buildertek__Unit_Price__c,
                                                                buildertek__UOM__c,
                                                                buildertek__Vendor__c
                                                                FROM buildertek__Quote_Item__c
                                                                WHERE buildertek__Quote__c IN: quoteIds]; 
             }
             List<buildertek__Master_Quote_Item__c> masterQuoteItemList;
             if(Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Additional_Discount__c.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Description__c.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Applied_Markup__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Quote_Line_Group__c.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Markup__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Product__c.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Quantity__c.isAccessible()&&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Unit_Price__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__UOM__c.isAccessible() &&
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Vendor__c.isAccessible() && 
                Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Master_Quote__c.isAccessible()){                                                   
                                 masterQuoteItemList = [SELECT Id,
                                                        Name,
                                                        buildertek__Cost_Code__c,
                                                        buildertek__Additional_Discount__c,
                                                        buildertek__Description__c,
                                                        buildertek__Applied_Markup__c,
                                                        buildertek__Quote_Line_Group__c,
                                                        buildertek__Markup__c,
                                                        buildertek__Product__c,
                                                        buildertek__Quantity__c,
                                                        buildertek__Unit_Cost__c,
                                                        buildertek__Unit_Price__c,
                                                        buildertek__UOM__c,
                                                        buildertek__Vendor__c
                                                        FROM buildertek__Master_Quote_Item__c
                                                        WHERE buildertek__Master_Quote__c IN: quoteIds];                                                     
                }
            List<buildertek__Quote_Item__c> quoteItemToInsertList =  new List<buildertek__Quote_Item__c>();
             buildertek__Quote_Line_Group__c quoteGroup ;
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
              quoteGroup = [SELECT Id FROM buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];
            }
            
            for(buildertek__Quote_Item__c qutItem : quoteItemList){
                buildertek__Quote_Item__c quoteItemToInsert = new buildertek__Quote_Item__c();  
                quoteItemToInsert.Name = qutItem.Name;
                quoteItemToInsert.buildertek__Quote__c = recordId;
                quoteItemToInsert.buildertek__Cost_Code__c = qutItem.buildertek__Cost_Code__c;
                quoteItemToInsert.buildertek__Additional_Discount__c = qutItem.buildertek__Additional_Discount__c;
                quoteItemToInsert.buildertek__Description__c = qutItem.buildertek__Description__c;
                quoteItemToInsert.buildertek__Applied_Markup__c = qutItem.buildertek__Applied_Markup__c;
                quoteItemToInsert.buildertek__Grouping__c = quoteGroup.Id;
                quoteItemToInsert.buildertek__Markup__c = qutItem.buildertek__Markup__c;
                quoteItemToInsert.buildertek__Product__c = qutItem.buildertek__Product__c;
                quoteItemToInsert.buildertek__Quantity__c = qutItem.buildertek__Quantity__c;
                quoteItemToInsert.buildertek__Unit_Cost__c = qutItem.buildertek__Unit_Cost__c;
                quoteItemToInsert.buildertek__Unit_Price__c = qutItem.buildertek__Unit_Price__c;
                quoteItemToInsert.buildertek__UOM__c = qutItem.buildertek__UOM__c;
                quoteItemToInsert.buildertek__Vendor__c = qutItem.buildertek__Vendor__c;
                quoteItemToInsertList.add(quoteItemToInsert);
            } 
            if(quoteItemToInsertList.size() > 0){
                if(Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Additional_Discount__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Description__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Applied_Markup__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__UOM__c.isCreateable() &&
        			Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Vendor__c.isCreateable() ){
                    insert quoteItemToInsertList;
        				}
                msg.Status = 'Success';
                msg.Message = 'Quote Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Quote Lines for this Quote';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
    public class MasterQuotesClass{
         @AuraEnabled
         public buildertek__Quote__c quoteRecord {get;set;}
          @AuraEnabled
         public buildertek__Master_Quote__c masterQuoteRecord {get;set;}
         @AuraEnabled
         public boolean quoteCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    } 
}