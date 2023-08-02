@isTest
public class PictureGalleryControllerTest {
    private static void createMedia(Id propertyId, Integer numImages) {
        List<pba__PropertyMedia__c> media = new List<pba__PropertyMedia__c>();
        for (Integer i = 0; i < numImages; i++) {
            pba__PropertyMedia__c pm = new pba__PropertyMedia__c();
            pm.Name = 'Test0'+i;
            pm.pba__Property__c = propertyId;
            pm.pba__BaseUrl__c = '/test0'+i+'.png';
            pm.pba__Category__c = 'images';
            media.add(pm);
        }
        insert media;
    }
    
    
    static testMethod void shouldGetThreeImagesListing() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test';
        insert listing;
        
        listing = [SELECT id, pba__Property__c FROM pba__Listing__c WHERE id = :listing.Id];
        createMedia(listing.pba__Property__c, 3);
        
        List<Object> images = PictureGalleryController.getImages(listing.id);
        System.assertEquals(3, images.size());
    }
    
    static testMethod void shouldGetThreeImagesProperty() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test';
        insert listing;
        
        listing = [SELECT id, pba__Property__c FROM pba__Listing__c WHERE id = :listing.Id];
        createMedia(listing.pba__Property__c, 3);
        
        List<Object> images = PictureGalleryController.getImages(listing.pba__property__c);
        System.assertEquals(3, images.size());
    }
    
}