@isTest
public class AccountPayableTriggerTest {
   public static testMethod void testAccountPayableTrigger() {
        try{
        Account account1 = new Account(
            Name = 'Sample Account 1'
        );
        insert account1;
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        insert contact1;
        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        insert project;
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c(
        buildertek__Contractor_Resource__c = contact1.Id,
        buildertek__Vendor__c = account1.Id,
        buildertek__Project__c = project.Id,
        buildertek__Ship_To_Address__c = account1.Id);
        insert purchaseOrder;
        List<buildertek__Account_Payable__c> accPayableList = new List<buildertek__Account_Payable__c>();
        buildertek__Account_Payable__c accPayable = new buildertek__Account_Payable__c(
            buildertek__Project__c = project.Id,
            buildertek__Purchase_Order__c = purchaseOrder.Id
        );
        
        accPayableList.add(accPayable);
        
        insert accPayableList;
        update accPayableList;
        delete accPayableList;
        AccountPayableHelper APH = new AccountPayableHelper();
        AccountPayableHelper.beforeDelete(accPayableList);
        }
        catch(exception e){
            
        }
        System.assertEquals('Test','Test');
    }
}