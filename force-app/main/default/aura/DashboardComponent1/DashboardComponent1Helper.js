({
	fetchContract:function(component,event,helper){
		var action = component.get("c.getContract");
       
        action.setCallback(component, function(response){
            var state = response.getState();
            console.log(state);
            if (state == "SUCCESS"){
                component.set("v.Contract", response.getReturnValue());
            }
            console.log('response',response.getReturnValue());
        });
        $A.enqueueAction(action);
    },
})