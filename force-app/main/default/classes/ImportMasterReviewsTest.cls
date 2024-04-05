/**
 * Title - ImportMasterReviewsTest
 *
 * @author - Nishit Suthar
 * @version 1.0
 * @description
 * @uses
 * @history
 * 		yyyy-mm-dd : 2024-03-28
 */
@isTest
private class ImportMasterReviewsTest {

    @isTest
    static void myUnitTest() {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;

        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        proj.buildertek__Customer__c = acc.Id;
        insert proj;

        buildertek__Vendor_Review__c vr = new buildertek__Vendor_Review__c();
        vr.Name = 'Test Review';
        vr.buildertek__Type__c = 'Standard';
        vr.buildertek__Project__c = proj.Id;
        vr.buildertek__Contractor__c = acc.Id;
        insert vr;

        buildertek__Vendor_Review__c vr2 = new buildertek__Vendor_Review__c();
        vr2.Name = 'Test Review 2';
        vr2.buildertek__Type__c = 'Master';
        vr2.buildertek__Project__c = proj.Id;
        vr2.buildertek__Contractor__c = acc.Id;
        insert vr2;

        buildertek__Vendor_Review__c vr3 = new buildertek__Vendor_Review__c();
        vr3.Name = 'Test Review 3';
        vr3.buildertek__Type__c = 'Master';
        vr3.buildertek__Project__c = proj.Id;
        vr3.buildertek__Contractor__c = acc.Id;
        insert vr3;

        String recordId2 = vr3.Id;
        String recordId = vr.Id;

        buildertek__Vendor_Review_Lines__c vrl = new buildertek__Vendor_Review_Lines__c();
        vrl.Name = 'Test Review Line 1';
        vrl.buildertek__Contract_Review__c = recordId2;
        insert vrl;

        buildertek__Vendor_Review_Lines__c vrl2 = new buildertek__Vendor_Review_Lines__c();
        vrl2.Name = 'Test Review Line 2';
        vrl2.buildertek__Contract_Review__c = recordId2;
        insert vrl2;

        buildertek__Vendor_Review_Lines__c vrl3 = new buildertek__Vendor_Review_Lines__c();
        vrl3.Name = 'Test Review Line 3';
        vrl3.buildertek__Contract_Review__c = recordId2;
        insert vrl3;


        List<String> reviewLines = new List<String>();
        reviewLines.add(vr2.Id);
        reviewLines.add(vr3.Id);

        Test.startTest();
        ImportMasterReviews.getMasterReviews('', 'Test');
        ImportMasterReviews.importMasterReviewLines(reviewLines,recordId);
        ImportMasterReviews.CheckUserAccess('Create');
        ImportMasterReviews.CheckUserAccess('Update');
        ImportMasterReviews.CheckUserAccess('Delete');
        Test.stopTest();
    }
}