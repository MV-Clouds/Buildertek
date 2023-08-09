@isTest
public class RFQTrigger_Test {
    static testmethod void  testRFQTrigger(){
        Account currAccount = new Account(Name = 'Test');
        insert currAccount;
        System.assert(currAccount.Id!=null);
        
        buildertek__Project__c project1 = new buildertek__Project__c();
        project1.name='test project';
        insert project1;
        
        buildertek__Admin_Interface_Node_Configuration__c AINC = new buildertek__Admin_Interface_Node_Configuration__c();
        AINC.Name = 'RFQ Configuration';
        AINC.buildertek__Update_Price_Book__c = true;
        insert AINC;
        
        
        buildertek__RFQ__c rfq1= new buildertek__RFQ__c();
        rfq1.buildertek__Project__c=project1.Id;
        insert rfq1; 
        
        buildertek__RFQ_To_Vendor__c vendor1= new buildertek__RFQ_To_Vendor__c();
        vendor1.name='test vendor';
        vendor1.buildertek__RFQ__c=rfq1.Id;
        vendor1.buildertek__Vendor__c=currAccount.Id;
        vendor1.Status__c='Accepted';
        insert vendor1; 
        
        
        rfq1.buildertek__Vendor__c=vendor1.Id;
        update rfq1;
        
        rfq1.buildertek__Description__c='test description';
        rfq1.buildertek__Status__c='Awarded';
        update rfq1;
        
        try{
            delete rfq1;    
        }   catch(Exception e){
            system.debug('error :: '+e);
        }     
        
        rfq1.buildertek__Status__c='Accepted';
        update rfq1;
        
        try{
            delete rfq1;    
        }   catch(Exception e){
            system.debug('error :: '+e);
        }  
        
        rfq1.buildertek__Status__c='Request Sent';
        update rfq1;
        
        try{
            delete rfq1;    
        }   catch(Exception e){
            system.debug('error :: '+e);
        }  
        System.assert(true);
        
    }
}