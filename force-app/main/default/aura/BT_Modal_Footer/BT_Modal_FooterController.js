({
	cancel : function(component, event, helper) {
		//$A.enqueueAction(component.get("v.cancel"));
	},
    
    save : function(component, event, helper) {
    	component.get("v.savecallback")();
		//$A.enqueueAction(component.get("v.save"));
	}
})