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
	updateStatus: function(component, event, helper, rfqtovendorId, statusToUpdate){
    	var actionUpdateStatus;
        actionUpdateStatus = component.get("c.updateRFQToVendorStatus");
        actionUpdateStatus.setParams({
            rfqToVendorLinkIds: JSON.stringify(rfqtovendorId),
            Status: statusToUpdate
        });
        actionUpdateStatus.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() !== ''){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": response.getReturnValue()
		            });
		            $A.get("e.force:refreshView").fire();
		            helper.updateInfoMessage(component, event, helper, statusToUpdate);
		            this.refreshGrid(component, event, helper);
		        } else {
		            toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": response.getReturnValue()
		            });
		        	
		    	}
			}else {
	    		toastEvent.setParams({
	                "type":"error",
	                "title": "error",
	                "message": response.getError()[0].message
	            });
	    	}
	        toastEvent.fire();
        });
        
        $A.enqueueAction(actionUpdateStatus);
    },
    
    refreshGrid: function(component, event, helper){
    	var grid = component.find("vendorReviewList");
		grid.refreshData();
    },
    
    updateInfoMessage: function(component, event, helper, status) {
    	// Set the info message
    	if(status == 'Awarded'){
    		component.find("infoMessage").set("v.type", "success");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Awarded_Status"));
    	} else if(status == 'Accepted'){
    		component.find("infoMessage").set("v.type", "success");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Accepted_Status"));
    	}else {
    		component.find("infoMessage").set("v.type", "info");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_New_Status"));
    	}
    }
	
})