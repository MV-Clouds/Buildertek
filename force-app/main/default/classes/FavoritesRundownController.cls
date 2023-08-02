public class FavoritesRundownController {

    public Integer numFavorites {
        get {
            return favorites.size();
        }
        set;
    }
    public List<pba__Favorite__c> favorites {
        get {
            return findFavorites();
        }
        set;
    }
    public pba__Listing__c fListing {
        get {
            return findListing();
        }
        set;
    }
    public List<AggregateResult> enquirySource {
        get {
            return getEnquirySource();
        }
        set;
    }
    
    private String lId;
    public String listingId {
        get {
            return lId == null ? ApexPages.currentPage().getParameters().get('id') : lId;
        }
        set { lId = value; }
    }
    private String order;
    public String orderBy {
        get {
            return order == null ? ApexPages.currentPage().getParameters().get('order') : order;
        }
        set { order = value; }
    }
    
    private List<AggregateResult> getEnquirySource() {
        Set<Id> requests = new Set<Id>();
        for (pba__Favorite__c f : favorites) {
            requests.add(f.pba__Request__c);
        }
        
        List<AggregateResult> agr = [SELECT Enquiry_Source__c, COUNT(ID) Total FROM pba__Request__c WHERE id = :requests GROUP BY Enquiry_Source__c];
        System.debug('Query: ' + agr);
        return agr;
    }
    
    public List<pba__Favorite__c> findFavorites() {
        String sql = 'SELECT ' + getFields('pba__Favorite__c') + ', pba__Contact__r.Name FROM pba__Favorite__c WHERE pba__Listing__c = \'' + listingId + '\'';
        sql += ' ORDER BY ' + (orderBy != null ? orderBy : 'CreatedDate DESC');
        System.debug('Query: ' + sql);
        
        if (listingId != null) {
            return Database.query(sql);
        } else {
            return new List<pba__Favorite__c>();
        }
    }
    
    public pba__Listing__c findListing() {
        String sql = 'SELECT ' + getFields('pba__Listing__c') + ', pba__Property__r.pba__Main_Website_Image__c  FROM pba__Listing__c WHERE id = \'' + listingId + '\'';
        System.debug('Query: ' + sql);
        
        if (listingId != null) {
            return Database.query(sql);
        } else {
            return new pba__Listing__c();
        }
    }
    
    private String getFields(String objectType) {
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objectType).getDescribe().fields.getMap();
        List<String> fields = new List<String>();
        for(String field: fieldMap.keySet()) {
            fields.add(field);
        }

        return String.join(fields, ', ');
    }
}