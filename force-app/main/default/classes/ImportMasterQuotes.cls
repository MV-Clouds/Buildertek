public with sharing class ImportMasterQuotes {
    
    @AuraEnabled
    public static object getMasterQuotes(String searchKeyword){
        list<buildertek__Master_Quote__c> masterQuoteList;
        String searchString = '%' + searchKeyword + '%';
        If(Schema.sObjectType.buildertek__Master_Quote__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Quote__c.fields.Id.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Quote__c.fields.buildertek__Type__c.isAccessible() &&
              Schema.sObjectType.buildertek__Master_Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()){
               masterQuoteList= [select id, Name, buildertek__Type__c, buildertek__Quote_Amount__c 
                                                                        from buildertek__Master_Quote__c WHERE Name LIKE:searchString  ORDER BY Name ASC limit 50000];
              }
            System.debug('masterQuoteList--->>>'+masterQuoteList);                                               
        List<MasterQuotesClass> MasterQuotesClassList = new List<MasterQuotesClass>();
        for(buildertek__Master_Quote__c masterQuote : masterQuoteList){
            MasterQuotesClass MasterQuotesClassRecord = new MasterQuotesClass(); 
            MasterQuotesClassRecord.masterQuoteRecord = masterQuote;
            MasterQuotesClassRecord.quoteCheck = false;
            MasterQuotesClassList.add(MasterQuotesClassRecord);
        }
        string type1 = 'Master';
        String query= 'SELECT Id, Name, buildertek__Project__r.Name, buildertek__Quote_Amount__c FROM buildertek__Master_Quote__c ';
        if ( searchKeyword != '' && searchKeyword != null ) {
            query = query + ' WHERE Name LIKE \'' + searchKeyword + '%\'';
        }
        masterQuoteList = Database.query(query); 

        List<buildertek__Quote__c> quotesList;
        If(Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
              Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() &&
               Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible() &&
              Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isAccessible() &&
              Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Type__c.isAccessible() &&
              Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){ 
                         quotesList = [SELECT Id,
                                        Name,
                                        buildertek__Quote_Amount__c,
                                        buildertek__Project__r.Name,
                                        buildertek__Type__c
                                        FROM buildertek__Quote__c
                                        WHERE buildertek__Type__c = 'Master' AND Name LIKE:searchString ORDER BY Name ASC];    
        
              }
        for(buildertek__Quote__c qut : quotesList){
            MasterQuotesClass MasterQuotesClassRecord = new MasterQuotesClass(); 
            MasterQuotesClassRecord.quoteRecord = qut;
            MasterQuotesClassRecord.quoteCheck = false;
            MasterQuotesClassList.add(MasterQuotesClassRecord);
        }
        return  MasterQuotesClassList;                                               
    }

    @AuraEnabled
    public static List<buildertek__Quote__c> getQuoteSearch (String searchKeyword){
        // buildertek__Quote__c quote = [SELECT Id,Name FROM buildertek__Quote__c WHERE Id = :quotId];
        // System.debug('quote--->>>'+quote);
        string type1 = 'Master';
        string type2 = 'Standard';
        String query= 'SELECT Id, Name, buildertek__Project__r.Name, buildertek__Quote_Amount__c FROM buildertek__Quote__c WHERE buildertek__Type__c = \''+type1+'\'';
        if ( searchKeyword != '' && searchKeyword != null ) {
            query = query + ' AND Name LIKE \'' + searchKeyword + '%\'';
        }
        System.debug('query--->>>'+query);
        return Database.query(query);
    } 
    
    @AuraEnabled
    public static MessageClass importMasterQuoteLines(List<String> quoteIds, String recordId){
        MessageClass msg = new MessageClass();
        try{
            List<buildertek__Quote_Item__c> quoteItemList;
            if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
                                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Notes__c.isAccessible() &&
                                Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Priority__c.isAccessible() &&
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
                        quoteItemList= [SELECT Id, Name, buildertek__Cost_Code__c, buildertek__Notes__c, buildertek__Priority__c, buildertek__Additional_Discount__c,
                                        buildertek__Description__c, buildertek__Applied_Markup__c, buildertek__Grouping__c,
                                        buildertek__Markup__c, buildertek__Product__c, buildertek__Quantity__c, buildertek__Unit_Cost__c,
                                        buildertek__Unit_Price__c, buildertek__UOM__c, buildertek__Vendor__c, buildertek__Quote__c, 
                                        buildertek__Quote__r.buildertek__Memo__c, buildertek__Quote__r.buildertek__Email_Body__c, 
                                        buildertek__Quote__r.buildertek__Section_I__c, buildertek__Quote__r.buildertek__Section_II__c, 
                                        buildertek__Quote__r.buildertek__Section_III__c, buildertek__Quote__r.buildertek__Section_IV__c, 
                                        buildertek__Quote__r.buildertek__Section_V__c, buildertek__Quote__r.buildertek__Section_VI__c, 
                                        buildertek__Quote__r.buildertek__Section_VII__c, buildertek__Quote__r.buildertek__Section_VIII__c, 
                                        buildertek__Quote__r.buildertek__Section_X__c, buildertek__Quote__r.buildertek__Section_IX__c, 
                                        buildertek__Quote__r.buildertek__Footer__c FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c IN: quoteIds]; 
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
                        masterQuoteItemList= [SELECT Id, Name, buildertek__Cost_Code__c, buildertek__Additional_Discount__c,
                                                buildertek__Description__c, buildertek__Applied_Markup__c, buildertek__Quote_Line_Group__c,
                                                buildertek__Markup__c, buildertek__Product__c, buildertek__Quantity__c, buildertek__Unit_Cost__c,
                                                buildertek__Unit_Price__c, buildertek__UOM__c, buildertek__Vendor__c, buildertek__Master_Quote__c, 
                                                buildertek__Master_Quote__r.buildertek__Email_Body__c FROM buildertek__Master_Quote_Item__c
                                                WHERE buildertek__Master_Quote__c IN: quoteIds];                                                     
            }

            List<buildertek__Quote_Item__c> quoteItemToInsertList =  new List<buildertek__Quote_Item__c>();
            buildertek__Quote_Line_Group__c quoteGroup;
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
                quoteGroup= [SELECT Id FROM buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];
            }
            if(!masterQuoteItemList.isEmpty()){
                for(buildertek__Master_Quote_Item__c qutItem : masterQuoteItemList){
                    buildertek__Quote_Item__c quoteItemToInsert = new buildertek__Quote_Item__c();  
                    quoteItemToInsert.Name = qutItem.Name;
                    quoteItemToInsert.buildertek__Quote__c = recordId;
                    quoteItemToInsert.buildertek__Cost_Code__c = qutItem.buildertek__Cost_Code__c;
                    quoteItemToInsert.buildertek__Additional_Discount__c = qutItem.buildertek__Additional_Discount__c;
                    quoteItemToInsert.buildertek__Description__c = qutItem.buildertek__Description__c;
                    quoteItemToInsert.buildertek__Applied_Markup__c = qutItem.buildertek__Applied_Markup__c;
                    if(qutItem.buildertek__Quote_Line_Group__c != null){
                       quoteItemToInsert.buildertek__Grouping__c = qutItem.buildertek__Quote_Line_Group__c; 
                    }else{
                        quoteItemToInsert.buildertek__Grouping__c = quoteGroup.Id;
                    }
                    quoteItemToInsert.buildertek__Markup__c = qutItem.buildertek__Markup__c;
                    quoteItemToInsert.buildertek__Product__c = qutItem.buildertek__Product__c;
                    quoteItemToInsert.buildertek__Quantity__c = qutItem.buildertek__Quantity__c;
                    quoteItemToInsert.buildertek__Unit_Cost__c = qutItem.buildertek__Unit_Cost__c;
                    quoteItemToInsert.buildertek__Unit_Price__c = qutItem.buildertek__Unit_Price__c;
                    quoteItemToInsert.buildertek__UOM__c = qutItem.buildertek__UOM__c;
                    quoteItemToInsert.buildertek__Vendor__c = qutItem.buildertek__Vendor__c;
                    quoteItemToInsertList.add(quoteItemToInsert);
                }         
            }
            if(!quoteItemList.isEmpty()){
                for(buildertek__Quote_Item__c qutItem : quoteItemList){
                    buildertek__Quote_Item__c quoteItemToInsert = new buildertek__Quote_Item__c();  
                    quoteItemToInsert.Name = qutItem.Name;
                    quoteItemToInsert.buildertek__Quote__c = recordId;
                    quoteItemToInsert.buildertek__Cost_Code__c = qutItem.buildertek__Cost_Code__c;
                    quoteItemToInsert.buildertek__Notes__c = qutItem.buildertek__Notes__c;
                    quoteItemToInsert.buildertek__Priority__c = qutItem.buildertek__Priority__c;
                    quoteItemToInsert.buildertek__Additional_Discount__c = qutItem.buildertek__Additional_Discount__c;
                    quoteItemToInsert.buildertek__Description__c = qutItem.buildertek__Description__c;
                    quoteItemToInsert.buildertek__Applied_Markup__c = qutItem.buildertek__Applied_Markup__c;
                    if(qutItem.buildertek__Grouping__c != null){
                       quoteItemToInsert.buildertek__Grouping__c = qutItem.buildertek__Grouping__c; 
                    }else{
                        quoteItemToInsert.buildertek__Grouping__c = quoteGroup.Id;
                    }
                    quoteItemToInsert.buildertek__Markup__c = qutItem.buildertek__Markup__c;
                    quoteItemToInsert.buildertek__Product__c = qutItem.buildertek__Product__c;
                    quoteItemToInsert.buildertek__Quantity__c = qutItem.buildertek__Quantity__c;
                    quoteItemToInsert.buildertek__Unit_Cost__c = qutItem.buildertek__Unit_Cost__c;
                    quoteItemToInsert.buildertek__Unit_Price__c = qutItem.buildertek__Unit_Price__c;
                    quoteItemToInsert.buildertek__UOM__c = qutItem.buildertek__UOM__c;
                    quoteItemToInsert.buildertek__Vendor__c = qutItem.buildertek__Vendor__c;
                    quoteItemToInsertList.add(quoteItemToInsert);
                }     
            }
            if(quoteItemToInsertList.size() > 0){
                if(Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()&&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable() &&
                    Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() &&
                                        Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Notes__c.isCreateable() &&
                                        Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Priority__c.isCreateable() &&
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

                    buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Memo__c, buildertek__Email_Body__c, buildertek__Section_I__c, 
                                                    buildertek__Section_II__c, buildertek__Section_III__c, buildertek__Section_IV__c, buildertek__Section_V__c, 
                                                    buildertek__Section_VI__c, buildertek__Section_VII__c, buildertek__Section_VIII__c, buildertek__Section_X__c, 
                                                    buildertek__Section_IX__c, buildertek__Footer__c FROM buildertek__Quote__c WHERE Id =:recordId];

                                                    

                    if(!quoteItemList.isEmpty()){
                        quote.buildertek__Memo__c = quoteItemList[0].buildertek__Quote__r.buildertek__Memo__c;
                        quote.buildertek__Email_Body__c = quoteItemList[0].buildertek__Quote__r.buildertek__Email_Body__c;
                        quote.buildertek__Section_I__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_I__c;
                        quote.buildertek__Section_II__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_II__c;
                        quote.buildertek__Section_III__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_III__c;
                        quote.buildertek__Section_IV__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_IV__c;
                        quote.buildertek__Section_V__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_V__c;
                        quote.buildertek__Section_VI__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_VI__c;
                        quote.buildertek__Section_VII__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_VII__c;
                        quote.buildertek__Section_VIII__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_VIII__c;
                        quote.buildertek__Section_X__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_X__c;
                        quote.buildertek__Section_IX__c = quoteItemList[0].buildertek__Quote__r.buildertek__Section_IX__c;
                        quote.buildertek__Footer__c = quoteItemList[0].buildertek__Quote__r.buildertek__Footer__c;
                    } else if(!masterQuoteItemList.isEmpty()) {
                        quote.buildertek__Email_Body__c = masterQuoteItemList[0].buildertek__Master_Quote__r.buildertek__Email_Body__c;
                    }
                    update quote;

                msg.Status = 'Success';
                msg.Message = 'Quote Lines Imported Successfully';
            }else{
                // msg.Status = 'Failed';
                // msg.Message = 'There were no Quote Lines for the selected Quote';  

                // Updated by: Poojan Gabani
                // Date:28-07-2023  Ticket No: BUIL-3436.
                // just changed the Error message to Sucess Message.
                buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Memo__c, buildertek__Email_Body__c, buildertek__Section_I__c, 
                                                    buildertek__Section_II__c, buildertek__Section_III__c, buildertek__Section_IV__c, buildertek__Section_V__c, 
                                                    buildertek__Section_VI__c, buildertek__Section_VII__c, buildertek__Section_VIII__c, buildertek__Section_X__c, 
                                                    buildertek__Section_IX__c, buildertek__Footer__c FROM buildertek__Quote__c WHERE Id =:recordId];
                List<buildertek__Quote__c> quote1 = [SELECT Id, Name, buildertek__Memo__c, buildertek__Email_Body__c, buildertek__Section_I__c, 
                                                    buildertek__Section_II__c, buildertek__Section_III__c, buildertek__Section_IV__c, buildertek__Section_V__c, 
                                                    buildertek__Section_VI__c, buildertek__Section_VII__c, buildertek__Section_VIII__c, buildertek__Section_X__c, 
                                                    buildertek__Section_IX__c, buildertek__Footer__c FROM buildertek__Quote__c WHERE Id =:quoteIds];
                    // if(!quoteItemList.isEmpty()){
                        system.debug('new to complete');
                        quote.buildertek__Memo__c = quote1[0].buildertek__Memo__c;
                        quote.buildertek__Email_Body__c = quote1[0].buildertek__Email_Body__c;
                        quote.buildertek__Section_I__c = quote1[0].buildertek__Section_I__c;
                        quote.buildertek__Section_II__c = quote1[0].buildertek__Section_II__c;
                        quote.buildertek__Section_III__c = quote1[0].buildertek__Section_III__c;
                        quote.buildertek__Section_IV__c = quote1[0].buildertek__Section_IV__c;
                        quote.buildertek__Section_V__c = quote1[0].buildertek__Section_V__c;
                        quote.buildertek__Section_VI__c = quote1[0].buildertek__Section_VI__c;
                        quote.buildertek__Section_VII__c = quote1[0].buildertek__Section_VII__c;
                        quote.buildertek__Section_VIII__c = quote1[0].buildertek__Section_VIII__c;
                        quote.buildertek__Section_X__c = quote1[0].buildertek__Section_X__c;
                        quote.buildertek__Section_IX__c = quote1[0].buildertek__Section_IX__c;
                        quote.buildertek__Footer__c = quote1[0].buildertek__Footer__c;
                    // } 
                    // else if(!masterQuoteItemList.isEmpty()) {
                    //     quote.buildertek__Email_Body__c = masterQuoteItemList[0].buildertek__Master_Quote__r.buildertek__Email_Body__c;
                    // }
                    update quote;
                msg.Status = 'Success';
                msg.Message = 'You have imported a Master Quote which has no Quote Lines.';
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