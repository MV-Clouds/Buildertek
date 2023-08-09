public with sharing class ImportMasterPO {
    
    Public String recordId {get;set;}
    Private ApexPages.StandardController controller; 
    Public ImportMasterPO(){
        recordId = ApexPages.currentPage().getParameters().get('Id');
    }
    
    @AuraEnabled 
    public static List<String> getProjectPlan(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = buildertek__Project__c.buildertek__Plan_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    
    @AuraEnabled 
    public static List<buildertek__Project__c> getMasterPO(String planType,String currentProjectId,String vendorName){
        System.debug('Plan Type::'+planType);
        if(vendorName != '' && vendorName != null){
            System.debug('Plan Type::'+planType+' '+vendorName);
            String newSearchText = '%'+vendorName+'%';
            List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master' AND buildertek__Vendor__r.Name LIKE: newSearchText) From buildertek__Project__c WHERE buildertek__Plan_Type__c =: planType AND ID !=:currentProjectId];
            if(projects.size()>0){
                return projects;
            }
        }else {
            List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master') From buildertek__Project__c WHERE buildertek__Plan_Type__c =: planType AND ID !=:currentProjectId];
            system.debug(projects);
            if(projects.size()>0){
                return projects;
            }
        }
        
        return null;
    }
    
    @AuraEnabled
    public  static List<buildertek__Project__c> getAllMasterPO(String currentProjectId,String vendorName){
        if(vendorName != '' && vendorName != null){
            String newSearchText = '%'+vendorName+'%';
            List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master' AND buildertek__Vendor__r.Name LIKE: newSearchText) From buildertek__Project__c ];
            if(projects.size()>0){
                return projects;
            }
        }else{
            List<buildertek__Project__c> projects = [Select Id,Name,buildertek__Plan_Type__c,(Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Description__c,buildertek__PO_Amount__c From buildertek__Purchase_Orders__r WHERE buildertek__PO_Type__c = 'Master') From buildertek__Project__c ];
            if(projects.size()>0){
                return projects;
            }
        }
        
        return null;
    }
    
    @AuraEnabled 
    public static String importPurchaseOrder(String currentProjectId,List<String> selectedPOId){
        try{
        list<buildertek__Purchase_Order__c> PurchaseordersList = new list<buildertek__Purchase_Order__c>();
        Map<String,Id> purchaseorderMap = new Map<String,Id>();
        List<buildertek__Purchase_Order__c> purchaseOrders = [SELECT Id, Name, RecordTypeId, buildertek__Auto_Number__c,buildertek__Project__c, buildertek__Budget__c, buildertek__Status__c, buildertek__PO_Amount__c, buildertek__Sub_Contract__c, buildertek__RFQ__c, buildertek__Vendor__c, buildertek__Period__c, buildertek__Change_Order__c, buildertek__CO_Amount__c, buildertek__Type__c, buildertek__Service_Request__c, buildertek__Contractor_Resource__c, buildertek__Required_Delivery_Date__c, buildertek__PO_Balance__c, buildertek__Schedule_Item__c, buildertek__Date_Created__c, buildertek__Date_Approved__c, buildertek__Delivery_Date__c, buildertek__Ship_To_Address__c, buildertek__Crew_Date__c, buildertek__Tax__c, buildertek__PO_Total__c, buildertek__Completion__c, buildertek__Location__c, buildertek__Quote__c, buildertek__Auto_Number1__c, buildertek__Proejct_PO_Number__c, buildertek__Description__c, buildertek__Paid_Amount__c, buildertek__Date_Confirmed__c, buildertek__Paid__c, buildertek__Over_Under_Paid__c, buildertek__Customer_Accepted_Date__c, buildertek__Date_Lien_Release_Signed__c, buildertek__Rejection_Reason__c, buildertek__Community__c, buildertek__Date_Lien_Release_Sent__c, buildertek__Rating__c, buildertek__PO_Type__c, buildertek__Bill_To_Address__c, buildertek__ShipToAddress__c, buildertek__Ship_To_City__c, buildertek__Ship_To_State__c, buildertek__Ship_To_Zip__c, buildertek__Ship_To_Country__c
                                                              FROM buildertek__Purchase_Order__c WHERE ID =:  selectedPOId];
        Map<buildertek__Purchase_Order__c,List<buildertek__Purchase_Order_Item__c>> poMap = new Map<buildertek__Purchase_Order__c,List<buildertek__Purchase_Order_Item__c>>();
        Map<Id,buildertek__Purchase_Order_Item__c> poLineMap = new Map<Id,buildertek__Purchase_Order_Item__c>();
        List<buildertek__Purchase_Order_Item__c> poLineList = [Select Id,Name,buildertek__Purchase_Order__c,buildertek__Description__c,buildertek__Product__c,buildertek__UOM__c,buildertek__Quantity__c,
                                                               buildertek__Tax__c,buildertek__Unit_Price__c,buildertek__Cost_Code__c
                                                               From buildertek__Purchase_Order_Item__c Where buildertek__Purchase_Order__c IN: selectedPOId];
        for(buildertek__Purchase_Order__c purchaseRec : purchaseOrders){
            system.debug('purchaseRec.buildertek__Tax__c-->'+purchaseRec.buildertek__Tax__c);
            buildertek__Purchase_Order__c newpurchaseRec  = purchaseRec.clone(false, false, false, false);
            newpurchaseRec.buildertek__Budget__c = null;
            newpurchaseRec.buildertek__Status__c = 'Open';
            newpurchaseRec.buildertek__Project__c = currentProjectId;
            newpurchaseRec.buildertek__Old_Purchase_Order__c = purchaseRec.id;
            newpurchaseRec.buildertek__Tax__c = purchaseRec.buildertek__Tax__c;
            PurchaseordersList.add(newpurchaseRec);
            system.debug('%%%%'+ newpurchaseRec.buildertek__Tax__c);
        }
        if(PurchaseordersList.size()>0){
            system.debug('PurchaseordersList.size()-->'+PurchaseordersList.size());
             system.debug('PurchaseordersList-->'+PurchaseordersList);
            insert PurchaseordersList;
        }
        for(buildertek__Purchase_Order__c purchaseordernewRec :PurchaseordersList){
            purchaseorderMap.put(purchaseordernewRec.buildertek__Old_Purchase_Order__c,purchaseordernewRec.id);
        }
       list<buildertek__Purchase_Order_Item__c> purchaseorderitemlist = new list<buildertek__Purchase_Order_Item__c>();
        for(buildertek__Purchase_Order_Item__c oldpurchaseorderrec : poLineList){
        buildertek__Purchase_Order_Item__c purchaseorderitemCopy = oldpurchaseorderrec.clone(false,true);
         if(purchaseorderMap.get(oldpurchaseorderrec.buildertek__Purchase_Order__c)!=null){
              purchaseorderitemCopy.buildertek__Purchase_Order__c = purchaseorderMap.get(oldpurchaseorderrec.buildertek__Purchase_Order__c);
             system.debug(purchaseorderitemCopy.buildertek__Purchase_Order__c);
         }
            purchaseorderitemlist.add(purchaseorderitemCopy);
        }
        if(purchaseorderitemlist.size()>0){
            system.debug('purchaseorderitemlist-->'+purchaseorderitemlist);
            insert purchaseorderitemlist;
        }
            if(PurchaseordersList.size() == 1){
               return PurchaseordersList[0].id;  
            }else{
                return 'Success';
            }
       
     /*   try{
            CreatePOLineWithPO createPOandPOlines = new CreatePOLineWithPO(selectedPOId,currentProjectId); 
            ID batchProcessId = Database.executeBatch(createPOandPOlines,1); 
            AsyncApexJob aaj = [SELECT Id, Status, JobItemsProcessed, TotalJobItems, NumberOfErrors 
                    FROM AsyncApexJob WHERE ID =: batchprocessId ];
            System.debug('Returned batch process ID: ' + aaj);
            buildertek__Purchase_Order__c recentlyCreatedPO = [Select Id FROM buildertek__Purchase_Order__c ORDER BY CreatedDate DESC LIMIT 1];
            system.debug(recentlyCreatedPO.Id);
            return 'SUCCESS';*/
        }catch(Exception e){
            String message = e.getMessage();
            system.debug(e);
            //return message;    
            return message;
        }
        
        
        
        /*for(buildertek__Purchase_Order__c purchaseOrder : purchaseOrders){
            purchaseOrder.Id = null;
            purchaseOrder.buildertek__Status__c = 'Open';
            purchaseOrder.buildertek__Project__c = currentProjectId;
        }
        insert purchaseOrders;
        return 'Success';*/
    }
}