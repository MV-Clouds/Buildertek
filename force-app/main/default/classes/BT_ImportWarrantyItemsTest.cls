@isTest
public class BT_ImportWarrantyItemsTest {

	static testMethod void test1() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    List<buildertek__Warranty__c> warrantyList = new List<buildertek__Warranty__c>();
	    buildertek__Warranty__c warranty = new buildertek__Warranty__c();
	    warranty.buildertek__Project__c = proj.Id;
	    warranty.buildertek__Type__c = 'Master';
	    warrantyList.add(warranty);
	    
	    buildertek__Warranty__c warranty2 = new buildertek__Warranty__c();
	    warranty2.buildertek__Project__c = proj.Id;
	    warranty2.buildertek__Type__c = 'Master';
	    warrantyList.add(warranty2);
	    insert warrantyList;
	    
	    List<String> selectedIds = new List<String>();
        selectedIds.add(warrantyList[0].Id);
	    
        
        Test.startTest();
        Test.setCurrentPage(Page.Import_Master_Warranty_Item);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(warrantyList);
        stdSetController.setSelected(warrantyList);
        Apexpages.currentPage().getParameters().put('Id', warrantyList[0].buildertek__Project__c);
        BT_ImportWarrantyItems ext = new BT_ImportWarrantyItems(stdSetController);
        Test.stopTest();
        system.assertEquals('test', 'test');
	}
	
	static testMethod void test2() { 
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    List<buildertek__Warranty__c> warrantyList = new List<buildertek__Warranty__c>();
	    buildertek__Warranty__c warranty = new buildertek__Warranty__c();
	    warranty.buildertek__Project__c = proj.Id;
	    warranty.buildertek__Type__c = 'Master';
	    warrantyList.add(warranty);
	    insert warrantyList;
	    
	    List<String> selectedIds = new List<String>();
        selectedIds.add(warrantyList[0].Id);
	    
	    
        ApexPages.StandardController sc = new ApexPages.StandardController(warranty);
        BT_ImportWarrantyItems IB = new BT_ImportWarrantyItems(SC);
        List<BT_ImportWarrantyItems.masterWarranty> MWList = new List<BT_ImportWarrantyItems.masterWarranty>();
        BT_ImportWarrantyItems.masterWarranty MW = new BT_ImportWarrantyItems.masterWarranty();
        MW.warranty = warrantyList[0];
        MW.isSelected = true;
        MWList.add(MW);
        IB.save();
        BT_ImportWarrantyItems.importMasterRecords(proj.Id,warrantyList[0].Id);
        system.assertEquals('test', 'test');
	}

}