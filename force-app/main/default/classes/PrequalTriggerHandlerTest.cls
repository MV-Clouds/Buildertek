@isTest
public class PrequalTriggerHandlerTest {
    static testMethod void createPrequal() {
        Account acc = new Account();
        acc.Name = 'test';
        insert acc;
        
        buildertek__Pre_Qual__c pq = new buildertek__Pre_Qual__c();
        pq.buildertek__Account__c = acc.Id;
        insert pq;
        
        buildertek__Pre_Qual__c pq1 = new buildertek__Pre_Qual__c();
        pq1.Id = pq.Id;
        pq1.buildertek__Qualification_Stage__c = 'Fully Executed';
        update pq1;
        
        
        
        
    }
}