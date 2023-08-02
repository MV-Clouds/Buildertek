/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  11-Apr-2018
*/
public with sharing class BT_ProductsAdderController {
    @AuraEnabled
    public static Opportunity getOpportunityRecord(Id opportunityId){
        List<Opportunity> opps;
        if(Schema.sObjectType.Opportunity.fields.Id.isAccessible()
            && Schema.sObjectType.Opportunity.fields.Name.isAccessible()
            && Schema.sObjectType.Pricebook2.fields.Id.isAccessible()
            && Schema.sObjectType.Pricebook2.fields.Name.isAccessible()){
            
            opps = [select Id, Name, Pricebook2.Id, Pricebook2.Name from Opportunity where Id =: opportunityId ];    
        }
        
        Opportunity opp = null;
        if(!opps.isEmpty()){
            opp = opps.get(0);
        }
        return opp;
    }
    
    @AuraEnabled
    public static List<PriceBookEntryFeed> applyFilterSearch(Id pricebook2Id, String filterInfoStr){
        BT_PricebookEntryService service = new BT_PricebookEntryService();
        List<PricebookEntry> pricebookEntries 
            = service.getPricebookEntryByFilter(pricebook2Id, filterInfoStr);
        return getPricebookEntryFeeds(pricebookEntries);
    }
    
    private static List<PriceBookEntryFeed> getPricebookEntryFeeds(List<PricebookEntry> pricebookEntries ){
        List<PriceBookEntryFeed> feeds = new List<PriceBookEntryFeed>();
        for(PriceBookEntry pb: priceBookEntries){
            feeds.add(new PriceBookEntryFeed(pb));
        }
        return feeds;
    }
    
    
    @AuraEnabled
    public static List<PriceBookEntryFeed> getProductCandidate(Id pricebook2Id, String orderedBy){
        BT_PricebookEntryService service = new BT_PricebookEntryService();
        
        List<PriceBookEntry> priceBookEntries = service.getPricebookEntryByPBId(pricebook2Id, orderedBy);
        return getPricebookEntryFeeds(pricebookEntries);
    }
    
    @AuraEnabled
    public static List<PriceBookEntryFeed> getProductCandidateByPBFamily(Id pricebook2Id, String orderedBy,String PFamily){
        BT_PricebookEntryService service = new BT_PricebookEntryService();
        
        List<PriceBookEntry> priceBookEntries = service.getPricebookEntryByPBIdPBFamily(pricebook2Id, orderedBy,PFamily);
        return getPricebookEntryFeeds(pricebookEntries);
    }
    
    @AuraEnabled
    public static List<Pricebook2> getPriceBook(){
        return [select Id, Name from Pricebook2 where IsActive = true];
    }
    
    
    @AuraEnabled
    public static String getPriceBookId(String recordId){
        String sobjectName = Id.valueOf(recordId).getSObjectType().getDescribe().getName();
        system.debug('sobjectName -----------> '+sobjectName);
        if(sobjectName != null && sobjectName.trim() != '' && Schema.getGlobalDescribe().get(sobjectName) != null){
            for(Sobject sobj:Database.query(String.escapeSingleQuotes('select Id, Project__r.Price_Book__c from '+sobjectName+' where Id =:recordId '))){
                system.debug('PricebookId ------------> '+String.valueOf(sobj.getSobject('Project__r').get('Price_Book__c')));
                return String.valueOf(sobj.getSobject('Project__r').get('Price_Book__c'));
                
            }   
        }
        return '';
    }
    
    @AuraEnabled
    public static String getProductFamilyPicklist(){
        
        List<productFamily> productFamilyOpt = new List<productFamily>();
        Schema.DescribeFieldResult fieldResult =  Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple)
        {
            productFamily productFamilyRec  = new productFamily();
            productFamilyRec.label=f.getLabel();
            productFamilyRec.value=f.getValue(); 
            productFamilyOpt.add(productFamilyRec);
        }       
        return JSON.serialize(productFamilyOpt);

    }
   
    public class productFamily{
        public String label{get;set;}
        public String value{get;set;}
        public productFamily(){
            label=value='';
        }
    }
    
    public class OpportunityItem{
        public Double salesPrice{set;get;}
        public Double quantity {set;get;}
        public String productName{set;get;}
        public String priceBookEntryId{set;get;}
        public Date serviceDate{set;get;}
        public String description{set;get;}
        public String Discount{set;get;}
    }
    
    public class PriceBookEntryFeed{
        public PriceBookEntryFeed(PriceBookEntry pbEntry){
            this.isSelected = false;
            this.pbEntry = pbEntry;
        }
        
        @AuraEnabled
        public PriceBookEntry pBEntry {private set;get;}
        
        @AuraEnabled
        public String linkURL{ private set; get{
            return '/' + pBEntry.Product2.Id;
            
        }}
        
        @AuraEnabled
        public Boolean isSelected {set;get;}
        
    }
    
    
    
}