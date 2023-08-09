({
	getTemplateBody : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getInvoiceLines");
		console.log('selected Email Template==='+component.get("v.selectedTemplate"));
	    action.setParams({
	        recordId : recordId,
	        templateId : component.get("v.selectedTemplate")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.invoiceLines", result);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	
	
	
})