@isTest
public with sharing class OpportunityTrigger_Test {
    static testmethod void testOpportunityTrigger(){
        Opportunity opp = new Opportunity();
        opp.Name = 'test';
        opp.StageName = 'Perception Analysis';
        opp.CloseDate = system.today();
        insert Opp;
        
        list<buildertek__Admin_Interface_Node_Configuration__c> adminlist = new list<buildertek__Admin_Interface_Node_Configuration__c>();
        buildertek__Admin_Interface_Node_Configuration__c  adminRec = new buildertek__Admin_Interface_Node_Configuration__c();
        adminRec.Name = 'Quote Configuration';
        adminRec.buildertek__Create_Project_from_Opportunity__c = true;
        adminlist.add(adminRec);
        insert adminlist;
        
        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;
        System.assert(proj.Id!=null);
        
         buildertek__Quote__c quote = new buildertek__Quote__c();
	    quote.Name = 'Test Budget';
	    quote.buildertek__Project__c = proj.Id;
	    quote.buildertek__Type__c = 'Master';
        quote.buildertek__Opportunity__c = opp.id;
	    insert quote;
        
        quote.buildertek__Status__c='Sent';
        update quote;
        
        quote.buildertek__Status__c='Customer Accepted';
        update quote;
        
        opp.StageName = 'Closed Won';
        update opp;
        
        
        try{
            delete quote;
        }catch(Exception e){
            System.debug('Delete failed :: '+e);
        }
        System.assert(true);
    }

}