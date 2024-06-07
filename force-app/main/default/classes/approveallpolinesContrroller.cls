public class approveallpolinesContrroller {
    
    @AuraEnabled
    public static returnWrapper approveallpolines(String recordId){
        returnWrapper returnWr = new returnWrapper();
        try {
            System.debug('we are on approveallpolines');
            List<buildertek__Purchase_Order__c> PO = [SELECT Id, Name,(SELECT Id, Name,buildertek__Status__c  FROM buildertek__Purchase_Order_Items__r)
                                                    FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
            
             
            if(PO[0].buildertek__Purchase_Order_Items__r.size() > 0){
                for(buildertek__Purchase_Order_Item__c line : PO[0].buildertek__Purchase_Order_Items__r){
                        line.buildertek__Status__c='Approved_For_Payment';
                }
                update PO[0].buildertek__Purchase_Order_Items__r;
            }

            returnWr.status = 'success';
            returnWr.message = 'Approved All PO Lines for Payment Successfully.';
            return returnWr;
        } catch (Exception e) {
            System.debug('Error in approveallpolinesController..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }

            returnWr.status = 'error';
            returnWr.message = e.getMessage();
            return returnWr;
        }
    }

    public class returnWrapper{
        @AuraEnabled public string status;
        @AuraEnabled public String message;
    }
}