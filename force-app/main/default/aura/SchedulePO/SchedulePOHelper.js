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
                    component.set('v.isProject', true);  
                    component.set("v.selectedLookUpRecordName", result.buildertek__Project__r.Name);
                    component.set("v.selectedProjectId", result.buildertek__Project__c);
                    component.set("v.taskRecord.Name", result.buildertek__Description__c);
                }
                if(result.buildertek__Vendor__c != null){
                    component.set('v.isVendor', true);
                    var selectedAccountRecord=component.get("v.selectedAccountRecord");
                    selectedAccountRecord.Id=result.buildertek__Vendor__c;
                    selectedAccountRecord.Name=result.buildertek__Vendor__r.Name;
                    component.set("v.selectedAccountRecord",selectedAccountRecord);
                }
        	} 
        });  
        $A.enqueueAction(action);    
	}, 
	getSchedules : function(component, event, helper) {
		var action = component.get("c.getSchedulelist"); 
		action.setParams({
		    "recordId" : component.get("v.recordId")
		});
        action.setCallback(this, function (response) {
        	if (response.getState() === "SUCCESS") {  
        	    var result = response.getReturnValue();
        	    /*for(var i=0;i<result.length;i++){
        	        options.push({
        	            "label": result[i].getSchedulesList.Name,
        	            "value": result[i].getSchedulesList.Id
        	        });    
        	    }*/
        		component.set("v.Schedules", result);
        	} 
        });  
        $A.enqueueAction(action);
	},
	
	fetchPickListVal: function(component, elementId, fieldName) {
        var action = component.get("c.getselectOptions");
        action.setParams({
            objectName : component.get("v.taskRecord"), 
            fieldName : fieldName
        });
        var opts = [];
        //alert('hiiiiiii 123');
        action.setCallback(this, function(response) {
            //alert('State --> '+response.getState());
            if (response.getState() === "SUCCESS") {
                var allValues = response.getReturnValue();
 
                if (allValues != undefined && allValues.length > 0) {
                    opts.push({
                        class: "optionClass",
                        label: "--- None ---",
                        value: ""
                    });
                }  
                for (var i = 0; i < allValues.length; i++) {
                    opts.push({
                        class: "optionClass",
                        label: allValues[i],
                        value: allValues[i]
                    });
                }
                component.find(elementId).set("v.options", opts);
                //alert('hiiiiiii');
            }
        });
        $A.enqueueAction(action);
    },

})