({
	sendEmail : function(component, event, helper) {
        var documentIds = component.get("v.documentIds");
        if(documentIds.length > 0){
        	var action = component.get("c.sendUploadedAttachment");
            action.setParams({
                accountId : component.get("v.recordId"),
                documentIds : documentIds
            });
            action.setCallback(this, function(response){
                if(response.getState() === 'SUCCESS'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": "success",
                        "message": "MSA Completed Successfully."
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();    
                }    
            });
            $A.enqueueAction(action);    
        }	
	}
})