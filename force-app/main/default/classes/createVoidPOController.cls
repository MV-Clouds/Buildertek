public class createVoidPOController {
    

    @AuraEnabled
    public static returnWrapper createVoidPO(String recordId){
        returnWrapper returnWr = new returnWrapper();
        try {
            
            List<buildertek__Purchase_Order__c> PO = [SELECT Id, Name,buildertek__Vendor__c, buildertek__Project__c, 
                                                        (SELECT Id, Name, buildertek__Unit_Price__c,buildertek__Tax__c,buildertek__Quantity__c, buildertek__Description__c,buildertek__Product__c  FROM buildertek__Purchase_Order_Items__r)
                                                    FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];

            buildertek__Purchase_Order__c VoidPOtoCreate = PO[0].clone(false, false, false, false);
            VoidPOtoCreate.buildertek__Old_Purchase_Order__c = PO[0].Id;
            insert VoidPOtoCreate;

            List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
            if(PO[0].buildertek__Purchase_Order_Items__r.size() > 0){
                for(buildertek__Purchase_Order_Item__c line : PO[0].buildertek__Purchase_Order_Items__r){
                    buildertek__Purchase_Order_Item__c POline = line.clone(false, false, false, false);
                    Poline.buildertek__Unit_Price__c = -(POline.buildertek__Unit_Price__c);
                    Poline.buildertek__Tax__c = POline.buildertek__Tax__c;
                    Poline.buildertek__Purchase_Order__c = VoidPOtoCreate.Id;
                    POlinesToCreate.add(POline);
                }
            }

            if(POlinesToCreate.size() > 0){
                insert POlinesToCreate;
            }

            returnWr.status = 'success';
            returnWr.message = 'Void PO created Successfully.';
            returnWr.createRecordId = VoidPOtoCreate.Id;
            return returnWr;
        } catch (Exception e) {
            System.debug('Error in createVoidPO ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
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
        @AuraEnabled public String createRecordId;
    }
}