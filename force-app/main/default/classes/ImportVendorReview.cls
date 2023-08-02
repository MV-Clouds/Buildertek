public class ImportVendorReview {
    @AuraEnabled
    public static List<MasterBudgetsClass> getMasterVendorReviews(string recordId){
        
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Vendor_Review__c> MasterVendorReview = new List<buildertek__Vendor_Review__c>();
        
        MasterVendorReview = [SELECT Id,
                              Name
                              FROM buildertek__Vendor_Review__c
                              WHERE buildertek__Type__c = 'Master'];  
        for(buildertek__Vendor_Review__c bud : MasterVendorReview){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;       
    }
    
    @AuraEnabled
    public static MessageClass importMasterVenderReviewLines(List<String> budgetIds, String recordId){
      //  system.debug('recordId--------->'+recordId);
      //  system.debug('budgetIds'+budgetIds);
        MessageClass msg = new MessageClass();
        try{
            
            List<buildertek__Vendor_Review__c> MasterVendorReviewList;
            
            MasterVendorReviewList = [select id,Name,buildertek__of_Questions__c,buildertek__Notes__c,buildertek__Project__c,buildertek__Purchase_Order__c,
                                      buildertek__Type__c,buildertek__Contractor__c
                                      from buildertek__Vendor_Review__c where Id IN: budgetIds
                                     ];
            
            List<buildertek__Vendor_Review__c> VendorReviewList =  new List<buildertek__Vendor_Review__c>();
            
            Id recID = Id.valueOf(recordId);
            String sObjName = recID.getSObjectType().getDescribe().getName();
            String parentId;
            
            if(sObjName == 'buildertek__Purchase_Order__c'){
                buildertek__Purchase_Order__c parentVendor = [select Id,buildertek__Vendor__c from buildertek__Purchase_Order__c where Id =: recordId];
            	parentId = parentVendor.buildertek__Vendor__c;
            }else if(sObjName == 'Account'){
                Account parentVendor = [select Id from Account where Id =: recordId];
            	parentId = parentVendor.Id;
            }
            // buildertek__Purchase_Order__c parentVendor = [select Id,buildertek__Vendor__c from buildertek__Purchase_Order__c where Id =: recordId];
            
            system.debug(parentId);
            if(!MasterVendorReviewList.isEmpty()){
                for(buildertek__Vendor_Review__c masterBudget : MasterVendorReviewList){
                    buildertek__Vendor_Review__c VendorItem = new buildertek__Vendor_Review__c();
                    VendorItem.Name = masterBudget.Name;
                    VendorItem.buildertek__of_Questions__c = masterBudget.buildertek__of_Questions__c;
                    if(sObjName == 'buildertek__Purchase_Order__c'){
                        VendorItem.buildertek__Purchase_Order__c = recordId;
                    }
                    VendorItem.buildertek__Notes__c = masterBudget.buildertek__Notes__c;
                    VendorItem.buildertek__Project__c = masterBudget.buildertek__Project__c;
                    //VendorItem.buildertek__Type__c = masterBudget.buildertek__Type__c;
                    VendorItem.buildertek__Type__c = 'Standard';
                    //VendorItem.buildertek__Contractor__c = parentVendor.buildertek__Vendor__c;
                    VendorItem.buildertek__Contractor__c = parentId;
                    VendorItem.buildertek__OldVendorId__c = masterBudget.Id;
                    VendorReviewList.add(VendorItem);
                }  
            }
           // system.debug('vendor revuew list-->'+VendorReviewList);
            if(VendorReviewList.size() > 0){
                insert VendorReviewList;
                list<Id> VRIds = new list<id>();
                for(buildertek__Vendor_Review__c VR : VendorReviewList){
                    VRIds.add(VR.id);
                }
                
                msg.Status = 'Success';
                msg.Message = 'Vendor Review  Imported Successfully';
                msg.Ids = VRIds;
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Vendor Review  for the selected Review';    
            }
            
            map<STring,String> vendormap = new map<string,string>();
          //  system.debug('vendor revuew list-->'+VendorReviewList);
            for(buildertek__Vendor_Review__c reviewLines : VendorReviewList){
                vendormap.put(reviewLines.buildertek__OldVendorId__c,reviewLines.id);
            }
                
            List<buildertek__Vendor_Review_Lines__c> masterBudgetList;
            masterBudgetList = [SELECT id, 
                                Name, 
                                buildertek__Notes__c, 
                                buildertek__Rating__c,
                                buildertek__Score__c,
                                buildertek__Contract_Review__c, 
                                buildertek__Weighting__c
                                FROM buildertek__Vendor_Review_Lines__c
                                WHERE buildertek__Contract_Review__c IN: budgetIds]; 
            List<buildertek__Vendor_Review_Lines__c> BudgetItemist =  new List<buildertek__Vendor_Review_Lines__c>();
            
            if(!masterBudgetList.isEmpty()){
                for(buildertek__Vendor_Review_Lines__c masterBudget : masterBudgetList){
                    buildertek__Vendor_Review_Lines__c BudgetItem = new buildertek__Vendor_Review_Lines__c();
                    BudgetItem.Name = masterBudget.Name;
                    BudgetItem.buildertek__Notes__c = masterBudget.buildertek__Notes__c;
                   // system.debug(masterBudget.buildertek__Contract_Review__c+'insidefor->'+vendormap.get(masterBudget.buildertek__Contract_Review__c));
                    BudgetItem.buildertek__Contract_Review__c = vendormap.get(masterBudget.buildertek__Contract_Review__c);
                    BudgetItem.buildertek__Weighting__c = masterBudget.buildertek__Weighting__c;
                    BudgetItemist.add(BudgetItem);
                }  
            }
            if(BudgetItemist.size() > 0){
                insert BudgetItemist;
                msg.Status = 'Success';
                msg.Message = 'Vendor Review Lines Imported Successfully';
            }else{
                msg.Status = 'Failed';
                msg.Message = 'There were no Vendor Review Lines for the selected Review';    
            }
            return msg;
        }catch(Exception exp){
            msg.Status = 'Failed';
            msg.Message = exp.getMessage();  
            return msg;
        }                                             
    }
    
    public class MasterBudgetsClass{
        @AuraEnabled
        public buildertek__Vendor_Review__c budgetRecord {get;set;}
        // @AuraEnabled
        // public buildertek__Master_Budget__c masterBudgetRecord {get;set;}
        @AuraEnabled
        public boolean budgetCheck {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        @AuraEnabled
        public list<String> Ids {get;set;}
        
  
    }
}