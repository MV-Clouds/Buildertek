({
	getPODetails : function(component, event, helper) {
	    var action = component.get("c.getPurchaseOrderData");  
	    action.setParams({
	        "recordId" : component.get("v.recordId")
	    });
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
                console.log('result===>',result);
        	    if(result.buildertek__Project__c != null){
                    component.set("v.selectedProjectId", result.buildertek__Project__c);
                    component.set("v.disablePro", 'true');
                    // helper.getSchedules(component, event, helper);
                }
                if(result.ContactId != null){
                    component.set("v.selectedContactRecord", result.ContactId);
                    component.set("v.disableCon", 'true');
                }
        	} 
        });  
        $A.enqueueAction(action);    
	}, 
	getSchedules : function(component, event, helper) {
		var action = component.get("c.getSchedulelist"); 
		action.setParams({
		    "recordId" : component.get("v.selectedProjectId")
		});
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();

                // Prepare the scheduleOptions list for the lightning:combobox
                var scheduleOptions = [];
                result.forEach(function(sch) {
                    scheduleOptions.push({
                        label: sch.getSchedulesList.Name + ' - ' + sch.getSchedulesList.buildertek__Description__c,
                        value: sch.getSchedulesList.Id
                    });
                });

                // Set the scheduleOptions attribute to be used in the lightning:combobox
                component.set("v.scheduleOptions", scheduleOptions);
        	} 
        });  
        $A.enqueueAction(action);
	},

})