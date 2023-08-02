@isTest
public with sharing class BT_CreateProjectFromQuoteTest {
    @TestSetup
    static void testProject(){
        buildertek__Quote__c qt=new buildertek__Quote__c();
        qt.Name='Testing';
        insert qt;
        
        User us=new User();
        us.Username='First1';
        
        Account ac=new Account();
        ac.Name='Testing Account';
        insert ac;
        
        Opportunity opp=new Opportunity();
        opp.Name='Testing Opp';
        
        buildertek__Project__c pr=new buildertek__Project__c();
        Date sampleDate = Date.parse('12/27/2023');
        pr.Name='Testing Project';
        pr.buildertek__Account__c=ac.Id;
        pr.buildertek__Customer__c=ac.Id;
        pr.buildertek__Opportunity__c=opp.Id;
        pr.buildertek__Project_Manager__c=us.Id;
        pr.buildertek__Contract_Date__c=sampleDate;
        insert pr;

        buildertek__Quote_Item__c item=new buildertek__Quote_Item__c();
        item.Name='TestItem';
        item.buildertek__Quote__c=qt.Id;
        insert item;
        
    }
    @isTest
    static void testProject2(){
        buildertek__Quote__c qt=new buildertek__Quote__c();
        qt=[SELECT Id, Name from buildertek__Quote__c LIMIT 1];
        
        buildertek__Project__c project = new buildertek__Project__c();
        project=[select Id, Name, buildertek__Account__c, buildertek__Customer__c, buildertek__Project_Manager__c, buildertek__Contract_Date__c From buildertek__Project__c LIMIT 1];
        //BT_CreateProjectFromQuote.getQuote(qt.Id);
        //BT_CreateProjectFromQuote.createProject(qt.Id,project.Name,project.buildertek__Account__c,project.buildertek__Project_Manager__c,project.buildertek__Contract_Date__c);
        
    }
}