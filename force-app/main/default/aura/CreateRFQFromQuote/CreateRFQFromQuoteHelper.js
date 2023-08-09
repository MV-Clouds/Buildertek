({
    showToast : function(component, event, helper, type, message) {
        var toastEvent = $A.get("e.force:showToast");
        
        toastEvent.setParams({
            "type": type,
            "message": message,
            "mode" : "sticky"
    	});
    	
        toastEvent.fire();
	}
})