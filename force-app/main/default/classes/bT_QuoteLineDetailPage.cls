public with sharing class bT_QuoteLineDetailPage {

    @AuraEnabled(cacheable=true)
    public static String getProductName(Id id) {
        System.debug('id: '+id);
        Product2 p = [SELECT Name FROM Product2 WHERE Id = :id];
        System.debug('p: '+p);
        System.debug('Name: '+p.Name);
        return p.Name;
    }

    //create a apex method which return UnitPrice from PriceBookEntry object and pass the product id as parameter and check if it is active or not
    @AuraEnabled(cacheable=true)
    public static Decimal getUnitPrice(Id id) {
        List<PriceBookEntry> pbe = [SELECT UnitPrice FROM PriceBookEntry WHERE Product2Id = :id AND IsActive = true];
        // System.debug('pbe'+pbe);
        if(!pbe.isEmpty()){
            return pbe[0].UnitPrice;
        }

        return null;
    } 
    
    public bT_QuoteLineDetailPage() {

    }
}