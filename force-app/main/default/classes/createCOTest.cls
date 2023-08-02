@isTest
public class createCOTest {
    @isTest static void testMethod1(){

        Product2 productRec = new Product2();
        productRec.buildertek__Type__c = 'Test';
        productRec.Name = 'New Product';
        insert productRec;

        buildertek__Question__c quesRec = new buildertek__Question__c();
        quesRec.Name='test';
        quesRec.buildertek__Cost__c=76;
        quesRec.buildertek__Product__c = productRec.id;
        insert quesRec;


        buildertek__Change_Order__c cOrder=new buildertek__Change_Order__c();
        cOrder.name='test';
        cOrder.buildertek__Status__c = 'Pending';
        cOrder.buildertek__Type__c = 'Customer'; 
        cOrder.buildertek__Date_Created__c = Date.Today();

    
        Test.startTest();
        createCO.changeOrderList(cOrder , quesRec.Id);
        Test.stopTest();

    }

}