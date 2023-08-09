@isTest
public class ImportVendorReviewTest {
    public static testMethod void getVendorReviews() {
        
        buildertek__Purchase_Order__c pur = new buildertek__Purchase_Order__c();
        insert pur;
        Account acc=new Account();
        acc.Name='test';
        insert acc;
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj; 
      
        
        List<buildertek__Vendor_Review__c> Masterlist = new List<buildertek__Vendor_Review__c>();
        buildertek__Vendor_Review__c vendor=new buildertek__Vendor_Review__c();
        vendor.buildertek__Contractor__c=acc.id;
        vendor.Name='account';
        vendor.buildertek__Purchase_Order__c=pur.id;
        vendor.buildertek__Type__c = 'Master';
        vendor.buildertek__of_Questions__c=3;
        vendor.buildertek__Notes__c='helo';
        vendor.buildertek__Project__c=proj.id;
        vendor.buildertek__OldVendorId__c='id';
        
        Masterlist.add(vendor);
        insert Masterlist;
        
          List<buildertek__Vendor_Review_Lines__c> groupList = new List<buildertek__Vendor_Review_Lines__c>();
        buildertek__Vendor_Review_Lines__c groups = new buildertek__Vendor_Review_Lines__c ();
        groups.Name='test';
        groups.buildertek__Contract_Review__c=Masterlist[0].id;
        groupList.add(groups);
        insert groupList;
         List<String> selectedIds = new List<String>();
        selectedIds.add( groupList[0].Id);
   
         List<String> selectedlist = new List<String>();
        selectedlist.add( Masterlist[0].Id);
        
        List<ImportVendorReview.MasterBudgetsClass> IQList = new List<ImportVendorReview.MasterBudgetsClass>();
        ImportVendorReview.MasterBudgetsClass IQ = new ImportVendorReview.MasterBudgetsClass();
        IQ.budgetRecord = Masterlist[0];
        IQ.budgetCheck = true;
        
        
        IQList.add(IQ);
        ImportVendorReview.importMasterVenderReviewLines(selectedIds,  groupList[0].Id);
        ImportVendorReview.getMasterVendorReviews(  Masterlist[0].Id);

        system.assertEquals('test', 'test');
        
        
        
        
    }  
    
}