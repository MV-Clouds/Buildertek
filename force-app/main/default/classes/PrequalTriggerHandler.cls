public class PrequalTriggerHandler {
    public void OnBeforeUpdate(buildertek__Pre_Qual__c[] oldAccount, buildertek__Pre_Qual__c[] updatedAccount, Map<ID, buildertek__Pre_Qual__c> newAccountMap, Map<Id, buildertek__Pre_Qual__c> oldAccountMap){
        List<String> AccIdsList = new List<String>();
        for(buildertek__Pre_Qual__c acc:updatedAccount){
            if(acc.buildertek__Qualification_Stage__c == 'Fully Executed'){
                AccIdsList.add(acc.buildertek__Account__c);
                acc.buildertek__Pre_Qualified__c = true;
            }
        }
        List<Account> accList = [Select id,Name,buildertek__Qualification_Stage__c,buildertek__Pre_Qualified__c from Account where Id IN:AccIdsList];
        for(Account acc:accList){
            if(acc.buildertek__Pre_Qualified__c == false){
                acc.buildertek__Pre_Qualified__c = true;
                acc.buildertek__Qualification_Stage__c = 'Fully Executed';
            }
            
        }
        if(accList.size() > 0){
            update accList;
        }
        
        
    }
    
}