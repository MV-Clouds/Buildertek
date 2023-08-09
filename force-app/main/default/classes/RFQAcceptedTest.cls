@isTest
public class RFQAcceptedTest {
    @testSetup
    static void setupMethod(){
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.Name = 'Test';
        rfq.Project__c = proj.Id;
        insert rfq;
        
        Contact c = new Contact();
        c.LastName='Tets';
        c.Email = 'test@gmail.com';
        insert c;
        
        buildertek__RFQ_To_vendor__c rfqTovendor = new buildertek__RFQ_To_vendor__c();
        rfqTovendor.Name = 'Test';
        rfqTovendor.buildertek__RFQ__c = rfq.Id;
        rfqTovendor.buildertek__Contact__c = c.Id;
        insert rfqTovendor;
    }
    
    @isTest
    static void testMethod1(){
        buildertek__RFQ_To_vendor__c rtv = [Select Id, Name FROM buildertek__RFQ_To_vendor__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.buildertek__RFQAccepted;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',rtv.id);
        pageRef.getParameters().put('status',String.valueOf(true));
        RFQAccepted objCtrl = new RFQAccepted();
        objCtrl.updateRFQ();
        test.stopTest();
    }
    
    @isTest
    static void testMethod2(){
        buildertek__RFQ_To_vendor__c rtv = [Select Id, Name FROM buildertek__RFQ_To_vendor__c LIMIT 1];
        Test.startTest();
        PageReference pageRef = Page.buildertek__RFQAccepted;
        Test.setCurrentPage(pageRef);
        pageRef.getParameters().put('id',rtv.id);
        pageRef.getParameters().put('status',String.valueOf(false));
        RFQAccepted objCtrl = new RFQAccepted();
        objCtrl.updateRFQ();
        test.stopTest();
    }
}