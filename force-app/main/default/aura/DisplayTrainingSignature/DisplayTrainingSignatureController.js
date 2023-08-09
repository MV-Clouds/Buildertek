({
	 doInit : function(component, event, helper) {
        helper.doChecklistHelper(component, event, helper);
		var action = component.get("c.getTSettings");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.bTSettings", result);
            }   
        });
        $A.enqueueAction(action);
	},
})