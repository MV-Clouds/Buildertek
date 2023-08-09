({
	getFilterFields : function() {
		var initialize, action = component.get("c.getFieldSet");
        action.setParams({
            "objectName" : component.get("v.sObjectName"),
            "FieldSetName" : component.get("v.fieldSetName")
        });
        action.setCallback(this, function(result) {
            var state = result.getState();
            if(state === "SUCCESS"){
               component.set("v.fieldlist",result.getReturnValue());
            }
        });
        
        initialize.setParams({
            "objectName" : component.get("v.sObjectName"),
            "FieldSetName" : component.get("v.fieldSetName")
        });
        initialize.setCallback(this, function(result) {
            var state = result.getState();
            if(state === "SUCCESS"){
                component.set("v.filterCriteriaList",result.getReturnValue().filterCriteriaList);
            }
        });
        
        $A.enqueueAction(action);
	}
})