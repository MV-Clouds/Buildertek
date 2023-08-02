@isTest
private class RegisterContactControllerTest {
  
    static testMethod void searchContacts() {
        Contact tom = createContact('Tom');
        Contact mary = createContact('Mary');
        
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.LastName = 'Tom';
        controller.search();
        List<Contact> contactsWithFilter = controller.contacts;
        
        System.assertEquals(1, contactsWithFilter.size());
    }
  
    static testMethod void searchContactError() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.LastName = '\'';
        controller.search();
        List<Contact> contacts = controller.contacts;
        
        System.assertEquals(null, contacts);
    }
  
    static testMethod void save() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.FirstName = 'Test';
        controller.LastName = 'Contact';
        controller.Email = 'test@propertybase.com';
        controller.MobilePhone = '0477888999';
        controller.save();
        
        Contact test = [SELECT id FROM Contact WHERE Name = 'Test Contact' LIMIT 1];
        System.assertEquals(controller.selectedContact, test.Id);
        
        pba__Favorite__c favorite = [SELECT id, pba__Contact__c FROM pba__Favorite__c WHERE pba__Contact__c = :test.Id LIMIT 1];
        System.assertEquals(controller.selectedContact, favorite.pba__Contact__c);
    }
  
    static testMethod void save_Company() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.FirstName = 'Test';
        controller.LastName = 'Contact';
        controller.Email = 'test@propertybase.com';
        controller.MobilePhone = '0477888999';
        controller.CompanyName = 'test';
        controller.selectedCompany = 'new';
        controller.save();
        
        Contact test = [SELECT id FROM Contact WHERE Name = 'Test Contact' LIMIT 1];
        System.assertEquals(controller.selectedContact, test.Id);
        
        pba__Favorite__c favorite = [SELECT id, pba__Contact__c FROM pba__Favorite__c WHERE pba__Contact__c = :test.Id LIMIT 1];
        System.assertEquals(controller.selectedContact, favorite.pba__Contact__c);
    }
  
    static testMethod void save_Individual() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.FirstName = 'Test';
        controller.LastName = 'Contact';
        controller.Email = 'test@propertybase.com';
        controller.MobilePhone = '0477888999';
        controller.CompanyName = 'test';
        controller.selectedCompany = 'individual';
        controller.save();
        
        Contact test = [SELECT id FROM Contact WHERE Name = 'Test Contact' LIMIT 1];
        System.assertEquals(controller.selectedContact, test.Id);
        
        pba__Favorite__c favorite = [SELECT id, pba__Contact__c FROM pba__Favorite__c WHERE pba__Contact__c = :test.Id LIMIT 1];
        System.assertEquals(controller.selectedContact, favorite.pba__Contact__c);
    }
    
    
    static testMethod void save_OtherCompany() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.FirstName = 'Test';
        controller.LastName = 'Contact';
        controller.Email = 'test@propertybase.com';
        controller.MobilePhone = '0477888999';
        controller.CompanyName = 'test';
        controller.save();
        
        Contact test = [SELECT id FROM Contact WHERE Name = 'Test Contact' LIMIT 1];
        System.assertEquals(controller.selectedContact, test.Id);
        
        pba__Favorite__c favorite = [SELECT id, pba__Contact__c FROM pba__Favorite__c WHERE pba__Contact__c = :test.Id LIMIT 1];
        System.assertEquals(controller.selectedContact, favorite.pba__Contact__c);
    }
    
    
    static testMethod void saveError() {
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.save();
        
        System.assertEquals(controller.selectedContact, null);
    }
  
    static testMethod void linkSelectedContact() {
        Contact tom = createContact('Tom');
        
        pba__Listing__c listing = new pba__Listing__c();
        listing.name = 'TestListing';
        insert listing;
        
        ApexPages.StandardController std = new ApexPages.StandardController(listing);
        RegisterContactController controller = new RegisterContactController(std);
        
        controller.selectedContact = tom.Id;
        controller.linkContact();
        
        pba__Favorite__c favorite = [SELECT id, pba__Contact__c FROM pba__Favorite__c WHERE pba__Contact__c = :tom.Id LIMIT 1];
        
        System.assertEquals(controller.selectedContact, favorite.pba__Contact__c);
    }
    
    private static Contact createContact(String lastName) {
        Contact c = new Contact();
        c.LastName = lastName;
        insert c;
        
        return c;
    }
}