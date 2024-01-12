public class BT_createPAfromPO_Controller {
    
    @AuraEnabled
    public static responseWrapper GetRelatedPaymanetApp(String recordId){
        responseWrapper responseWrapper = new responseWrapper();
        try {

            List<buildertek__SOV_Payment_Application__c> payment_app = [SELECT Id, Name, buildertek__Application__c,buildertek__BT_Purchase_Order__c  FROM buildertek__SOV_Payment_Application__c WHERE buildertek__BT_Purchase_Order__c =: recordId ORDER BY buildertek__Application__c DESC LIMIT 1];
            if(payment_app.size() > 0){
                String payment_app_Id = payment_app[0].Id;

                responseWrapper.recordId = payment_app_Id;
                responseWrapper.returnMessage = 'existing_PA';
                return responseWrapper;
            }
            else {
                // Need to Create New Payment Application....
                System.debug('Need to Create New Payment Application...');
                Date dToday = Date.today();
                String dateStr = dToday.year() + '/' + dToday.month() + '/' + dToday.day();

                    list<buildertek__Purchase_Order__c> PO = [SELECT Id, Name, buildertek__Vendor__c, buildertek__Description__c FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];      
                    // List is used to handle "list has no raw to assign sObject".....
                    if(PO.size() > 0){
                            List<RecordType> recordType = [SELECT Id, Name FROM RecordType WHERE sObjectType='buildertek__SOV_Payment_Application__c' AND Name = 'AP'];
        
                            buildertek__SOV_Payment_Application__c newPA = new buildertek__SOV_Payment_Application__c();
                            newPA.Name = PO[0].Name;
                            // newPA.Name = PO[0].buildertek__Description__c;
                            newPA.buildertek__PA_Type__c = 'AP';
                            newPA.buildertek__Owner_Account__c = PO[0].buildertek__Vendor__c;
                            newPA.buildertek__Period_To__c = dToday;
                            newPA.buildertek__Application__c = '1';
                            newPA.buildertek__BT_Purchase_Order__c = recordId;
                            newPA.buildertek__Retainage__c = 0;
                            newPA.RecordTypeId = recordType.size() > 0 ? recordType[0].Id : null;
            
                            insert newPA;
            
                            List<buildertek__SOV_Continuation__c> conSheets = [SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE buildertek__SOV_Payment_Application__c =: newPA.Id];
            
                            List<buildertek__SOV_Continuation_Sheet_Lines__c> ComSheetLinesToCreate = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
    
                            List<buildertek__Purchase_Order_Item__c> POlines = [SELECT Id, Name,buildertek__Total_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: recordId];
                            if(POlines.size() > 0){
                                for(buildertek__Purchase_Order_Item__c POline : POlines){
                                    buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
                                    conSheetLine.Name = POline.Name;
                                    conSheetLine.buildertek__Status__c = 'Pending';
                                    conSheetLine.buildertek__Scheduled_Value__c = POline.buildertek__Total_Price__c;
                                    conSheetLine.buildertek__Description_of_Work__c = POline.Name;
                                    conSheetLine.buildertek__SOV_Continuation_Sheet__c = conSheets[0].Id;
                                    ComSheetLinesToCreate.add(conSheetLine);
                                }
                            }

                            if(ComSheetLinesToCreate.size() > 0){
                                insert ComSheetLinesToCreate;
                            }

                            responseWrapper.recordId = newPA.Id;
                            responseWrapper.returnMessage = 'newCreated_PA';
                            return responseWrapper;
                    }
                    else{
                        return null;
                    }
    
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

    public class responseWrapper{
        @AuraEnabled public String recordId;
        @AuraEnabled public String returnMessage;
    }
}