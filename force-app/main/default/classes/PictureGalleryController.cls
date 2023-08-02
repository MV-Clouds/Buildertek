public with sharing class PictureGalleryController {
  
    @AuraEnabled
    public static List<Object> getImages(Id listingId) {

        Id propId;
        
        for (pba__Listing__c PID : [SELECT pba__Property__c FROM pba__Listing__c WHERE id = :listingId]){
            propID = PID.pba__Property__c;
            System.debug( 'PID: ' + PID);
        }
        
        
        List<Object> images = new List<Object>();
        
        for (pba__PropertyMedia__c pm : [SELECT id, pba__Url__c,pba__MidresURL__c FROM pba__PropertyMedia__c WHERE pba__Property__c = :propId AND pba__Category__c = 'Images' ORDER BY pba__SortOnExpose__c]) {
            images.add(pm.pba__MidresURL__c);
            System.debug( 'Images From Listing: ' + images);
        }
        
        for (pba__PropertyMedia__c pm : [SELECT id, pba__Url__c,pba__MidresURL__c FROM pba__PropertyMedia__c WHERE pba__Property__c = :listingId AND pba__Category__c = 'Images' ORDER BY pba__SortOnExpose__c]) {
            images.add(pm.pba__MidresURL__c);
            System.debug( 'Images From Property: ' + images);
        }
                
        return images;
    }
}