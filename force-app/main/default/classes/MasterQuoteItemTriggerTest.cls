@isTest
public class MasterQuoteItemTriggerTest {
    static testmethod void testMasterQuoteItemTrigger(){
        buildertek__Master_Quote__c masterQuoteRec = new buildertek__Master_Quote__c();
        masterQuoteRec.Name='Test Master Quote';
        insert masterQuoteRec;
        buildertek__Quote_Line_Group__c quotline =new buildertek__Quote_Line_Group__c ();
        quotline.Name='test';
        insert quotline;
        
        
       /* System.assert(masterQuoteRec.Id!=null);
        
        buildertek__Master_Quote_Item__c masterQuoteItemRec = new buildertek__Master_Quote_Item__c();
        masterQuoteItemRec.Name='Test Master Quote Item';
        masterQuoteItemRec.buildertek__Master_Quote__c=masterQuoteRec.Id;
        insert masterQuoteItemRec;
        
        System.assert(masterQuoteItemRec.Id!=null);*/

    }
}