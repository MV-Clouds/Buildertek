({
    init : function(component, event, helper) {
        var budgetId = component.get("v.recordId");
        var action = component.get("c.getBudgetInformation");
        action.setParams({
            budgetId : budgetId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.projectId",result.buildertek__Project__c);
            }  
        });
        $A.enqueueAction(action);
    },
    
    doInit : function(component, event, helper) {
        var budgetId = component.get("v.recordId");
	    var islocked = component.get("v.budget.buildertek__Is_Budget_Locked__c");
	    if(islocked == true){
	       //alert('You Cannot Delete this record as Budget is Locked');
	        $A.get("e.force:closeQuickAction").fire();
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Waring!",
                        "message": "You Cannot Delete this record as Budget is Locked.",
                        "type" : "warning"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.projectId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
    		/* var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": budgetId,
              "slideDevName": "related"
            });
            navEvt.fire(); */
	    }
	},
	
	deleteBudget : function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var budgetId = component.get("v.recordId");
    	    var action = component.get("c.deleteBudgetRecord");
    	    action.setParams({
    	        budgetId : budgetId
    	    });
    	    action.setCallback(this, function(response){
    	        var state = response.getState();
                if(state === "SUCCESS"){
                    //$A.enqueueAction(component.get('c.gotoList'));
                    component.set("v.Spinner", false);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "Budget record has been deleted successfully.",
                        "type" : "success"
                    });
                    toastEvent.fire();
                    $A.get("e.force:closeQuickAction").fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": component.get("v.projectId"),
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                    
    	           /* var url = location.href;
                    var baseURL = url.substring(0, url.indexOf('/', 14));
                    $A.get("e.force:navigateToURL").setParams({ 
                       "url": baseURL+'/one/one.app?source=aloha#/sObject/buildertek__Budget__c/home' 
                    }).fire();
                    */
    	        }
    	    });
    	    $A.enqueueAction(action);
	},
	
	closeModal : function(component, event, helper) {
	    $A.get("e.force:closeQuickAction").fire();
	}
})