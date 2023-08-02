@isTest
public class TakeOffLineTriggerHandler_Test {
    @isTest 
    public static void afterInsert() {
        
        
        //Buildertek__Project_Takeoff_Lines__c
        buildertek__Project_Takeoff__c b = new buildertek__Project_Takeoff__c(buildertek__Description__c='test Desc', buildertek__Name__c = 'test name');
        insert b;
        
        
        
    
        
        
        Buildertek__Project_Takeoff_Lines__c t = new Buildertek__Project_Takeoff_Lines__c( buildertek__Project_Takeoff__c = b.Id, buildertek__Description__c = 'test 33');
        insert t;
        
        // t.buildertek__Description__c = 'test 43';
        //update t;
        
        
        
        
    }
}