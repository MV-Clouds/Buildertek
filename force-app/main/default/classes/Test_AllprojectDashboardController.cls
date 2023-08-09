@isTest
public with sharing class Test_AllprojectDashboardController {
    
    @testSetup
    public static void TestDataSetupMethod() {
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        listing.Project_Unit__c = pb.Id;
        listing.Hold_Expiration_Date__c = System.today().addMonths(-1);
        insert listing;

        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.CreatedDate = System.today().addMonths(-1);
        insert req;

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
        insert offer;
    }

    @isTest
    public static void test(){
        AllprojectDashboardController pbd = new AllprojectDashboardController();
        AllprojectendofmonthSnapshotController ap = new AllprojectendofmonthSnapshotController();
    }
    
    @isTest
    public static void test1(){
        AllprojectDashboardwithfilterController apd = new AllprojectDashboardwithfilterController();
        
        PageReference pageRef = Page.AllprojectSnapshotwithFilter;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('startdate',String.valueOf(Date.today()));
        ApexPages.currentPage().getParameters().put('enddate',String.valueOf(Date.today()+3));
        
        AllprojectDashboardwithfilterController apd1 = new AllprojectDashboardwithfilterController();
    }

    @isTest
    public static void test2(){
        AllprojecteomSnapshotController apd = new AllprojecteomSnapshotController();
        
        PageReference pageRef = Page.AllprojecteomfilterSnapshot;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('month','7');
        ApexPages.currentPage().getParameters().put('year','2022');
        
        AllprojecteomSnapshotController apd1 = new AllprojecteomSnapshotController();
        apd1.getmonths();
        apd1.getyears();
        Pagereference p = apd1.pdfpage();
        
        PageReference pageRef1 = Page.AllprojectendofmonthSnapshotRender ;
        Test.setCurrentPage(pageRef1);
	}
    
    @isTest
    public static void test3(){
        Account a = new Account();
        a.Name = 'Test Account';
        insert a;

        pba__Property__c pb = new pba__Property__c();
        pb.Name = 'Test Property';
        pb.Sales_Agency__c = a.Id;
        pb.RecordTypeId = Schema.SObjectType.pba__Property__c.getRecordTypeInfosByName().get('Project').getRecordTypeId();
        insert pb;

        pba__Listing__c listing = new pba__Listing__c();
        listing.Name = 'Test Listing';
        listing.pba__Status__c = 'Available';
        listing.Project_Unit__c = pb.Id;
        listing.Hold_Expiration_Date__c = System.today().addMonths(-1);
        insert listing;

        pba__Request__c req = new pba__Request__c();
        req.Project_Look_Up__c = pb.Id;
        req.Source_Type__c = 'Walk In';
        req.CreatedDate = System.today().addMonths(-1);
        insert req;

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
        insert offer;
        
		PageReference pageRef1 = Page.AllprojectendofmonthSnapshotRender ;
		Test.setCurrentPage(pageRef1);
        ApexPages.currentPage().getParameters().put('ID',pb.Id);
        AllprojectendofmonthSnapshotRender ar = new AllprojectendofmonthSnapshotRender();
    }
}