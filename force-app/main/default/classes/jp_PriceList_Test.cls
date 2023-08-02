@isTest
global class jp_PriceList_Test {
    static testMethod void testPriceList() {
        pba__Setting__c setting = new pba__Setting__c();
        setting.pba__Key__c = 'price_list_master_property_relation_field';
        setting.pba__Value__c = 'Project_Unit__c';
        insert setting;
        
        RecordType rt = [select Id from RecordType where Name = 'Project' and SobjectType = 'pba__Property__c' limit 1];        

        pba__Property__c Project = new pba__Property__c();
        Project.Name = 'Test Project';
        Project.RecordTypeID = rt.id;
        insert Project;

        String listingFields = '{ \"Name\":\"Test Listing\", \"Project_Unit__c\":\"' + Project.id + '\", \"Pba__Status__c\":\"Available\" }';
        
        
        pba__Listing__c listing = (pba__Listing__c)JSON.deserialize(listingFields, pba__Listing__c.class);
        //Listing.Name = 'Test Listing';
        //Listing.Project_Unit__c = Project.id;
        //Listing.Pba__Status__c = 'Available';
        insert Listing;
            
        ApexPages.currentPage().getParameters().put('ID', Project.id);
        
        
        jp_PriceListController obj = new jp_PriceListController(new ApexPages.StandardController(new pba__Property__c()));
        obj.getprojectListings();
    }
}