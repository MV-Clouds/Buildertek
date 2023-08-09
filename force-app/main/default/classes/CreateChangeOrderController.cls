public class CreateChangeOrderController {
	@AuraEnabled
    public static ResponseBase createChangeOrder(Id purchaseOrderId) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            response.strRecordId = ChangeOrderHelper.createChangeOrder(purchaseOrderId);
            response.strMessage = 'success';
        }
        catch(Exception ex) {
            response.isSuccess = false;
            response.strMessage = ex.getMessage();
        }
        
        return response;
    }
    
	@AuraEnabled
    public static ResponseBase createInspection(Id purchaseOrderId) {
        ResponseBase response = new ResponseBase();
        response.isSuccess = true;
        
        try {
            response.strRecordId = ChangeOrderHelper.createInspection(purchaseOrderId);
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
        @AuraEnabled public String strRecordId;
    }
}