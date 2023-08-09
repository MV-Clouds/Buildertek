/**
** Developed on 31st October 2019.
** Purpus : This trigger will update the Order Entry Release and Product Discription fields in Shipment Line Record based on the inputs provided by Dell Boomi trigger.
** Version : 1
** UnitTestClass : UnitTests_SalesOrderShipmentNotifyBatch.
**/

trigger ShipmentLineBIBU on Shipment_Line__c (before insert,before update) {
    // Set to collect the SO numbers from Oracle to query Order Entry Release object.
    Set<String> orderEntryReleaseIds = new Set<String>();
    // Set to collect the Product Code from Oracle to query Product2 object and get Product Discription.
    Set<String> productCodesSet = new Set<String>();
    
    for(Shipment_Line__c slRec: Trigger.New){
        if(Trigger.isInsert){
            if(slRec.SO_Number__c != null){
                orderEntryReleaseIds.add(slRec.SO_Number__c);
            }
            if(slRec.Product_SKU__c!= null){
                productCodesSet.add(slRec.Product_SKU__c);
            }
        }
        if(Trigger.isUpdate){
            Shipment_Line__c oldRec = Trigger.OldMap.get(slRec.id);
            if(slRec.SO_Number__c != null && oldRec.SO_Number__c != slRec.SO_Number__c){
                orderEntryReleaseIds.add(slRec.SO_Number__c);
            }
            if(slRec.Product_SKU__c!= null && slRec.Product_SKU__c != oldRec .Product_SKU__c){
                productCodesSet.add(slRec.Product_SKU__c);
            }
          
            if(slRec.SO_Number__c == null && oldRec.SO_Number__c!= slRec.SO_Number__c){
                slRec.Order_Entry_Release_Record__c = null;
            }
            if(slRec.Product_SKU__c == null && slRec.Product_SKU__c != oldRec .Product_SKU__c){
                slRec.Product_Description__c = null;
            }
        }
    }
    map<string,id> orderEntryReleaseIdMap = new map<String,id>();
    if(orderEntryReleaseIds.size()>0){
        // Collect the Order Entry Release record's SFDC ids and put into a map.        
        for(Order_Entry_Release__c oer:[select id,Oracle_Sales_Order_Id__c from Order_Entry_Release__c where Oracle_Sales_Order_Id__c in :orderEntryReleaseIds]){
            orderEntryReleaseIdMap.put(oer.Oracle_Sales_Order_Id__c,oer.id);
        }
    }
    
    map<string,string> productCodeDiscriptionMap = new map<String,string>();
    if(productCodesSet.size()>0){
        // Get the product discription and put them into a map.
        for(Product2 productRec: [select id,Description,ProductCode from Product2 where ProductCode in :productCodesSet]){
            productCodeDiscriptionMap.put(productRec.ProductCode,productRec.Description);
        }
    }
    
    for(Shipment_Line__c slRec: Trigger.New){
        //Update the Order Entry Release (Lookup field) with the curresponding SFDC Id to establish the link between Shipment Line and the Order Entry Relase object.
        if(orderEntryReleaseIdMap.get(slRec.SO_Number__c) != null){
            slRec.Order_Entry_Release_Record__c = orderEntryReleaseIdMap.get(slRec.SO_Number__c);
        }
        
        //Update the Product description.
        if(productCodeDiscriptionMap.get(slRec.Product_SKU__c) != null){
            slRec.Product_Description__c = productCodeDiscriptionMap.get(slRec.Product_SKU__c);
        }
    }    
    
}