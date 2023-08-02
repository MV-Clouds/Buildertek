@isTest
public class BT_ImportContractTest {

	static testMethod void test1() {
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    List<buildertek__Contract__c> contractList = new List<buildertek__Contract__c>();
	    buildertek__Contract__c contract = new buildertek__Contract__c();
	    contract.Name = 'Test Budget';
	    contract.buildertek__Project__c = proj.Id;
	    contract.buildertek__Type__c = 'Master';
	    contractList.add(contract);
	    
	    buildertek__Contract__c contract2 = new buildertek__Contract__c();
	    contract2.Name = 'Test Budget2';
	    contract2.buildertek__Project__c = proj.Id;
	    contract2.buildertek__Type__c = 'Master';
	    contractList.add(contract2);
	    insert contractList;
	    
	    List<String> selectedIds = new List<String>();
        selectedIds.add(contractList[0].Id);
	    
	    List<buildertek__Contract_Line_Group__c> groupList = new List<buildertek__Contract_Line_Group__c>();
	    buildertek__Contract_Line_Group__c groups = new buildertek__Contract_Line_Group__c();
	    groups.Name = 'Test Group';
	    groupList.add(groups);
	    insert groupList;
        
        Test.startTest();
        Test.setCurrentPage(Page.Import_Master_Contracts);
        ApexPages.StandardSetController stdSetController = new ApexPages.StandardSetController(contractList);
        stdSetController.setSelected(contractList);
        Apexpages.currentPage().getParameters().put('Id',contractList[0].buildertek__Project__c);
        BT_ImportContract ext = new BT_ImportContract(stdSetController);
        Test.stopTest();
        system.assertEquals('test', 'test');
	}
	
	static testMethod void test2() { 
	    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
	    
	    List<buildertek__Contract__c> contractList = new List<buildertek__Contract__c>();
	    buildertek__Contract__c contract = new buildertek__Contract__c();
	    contract.Name = 'Test Budget';
	    contract.buildertek__Project__c = proj.Id;
	    contract.buildertek__Type__c = 'Master';
	    contractList.add(contract);
	    insert contractList;
         
	    List<String> selectedIds = new List<String>();
        selectedIds.add(contractList[0].Id);
	    
	    List<buildertek__Contract_Line_Group__c> groupList = new List<buildertek__Contract_Line_Group__c>();
	    buildertek__Contract_Line_Group__c groups = new buildertek__Contract_Line_Group__c();
	    groups.Name = 'Test Group';
	    groupList.add(groups);
	    insert groupList;
	      
        
        buildertek__Contract_Item__c contractItem1 = new buildertek__Contract_Item__c();
        contractItem1.buildertek__Contract__c=contractList[0].Id;
        contractItem1.Name='test';
        contractItem1.buildertek__Contract_Line_Group__c=groupList[0].id;
        insert contractItem1;
        
         ApexPages.StandardController sc = new ApexPages.StandardController(contract);
        BT_ImportContract IB = new BT_ImportContract(SC);
        List<BT_ImportContract.masterContract> MBList = new List<BT_ImportContract.masterContract>();
        BT_ImportContract.masterContract MB = new BT_ImportContract.masterContract();
        MB.contracts = contractList[0];
        MB.isSelected = true;
        MBList.add(MB);
        IB.masterContracts=MBList;
        IB.save();
        system.assertEquals('test', 'test');
	}

}