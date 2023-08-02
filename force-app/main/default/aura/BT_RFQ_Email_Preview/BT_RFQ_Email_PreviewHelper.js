({
	getEmailPreview : function(component, event, helper, vendorId) {       
		var action;
        action = component.get("c.emailPreview");
        action.setParams({
            "rfqId" : component.get("v.rfqId"),
            "vendorId":vendorId
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                result = JSON.parse(result);
                console.log('result',result);
            	component.set("v.emailPreviewHTML", result.emailBody);
            	component.set("v.emailSubject", result.emailSubject);
            	if(result.contactId != null){
            	    component.set("v.contactId", result.contactId);
            	}
            }
        });
        $A.enqueueAction(action);
	}
})