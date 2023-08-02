({
	updateProductQuantity : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
	    var status = component.get("v.QuoteRecord.buildertek__Status__c");
	    //alert('status --> '+status);
	    if(status == 'Delivered'){
	        //alert('This Quote is already Delivered');
	        component.set("v.message", 'This Quote is already Delivered');
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
    	            //var result = response.getReturnValue();
    	            component.set("v.message", 'Quoted Delivered Successfully');
    	           // component.set("v.status", result);
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