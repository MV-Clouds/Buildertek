({

	init : function(component, event, helper){
	    //alert('Hiiiiiii');
		var vendorId = component.get("v.vendorIds")[0]; 
		//alert('vendorId --------> '+vendorId);
		helper.getEmailPreview(component, event, helper, vendorId);
	},
	cancel : function(component, event, helper) {
		component.find("overlayLib").notifyClose();
	},
	send : function(component, event, helper) {
		var onSuccess = component.get("v.onSuccess");
		component.set('v.IsSpinner' , true);
    	if (!$A.util.isUndefinedOrNull(onSuccess)) {
    		onSuccess(component.get("v.emailSubject"), component.get("v.contactId"));
    	}
    /*	var action = component.get("c.sendEmail");
        //alert(component.get("v.vendorIds")[0]);
    	action.setParams({
    	    parentRecordID : component.get("v.vendorIds")[0]
    	});
    	action.setCallback(this, function(response){
    	    var state = response.getState();
    	    if(state === "SUCCESS"){
    	        component.get("v.onSuccess")();       
    	    }
    	}); 
    	$A.enqueueAction(action);*/
	}
})