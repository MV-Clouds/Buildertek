public class warrantyLockedBatchcontroller{
    public list<buildertek__Warranty__c> warrantylst = new list<buildertek__Warranty__c>();
    public warrantyLockedBatchcontroller(){
    }
    public void  batchjobexcute(){ 
        
        warrantylst = [select id,name,buildertek__Due_Date__c,buildertek__Locked__c from buildertek__Warranty__c where buildertek__Locked__c !=true];
        
        warrantyLocked_Batch warrantylock =new warrantyLocked_Batch(warrantylst);
        
        database.executebatch(warrantylock,200);
        
        
    }
}