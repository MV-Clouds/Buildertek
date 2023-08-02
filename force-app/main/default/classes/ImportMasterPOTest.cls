@isTest
public class ImportMasterPOTest {
    private static testMethod void getPO() {
        
         List<buildertek__Purchase_Order__c> purchaseList = new List<buildertek__Purchase_Order__c>();
	    buildertek__Purchase_Order__c purchase = new buildertek__Purchase_Order__c();
        purchase.buildertek__Old_Purchase_Order__c=purchase.Id;
	    purchase.buildertek__PO_Type__c = 'Master';
	    purchaseList.add(purchase); 
	    insert purchaseList;
       
        List<buildertek__Project__c> proList = new List<buildertek__Project__c>(); 
    buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
        //proj= [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master') From buildertek__Project__c  WHERE buildertek__Plan_Type__c =:'Deschutes' AND ID !=:proj.Id];
       //proj.buildertek__Plan_Type__c= planType;
        proj.buildertek__Plan_Type__c='Deschutes';
        proList.add(proj);
	    insert proList;
         System.assert(proList[0]!=null);
        Account acc=new Account();
        acc.Name='test';
        insert acc;
        
        List<buildertek__Purchase_Order__c> purList = new List<buildertek__Purchase_Order__c>();
	    buildertek__Purchase_Order__c pur = new buildertek__Purchase_Order__c();
	    pur.buildertek__Vendor__c = acc.id;
	    pur.buildertek__Project__c = proj.Id;
        pur.buildertek__Old_Purchase_Order__c=pur.Id;
	    pur.buildertek__PO_Type__c = 'Master';
	    purList.add(pur); 
	    insert purList;
        System.assert(purList[0].Id!=null);
        
         List<buildertek__Purchase_Order_Item__c> PoList = new List<buildertek__Purchase_Order_Item__c>();
         buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
        POItem.buildertek__Purchase_Order__c=pur.Id;
   
        POItem.buildertek__Quantity__c=5;
        POItem.buildertek__Unit_Price__c=5000;
        PoList.add(POItem);
        insert PoList;
        
         List<String> selectedIds = new List<String>();
        selectedIds.add(purList[0].Id);
        
         ApexPages.StandardController sc = new ApexPages.StandardController(purList[0]);
        ApexPages.currentPage().getParameters().put('Id',purList[0].id);
         List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master') From buildertek__Project__c ];
         ImportMasterPO.getProjectPlan();
         ImportMasterPO.importPurchaseOrder(purList[0].Id,selectedIds);
         ImportMasterPO.getMasterPO('Deschutes',purList[0].Id,'Test vendor');
        ImportMasterPO.getAllMasterPO(purList[0].Id,'Test vendor');


        

}
}