public class VendorReviewTriggerHandler {
     //Boolean variable to allow skipping execution of trigger in certain scenarios
    public static Boolean blnSkipVendorReviewTrigger = false;
     
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public VendorReviewTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    
     public void OnAfterInsert(buildertek__Vendor_Review__c[] newVendorReview, Map<ID, buildertek__Vendor_Review__c> newVendorReviewMap){ 
        SET<Id> VendorReviewIdSet = new SET<Id>();
        SET<Id> VendorReviewContractIdSet = new SET<Id>();
		SET<Id> VendorReviewPoIdSet = new SET<Id>();
        Map<String, Decimal> contractMap = new Map<String, Decimal>();
		 Map<String, Decimal> poMap = new Map<String, Decimal>();
          Map<id, list<buildertek__Vendor_Review__c>> AccvendorreviewMap = new  Map<id, list<buildertek__Vendor_Review__c>>();
        List<Account> contractToUpdateList = new List<Account>();
		List<buildertek__Purchase_Order__c> poToUpdateList = new List<buildertek__Purchase_Order__c>();
        
        for(buildertek__Vendor_Review__c VendorReview : newVendorReview){
            if(VendorReview.buildertek__Contractor__c != null){
                VendorReviewIdSet.add(VendorReview.Id);
                VendorReviewContractIdSet.add(VendorReview.buildertek__Contractor__c);
            }
			if(VendorReview.buildertek__Purchase_Order__c != null){
			VendorReviewPoIdSet.add(VendorReview.buildertek__Purchase_Order__c);
			}
                   
        }
        List<buildertek__Vendor_Review__c> VendorReviewsList = new List<buildertek__Vendor_Review__c> ();
         if(VendorReviewContractIdSet.size() > 0 ){
                            VendorReviewsList= [SELECT Id,
                                             Name,
                                             buildertek__Contractor__c,
                                             buildertek__Total_Score__c,
											 buildertek__Purchase_Order__c,
											 buildertek__Rating__c
                                             FROM buildertek__Vendor_Review__c
                                             WHERE buildertek__Contractor__c IN: VendorReviewContractIdSet ];
		}
								
	List<buildertek__Vendor_Review__c> PoVendorReviewsList = new List<buildertek__Vendor_Review__c>();
         if(VendorReviewPoIdSet.size() > 0){
                            PoVendorReviewsList= [SELECT Id,
                                             Name,
                                             buildertek__Contractor__c,
                                             buildertek__Total_Score__c,
											 buildertek__Purchase_Order__c,
											 buildertek__Rating__c
                                             FROM buildertek__Vendor_Review__c
                                             WHERE buildertek__Purchase_Order__c IN: VendorReviewPoIdSet and buildertek__Total_Score__c != null
                                             order by createddate desc limit 1];
                }
				
				
        for(buildertek__Vendor_Review__c VendorReviews : VendorReviewsList){
           if(AccvendorreviewMap.get(VendorReviews.buildertek__Contractor__c) == null){
                          AccvendorreviewMap.put(VendorReviews.buildertek__Contractor__c, new list<buildertek__Vendor_Review__c>());
                     } 
                     AccvendorreviewMap.get(VendorReviews.buildertek__Contractor__c).add(VendorReviews);
        }
        for(String contractId : AccvendorreviewMap.keySet()){
             decimal avgrate = 0;
            if(contractId != null ){
               for(buildertek__Vendor_Review__c rec:AccvendorreviewMap.get(contractId)){
                avgrate+=rec.buildertek__Rating__c;
            }
                avgrate = avgrate/AccvendorreviewMap.get(contractId).size();
                Account contractToUpdate = new Account();
                    contractToUpdate.Id = contractId;
                   contractToUpdate.buildertek__Total_Rating__c = avgrate;
                    contractToUpdateList.add(contractToUpdate);     
                
                   
            }
        }
      
        if(contractToUpdateList.size() > 0){
              update contractToUpdateList; 
            
            
        }
		
		if(PoVendorReviewsList.size() > 0 ){
		 for(buildertek__Vendor_Review__c VendorReviews : PoVendorReviewsList){
            if(poMap.get(VendorReviews.buildertek__Purchase_Order__c) == null){
                poMap.put(VendorReviews.buildertek__Purchase_Order__c, VendorReviews.buildertek__Rating__c);    
            }else{
               decimal finalTotalAmount = poMap.get(VendorReviews.buildertek__Purchase_Order__c) + VendorReviews.buildertek__Rating__c; 
               poMap.put(VendorReviews.buildertek__Purchase_Order__c, finalTotalAmount);
            }
        }
        for(String poId : poMap.keySet()){
            if(poId != null ){
               
                    buildertek__Purchase_Order__c poToUpdate = new buildertek__Purchase_Order__c();
                    poToUpdate.Id = poId;
                    poToUpdate.buildertek__Rating__c = poMap.get(poId);
                    poToUpdateList.add(poToUpdate);     
                
                   
            }
        }
      
        if(poToUpdateList.size() > 0){
                update poToUpdateList; 
            
            
        } 
        }
       
    }   
    
    
     public void OnAfterUpdate(buildertek__Vendor_Review__c[] oldVendorReview, buildertek__Vendor_Review__c[] updatedVendorReview, Map<ID, buildertek__Vendor_Review__c> VendorReviewMap, Map<Id, buildertek__Vendor_Review__c> oldVendorReviewMap){
         SET<Id> VendorReviewIdSet = new SET<Id>();
        SET<Id> VendorReviewContractIdSet = new SET<Id>();
		SET<Id> VendorReviewPoIdSet = new SET<Id>();
      
        Set<Id> oldvendorreviewids = new Set<Id>();
        Map<id, list<buildertek__Vendor_Review__c>> AccvendorreviewMap = new  Map<id, list<buildertek__Vendor_Review__c>>();
         for(buildertek__Vendor_Review__c oldCO : oldVendorReview){
		    if(oldCO.buildertek__Contractor__c !=null){
                VendorReviewContractIdSet.add(oldCO.buildertek__Contractor__c);
               }
             if(oldCO.buildertek__Purchase_Order__c != null){
                VendorReviewPoIdSet.add(oldCO.buildertek__Purchase_Order__c);
				 
             }
        }
       
       
        
        Map<String, Decimal> contractMap = new Map<String, Decimal>();
        List<Account> contractToUpdateList = new List<Account>();
       Map<String, Decimal> poMap = new Map<String, Decimal>();
        List<buildertek__Purchase_Order__c> poToUpdateList = new List<buildertek__Purchase_Order__c>();
		 List<buildertek__Vendor_Review__c> VendorReviewsList = new List<buildertek__Vendor_Review__c> ();
        for(buildertek__Vendor_Review__c VendorReview : updatedVendorReview){
            VendorReviewIdSet.add(VendorReview.Id);
              if(VendorReview.buildertek__Contractor__c != null){
                
                VendorReviewContractIdSet.add(VendorReview.buildertek__Contractor__c);
            }
			if(VendorReview.buildertek__Purchase_Order__c != null){
			VendorReviewPoIdSet.add(VendorReview.buildertek__Purchase_Order__c);
			}
            
                   
        }
         
          if(VendorReviewContractIdSet.size() > 0 ){
                            VendorReviewsList= [SELECT Id,
                                             Name,
                                             buildertek__Contractor__c,
                                             buildertek__Total_Score__c,
											 buildertek__Purchase_Order__c,
											 buildertek__Rating__c
                                             FROM buildertek__Vendor_Review__c
                                             WHERE buildertek__Contractor__c IN: VendorReviewContractIdSet ];
		}
          for(buildertek__Vendor_Review__c VendorReviews : VendorReviewsList){
           if(AccvendorreviewMap.get(VendorReviews.buildertek__Contractor__c) == null){
                          AccvendorreviewMap.put(VendorReviews.buildertek__Contractor__c, new list<buildertek__Vendor_Review__c>());
                     } 
                     AccvendorreviewMap.get(VendorReviews.buildertek__Contractor__c).add(VendorReviews);
        }
        for(String contractId : AccvendorreviewMap.keySet()){
             decimal avgrate = 0;
            if(contractId != null ){
               for(buildertek__Vendor_Review__c rec:AccvendorreviewMap.get(contractId)){
                avgrate+=rec.buildertek__Rating__c;
            }
                avgrate = avgrate/AccvendorreviewMap.get(contractId).size();
                Account contractToUpdate = new Account();
                    contractToUpdate.Id = contractId;
                   contractToUpdate.buildertek__Total_Rating__c = avgrate;
                    contractToUpdateList.add(contractToUpdate);     
                
                   
            }
        }
      system.debug('contractToUpdateList'+contractToUpdateList.size());
        if(contractToUpdateList.size() > 0){
              update contractToUpdateList; 
            
            
        }
         List<buildertek__Vendor_Review__c> PoVendorReviewsList = new List<buildertek__Vendor_Review__c>();
         if(VendorReviewPoIdSet.size() > 0){
                            PoVendorReviewsList= [SELECT Id,
                                             Name,
                                             buildertek__Contractor__c,
                                             buildertek__Total_Score__c,
											 buildertek__Purchase_Order__c,
											 buildertek__Rating__c
                                             FROM buildertek__Vendor_Review__c
                                             WHERE buildertek__Purchase_Order__c IN: VendorReviewPoIdSet and buildertek__Total_Score__c != null
                                             order by createddate desc limit 1];
                }
                
				
				if(PoVendorReviewsList.size() > 0 ){
		 for(buildertek__Vendor_Review__c VendorReviews : PoVendorReviewsList){
            if(poMap.get(VendorReviews.buildertek__Purchase_Order__c) == null){
                poMap.put(VendorReviews.buildertek__Purchase_Order__c, VendorReviews.buildertek__Rating__c);    
            }else{
               decimal finalTotalAmount = poMap.get(VendorReviews.buildertek__Purchase_Order__c) + VendorReviews.buildertek__Rating__c; 
               poMap.put(VendorReviews.buildertek__Purchase_Order__c, finalTotalAmount);
            }
        }
        for(String poId : poMap.keySet()){
            if(poId != null ){
               
                    buildertek__Purchase_Order__c poToUpdate = new buildertek__Purchase_Order__c();
                    poToUpdate.Id = poId;
                    poToUpdate.buildertek__Rating__c = poMap.get(poId);
                    poToUpdateList.add(poToUpdate);     
                
                   
            }
        }
      
        if(poToUpdateList.size() > 0){
                update poToUpdateList; 
          } 
		
   
        system.debug('Contract Map ---------> '+poMap.keySet());
        
        
           }
     }
     
    }