public class CreateBudgetController {
	@AuraEnabled
    public static ResponseBase createBudget(Id contractId) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            List<buildertek__Budget__c> newBudget = BudgetContractCreateHelper.createBudgetFromContract(new List<Id> {contractId});
            response.strMessage = 'success';
            response.newRecordId = newBudget[0].Id;
        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
    @AuraEnabled
    public static ResponseBase createBudgetFromQuote(Id QuoteId) {
        system.debug('testt');
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            List<buildertek__Budget__c> newBudget = BudgetContractCreateHelper.createBudgetFromQuote(new List<Id> {QuoteId});
            response.strMessage = 'success';
            response.newRecordId = newBudget[0].Id;
        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
	@AuraEnabled
    public static ResponseBase createContract(Id quotetId) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        //try {
            List<buildertek__Contract__c> newContracts = BudgetContractCreateHelper.createContractsFromQuote(new List<Id> {quotetId});
            response.strMessage = 'success';
            response.newRecordId = newContracts[0].Id;
        //}
        /*catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }*/
        
        return response;
    }
    
    @AuraEnabled
    public static ResponseBase createBudgetFromPurchase(Id purchaseId) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            List<buildertek__Budget__c> newBudgets = BudgetPurchaseOrderCreateHelper.createBudgetFromPurchaseOrder(new List<Id> {purchaseId});
            system.debug('Budget Id ------> '+newBudgets[0].Id);
            response.newRecordId = newBudgets[0].Id;
            response.strMessage = 'success';
        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String newRecordId;
    }
}