public with sharing class pricingRequestLineTriggerHandler {
    public static boolean firstRun = true; 
    public static void afterEvent(List<buildertek__Pricing_Request_Line__c> PRLList , Map<Id,buildertek__Pricing_Request_Line__c>PRLMap) {
        System.debug(firstRun);
        Set<Id> PricingReqLineSet =new Set<Id>();

        for(buildertek__Pricing_Request_Line__c PriReqLine:PRLList){
            buildertek__Pricing_Request_Line__c oldPRL = PRLMap.get(PriReqLine.id);
            // System.debug(oldPRL);
            // System.debug(oldPRL.buildertek__Status__c=='Pricing Complete');
            // System.debug(oldPRL.buildertek__Status__c);
            if(PriReqLine.buildertek__Status__c=='Pricing Complete' && oldPRL.buildertek__Status__c!='Pricing Complete'){
                PricingReqLineSet.add(PriReqLine.Id);
            }
        }

        if(PricingReqLineSet.size() > 0){
            List<buildertek__Question__c> optionList = new List<buildertek__Question__c>();
            List<buildertek__Pricing_Request_Line_Details__c> PricReqLineDetailList =[Select Id , buildertek__Unit_Sales_Price__c , Name, buildertek__Quantity__c ,buildertek__Price__c, buildertek__Pricing_Request_Line__c ,(SELECT Id, buildertek__Cost__c, buildertek__Quantity__c    FROM buildertek__Options__r) From buildertek__Pricing_Request_Line_Details__c WHERE buildertek__Pricing_Request_Line__c=:PricingReqLineSet];
            System.debug(PricReqLineDetailList);
            for(buildertek__Pricing_Request_Line_Details__c prld:PricReqLineDetailList){
                for(buildertek__Question__c option:prld.buildertek__Options__r){
                    option.buildertek__Quantity__c=prld.buildertek__Quantity__c;
                    option.buildertek__Cost__c=prld.buildertek__Unit_Sales_Price__c;
                    optionList.add(option);
                }
            }
            System.debug(optionList);

            if(optionList.size() > 0){
                update optionList;
                pricingRequestLineTriggerHandler.firstRun = false; 
            }
        }
        System.debug(firstRun);        
    }
}