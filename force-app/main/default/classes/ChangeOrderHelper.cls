public with sharing class ChangeOrderHelper {
    public static String createChangeOrder(Id purchaseOrderId) {
        List<buildertek__Change_Order_Item__c> listChangeOrders = new List<buildertek__Change_Order_Item__c>();
        buildertek__Purchase_Order__c currPurchaseOrder;
          /*if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Period__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Sub_Contract__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
    		
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Id.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Description__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Item_Name__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__RFQ_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible()){*/
                currPurchaseOrder= [SELECT Id, Name, buildertek__Budget__c, buildertek__Project__c, buildertek__Period__c,
                                                                  buildertek__RFQ__c, buildertek__Status__c, buildertek__Sub_Contract__c, buildertek__Vendor__c,
                                                                  
                                                                  (SELECT Id, Name, buildertek__Auto_Number__c, buildertek__Budget_Item__c, 
                                                                  buildertek__Cost_Code__c, buildertek__Description__c, buildertek__Item_Name__c, 
                                                                  buildertek__Product__c, buildertek__Purchase_Order__c, buildertek__Quantity__c, 
                                                                  buildertek__RFQ_Item__c, buildertek__Total_Price__c, buildertek__Unit_Price__c
                                                                  FROM buildertek__Purchase_Order_Items__r)
                                                           FROM buildertek__Purchase_Order__c
                                                           WHERE Id =: purchaseOrderId];
    		/*}*/
        buildertek__Change_Order__c currChangeOrder = new buildertek__Change_Order__c(
            												Name = currPurchaseOrder.Name,
                                                            buildertek__Budget__c = currPurchaseOrder.buildertek__Budget__c,
                                                            // buildertek__Contract__c = currPurchaseOrder.buildertek__Sub_Contract__c,
                                                            buildertek__Period__c = currPurchaseOrder.buildertek__Period__c,
                                                            buildertek__Project__c = currPurchaseOrder.buildertek__Project__c,
                                                            buildertek__RFQ__c = currPurchaseOrder.buildertek__RFQ__c,
                                                            buildertek__Customer_Account__c = currPurchaseOrder.buildertek__Vendor__c,
                                                            buildertek__Vendor__c = currPurchaseOrder.buildertek__Vendor__c,
                                                            buildertek__Type__c = 'Vendor',
            												buildertek__Purchase_Order__c = currPurchaseOrder.Id
                                                        );
       /* if(Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Budget__c.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Period__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Project__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__RFQ__c.isCreateable() &&
				Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Customer_Account__c.isCreateable()&&
                Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Vendor__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Type__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Change_Order__c.fields.buildertek__Purchase_Order__c.isCreateable() ){*/
                 insert currChangeOrder;
    		/*	}*/
        for(buildertek__Purchase_Order_Item__c purchaseOrderLine : currPurchaseOrder.buildertek__Purchase_Order_Items__r) {
            listChangeOrders.add(new buildertek__Change_Order_Item__c(
                buildertek__Description__c = purchaseOrderLine.buildertek__Description__c,
                Name = purchaseOrderLine.Name,
                buildertek__Quantity__c = purchaseOrderLine.buildertek__Quantity__c,
                buildertek__Unit_Price__c = purchaseOrderLine.buildertek__Unit_Price__c,
                buildertek__Product__c = purchaseOrderLine.buildertek__Product__c,
                buildertek__Budget_Item__c = purchaseOrderLine.buildertek__Budget_Item__c,
                buildertek__Change_Order__c = currChangeOrder.Id
            ));
        }
        
        if(!listChangeOrders.isEmpty()) {
           /* if(Schema.sObjectType.buildertek__Change_Order_Item__c.isCreateable()&&
            Schema.sObjectType.buildertek__Change_Order_Item__c.fields.Name.isCreateable()&&
            Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Description__c.isCreateable() &&
			Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
			Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Unit_Price__c.isCreateable()&&
            Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Budget_Item__c.isCreateable() &&
			Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Product__c.isCreateable() &&
			Schema.sObjectType.buildertek__Change_Order_Item__c.fields.buildertek__Change_Order__c.isCreateable()){*/
            insert listChangeOrders;
			/*}*/
        }
        
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c(Id = purchaseOrderId, buildertek__Change_Order__c = currChangeOrder.Id);
        purchaseOrder.buildertek__CO_Amount__c = [SELECT buildertek__Total_Amount__c FROM buildertek__Change_Order__c WHERE Id =: currChangeOrder.Id].buildertek__Total_Amount__c;
        purchaseOrder.buildertek__New_PO_Amount__c = purchaseOrder.buildertek__CO_Amount__c != NULL ? purchaseOrder.buildertek__CO_Amount__c : 0.0;
        purchaseOrder.buildertek__New_PO_Amount__c = purchaseOrder.buildertek__New_PO_Amount__c + (purchaseOrder.buildertek__PO_Amount__c != NULL ? purchaseOrder.buildertek__PO_Amount__c : 0.0);
       /* if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isUpdateable() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isUpdateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Tax__c.isUpdateable()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Change_Order__c.isUpdateable() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__New_PO_Amount__c.isUpdateable()){*/
            update purchaseOrder;
        /*}*/
        
        return currChangeOrder.Id;
    }
    
    public static String createInspection(Id purchaseOrderId) {
        Date myDate = Date.today();

        List<buildertek__Inspection_Line__c> listInspectionLines = new List<buildertek__Inspection_Line__c>();
        buildertek__Purchase_Order__c currPurchaseOrder;
        if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Budget__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Period__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__RFQ__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Status__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Sub_Contract__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
    		
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Id.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Budget_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Cost_Code__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Description__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Item_Name__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Purchase_Order__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__RFQ_Item__c.isAccessible() &&
    		Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Unit_Price__c.isAccessible()){
                        currPurchaseOrder= [SELECT Id, Name, buildertek__Budget__c, buildertek__Project__c, buildertek__Period__c,
                                                                  buildertek__RFQ__c, buildertek__Status__c, buildertek__Sub_Contract__c, 
                                                                  buildertek__Vendor__c, //buildertek__Vendor__r.buildertek__Trade_Type__c, 
                                                                  (SELECT Id, Name, buildertek__Auto_Number__c, buildertek__Budget_Item__c, 
                                                                  buildertek__Cost_Code__c, buildertek__Description__c, buildertek__Item_Name__c, 
                                                                  buildertek__Product__c, buildertek__Purchase_Order__c, buildertek__Quantity__c, 
                                                                  buildertek__RFQ_Item__c, buildertek__Total_Price__c, buildertek__Unit_Price__c
                                                                  FROM buildertek__Purchase_Order_Items__r)
                                                           FROM buildertek__Purchase_Order__c
                                                           WHERE Id =: purchaseOrderId];
			}
        buildertek__Inspection__c inspection = new buildertek__Inspection__c(
            //Name = currPurchaseOrder.Name,
            buildertek__Status__c = 'Open',
            buildertek__Purchase_Order__c = purchaseOrderId,//currPurchaseOrder.Id,
            buildertek__Responsible_Contractor__c = currPurchaseOrder.buildertek__Vendor__c,
            buildertek__Project__c = currPurchaseOrder.buildertek__Project__c,
            buildertek__Inspection_Date__c = myDate,
            buildertek__Scheduled_Date__c = myDate
            //buildertek__Trade_Type__c = currPurchaseOrder.buildertek__Vendor__r.buildertek__Trade_Type__c
        );
        if(Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Status__c.isCreateable()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Purchase_Order__c.isCreateable() &&
			Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Responsible_Contractor__c.isCreateable() &&
			Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Project__c.isCreateable() &&
			Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Inspection_Date__c.isCreateable() &&
			Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Scheduled_Date__c.isCreateable()){
              insert inspection;
         }
        
        for(buildertek__Purchase_Order_Item__c purchaseOrderLine : currPurchaseOrder.buildertek__Purchase_Order_Items__r) {
            listInspectionLines.add(new buildertek__Inspection_Line__c(
                buildertek__Inspection__c = inspection.Id,
                buildertek__Description__c = purchaseOrderLine.Name,
                buildertek__Status__c = 'Pending'
            ));
        }
        
        if(!listInspectionLines.isEmpty()) {
        if (Schema.sObjectType.buildertek__Inspection_Line__c.fields.Id.isCreateable() && 
            Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Inspection__c.isCreateable() &&
             Schema.sObjectType.buildertek__Inspection_Line__c.fields.Name.isCreateable() &&
             Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Status__c.isCreateable() &&
             Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Description__c.isCreateable()) {
             insert listInspectionLines;
            }
        }
        
        return inspection.Id;
    }
}