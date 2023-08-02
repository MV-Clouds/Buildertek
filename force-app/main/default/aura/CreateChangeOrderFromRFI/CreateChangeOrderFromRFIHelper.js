({
	fetchPickListVal: function(component, fieldName, elementId) {
    	var actions = component.get("c.getselectOptions");
    	actions.setParams({
    		"changeOrderObject": component.get("v.changeOrder"),
    		"changeOrderField": fieldName
    	});
    	var opts = [];
    	actions.setCallback(this, function(response) {
    		if (response.getState() == "SUCCESS") {
    			var allchangeOrderValues = JSON.parse(response.getReturnValue());
    			if (allchangeOrderValues != undefined && allchangeOrderValues.length > 0) {
    				opts.push({
    					class: "optionClass",
    					label: "--- None ---",
    					value: ""
    				});
    			}
    			for (var i = 0; i < allchangeOrderValues.length; i++) {
    				opts.push({
    					class: "optionClass",
    					label: allchangeOrderValues[i].label,
    					value: allchangeOrderValues[i].value
    				});
    				
    			}
    			component.find(elementId).set("v.options", opts);
    			//component.set("v.options", opts);
    		}
    	});
    	$A.enqueueAction(actions);
    },
})