public with sharing class QuotePreviewPDFController {
    
    public String qId{get;set;}
    public buildertek__Quote__c quoteList{get;set;}
    
    public QuotePreviewPDFController(ApexPages.StandardController std){
        qId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        if (Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Doc_Template__c.isAccessible()){
            quoteList = [select Id,buildertek__Doc_Template__c from buildertek__Quote__c where Id = :qId];
        }  
    } 

}