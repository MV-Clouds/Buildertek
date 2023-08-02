@isTest
public class VendorReviewTriggerHandlerTest {

     static testMethod void testvendorreview() {
          Account accRec = new Account();
        accRec.Name = 'Test';
        accRec.buildertek__Email_Address__c = 'laxmantest@gmail.com';
        insert accRec;
         
        buildertek__Project__c pro = new buildertek__Project__c();
        pro.Name = 'Testproject';
        pro.buildertek__Account__c = accRec.id;
        insert pro;
         
        buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
        PO.buildertek__Description__c = 'Test PO';
        PO.buildertek__Project__c = pro.Id;
        PO.buildertek__Vendor__c = accRec.Id;
        insert PO;
         list<buildertek__Vendor_Review__c> vrlist = new list<buildertek__Vendor_Review__c>();
        buildertek__Vendor_Review__c vr = new buildertek__Vendor_Review__c();
         vr.Name = 'test';
         vr.buildertek__Purchase_Order__c = PO.id;
         vr.buildertek__Contractor__c = accRec.Id;
         insert vr;
         vrlist.add(vr);
        // Map<Id, buildertek__Vendor_Review__c> newmap = Map<Id, buildertek__Vendor_Review__c> ();
         buildertek__Vendor_Review_Lines__c vrlines = new buildertek__Vendor_Review_Lines__c();
         vrlines.Name = 'Did the Vendor keep the jobsite clean?';
         vrlines.buildertek__Contract_Review__c = vr.Id;
         vrlines.buildertek__Rating__c = 10;
         vrlines.buildertek__Weighting__c = 10;
         insert vrlines;
         VendorReviewTriggerHandler handler = new VendorReviewTriggerHandler(true,1);
         handler.OnAfterInsert(vrlist,null);
        
    }
}