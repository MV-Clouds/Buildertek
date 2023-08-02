@isTest
public class RFQTOVendorLineTriggerHandlerTest {

      @isTest static void myTest() {
     
          buildertek__RFQ_Vendor_Item__c rfqVendor = new buildertek__RFQ_Vendor_Item__c();
          
          rfqVendor.Name = 'Test1';
          rfqVendor.buildertek__Vendor__c = 'a0V1K00000EeHXwUAN';
          insert rfqVendor;  
          
          update rfqVendor;
          
          List<buildertek__RFQ_Vendor_Item__c>  b = new  List<buildertek__RFQ_Vendor_Item__c>();
          b.add(rfqVendor);
          RFQTOVendorLineTriggerHandler a = new RFQTOVendorLineTriggerHandler();
          a.beforeInsert(b);
      }
}