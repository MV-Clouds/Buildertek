@isTest
    public class ReceiptTriggerTest {
        public static testMethod void testOnAfterInsert() {
            buildertek__Project__c proj = new buildertek__Project__c();
            proj.Name = 'Test Project';
            insert proj;

            Account acc = new Account();
            acc.Name='test';
            insert acc;
        
            Change_Order__c co = new Change_Order__c();
            co.Name = 'test';
            co.Customer_Account__c=acc.id;
            insert co;
        

            Billings__c billing = new Billings__c();
            billing.Name='test';
            billing.Change_Order__c=co.id;
            insert billing;
            

            List<buildertek__Receipt__c> newReceiptList = new List<buildertek__Receipt__c>();
            newReceiptList.add(new buildertek__Receipt__c(buildertek__Billing__c=billing.Id , buildertek__Project__c = proj.Id));
            newReceiptList.add(new buildertek__Receipt__c( buildertek__Billing__c=billing.Id , buildertek__Project__c = proj.Id));
    
            insert newReceiptList;
            // OnAfterInsert.onAfterInsert(newReceiptList);

            for(buildertek__Receipt__c rec:newReceiptList){
                rec.buildertek__Receipt_Number__c='CR-0011'; 

            }
            update newReceiptList;
    
        }
    
    
    
}