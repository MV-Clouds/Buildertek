({
	updateProductQuantity : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    //alert("recordId -->  "+recordId);
	    var status = component.get("v.PurchaseOrderRecord.buildertek__Status__c");
	    if(status == 'Received'){
	        component.set("v.message", 'This Purchase Order is already Received');
	        window.setTimeout(
                $A.getCallback(function() {
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }), 3000
            );    
	    }else{
	        var action = component.get("c.updateAvailableQuantity");
    	    action.setParams({
    	        recordId : recordId
    	    });
    	    action.setCallback(this, function(response){
    	        var state = response.getState();
    	        if(state === "SUCCESS"){
    	            component.set("v.message", 'Purchase Order Received Successfully'); 
    	            window.setTimeout(
                        $A.getCallback(function() {
                            $A.get("e.force:closeQuickAction").fire();
                            $A.get('e.force:refreshView').fire();
                        }), 3000
                    );
    	        }
    	    })
    	    $A.enqueueAction(action);   
    	    }
	}
})