({
    getBaseData1 : function(component, event, helper) {
		var action = component.get("c.getBaseData");
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                
                if(result.isSuccess) {
                    component.set("v.baseData", result);
                    // helper.showToast("Success", result.strMessage, "success");
                }
                else {
                    helper.showToast("Error", result.strMessage, "error");
                }
            }
        });
        
        $A.enqueueAction(action);
    },
    
    saveQuoteLine : function(component, event, helper) {
		var action = component.get("c.insertQuoteLineItem");
        var quoteItem = component.get("v.quoteItem");
        var selectedQuote = component.get("v.selectedQuote");
        var selectedProduct = component.get("v.selectedProduct");
        var selectedGroup = component.get("v.selectedGroup");
        var selectedVendor = component.get("v.selectedVendor");
        var selectedCostCode = component.get("v.selectedCostCode");
        
        quoteItem.buildertek__Cost_Code__c = selectedCostCode.strId;
        quoteItem.buildertek__Product__c = selectedProduct.strId;
        quoteItem.buildertek__Grouping__c = selectedGroup.strId;
        quoteItem.buildertek__Quote__c = selectedQuote.strId;
        quoteItem.buildertek__Vendor__c = selectedVendor.strId;
        
        console.log('quoteItem ::: ',quoteItem);
        
        action.setParams({
            quoteItem : JSON.stringify(quoteItem)

        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            
            if(state == "SUCCESS") {
                var result = response.getReturnValue();
                
                if(result.isSuccess) {
                    helper.showToast("Success", result.strMessage, "success");
                    $A.get("e.force:closeQuickAction").fire();
                }
                else {
                    helper.showToast("Error", result.strMessage, "error");
                }
            }
        });
        
        // $A.enqueueAction(action);
    },
    
    showToast : function(title, message, type) {
        var toastEvent = $A.get("e.force:showToast");  
        
        toastEvent.setParams({ 
            "title" : title,
            "message" : message,  
            "type" : type 
        });  
        
        toastEvent.fire(); 
    }
})