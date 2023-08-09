({
	fetchPickListVal: function(component, event,helper) { 
	    var opts = [];
    	var actions = component.get("c.getselectOptions");
    	actions.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    		    var result  = response.getReturnValue();
    			var opts = [];
    			opts.push({key: "None", value: "" });
                for(var key in result){
                    opts.push({key: key, value: result[key]});
                }
    			component.set("v.Options", opts);
    		}
    	});
    	$A.enqueueAction(actions);
    },
    
    getTimezone : function(component, event,helper) { 
        var action = component.get("c.getUserTimeZone");
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.timezone", result);
            }
        });
        $A.enqueueAction(action);
    }
})