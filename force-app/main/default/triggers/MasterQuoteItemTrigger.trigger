trigger MasterQuoteItemTrigger on buildertek__Master_Quote_Item__c (before insert, after insert, after delete) {
    if(Trigger.isInsert && Trigger.isBefore){
        List<buildertek__Master_Quote_Item__c> mqItems = new List<buildertek__Master_Quote_Item__c>(); 
        for(buildertek__Master_Quote_Item__c masterQuoteLine : Trigger.new){
            if(masterQuoteLine.buildertek__Quote_Line_Group__c == null) {
     			mqItems.add(masterQuoteLine);
     		}
        }
        if(!mqItems.isEmpty()) MasterquoteItemDAO.setDefaultGrouping(mqItems);
    }
}