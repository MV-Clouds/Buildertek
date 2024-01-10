public class BT_createPAfromPO_Controller {
    
    @AuraEnabled
    public static returnWrapper GetRelatedPaymanetApp(String SOVid){
        returnWrapper returnWrapper = new returnWrapper();
        try {

            List<buildertek__SOV_Payment_Application__c> payment_app = [SELECT Id, Name, buildertek__BT_Schedule_of_Values__c, buildertek__Application__c FROM buildertek__SOV_Payment_Application__c WHERE buildertek__BT_Schedule_of_Values__c =: SOVid ORDER BY buildertek__Application__c DESC LIMIT 1];
            if(payment_app.size() > 0){
                String payment_app_Id = payment_app[0].Id;

                returnWrapper.recordId = payment_app_Id;
                returnWrapper.returnMessage = 'existing_PA';
                return returnWrapper;
            }
            else {
                // Need to Create New Payment Application
                System.debug('Need to Create New Payment Application...');
                Date dToday = Date.today();
                String dateStr = dToday.year() + '/' + dToday.month() + '/' + dToday.day();

                buildertek__Schedule_of_Values__c SOV = [SELECT Id, Name,buildertek__Vendor__c, buildertek__BT_Purchase_Order__r.Name, buildertek__BT_Purchase_Order__c, buildertek__BT_Purchase_Order__r.buildertek__Vendor__c FROM buildertek__Schedule_of_Values__c WHERE Id =:SOVid LIMIT 1];
                if(SOV.buildertek__BT_Purchase_Order__c != null){

                    List<RecordType> recordType = [SELECT Id, Name FROM RecordType WHERE sObjectType='buildertek__SOV_Payment_Application__c' AND Name = 'AR'];

                    buildertek__SOV_Payment_Application__c newPA = new buildertek__SOV_Payment_Application__c();
                    // newPA.Name = SOV.Name;                                // SOV
                    newPA.Name = SOV.buildertek__BT_Purchase_Order__r.Name; // PO
                    // newPA.buildertek__PA_Type__c = ;
                    // newPA.buildertek__Owner_Account__c = SOV.buildertek__Vendor__c;     // SOV
                    newPA.buildertek__Owner_Account__c = SOV.buildertek__BT_Purchase_Order__r.buildertek__Vendor__c; // PO
                    // newPA.buildertek__Payment_Application_To__c = SOV.buildertek__BT_Purchase_Order__r.buildertek__Vendor__c;
                    newPA.buildertek__Period_To__c = dToday;
                    newPA.buildertek__Application__c = '1';
                    newPA.buildertek__BT_Schedule_of_Values__c = SOVid;
                    newPA.buildertek__Retainage__c = 0;
                    newPA.RecordTypeId = recordType.size() > 0 ? recordType[0].Id : null;
    
                    insert newPA;
    
                    List<buildertek__SOV_Continuation__c> conSheets = [SELECT Id, Name, buildertek__SOV_Payment_Application__c FROM buildertek__SOV_Continuation__c WHERE buildertek__SOV_Payment_Application__c =: newPA.Id];
    
                    List<buildertek__SOV_Continuation_Sheet_Lines__c> ComSheetLinesToCreate = new List<buildertek__SOV_Continuation_Sheet_Lines__c>();
    
                    // SOV Lines
                    // list<buildertek__Schedule_of_Value_Lines__c> SOVLines = [SELECT Id, Name,buildertek__Scheduled_Value__c FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: SOVid];
                    // if(SOVLines.size() > 0){
                    //     for(buildertek__Schedule_of_Value_Lines__c SOVline : SOVLines){
                    //         buildertek__SOV_Continuation_Sheet_Lines__c conSheetLine = new buildertek__SOV_Continuation_Sheet_Lines__c();
                    //         conSheetLine.Name = SOVline.Name;
                    //         conSheetLine.buildertek__Status__c = 'Pending';
                    //         conSheetLine.buildertek__Scheduled_Value__c = SOVline.buildertek__Scheduled_Value__c;
                    //         conSheetLine.buildertek__SOV_Continuation_Sheet__c = conSheets[0].Id;
                    //         conSheetLine.buildertek__Description_of_Work__c = SOVline.Name;
                    //         ComSheetLinesToCreate.add(conSheetLine);
                    //     }
                    // }
    
                    // PO line
                    List<buildertek__Purchase_Order_Item__c> POlines = [SELECT Id, Name,buildertek__Total_Price__c FROM buildertek__Purchase_Order_Item__c WHERE buildertek__Purchase_Order__c =: SOV.buildertek__BT_Purchase_Order__c];
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
    
                    returnWrapper.recordId = newPA.Id;
                    returnWrapper.returnMessage = 'newCreated_PA';
                    return returnWrapper;
                }
                else{
                    returnWrapper.returnMessage = 'po_null';
                    return returnWrapper;
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

    public class returnWrapper{
        @AuraEnabled public String recordId;
        @AuraEnabled public String returnMessage;
    }
}