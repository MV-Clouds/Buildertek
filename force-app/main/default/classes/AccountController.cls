public class AccountController {
    @AuraEnabled
    public static buildertek__DocuSign_Authentication__c saveAccount (buildertek__DocuSign_Authentication__c acc) {
        system.debug(acc);
        
        upsert acc;
      
        return acc;
    }
}