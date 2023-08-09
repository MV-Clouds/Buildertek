({
	doinit : function(component, event, helper) {
        var sovId=component.get("v.recordId");
		//alert('sovId ---'+sovId);
        var sovAction = component.get("c.getSOVRec");
        sovAction.setParams({
            recordId : component.get("v.recordId"),
        });
        sovAction.setCallback(this, function (response) {
            var state = response.getState();
            var sovDispaly= response.getReturnValue();
            if (state === "SUCCESS") {
				component.set("v.sovList", sovDispaly);
                //alert(JSON.stringify(sovDispaly));
            }
            
        });
        $A.enqueueAction(sovAction);
	}
})