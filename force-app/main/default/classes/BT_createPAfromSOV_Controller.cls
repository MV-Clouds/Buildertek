public class BT_createPAfromSOV_Controller {
    
    @AuraEnabled
    public static string GetRelatedPaymanetApp(String SOVid){
        try {

            List<buildertek__SOV_Payment_Application__c> payment_app = [SELECT Id, Name, buildertek__BT_Schedule_of_Values__c FROM buildertek__SOV_Payment_Application__c WHERE buildertek__BT_Schedule_of_Values__c =: SOVid ORDER BY CreatedDate DESC LIMIT 1];
            if(payment_app.size() > 0){
                String payment_app_Id = payment_app[0].Id;
                return payment_app_Id;
            }
            else {
                return 'create_new_payment_app';
            }

        } catch (Exception e) {
            System.debug('Error in GetRelatedPaymanetApp ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
                return null;
        }
    }
}