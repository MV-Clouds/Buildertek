({
    onConform : function(component, event, helper) {
       component.set("v.Spinner",true);
		var action = component.get("c.createContractRec");
        action.setParams({
            "recordId": component.get('v.recordId')  
        });
        action.setCallback(this, function(response) { 
            var state = response.getState();
             component.set("v.Spinner",false);
            console.log('state :: ',state);
            $A.get("e.force:closeQuickAction").fire();
            if (state === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "The record has been created successfully.",
                    "type":"success"
                });
                toastEvent.fire();
                var result=response.getReturnValue();
                if(result != null && result != ''){
                    var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        recordId: result,
                        slideDevName: "detail"
                    });
                    navEvent.fire();
                }
            }else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Something went wrong.",
                    "type":"error"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action); 
	},
    
	onCancel : function(component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	}
})