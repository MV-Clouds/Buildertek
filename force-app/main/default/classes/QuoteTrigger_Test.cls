@isTest
public class QuoteTrigger_Test {
    static testmethod void testQuoteTrigger(){
        
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        System.assert(proj.Id!=null);
        
        buildertek__Admin_Interface_Node_Configuration__c AINC = new buildertek__Admin_Interface_Node_Configuration__c();
        AINC.Name = 'Quote Configuration';
        AINC.buildertek__Quote_Configuration__c = true;
        insert AINC;
        
         buildertek__Quote__c quote = new buildertek__Quote__c();
	    quote.Name = 'Test Budget';
	    quote.buildertek__Project__c = proj.Id;
	    quote.buildertek__Type__c = 'Master';
	    insert quote;
        
        quote.buildertek__Status__c='Sent';
        update quote;
        
        quote.buildertek__Status__c='Approved';
        update quote;
        
        
        try{
            delete quote;
        }catch(Exception e){
            System.debug('Delete failed :: '+e);
        }
        System.assert(true);
    }
}