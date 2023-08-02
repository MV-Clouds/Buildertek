({
	doInit : function(component, event, helper) {
		var action = component.get("c.getInvoices");
        action.setParams({AccId : component.get('v.AccountId')});
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                alert('&&&&&&&&&'+result);
            }
        });
        $A.enqueueAction(action);
    },
})