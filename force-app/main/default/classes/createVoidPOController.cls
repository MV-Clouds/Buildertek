public class createVoidPOController {
    

    @AuraEnabled
    public static returnWrapper createVoidPO(String recordId){
        returnWrapper returnWr = new returnWrapper();
        
        try {
            
            List<buildertek__Purchase_Order__c> PO = [SELECT Id, Name,buildertek__Vendor__c, buildertek__Project__c,buildertek__Status__c, buildertek__Schedule__c,buildertek__Schedule_Item__c,buildertek__Completion__c,buildertek__Projected_Start_Date__c,buildertek__Projected_Completion_Date__c, 
                                                        (SELECT Id, Name, buildertek__Unit_Price__c,buildertek__Tax__c, buildertek__Cost_Type__c, 
                                                          buildertek__Cost_Code__c, buildertek__Quantity__c, buildertek__Description__c,buildertek__Product__c  FROM buildertek__Purchase_Order_Items__r)
                                                    FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
            
            if(PO[0].buildertek__Status__c=='Paid' || PO[0].buildertek__Status__c=='Partially Paid'){                
                returnWr.status = 'error';
                returnWr.message = 'You cannot void a Paid or Partially Paid Purchase Order';
                return returnWr;                
            }                        
            
            buildertek__Purchase_Order__c VoidPOtoCreate = PO[0].clone(false, false, false, false);
            VoidPOtoCreate.buildertek__Old_Purchase_Order__c = PO[0].Id;
            VoidPOtoCreate.buildertek__Schedule__c = PO[0].buildertek__Schedule__c;
            VoidPOtoCreate.buildertek__Schedule_Item__c = PO[0].buildertek__Schedule_Item__c;
            VoidPOtoCreate.buildertek__Completion__c = PO[0].buildertek__Completion__c;
            VoidPOtoCreate.buildertek__Projected_Start_Date__c = PO[0].buildertek__Projected_Start_Date__c;
            VoidPOtoCreate.buildertek__Projected_Completion_Date__c = PO[0].buildertek__Projected_Completion_Date__c;
            
            insert VoidPOtoCreate;

            //BUIL-4167 PO's - Void PO button needs some additional logic.
            PO[0].buildertek__Status__c='Canceled';
            PO[0].buildertek__Schedule__c=null;
            PO[0].buildertek__Schedule_Item__c=null;
            PO[0].buildertek__Completion__c=null;
            PO[0].buildertek__Projected_Start_Date__c=null;
            PO[0].buildertek__Projected_Completion_Date__c=null;
            update PO[0];

            
            List<buildertek__Purchase_Order_Item__c> POlinesToCreate = new List<buildertek__Purchase_Order_Item__c>();
            if(PO[0].buildertek__Purchase_Order_Items__r.size() > 0){
                for(buildertek__Purchase_Order_Item__c line : PO[0].buildertek__Purchase_Order_Items__r){
                    buildertek__Purchase_Order_Item__c POline = line.clone(false, false, false, false);
                    Poline.buildertek__Unit_Price__c = -(POline.buildertek__Unit_Price__c);
                    Poline.buildertek__Tax__c = POline.buildertek__Tax__c;
                    Poline.buildertek__Cost_Code__c = POline.buildertek__Cost_Code__c;
                    Poline.buildertek__Cost_Type__c = POline.buildertek__Cost_Type__c;
                    Poline.buildertek__Purchase_Order__c = VoidPOtoCreate.Id;
                    POlinesToCreate.add(POline);
                }
            }

            if(POlinesToCreate.size() > 0){
                insert POlinesToCreate;                               
            }
            
             //If the secondary PO is create then update the initial PO fields.  2024/06/03 BC
             List<buildertek__Purchase_Order__c> POFields = [SELECT Id, Name,buildertek__Vendor__c, buildertek__Project__c, buildertek__Status__c, buildertek__Schedule__c 
                                                         FROM buildertek__Purchase_Order__c WHERE Id =: recordId LIMIT 1];
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