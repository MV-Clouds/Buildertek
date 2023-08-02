({
	getTemplateBody : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getPayableLines");
	    action.setParams({
	        recordId : recordId,
	        templateId : component.get("v.selectedTemplate")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.payableLines", result);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	
	
	
})