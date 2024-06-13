({
	getPODetails : function(component, event, helper) {
	    var action = component.get("c.getPurchaseOrderData");  
	    action.setParams({
	        "recordId" : component.get("v.recordId")
	    });
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
        	    if(result.buildertek__Project__c != null){
                    component.set("v.selectedProjectId", result.buildertek__Project__c);
                }
                if(result.buildertek__Description__c != null){
                    component.set("v.selectedTaskName", result.buildertek__Description__c);
                }
                if(result.buildertek__Vendor__c != null){
                    component.set("v.selectedVendorId",result.buildertek__Vendor__c);
                }
                helper.getSchedules(component, event, helper);
        	} 
        });  
        $A.enqueueAction(action);    
	}, 
	getSchedules : function(component, event, helper) {
        window.setTimeout(
            $A.getCallback(function () {
                component.set("v.Spinner", false);
            }), 2000
        );
		var action = component.get("c.getSchedulelist"); 
		action.setParams({
		    "recordId" : component.get("v.recordId")
		});
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
        		component.set("v.Schedules", result);
        	} 
        });  
        $A.enqueueAction(action);
	},

    getFieldsetValue : function(component, event, helper) {
        component.set("v.Spinner", true);
		var getFields = component.get("c.getFieldSet");
        getFields.setParams({
            objectName: 'buildertek__Project_Task__c',
            fieldSetName: 'buildertek__New_Fieldset_For_Po'
        });
        getFields.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                var listOfFields = JSON.parse(response.getReturnValue());
                console.log({listOfFields});
                component.set("v.listOfFields", listOfFields);
            }
        });
        $A.enqueueAction(getFields);
        helper.getPODetails(component, event, helper);
	},

    modifyDate: function(inputDate) {
        // Convert the inputDate to a JavaScript Date object
        var dt = new Date(inputDate);
        
        // Check if the inputDate is Saturday (6) or Sunday (0)
        var dayOfWeek = dt.getDay();
        if (dayOfWeek === 6) { // Saturday
            dt.setDate(dt.getDate() + 2); // Add 2 days
        } else if (dayOfWeek === 0) { // Sunday
            dt.setDate(dt.getDate() + 1); // Add 1 day
        }
        // Return the modified date
        return dt;
    },

})