({
	getTypeVal : function(component, fieldName, elementId) {
        var action = component.get("c.getTypeOptions");
        var budget = component.get("v.objectApiName");
        //alert('budget '+budget);
        action.setParams({
            "budget": budget,
            "field": fieldName
        });
        var opts = [];
        action.setCallback(this, function(response) {
            if (response.getState() == "SUCCESS") {
                var allValues = JSON.parse(response.getReturnValue());
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }
                for (var i = 0; i < allValues.length; i++) {
                    if(component.get("v.budget.buildertek__Type__c") == allValues[i].value){
                        opts.push({
                            class: "optionClass",
                            label: allValues[i].label,
                            value: allValues[i].value,
                            selected: true
                        });
                    }else{
                        opts.push({
                            class: "optionClass",
                            label: allValues[i].label,
                            value: allValues[i].value
                        });
                    }
                    
                }
                component.find(elementId).set("v.options", opts);
            }
        });
        $A.enqueueAction(action);
	}
})