({
	doInit : function(component, event, helper) {
	    helper.fetchPickListVal(component, event, helper);
	    helper.getTimezone(component, event, helper);
	    var action = component.get("c.getMasterData"); 
	    action.setParams({
	        recordId : component.get("v.recordId")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.newMasterBudget", result.masterBudgetRecord);
	            component.set("v.newMasterBudgetLines", result.masterBudgetLineRecord);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	save : function(component, event, helper) {
	    //alert('Master Budget --------> '+JSON.stringify(component.get("v.newMasterBudget")));
	    component.set("v.Spinner", true);
	    var action = component.get("c.saveMasterBudget");
	    action.setParams({
	        masterBudgetRecord : component.get("v.newMasterBudget"),
	        masterBudgetLines : component.get("v.newMasterBudgetLines"),
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();  
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": result.Id,
                  "slideDevName": "related"
                });
                navEvt.fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Master Budget was created',
                    messageTemplate: "Master Budget {0} was created.",
                    messageTemplateData: [{
                    label: result.Name,
                    }],
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	doSaveAndNew : function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var action = component.get("c.saveMasterBudget");
	    action.setParams({
	        masterBudgetRecord : component.get("v.newMasterBudget"),
	        masterBudgetLines : component.get("v.newMasterBudgetLines"),
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();  
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            component.set("v.newMasterBudget.Name", '');
	            component.set("v.newMasterBudget.buildertek__Is_Budget_Locked__c", ''); 
	            component.set("v.newMasterBudget.buildertek__Type__c", '');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Master Budget was created',
                    messageTemplate: "Master Budget {0} was created.",
                    messageTemplateData: [{
                    label: result.Name,
                    }],
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                component.set("v.Spinner", false);
	        }
	    });
	    $A.enqueueAction(action);    
	},
	
	closeModal : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
	}
})