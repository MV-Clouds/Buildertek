({
	
	//showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, 'slds-show');
        $A.util.removeClass(spinner, 'slds-hide');
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, 'slds-hide');
        $A.util.removeClass(spinner, 'slds-show');
    },
	
	doInit : function(component, event, helper) {
		var action;
        action = component.get("c.getQuoteTemplates");
        action.setCallback(this, function (response) {
        	if (component.isValid() && response.getState() === "SUCCESS") {
        		console.log(response.getReturnValue());
        		component.set("v.quoteTemplateoptions",response.getReturnValue());
        		component.set("v.selectedTemplateId",response.getReturnValue()[0].Id);
        	}
        });
        
        $A.enqueueAction(action);
	},
	
	sendQuoteEmail : function(component, event, helper) {
		/*
		var signaturePadCmp = component.find("signaturePad");
		var signaturePad = signaturePadCmp.get("v.signaturePad");
		var signature = signaturePad.toDataURL();
		console.log(signature);
		if (signaturePad.isEmpty()) {
		    alert("Please provide a signature first.");
		    return false;
		}
		*/
		
		var action;
        action = component.get("c.sendQuote");
        action.setParams({
            recordId: component.get("v.recordId"),
            targetRecipientId: component.get("v.quote").buildertek__Primary_Contact__c,
            templateId: component.get("v.selectedTemplateId"),
            signatureBase64:""
        });
        action.setCallback(this, function (response) {
        	$A.get("e.force:closeQuickAction").fire();
        	if (component.isValid() && response.getState() === "SUCCESS") {
        		var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "title": "",
	                "message": "Quote has been sent.",
	                "type": "success"
	            });
	             toastEvent.fire();
        	} else {
        		var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
	                "type":"error",
	                "title": "Error!",
	                "message": response.getError()[0].message
	            });
	            toastEvent.fire();
        	}
        	
        	
        });
        
        $A.enqueueAction(action);
		
		
	}
})