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
        action = component.get("c.getContractTemplates");
        action.setCallback(this, function (response) {
        	if (component.isValid() && response.getState() === "SUCCESS") {
        		component.set("v.Templateoptions",response.getReturnValue());
        		component.set("v.selectedTemplateId",response.getReturnValue()[0].Id);
        	}
        });
        
        $A.enqueueAction(action);
	},
	
	sendEmail : function(component, event, helper) {
		
		
	}
})