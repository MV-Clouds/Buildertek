public without sharing class ReceiptTriggerHandler {


    public static void OnAfterInsert(buildertek__Receipt__c[] newReceiptList){
        SET<Id> receiptIdSet = new SET<Id>();
        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Receipt__c> receiptToUpdate = new List<buildertek__Receipt__c>();
        
        for(buildertek__Receipt__c recp : newReceiptList){
            projectIdSet.add(recp.buildertek__Project__c);     
        }
        
        List<buildertek__Receipt__c> receiptList;
        
        if(projectIdSet.size() > 0){
            if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible()&& Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()&& Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Project__c.isAccessible()){
                receiptList = [SELECT Id,  Name FROM buildertek__Receipt__c  WHERE buildertek__Project__c IN: projectIdSet   ORDER BY CreatedDate ASC];   
            }
        }else{
            if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible()&&  Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()){
                 receiptList = [SELECT Id,    Name  FROM buildertek__Receipt__c  ORDER BY CreatedDate ASC LIMIT 50000];
            }
        }                                                            
        
        
        String receiptId;
        Integer i = 1;
        if(receiptList != null){
        for(buildertek__Receipt__c recpt : receiptList){
            system.debug('increment --------> '+i);
            if(i > 9){
                receiptId = 'CR-00';      
            }else if(i > 99){
                receiptId = 'CR-0';    
            }else if(i > 999){
                receiptId = 'CR-';    
            }else{
                receiptId = 'CR-000';    
            }
            recpt.buildertek__Receipt_Number__c = receiptId + i;
            receiptToUpdate.add(recpt);
            i++;    
        }
        if(Schema.sObjectType.buildertek__Receipt__c.isUpdateable() && Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Receipt_Number__c.isUpdateable()){
              update receiptToUpdate;  
           }
        }

    }

    // public static void OnAfterDelete(buildertek__Receipt__c[] oldReceiptList){
    //     SET<Id> receiptIdSet = new SET<Id>();
    //     SET<Id> projectIdSet = new SET<Id>();
    //     List<buildertek__Receipt__c> receiptToUpdate = new List<buildertek__Receipt__c>();
        
    //     for(buildertek__Receipt__c recp : oldReceiptList){
    //         projectIdSet.add(recp.buildertek__Project__c);     
    //     }
        
    //     List<buildertek__Receipt__c> receiptList;
        
    //     if(projectIdSet.size() > 0){
    //         if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()&&  Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Project__c.isAccessible()){
    //             receiptList = [SELECT Id,  Name   FROM buildertek__Receipt__c WHERE buildertek__Project__c IN: projectIdSet   ORDER BY CreatedDate ASC];    
    //         }
    //     }else{
    //         if(Schema.sObjectType.buildertek__Receipt__c.fields.Id.isAccessible() &&  Schema.sObjectType.buildertek__Receipt__c.fields.Name.isAccessible()){
    //             receiptList = [SELECT Id,  Name  FROM buildertek__Receipt__c ORDER BY CreatedDate ASC LIMIT 50000];
    //         }
    //     }                                                            
        
        
    //     String receiptId;
    //     Integer i = 1;
    //     for(buildertek__Receipt__c recpt : receiptList){
    //         system.debug('increment --------> '+i);
    //         if(i > 9){
    //             receiptId = 'CR-00';      
    //         }else if(i > 99){
    //             receiptId = 'CR-0';    
    //         }else if(i > 999){
    //             receiptId = 'CR-';    
    //         }else{
    //             receiptId = 'CR-000';    
    //         }
    //         recpt.buildertek__Receipt_Number__c = receiptId + i;
    //         receiptToUpdate.add(recpt);
    //         i++;    
    //     }
    //     if(Schema.sObjectType.buildertek__Receipt__c.isUpdateable() &&  Schema.sObjectType.buildertek__Receipt__c.fields.buildertek__Receipt_Number__c.isUpdateable()){
    //         update receiptToUpdate;      
    //     }
       
    // }

   
}