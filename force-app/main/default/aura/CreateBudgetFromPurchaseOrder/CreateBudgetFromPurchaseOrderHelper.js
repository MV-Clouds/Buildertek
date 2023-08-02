({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "type": type,
            "message": message,
            "mode" : "sticky"
    	});
    	
        toastEvent.fire();
	},
	
	 createBudget : function(component, helper){
	   var action = component.get("c.createBudgetFromPurchase");
        action.setParams({ purchaseId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result.strMessage === "success"){
                    $A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Budget created.",
    		            closeCallback: function() {
    		            	$A.get('e.force:refreshView').fire();
    		            	var event = $A.get('e.force:navigateToSObject' );
    		            	event.setParams({
    				            'recordId' : response.getReturnValue().newRecordId
    				        }).fire();
    		            }
    		        });    
                }else{
                    $A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
    		            "variant": "error",
    		            "header": "Error",
    		            "message": result.strMessage,
    		            closeCallback: function() {
    		            	
    		            }
    		        });
                }
                
            }
        });
        
        $A.enqueueAction(action); 
	}  
})