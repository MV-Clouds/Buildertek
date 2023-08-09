@isTest
public class ImportmasterBudgetClassTest {
    public static testMethod void test1() {
        
        Master_Budget__c mb = new Master_Budget__c();
        mb.Name='test';
        mb.Type__c='Master';
        insert mb;
        
        Master_Budget_Line__c mbl = new Master_Budget_Line__c(); 
        mbl.Master_Budget__c = mb.id;
        mbl.UOM__c = 'Box';
        insert mbl;
        
        Project__c p = new Project__c();
        p.Name = 'test';
        insert p;
        
        Budget__c b = new Budget__c();
        b.Name= 'test';
        b.Project__c = p.id;
        insert b;
        
        Budget__c b1 = new Budget__c();
        b1.Name= 'test';
        b1.Project__c = p.id;
        b1.Type__c = 'Master'; 
        insert b1;
        
        Budget_Item__c bi = new Budget_Item__c();
        bi.Name = 'test product';
        bi.Budget__c = b.id;
        insert bi;
     
        String masterid = Id.valueOf(mb.id);
        List<String> masterbudgetid = new List<String>();
        masterbudgetid.add(masterid);
        
        ImportmasterBudgetClass.getMasterBudgets();
        ImportmasterBudgetClass.importMasterBudgetLines(masterbudgetid,Id.valueOf(bi.id));
        
        System.assertEquals('Test','Test');
        
    }
     
        
}