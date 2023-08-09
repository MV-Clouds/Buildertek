global class CreatePOLineWithPO implements Database.Batchable<sObject> {
    private List<String> selectedPOId;
    private String projectId;
    public CreatePOLineWithPO(List<String> strParam,String currentProjectId) {
        selectedPOId = strParam;
        projectId = currentProjectId;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //system.debug(strParameter);
        
        
        String query = 'SELECT Id, Name, RecordTypeId, buildertek__Auto_Number__c, buildertek__Project__c,buildertek__Budget__r.buildertek__Project__c, buildertek__Budget__c, buildertek__Status__c, buildertek__PO_Amount__c, buildertek__Sub_Contract__c, buildertek__RFQ__c, buildertek__Vendor__c, buildertek__Period__c, buildertek__Change_Order__c, buildertek__CO_Amount__c, buildertek__Type__c, buildertek__Service_Request__c, buildertek__Contractor_Resource__c, buildertek__Required_Delivery_Date__c, buildertek__PO_Balance__c, buildertek__Schedule_Item__c, buildertek__Date_Created__c, buildertek__Date_Approved__c, buildertek__Delivery_Date__c, buildertek__Ship_To_Address__c, buildertek__Crew_Date__c, buildertek__Tax__c, buildertek__PO_Total__c, buildertek__Completion__c, buildertek__Location__c, buildertek__Quote__c, buildertek__Auto_Number1__c, buildertek__Proejct_PO_Number__c, buildertek__Description__c, buildertek__Paid_Amount__c, buildertek__Date_Confirmed__c, buildertek__Paid__c, buildertek__Over_Under_Paid__c, buildertek__Customer_Accepted_Date__c, buildertek__Date_Lien_Release_Signed__c, buildertek__Rejection_Reason__c, buildertek__Community__c, buildertek__Date_Lien_Release_Sent__c, buildertek__Rating__c, buildertek__PO_Type__c, buildertek__Bill_To_Address__c, buildertek__ShipToAddress__c, buildertek__Ship_To_City__c, buildertek__Ship_To_State__c, buildertek__Ship_To_Zip__c, buildertek__Ship_To_Country__c FROM buildertek__Purchase_Order__c WHERE ID =: selectedPOId ';
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<buildertek__Purchase_Order__c> POList) { 
        try{
            List<buildertek__Purchase_Order_Item__c> poLineList = [Select Id,Name,buildertek__Purchase_Order__c,buildertek__Product__c,buildertek__UOM__c,buildertek__Quantity__c,
                                                                   buildertek__Tax__c,buildertek__Unit_Price__c,buildertek__Cost_Code__c
                                                                   From buildertek__Purchase_Order_Item__c Where buildertek__Purchase_Order__c IN: POList];
            
            List<buildertek__Purchase_Order__c> newPOList = new List<buildertek__Purchase_Order__c>();
            for(buildertek__Purchase_Order__c PoItem : POList) {
                //there is a lookup filter for budget with condition "Purchase Order: Project ID EQUALS Budget: Project ID"
                /*if(PoItem.buildertek__Budget__c != null){
                    if(PoItem.buildertek__Budget__r.buildertek__Project__c != PoItem.buildertek__Project__c){
                        PoItem.buildertek__Budget__c = null;
                    }                    
                }*/
                PoItem.buildertek__Budget__c = null;

                PoItem.Id = null;
                PoItem.buildertek__Status__c = 'Open';
                PoItem.buildertek__Project__c = projectId;
                newPOList.add(PoItem);
            }
            insert newPOList;
            system.debug(newPOList);
            List<buildertek__Purchase_Order_Item__c> newPOLineList = new List<buildertek__Purchase_Order_Item__c>();
            for(buildertek__Purchase_Order__c insertedPoItem : newPOList){
                for(buildertek__Purchase_Order_Item__c polineItem : poLineList){
                    polineItem.Id = null;
                    polineItem.buildertek__Purchase_Order__c = insertedPoItem.Id;
                    newPOLineList.add(polineItem);
                }
            }
            insert newPOLineList;
           system.debug(newPOLineList);
        }catch (Exception e) {
            
            throw e;
        }
        
    }   
    
    global void finish(Database.BatchableContext BC) {
        // execute any post-processing operations
    }
}