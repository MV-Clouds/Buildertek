/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  02-Jul-2018
*/
public with sharing class BT_ImportQuote {
    public List<masterQuote> masterQuotes {get;set;}
    public Project__c Project {get;set;}
    String projectId;
    public BT_ImportQuote(ApexPages.StandardController controller){
        
        buildertek__Quote__c record = (buildertek__Quote__c)controller.getRecord();
        projectId = record.Project__c;
        system.debug('----------projectId---'+projectId);
        
        Project = new Project__c();
        if(projectId != null) {
            if(Schema.sObjectType.project__c.fields.Id.isAccessible()
                && Schema.sObjectType.project__c.fields.Name.isAccessible()){
                project = [Select Id, Name from project__c where Id =:projectId];        
            }
        }
        
        masterQuotes = new List<masterQuote>();
        List<buildertek__Quote__c> qList;
        if(Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()){
            qList = [Select Id, Name, Description__c, buildertek__Quote_Amount__c from buildertek__Quote__c where Type__c = 'Master'];    
        }
        for(buildertek__Quote__c qut : qList){
            masterQuote mq = new masterQuote();
            mq.quotes = qut;
            mq.isSelected = false;
            masterQuotes.add(mq);
        }
        
        List<buildertek__Master_Quote__c> mqList;
        if(Schema.sObjectType.buildertek__Master_Quote__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()){
            mqList = [Select Id, Name, Description__c, buildertek__Quote_Amount__c from buildertek__Master_Quote__c ORDER BY Name ASC LIMIT 50000];    
        }
        for(buildertek__Master_Quote__c qut : mqList){
            masterQuote mq = new masterQuote();
            mq.masterQuotes = qut;
            mq.isSelected = false;
            masterQuotes.add(mq);
        }
    }
    
    public BT_ImportQuote(ApexPages.StandardSetController contract){
        system.debug('----------26---');
        projectId = Apexpages.currentPage().getParameters().get('Id').escapeHtml4();
        project = new Project__c();
        
        if(projectId != null) {
            if(Schema.sObjectType.project__c.fields.Id.isAccessible()
                && Schema.sObjectType.project__c.fields.Name.isAccessible()){
                project = [Select Id, Name from project__c where Id =:projectId];
            }    
        }
        
        masterQuotes = new List<masterQuote>();
        List<buildertek__Quote__c> qList;
        if(Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()){
            qList = [Select Id, Name, Description__c, buildertek__Quote_Amount__c from buildertek__Quote__c where Type__c = 'Master'];    
        }
        for(buildertek__Quote__c qu : qList){
            masterQuote mq = new masterQuote();
            mq.quotes = qu;
            mq.isSelected = false;
            masterQuotes.add(mq);
        }
        List<buildertek__Master_Quote__c> mqList;
        if(Schema.sObjectType.buildertek__Master_Quote__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.buildertek__Quote_Amount__c.isAccessible()){
            mqList = [Select Id, Name, Description__c, buildertek__Quote_Amount__c from buildertek__Master_Quote__c ORDER BY Name ASC LIMIT 50000];    
        }
        for(buildertek__Master_Quote__c qu : mqList){
            masterQuote mq = new masterQuote();
            mq.masterQuotes = qu;
            mq.isSelected = false;
            masterQuotes.add(mq);
        }
        
    }
    
    
    public void goback(){
    
    }
    public void save(){
        //String selectedIds = '';
        List<String> selectedIds = new List<String>();
        List<buildertek__Quote__c> masterQuoteList = new List<buildertek__Quote__c>();
        for(masterQuote mc : masterQuotes){
            if(mc.isSelected){
                if(mc.masterQuotes != null){
                    selectedIds.add(mc.masterQuotes.Id);         
                }else if(mc.quotes != null){
                    selectedIds.add(mc.quotes.Id);     
                }
                //selectedIds.add(mc.quotes.Id); 
                if(Schema.sObjectType.buildertek__Quote__c.fields.Name.isCreateable() && 
                Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Status__c.isCreateable() &&
                Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isCreateable()){
                    buildertek__Quote__c quote = new buildertek__Quote__c();
                    if(mc.masterQuotes != null){
                        quote.Name = mc.masterQuotes.Name;  
                    }else if(mc.quotes != null){
                       quote.Name = mc.quotes.Name;  
                    }
                    quote.buildertek__Project__c = projectId;
                    quote.buildertek__Status__c = 'Draft'; 
                    masterQuoteList.add(quote);
                }
            }
            
        }
        if(masterQuoteList.size() > 0){
            insert masterQuoteList;    
        }
        Map<String, String> quoteMap = new Map<String, String>();
        Map<String, String> quoteNameMap = new Map<String, String>();
        for(buildertek__Quote__c qut : masterQuoteList){
            quoteMap.put(qut.Name, qut.Id);
            quoteNameMap.put(qut.Id, qut.Name);
        }
        String groupId;
        Map<String, String> groupMap = new Map<String, String>();
        List<buildertek__Quote_Line_Group__c> quoteGroup;
        if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
            
            quoteGroup = [Select Id, Name from buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];    
        }
        
        if(quoteGroup.size() > 0){
            groupId = quoteGroup[0].Id;        
        }else{
            buildertek__Quote_Line_Group__c qutGroup = new buildertek__Quote_Line_Group__c(); 
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
                qutGroup.Name = 'No Grouping';    
            }
            insert qutGroup;
            groupId = qutGroup.Id;
        }
        List<buildertek__Quote_Item__c> quoteItem;
        if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Item_Name__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible()){
            
            quoteItem = [select Id, Name, buildertek__Quote__c, buildertek__Quote__r.Name, buildertek__Product__c, buildertek__Item_Name__c, 
                                                                  buildertek__Cost_Code__c,buildertek__Quantity__c,buildertek__Grouping__c,buildertek__Grouping__r.Name, 
                                                                  buildertek__Markup__c, buildertek__Unit_Cost__c from buildertek__Quote_Item__c
                                                                  where buildertek__Quote__c IN: selectedIds];    
        }
        
        
        List<buildertek__Master_Quote_Item__c> masterQuoteItem;
        if(Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Master_Quote__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Product__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Item_Name__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Cost_Code__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Quantity__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Markup__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Unit_Cost__c.isAccessible()
            && Schema.sObjectType.buildertek__Master_Quote_Item__c.fields.buildertek__Quote_Line_Group__c.isAccessible()
            && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
            
            masterQuoteItem = [select Id, Name, buildertek__Master_Quote__c, buildertek__Master_Quote__r.Name, buildertek__Product__c, buildertek__Item_Name__c, 
                                                                  buildertek__Cost_Code__c,buildertek__Quantity__c,buildertek__Quote_Line_Group__c,buildertek__Quote_Line_Group__r.Name, 
                                                                  buildertek__Markup__c, buildertek__Unit_Cost__c from buildertek__Master_Quote_Item__c
                                                                  where buildertek__Master_Quote__c IN: selectedIds];    
        }
        
                                                                  
        List<buildertek__Quote_Item__c> quoteItemToInsert = new List<buildertek__Quote_Item__c>();
        for(buildertek__Quote_Item__c quoteItems : quoteItem){
            system.debug('Budget Id ----------> '+quoteMap.get(quoteItems.buildertek__Quote__r.Name));
            system.debug('Group Name ----------> '+quoteItems.buildertek__Grouping__r.Name);
            if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Item_Name__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable()
              && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable()){
                
                buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                quoteLine.Name = quoteItems.Name;
                quoteLine.buildertek__Quote__c = quoteMap.get(quoteItems.buildertek__Quote__r.Name);
                quoteLine.buildertek__Product__c = quoteItems.buildertek__Product__c;
                quoteLine.buildertek__Item_Name__c = quoteItems.buildertek__Item_Name__c;
                quoteLine.buildertek__Markup__c = quoteItems.buildertek__Markup__c;
                quoteLine.buildertek__Cost_Code__c = quoteItems.buildertek__Cost_Code__c;
                quoteLine.buildertek__Quantity__c = quoteItems.buildertek__Quantity__c;
                quoteLine.buildertek__Unit_Cost__c = quoteItems.buildertek__Unit_Cost__c;
                if(quoteItems.buildertek__Grouping__c != null){
                    quoteLine.buildertek__Grouping__c = quoteItems.buildertek__Grouping__c;    
                }else{
                    quoteLine.buildertek__Grouping__c = groupId;    
                }
                quoteItemToInsert.add(quoteLine);
            }   
        }
        for(buildertek__Master_Quote_Item__c masterQuoteItems : masterQuoteItem){
            system.debug('Budget Id ----------> '+quoteMap.get(masterQuoteItems.buildertek__Master_Quote__r.Name));
            system.debug('Group Name ----------> '+masterQuoteItems.buildertek__Quote_Line_Group__r.Name);
            if(Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Item_Name__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable()
               && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable()
              && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Markup__c.isCreateable() && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable() ){
                
                buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                quoteLine.Name = masterQuoteItems.Name;
                quoteLine.buildertek__Quote__c = quoteMap.get(masterQuoteItems.buildertek__Master_Quote__r.Name);
                quoteLine.buildertek__Product__c = masterQuoteItems.buildertek__Product__c;
                quoteLine.buildertek__Item_Name__c = masterQuoteItems.buildertek__Item_Name__c;
                quoteLine.buildertek__Markup__c = masterQuoteItems.buildertek__Markup__c;
                quoteLine.buildertek__Cost_Code__c = masterQuoteItems.buildertek__Cost_Code__c;
                quoteLine.buildertek__Quantity__c = masterQuoteItems.buildertek__Quantity__c;
                quoteLine.buildertek__Unit_Cost__c = masterQuoteItems.buildertek__Unit_Cost__c;
                if(masterQuoteItems.buildertek__Quote_Line_Group__c != null){
                    quoteLine.buildertek__Grouping__c = masterQuoteItems.buildertek__Quote_Line_Group__c;    
                }else{
                    quoteLine.buildertek__Grouping__c = groupId;    
                }
                quoteItemToInsert.add(quoteLine);
            }   
        }
        if(quoteItemToInsert.size() > 0){
            insert quoteItemToInsert;    
        }
        /*Map<String,String> additionalFields = new Map<String,String>();
        additionalFields.put('Project__c',projectId);
        additionalFields.put('Type__c','Standard');
        
        BT_Utils.CloneAny('buildertek__Quote__c', selectedIds, 'buildertek__Quote__c', 'buildertek__Quote_Item__c', additionalFields);*/
                
    }
    
    public class masterQuote{
        public buildertek__Quote__c quotes {get;set;}
        public buildertek__Master_Quote__c masterQuotes {get;set;}
        public Boolean isSelected {get;set;}
    }
}