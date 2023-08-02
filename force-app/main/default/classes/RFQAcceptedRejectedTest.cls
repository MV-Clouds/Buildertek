@isTest
public class RFQAcceptedRejectedTest {
    @testSetup
    static void setupMethod(){
        buildertek__RFQ_Template_Settings__c cs = new buildertek__RFQ_Template_Settings__c();
        cs.buildertek__Sites_URL__c = 'test.com';
        insert cs;
    }
    
    @isTest
    static void testMethod1(){
        RFQAcceptedRejected rfq = new RFQAcceptedRejected();  
    }
}