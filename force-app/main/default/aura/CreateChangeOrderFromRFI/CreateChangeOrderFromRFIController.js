({
	init : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
	    helper.fetchPickListVal(component, 'buildertek__Status__c', 'statusId');
	    helper.fetchPickListVal(component, 'buildertek__Type__c', 'typeId');
	    var action = component.get("c.getProjectId");
	    action.setParams({
	        recordId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
    	        component.set("v.projectId", result.buildertek__Project__r.Id);
    	        component.set("v.RFIName", result.Name); 
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	createChangeOrder : function(component, event, helper) {
	    var changeOrder = component.get("v.changeOrder");
	    var name = component.get("v.RFIName");
	    var selectedProject = component.get("v.projectId");
	    var selectedAccountPeriod = component.get("v.selectedValue");
	    var selectedAccountPeriodId;
	    if(selectedAccountPeriod != undefined){
	        selectedAccountPeriodId = component.get("v.selectedValue").Id;     
	    }else{
	        selectedAccountPeriodId = null;
	    }
	    var selectedAccountValue = component.get("v.selectedAccountValue");
	    var selectedAccountId;
	    if(selectedAccountValue != undefined){
	        selectedAccountId = component.get("v.selectedAccountValue").Id;         
	    }else{
	        selectedAccountId = null;
	    }
	    var action = component.get("c.insertChangeOrder");
	    action.setParams({
	        changeOrder : changeOrder,
	        name : name,
	        projectId : selectedProject,
	        accountPeriod : selectedAccountPeriodId,
	        accountId : selectedAccountId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
	            var result = response.getReturnValue();
	            if(result.status == "Error"){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: result.Message,
                        type : 'error'
                    });
                    toastEvent.fire();
                    }else{
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: result.Message,
                            messageTemplate: "Change Order {0} created successfully.",
                            messageTemplateData: [{
                            url: baseURL+'/lightning/r/buildertek__Change_Order__c/'+escape(result.recordId)+'/view',
                            label: result.recordName,
                            }],
                            type : 'success'
                        });
                        toastEvent.fire();
                    }
                    
                    var recordId = component.get("v.recordId");
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	closeModel : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
            "recordId": recordId,
            "slideDevName": "detail"
        });
        navEvt.fire();
	},
})