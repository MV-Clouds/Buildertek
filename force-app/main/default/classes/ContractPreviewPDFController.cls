public with sharing class ContractPreviewPDFController {
    
    public String contractId{get;set;}
    public buildertek__Contract__c contractList{get;set;}
    
    public ContractPreviewPDFController(ApexPages.StandardController std){
        contractId = ApexPages.currentPage().getParameters().get('Id').escapeHtml4();
        if (Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Doc_Template__c.isAccessible()){
            contractList = [select Id,buildertek__Doc_Template__c from buildertek__Contract__c where Id = :contractId];
        } 
    }

}