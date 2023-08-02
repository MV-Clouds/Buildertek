@isTest
private class FavoritesRundownControllerTest {
    
    static testMethod void testProperties() {
        FavoritesRundownController controller = new FavoritesRundownController();
        
        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test';
        insert listing;
        
        controller.listingId = listing.Id;
        
        pba__Listing__c favListings = controller.flisting;
        List<pba__Favorite__c> favorites = controller.favorites;
        Integer favs = controller.numFavorites;
        List<AggregateResult> source = controller.enquirysource;
    }
}