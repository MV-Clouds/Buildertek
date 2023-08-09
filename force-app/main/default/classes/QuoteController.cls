public with sharing class QuoteController {
    @AuraEnabled
    public static string createQuote(String recordId) {
        
        try {            
            Opportunity opp = [SELECT Id, Name, AccountId, Account.Name, Account.Billingcity, Account.Billingstate, Account.Billingcountry, Account.Billingstreet, 
                                Account.buildertek__Email_Address__c, Account.Phone, Account.Billingpostalcode FROM Opportunity WHERE Id =: recordId]; 
            System.debug('Opportunity =>'+opp);

            buildertek__Quote__c quoteRecord = new buildertek__Quote__c();
            quoteRecord.buildertek__Opportunity__c = opp.Id;
            quoteRecord.Name = opp.Name;    
            quoteRecord.buildertek__Status__c = 'Draft';
            quoteRecord.buildertek__Type__c = 'Standard';
            quoteRecord.buildertek__Bill_To_Email_Address__c = opp.Account.buildertek__Email_Address__c;
            quoteRecord.buildertek__Bill_To_Cell_Phone__c = opp.Account.Phone;
            quoteRecord.buildertek__Bill_To_Name__c = opp.Account.Name;
            quoteRecord.buildertek__Bill_To_City__c = opp.Account.Billingcity;
            quoteRecord.buildertek__Bill_To_Street__c = opp.Account.Billingstreet;
            quoteRecord.buildertek__Bill_To_Zip_Code__c = opp.Account.Billingpostalcode;
            insert quoteRecord; 
            System.debug('quoteRecord => '+quoteRecord);
            
            List<OpportunityLineItem> oppProdList = [SELECT id,Name,TotalPrice, Quantity, ListPrice FROM OpportunityLineItem WHERE OpportunityId=:recordId];
            System.debug('OpportunityLineItem====>' + oppProdList);

            List<buildertek__Quote_Item__c> quoteItemList=new List<buildertek__Quote_Item__c>();
           
            for (OpportunityLineItem prod : oppProdList) {
                buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                quoteLine.buildertek__Quote__c = quoteRecord.Id;
                quoteLine.Name = prod.Name;
                quoteLine.buildertek__Quantity__c = prod.Quantity;
                quoteLine.buildertek__Unit_Price__c = prod.ListPrice;   
                                                          
                if(prod.TotalPrice != null  && prod.Quantity != null){
                    quoteLine.buildertek__Unit_Price__c = prod.TotalPrice/prod.Quantity;
                }
                
                System.debug('quoteLine => '+quoteLine);
                quoteItemList.add(quoteLine);
            }            
            if(quoteItemList.size()>0){
                insert quoteItemList;
            }            
            return quoteRecord.Id;
        }catch (Exception e) {
            System.debug('Error => '+e.getMessage());
            return 'Error';
        }
    }

    @AuraEnabled
    public static buildertek__Project__c getProjectDetails(Id get_accountid){
        buildertek__Project__c project;
        project=[select Name,buildertek__Address__c,buildertek__City__c,buildertek__State__c,buildertek__Zip__c,buildertek__Country__c from buildertek__Project__c where id=:get_accountid];
        return project;
    }
    
    @AuraEnabled
    public static buildertek__Service_Request__c getServiceReqDetails(String recordId){
        buildertek__Service_Request__c serviceReq ;
        serviceReq = [Select Id, Name, buildertek__Project__c from buildertek__Service_Request__c where Id =: recordId]; 
        return serviceReq;
    }
    
    @AuraEnabled
    public static quotebilladdresswrap getOpportunityDetails(String recordId){
        Opportunity opp ;
             opp = [Select Id, Name,AccountId,
                        Account.Name,
                        Account.Billingcity,
                        Account.Billingstate,
                        Account.Billingcountry,
                        Account.Billingstreet,
                        Account.buildertek__Email_Address__c,
                        Account.Phone,
                        Account.Billingpostalcode
                        from Opportunity where Id =: recordId   limit 1]; 

        list<quotebilladdresswrap>  wraplst = new list<quotebilladdresswrap> ();
        quotebilladdresswrap wraprec = new quotebilladdresswrap();
            wraprec.accemail = opp.Account.buildertek__Email_Address__c;
            wraprec.accphone = opp.Account.Phone;
            wraprec.OppName = opp.Name;
            wraprec.BillingName = opp.Account.Name;
            wraprec.Billingcity = opp.Account.Billingcity;
            wraprec.Billingstate = opp.Account.Billingstate;
            wraprec.Billingcountry = opp.Account.Billingcountry;
            wraprec.Billingstreet = opp.Account.Billingstreet;
            wraprec.Billingpostalcode = opp.Account.Billingpostalcode;
            wraplst.add(wraprec);
        return wraprec;
    }

    public class quotebilladdresswrap {
        @AuraEnabled
        public String accemail {get;set;}
        @AuraEnabled
        public String accphone {get;set;}
        @AuraEnabled
        public String OppName {get;set;}
        @AuraEnabled
        public String BillingName {get;set;}
        @AuraEnabled
        public String Billingcity {get;set;}
        @AuraEnabled
        public String Billingstate {get;set;}
        @AuraEnabled
        public String Billingcountry {get;set;}
        @AuraEnabled
        public String Billingstreet {get;set;}
        @AuraEnabled
        public String Billingpostalcode {get;set;}
    }
}