@isTest(seeAllData=false)
public with sharing class Test_DashboardReportControllerRender {

    @isTest
    public static void test1(){

        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        List<pba__Property__c> propertylist = new List<pba__Property__c>();
        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb);

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property 1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb1);
        insert propertylist;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        listing.pba__Property__c = pb.Id;
        listing.pba__PropertyType__c = 'Residential';
        listing.Stage_Unit__c = pb1.Id;
        listing.Hold_Expiration_Date__c = System.today();
        insert listing;
        
        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.pba__ListingType__c = 'Sale';
        insert req;      

        List<pba__Offer__c> offerlist = new List<pba__Offer__c>();
        
        pba__Offer__c newoffer = new pba__Offer__c();
        newoffer.pba__Listing__c = listing.Id;
        newoffer.pba__Status__c = 'Cancelled';
        newoffer.pba__Request__c = req.Id;
        newoffer.Initial_Deposit_Paid_Date__c = System.today().addDays(-8);
        newoffer.Contract_Date__c = System.today();
        newoffer.Balance_Deposit_Amount_Paid__c = 3422;
        newoffer.Project_Look_Up__c = pb.Id;
        newoffer.Price__c = 2341;
        newoffer.Cancellation_Date__c = System.today().addDays(-2);
        newoffer.Cancellation_Reason__c = 'Test';
        newoffer.Previous_Status__c = 'Contracted';
        newoffer.Property__c = pb.Id;
        offerlist.add(newoffer);
        //insert newoffer;
        
        pba__Offer__c offer = new pba__Offer__c();
        offer.pba__Listing__c = listing.Id;
        offer.pba__Status__c = 'Reserved';
        offer.pba__Request__c = req.Id;
        offer.Initial_Deposit_Paid_Date__c = System.today();
        offer.Contract_Date__c = System.today();
        offer.Balance_Deposit_Amount_Paid__c = 3422;
        offer.Project_Look_Up__c = pb.Id;
        offer.Price__c = 2341;
        offer.Cancellation_Date__c = System.today().addDays(-2);
        offer.Cancellation_Reason__c = 'Test';
        offer.Property__c = pb.Id;
        offer.Price__c = 1000;
        offerlist.add(offer);
        //insert offer;

        pba__Offer__c offer2 = new pba__Offer__c();
        offer2.pba__Listing__c = listing.Id;
        offer2.pba__Status__c = 'Cancelled';
        offer2.pba__Request__c = req.Id;
        offer2.Initial_Deposit_Paid_Date__c = System.today();
        offer2.Contract_Date__c = System.today();
        offer2.Balance_Deposit_Amount_Paid__c = 3422;
        offer2.Project_Look_Up__c = pb.Id;
        offer2.Price__c = 2341;
        offer2.Cancellation_Date__c = System.today().addDays(-8);
        offer2.Cancellation_Reason__c = 'Test';
        offer2.Previous_Status__c = 'Reserved';
        offer2.Price__c = 1000;
        offer2.Property__c = pb.Id;
		offerlist.add(offer2);

        pba__Offer__c offer3 = new pba__Offer__c();
        offer3.pba__Listing__c = listing.Id;
        offer3.pba__Status__c = 'Cancelled';
        offer3.pba__Request__c = req.Id;
        offer3.Initial_Deposit_Paid_Date__c = System.today();
        offer3.Contract_Date__c = System.today().addDays(-10);
        offer3.Balance_Deposit_Amount_Paid__c = 3422;
        offer3.Project_Look_Up__c = pb.Id;
        offer3.Price__c = 2341;
        offer3.Cancellation_Date__c = System.today().addDays(-8);
        offer3.Cancellation_Reason__c = 'Test';
        offer3.Price__c = 1000;
        offer3.Previous_Status__c = 'Contracted';
        offer3.Property__c = pb.Id;
		offerlist.add(offer3);

        pba__Offer__c offer4 = new pba__Offer__c();
        offer4.pba__Listing__c = listing.Id;
        offer4.pba__Status__c = 'Reserved';
        offer4.pba__Request__c = req.Id;
        offer4.Initial_Deposit_Paid_Date__c = System.today();
        offer4.Contract_Date__c = System.today().addDays(-10);
        offer4.Balance_Deposit_Amount_Paid__c = 3422;
        offer4.Project_Look_Up__c = pb.Id;
        offer4.Price__c = 2341;
        offer4.Cancellation_Date__c = System.today().addDays(-8);
        offer4.Cancellation_Reason__c = 'Test';
        offer4.Price__c = 1000;
        offer4.Previous_Status__c = 'Contracted';
        offer4.Property__c = pb1.Id;
        offer4.CreatedDate = System.today().addDays(-10);
		offerlist.add(offer4);
        
        insert offerlist;

        PageReference pageRef = Page.DashboardReportRender;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('ID',pb.Id);
        System.debug('pb[0].Id-->'+pb.Id);
        DashboardReportControllerRender pbd1 = new DashboardReportControllerRender();

        PageReference pageRef2 = Page.DashboardReportRender;
        Test.setCurrentPage(pageRef2);
        ApexPages.currentPage().getParameters().put('ID',pb1.Id);
        System.debug('pb[1].Id-->'+pb1.Id);
        DashboardReportControllerRender pbd2 = new DashboardReportControllerRender();
    }
    @IsTest
    public static void test3(){
        Set<String> propertyId = new Set<String>();
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        List<pba__Property__c> propertylist = new List<pba__Property__c>();
        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb);
        

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property 1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb1);
        
        insert propertylist;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        listing.pba__Property__c = pb.Id;
        listing.pba__PropertyType__c = 'Residential';
        listing.Stage_Unit__c = pb1.Id;
        listing.Hold_Expiration_Date__c = System.today();
        insert listing;
        
        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.pba__ListingType__c = 'Sale';
        insert req;      

        List<pba__Offer__c> offerlist = new List<pba__Offer__c>();
        
        // pba__Offer__c newoffer = new pba__Offer__c();
        // newoffer.pba__Listing__c = listing.Id;
        // newoffer.pba__Status__c = 'Cancelled';
        // newoffer.pba__Request__c = req.Id;
        // newoffer.Initial_Deposit_Paid_Date__c = System.today().addDays(-8);
        // newoffer.Contract_Date__c = System.today();
        // newoffer.Balance_Deposit_Amount_Paid__c = 3422;
        // newoffer.Project_Look_Up__c = pb.Id;
        // newoffer.Price__c = 2341;
        // newoffer.Cancellation_Date__c = System.today().addDays(-2);
        // newoffer.Cancellation_Reason__c = 'Test';
        // newoffer.Previous_Status__c = 'Contracted';
        // newoffer.Property__c = pb.Id;
        // offerlist.add(newoffer);
        //insert newoffer;
        
        pba__Offer__c offer = new pba__Offer__c();
        offer.pba__Listing__c = listing.Id;
        offer.pba__Status__c = 'Reserved';
        offer.pba__Request__c = req.Id;
        offer.Initial_Deposit_Paid_Date__c = System.today();
        offer.Contract_Date__c = System.today();
        offer.Balance_Deposit_Amount_Paid__c = 3422;
        offer.Project_Look_Up__c = pb.Id;
        offer.Price__c = 2341;
        offer.Cancellation_Date__c = System.today().addDays(-2);
        offer.Cancellation_Reason__c = 'Test';
        offer.Property__c = pb.Id;
        offer.Previous_Status__c = 'Reserved';
        offer.Price__c = 1000;
        offerlist.add(offer);
        // insert offer;

        pba__Offer__c offer2 = new pba__Offer__c();
        offer2.pba__Listing__c = listing.Id;
        offer2.pba__Status__c = 'Cancelled';
        offer2.pba__Request__c = req.Id;
        offer2.Initial_Deposit_Paid_Date__c = System.today();
        offer2.Contract_Date__c = System.today().addDays(-7);
        offer2.Balance_Deposit_Amount_Paid__c = 3422;
        offer2.Project_Look_Up__c = pb.Id;
        offer2.Price__c = 2341;
        offer2.Cancellation_Date__c = System.today().addDays(-6);
        offer2.Cancellation_Reason__c = 'Test';
        offer2.Previous_Status__c = 'Contracted';
        offer2.Price__c = 1000;
        offer2.Property__c = pb.Id;
        offer2.CreatedDate = system.today().addDays(-7);
		offerlist.add(offer2);

        pba__Offer__c offer3 = new pba__Offer__c();
        offer3.pba__Listing__c = listing.Id;
        offer3.pba__Status__c = 'Cancelled';
        offer3.pba__Request__c = req.Id;
        offer3.Initial_Deposit_Paid_Date__c = System.today();
        offer3.Contract_Date__c = System.today().addDays(-10);
        offer3.Balance_Deposit_Amount_Paid__c = 3422;
        offer3.Project_Look_Up__c = pb.Id;
        offer3.Price__c = 2341;
        offer3.Cancellation_Date__c = System.today().addDays(-8);
        offer3.Cancellation_Reason__c = 'Test';
        offer3.Price__c = 1000;
        offer3.Previous_Status__c = 'Contracted';
        offer3.Property__c = pb.Id;
		offerlist.add(offer3);
       
        insert offerlist;

        for(pba__Property__c pbp : propertylist){
            propertyId.add(pbp.Id);
        }

        PageReference pageRef2 = Page.DashboardReportRender;
        Test.setCurrentPage(pageRef2);
        // ApexPages.currentPage().getParameters().put('ID',pb1.Id);
        ApexPages.currentPage().getParameters().put('ID',propertylist[0].Id);
        System.debug('propertyID ==> '+propertyId);
        System.debug('OfferList ==> '+offerlist);
        System.debug('check your offer 2 here ==> '+offer2);
        DashboardReportControllerRender drc = new DashboardReportControllerRender();
        
    }
    @IsTest
    public static void test2(){
        Set<String> propertyId = new Set<String>();
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        List<pba__Property__c> propertylist = new List<pba__Property__c>();
        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb);
        

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property 1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        propertylist.add(pb1);
        
        insert propertylist;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        listing.pba__Property__c = pb.Id;
        listing.pba__PropertyType__c = 'Residential';
        listing.Stage_Unit__c = pb1.Id;
        listing.Hold_Expiration_Date__c = System.today();
        insert listing;
        
        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.pba__ListingType__c = 'Sale';
        insert req;      

        List<pba__Offer__c> offerlist = new List<pba__Offer__c>();
        
        // pba__Offer__c newoffer = new pba__Offer__c();
        // newoffer.pba__Listing__c = listing.Id;
        // newoffer.pba__Status__c = 'Cancelled';
        // newoffer.pba__Request__c = req.Id;
        // newoffer.Initial_Deposit_Paid_Date__c = System.today().addDays(-8);
        // newoffer.Contract_Date__c = System.today();
        // newoffer.Balance_Deposit_Amount_Paid__c = 3422;
        // newoffer.Project_Look_Up__c = pb.Id;
        // newoffer.Price__c = 2341;
        // newoffer.Cancellation_Date__c = System.today().addDays(-2);
        // newoffer.Cancellation_Reason__c = 'Test';
        // newoffer.Previous_Status__c = 'Contracted';
        // newoffer.Property__c = pb.Id;
        // offerlist.add(newoffer);
        //insert newoffer;
        
        pba__Offer__c offer = new pba__Offer__c();
        offer.pba__Listing__c = listing.Id;
        offer.pba__Status__c = 'Reserved';
        offer.pba__Request__c = req.Id;
        offer.Initial_Deposit_Paid_Date__c = System.today();
        offer.Contract_Date__c = System.today();
        offer.Balance_Deposit_Amount_Paid__c = 3422;
        offer.Project_Look_Up__c = pb.Id;
        offer.Price__c = 2341;
        offer.Cancellation_Date__c = System.today().addDays(-2);
        offer.Cancellation_Reason__c = 'Test';
        offer.Property__c = pb.Id;
        offer.Price__c = 1000;
        offerlist.add(offer);
        //insert offer;

        pba__Offer__c offer2 = new pba__Offer__c();
        offer2.pba__Listing__c = listing.Id;
        offer2.pba__Status__c = 'Reserved';
        offer2.pba__Request__c = req.Id;
        offer2.Initial_Deposit_Paid_Date__c = System.today();
        offer2.Contract_Date__c = System.today().addDays(-5);
        offer2.Balance_Deposit_Amount_Paid__c = 3422;
        offer2.Project_Look_Up__c = pb.Id;
        offer2.Price__c = 2341;
        offer2.Cancellation_Date__c = System.today().addDays(-4);
        offer2.Cancellation_Reason__c = 'Test';
        offer2.Previous_Status__c = 'Reserved';
        offer2.Price__c = 1000;
        offer2.Property__c = pb.Id;
        offer2.CreatedDate = system.today().addDays(-6);
		offerlist.add(offer2);

        pba__Offer__c offer3 = new pba__Offer__c();
        offer3.pba__Listing__c = listing.Id;
        offer3.pba__Status__c = 'Cancelled';
        offer3.pba__Request__c = req.Id;
        offer3.Initial_Deposit_Paid_Date__c = System.today();
        offer3.Contract_Date__c = System.today().addDays(-10);
        offer3.Balance_Deposit_Amount_Paid__c = 3422;
        offer3.Project_Look_Up__c = pb.Id;
        offer3.Price__c = 2341;
        offer3.Cancellation_Date__c = System.today().addDays(-8);
        offer3.Cancellation_Reason__c = 'Test';
        offer3.Price__c = 1000;
        offer3.Previous_Status__c = 'Contracted';
        offer3.Property__c = pb.Id;
		offerlist.add(offer3);
       
        insert offerlist;

        for(pba__Property__c pbp : propertylist){
            propertyId.add(pbp.Id);
        }

        PageReference pageRef2 = Page.DashboardReportRender;
        Test.setCurrentPage(pageRef2);
        // ApexPages.currentPage().getParameters().put('ID',pb1.Id);
        ApexPages.currentPage().getParameters().put('ID',propertylist[0].Id);
        System.debug('propertyID ==> '+propertyId);
        System.debug('OfferList ==> '+offerlist);
        System.debug('check your offer 2 here ==> '+offer2);
        DashboardReportControllerRender drc = new DashboardReportControllerRender();
        
    }

     @IsTest
    public static void test4(){
        Set<String> propertyId = new Set<String>();
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        // List<pba__Property__c> propertylist = new List<pba__Property__c>();
        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        // propertylist.add(pb);
        insert pb;

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        // propertylist.add(pb);
        insert pb1;

        List<pba__Listing__c> lstList = new List<pba__Listing__c>();

        pba__Listing__c listing1 = new pba__Listing__c();
        listing1.Name = 'Test Listing';
        listing1.pba__Status__c = 'On Hold';
        listing1.pba__Property__c = pb.Id;
        listing1.pba__PropertyType__c = 'Residential';
        listing1.Stage_Unit__c = pb1.Id;
        listing1.Hold_Expiration_Date__c = System.today();
        listing1.CreatedDate = System.today().addDays(-4);
	    listing1.Project_Unit__c = pb1.Id;
        // insert listing;
        lstList.add(listing1);
        
        pba__Listing__c listing2 = new pba__Listing__c();
        listing2.Name = 'Test Listing';
        listing2.pba__Status__c = 'On Hold';
        listing2.pba__Property__c = pb.Id;
        listing2.pba__PropertyType__c = 'Residential';
        listing2.Stage_Unit__c = pb1.Id;
        listing2.Hold_Expiration_Date__c = System.today();
        listing2.CreatedDate = system.today().addDays(-4);
        // insert listing;
        lstList.add(listing2);
        insert lstList;
 

        PageReference pageRef2 = Page.DashboardReportRender;
        Test.setCurrentPage(pageRef2);
        // ApexPages.currentPage().getParameters().put('ID',pb1.Id);
        ApexPages.currentPage().getParameters().put('ID',pb.Id);
        // ApexPages.currentPage().getParameters().put('ID',pb1.Id);
        System.debug('propertyID ==> '+propertyId);
     
        DashboardReportControllerRender drc = new DashboardReportControllerRender();        
        
    }
}