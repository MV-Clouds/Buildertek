// @isTest(seeAllData=false)
// public with sharing class Test_AllprojectendofmonthSnapshotRender {
//     @isTest
//     public static void test1(){
//         Account a = new Account();
//         a.Name = 'Test Account';
//         insert a;

//         pba__Property__c pb = new pba__Property__c();
//         pb.Name = 'Test Property';
//         pb.Sales_Agency__c = a.Id;
//         pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
//         insert pb;

//         pba__Property__c pb1 = new pba__Property__c();
//         pb1.Name = 'Test Property 1';
//         pb1.Sales_Agency__c = a.Id;
//         pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
//         insert pb1;

//         pba__Listing__c listing = new pba__Listing__c();
//         listing.Name = 'Test Listing';
//         listing.pba__Status__c = 'Available';
//         listing.Project_Unit__c = pb.Id;
//         listing.Hold_Expiration_Date__c = System.today().addMonths(-1);
//         listing.Stage_Unit__c = pb1.Id;
//         insert listing;

//         pba__Request__c req = new pba__Request__c();
//         req.Project_Look_Up__c = pb.Id;
//         req.Source_Type__c = 'Walk In';
//         req.pba__ListingType__c = 'Sale';
//         insert req;

//         List<pba__Offer__c> offerlist = new List<pba__Offer__c>();
        
//         pba__Offer__c offer = new pba__Offer__c();
//         offer.pba__Listing__c = listing.Id;
//         offer.pba__Status__c = 'Reserved';
//         offer.pba__Request__c = req.Id;
//         offer.Initial_Deposit_Paid_Date__c = System.today();
//         offer.Contract_Date__c = System.today();
//         offer.Balance_Deposit_Amount_Paid__c = 3422;
//         offer.Project_Look_Up__c = pb.Id;
//         offer.Price__c = 2341;
//         offer.Cancellation_Date__c = System.today().addDays(-2);
//         offer.Cancellation_Reason__c = 'Test';
//         offer.Property__c = pb.Id;
//         offer.Price__c = 1000;
//         offerlist.add(offer);

//         pba__Offer__c offer2 = new pba__Offer__c();
//         offer2.pba__Listing__c = listing.Id;
//         offer2.pba__Status__c = 'Reserved';
//         offer2.pba__Request__c = req.Id;
//         offer2.Initial_Deposit_Paid_Date__c = System.today();
//         offer2.Contract_Date__c = System.today().addDays(-5);
//         offer2.Balance_Deposit_Amount_Paid__c = 3422;
//         offer2.Project_Look_Up__c = pb.Id;
//         offer2.Price__c = 2341;
//         offer2.Cancellation_Date__c = System.today().addDays(-4);
//         offer2.Cancellation_Reason__c = 'Test';
//         offer2.Previous_Status__c = 'Reserved';
//         offer2.Price__c = 1000;
//         offer2.Property__c = pb.Id;
//         offer2.CreatedDate = system.today().addDays(-6);
// 		offerlist.add(offer2);

//         pba__Offer__c offer3 = new pba__Offer__c();
//         offer3.pba__Listing__c = listing.Id;
//         offer3.pba__Status__c = 'Cancelled';
//         offer3.pba__Request__c = req.Id;
//         offer3.Initial_Deposit_Paid_Date__c = System.today();
//         offer3.Contract_Date__c = System.today().addDays(-10);
//         offer3.Balance_Deposit_Amount_Paid__c = 3422;
//         offer3.Project_Look_Up__c = pb.Id;
//         offer3.Price__c = 2341;
//         offer3.Cancellation_Date__c = System.today().addDays(-8);
//         offer3.Cancellation_Reason__c = 'Test';
//         offer3.Price__c = 1000;
//         offer3.Previous_Status__c = 'Contracted';
//         offer3.Property__c = pb.Id;
// 		offerlist.add(offer3);
       
//         insert offerlist;
        
// 		PageReference pageRef1 = Page.AllprojectendofmonthSnapshotRender ;
// 		Test.setCurrentPage(pageRef1);
//         ApexPages.currentPage().getParameters().put('ID',pb.Id);
//         AllprojectendofmonthSnapshotRender ar = new AllprojectendofmonthSnapshotRender();

//     }
// }

@isTest(seeAllData=false)
public with sharing class Test_AllprojectendofmonthSnapshotRender {
    @isTest
    public static void test1(){
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb;

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property 1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb1;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        // listing.Project_Unit__c = pb.Id;
        listing.Hold_Expiration_Date__c = System.today().addMonths(-1);
        listing.Stage_Unit__c = pb1.Id;
        // listing.pba__Property__c = pb1.Id;
        insert listing;

        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.CreatedDate = System.today().addDays(-36);
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
        // List<pba__Offer__c> offerlist = new List<pba__Offer__c>();
        // pba__Offer__c offer = new pba__Offer__c();
        // offer.pba__Listing__c = listing.Id;
        // offer.pba__Status__c = 'Reserved';
        // offer.pba__Request__c = req.Id;
        // offer.Initial_Deposit_Paid_Date__c = System.today();
        // offer.Contract_Date__c = System.today();
        // offer.Balance_Deposit_Amount_Paid__c = 3422;
        // offer.Project_Look_Up__c = pb.Id;
        // offer.Price__c = 1234;
        // // offer.pba__SystemIsAccepted__c = false;
        // offerlist.add(offer);

        // pba__Offer__c offer1 = new pba__Offer__c();
        // offer1.pba__Listing__c = listing.Id;
        // offer1.pba__Status__c = 'Cancelled';
        // offer1.pba__Request__c = req.Id;
        // offer1.Initial_Deposit_Paid_Date__c = System.today();
        // offer1.Contract_Date__c = System.today();
        // offer1.Balance_Deposit_Amount_Paid__c = 3422;
        // offer1.Project_Look_Up__c = pb.Id;
        // offer1.Price__c = 5678;
        // offer1.Cancellation_Date__c = System.today().addDays(-2);
        // offer1.Cancellation_Reason__c = 'Test Reason';
        // // offer1.pba__SystemIsAccepted__c = false;
        // offerlist.add(offer1);
        // insert offerlist;
        
        // Test.startTest();
		PageReference pageRef1 = Page.AllprojectendofmonthSnapshotRender ;
		Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('ID',pb.Id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(a);
        AllprojectendofmonthSnapshotRender ar = new AllprojectendofmonthSnapshotRender(stdController);
        
        offerlist[0].pba__Status__c = 'Conditional';
        offerlist[0].Contract_Date__c = Date.today().addMonths(-1);
        offerlist[0].Initial_Deposit_Paid_Date__c = Date.today().addMonths(-1);
        update offerlist;
        Apexpages.StandardController stdController1 = new Apexpages.StandardController(a);
        AllprojectendofmonthSnapshotRender ar1 = new AllprojectendofmonthSnapshotRender(stdController1);
        // Test.stopTest();
    }

    @IsTest
    public static void test2(){

        List<pba__Listing__c> lstList = new List<pba__Listing__c>();
        
        Account a = new Account();
        a.Name = 'Test2 Account';
        insert a;

        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test2 Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb;

        pba__Property__c pb1 = new pba__Property__c();
        pb1.Name = 'Test Property 1';
        pb1.Sales_Agency__c = a.Id;
        pb1.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb1;

        pba__Listing__c listing1 = new pba__Listing__c();
        listing1.Name = 'Test Listing';
        listing1.pba__Status__c = 'Available';
        listing1.Project_Unit__c = pb.Id;
        listing1.Hold_Expiration_Date__c = System.today().addMonths(-1);
        listing1.Stage_Unit__c = pb.Id;
        // listing.pba__Property__c = pb1.Id;
        // insert listing1;
        lstList.add(listing1);

        pba__Listing__c listing2 = new pba__Listing__c();
        listing2.Name = 'Test Listing';
        listing2.pba__Status__c = 'Available';
        listing2.Project_Unit__c = pb.Id;
        listing2.Hold_Expiration_Date__c = System.today().addMonths(-1);
        listing2.Stage_Unit__c = pb.Id;
        // listing.pba__Property__c = pb1.Id;
        // insert listing2;
        lstList.add(listing2);
        insert lstList;

        PageReference pageRef1 = Page.AllprojectendofmonthSnapshotRender ;
		Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('ID',pb.Id);
        Apexpages.StandardController stdController = new Apexpages.StandardController(a);
        AllprojectendofmonthSnapshotRender ar = new AllprojectendofmonthSnapshotRender(stdController);



        
    }
}