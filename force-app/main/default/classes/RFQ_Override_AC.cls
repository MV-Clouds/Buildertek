public with sharing class RFQ_Override_AC {
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews;
        if(Schema.sObjectType.ListView.fields.id.isAccessible()
            && Schema.sObjectType.ListView.fields.Name.isAccessible()){
            listviews = [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__RFQ__c'];    
        }
        return listviews;
    }
}