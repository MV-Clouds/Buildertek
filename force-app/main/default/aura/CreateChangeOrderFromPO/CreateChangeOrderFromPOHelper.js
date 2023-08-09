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
	
	createCO : function(component, helper){
	  var action = component.get("c.createChangeOrder");
        action.setParams({ purchaseOrderId : component.get("v.recordId") });
        console.log('recordId ', component.get("v.recordId"));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                if(response.getReturnValue().strMessage === 'success'){
                    $A.get("e.force:closeQuickAction").fire();
            		component.find('notifLib').showNotice({
    		            "variant": "success",
    		            "header": "Success",
    		            "message": "Change Order created.",
    		            closeCallback: function() {
    		            	$A.get('e.force:refreshView').fire();
    		            	var event = $A.get('e.force:navigateToSObject' );
    		            	event.setParams({
    				            'recordId' : response.getReturnValue().strRecordId
    				        }).fire();
    		            }
    		        });    
                }else{
                    $A.get("e.force:closeQuickAction").fire();
        		    component.find('notifLib').showNotice({
		            "variant": "error",
		            "header": "Error",
		            "message": response.getReturnValue().strMessage,
    		            closeCallback: function() {
    		            
    		            }
    		        });
                }
                
            }
        });
        
        $A.enqueueAction(action);    
	} 
})