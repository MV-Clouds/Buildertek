@isTest
public class BT_New_ContractTest {
	public static testMethod void testBT_New_Contract() {
        Account account1 = new Account(
            Name = 'Sample Account 1'
        );
        
        insert account1;
        BT_New_Contract.getsObjName(account1.Id); 
        System.assertEquals('Test','Test');
    }
}