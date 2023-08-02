global with sharing class QuoteSummaryController {

    global string quoteId;
    global buildertek__Quote__c quote {get;set;}
    global List<buildertek__Quote_Item__c> QuoteLineRecordList { get; set; }


    global void setrelatedToId(string Id){
        this.quoteId = Id;
        getQuoteData();
    }
    
    global string getrelatedToId( ){
        return quoteId;
    }

    global void getQuoteData(){
        System.debug('-- getQuoteData --');
        String quoteId = this.quoteId;
        quote = [SELECT Id, Name, buildertek__Quote_Line_Grouping_Fields__c, buildertek__Roll_Up__c FROM buildertek__Quote__c WHERE Id =: quoteId];

        QuoteLineRecordList = new List<buildertek__Quote_Item__c>();
        if (quoteId != null) {
            QuoteLineRecordList = [SELECT Id, Name, buildertek__BL_SERVICE_CATEGORY__c,buildertek__Description__c,buildertek__Quantity__c, buildertek__Net_Unit__c, buildertek__Net_Total_Price__c  
                                    FROM buildertek__Quote_Item__c  WHERE buildertek__Quote__c =: quoteId];
        }        
    }
}