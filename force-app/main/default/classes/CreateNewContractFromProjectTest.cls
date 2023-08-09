@isTest
public class CreateNewContractFromProjectTest {
 @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test 1';
        con.email = 'test@test.com';
        insert con;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        insert project;
        
        buildertek__Contract__c contract = new buildertek__Contract__c();
        contract.buildertek__Project__c = project.Id;
        contract.Name = 'Test';
        insert contract;
    }
    @isTest
    static void testMethod1(){
        List<buildertek__Project__c> project = [Select Id
                                                FROM buildertek__Project__c
                                                LIMIT 1];
        CreateNewContractFromProject.getContractTemplate(project[0].Id);
        CreateNewContractFromProject.getContractTemplate('');
    }
}