@isTest
private class AssociateWarrantyControllerTest {
    private static testMethod void Method1() {
       buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        List<buildertek__Warranty__c> warrantyList = new List<buildertek__Warranty__c>();
        buildertek__Warranty__c warranty = new buildertek__Warranty__c();
        warranty.buildertek__Project__c = proj.Id;
        warranty.buildertek__Type__c = 'Master';
        warranty.buildertek__Lag_Value__c = 5;
         warrantyList.add(warranty);
        insert warrantyList;
       // insert warranty;
       // warrantyList.add(warranty);
        List<buildertek__Warranty__c> warrantyList2 = new List<buildertek__Warranty__c>();
        buildertek__Warranty__c warranty2 = new buildertek__Warranty__c();
        warranty2.buildertek__Project__c = proj.Id;
        warranty2.buildertek__Type__c = 'Master';
        warranty2.buildertek__Lag_Value__c = 5;
        // warrantyList2.add(warranty2);
       // insert warrantyList2;
       // warrantyList.add(warranty2);
        insert warranty2;
      //  List<String> selectedIds = new List<String>();
       // selectedIds.add(warrantyList[0].Id);
      //  List<String> selectedId = new List<String>();
     //   selectedId.add(warrantyList2[0].Id);
        
        //AssociateWarrantyController AWC = new AssociateWarrantyController();
        //AssociateWarrantyController.warrantydetails(warrantyList[0].Id);
      	//AssociateWarrantyController.newWarranty(warranty2.id,warranty.id,5);
     	//AssociateWarrantyController.newWarranty(warrantyList2[0].Id,warrantyList[0].Id,5);
    }

}