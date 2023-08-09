({
	doInit : function(component, event, helper) {
        //alert('budgetId '+budgetId);
        var islocked = component.get("v.budget.buildertek__Is_Budget_Locked__c");
        //alert('islocked --> '+islocked);
        var budgetId = component.get("v.recordId");
        if(islocked == true){
            alert('You Cannot Edit this record as Budget is locked');
    		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": budgetId,
              "slideDevName": "related"
            });
            navEvt.fire();
        }else{
            var cmpTarget = component.find('Modalbox');
    		var cmpBack = component.find('Modalbackdrop');
    		$A.util.addClass(cmpBack,'slds-backdrop--open');
    		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
            component.set('v.objectApiName','buildertek__Budget__c');
    	    helper.getTypeVal(component, 'buildertek__Type__c', 'typeId');
            var budgetId = component.get("v.recordId");
            var action = component.get("c.editBudget");
            action.setParams({
             budgetId : budgetId
            });
            action.setCallback(this, function(response){
             var state = response.getState();
             //alert('state '+state);
             if(state === "SUCCESS"){
                var result =  response.getReturnValue();
                //alert('result '+result);
                component.set("v.budget",result);
                //alert('Lookup Value '+result.buildertek__Project__r.Name);
                var projectId = result.buildertek__Project__c;
                component.set("v.budget.buildertek__Project__c",projectId);
             }
            });
            $A.enqueueAction(action);
        }
         
	},
	closeModel : function(component, event, helper) {
	    var budgetId = component.get("v.recordId");
	    var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--close');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
		var navEvt = $A.get("e.force:navigateToSObject");
            navEvt.setParams({
              "recordId": budgetId,
              "slideDevName": "related"
            });
            navEvt.fire();
	},
	saveBudget : function(component, event, helper) {
	    var budgetId = component.get("v.recordId");
	    var budget = component.get("v.budget");
	    //alert('Lookup Value --> '+component.get("v.selectedLookupValue").Id);
	    if(component.get("v.selectedLookupValue").Id != undefined){
            budget.buildertek__Project__c = component.get("v.selectedLookupValue").Id;
        }
	    var action = component.get("c.updateBudgetInformation");
	    action.setParams({
	        budget : budget
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        //alert('Update state --> '+state);
	        if(state === "SUCCESS"){
	            var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                  "recordId": budgetId,
                  "slideDevName": "related"
                });
                navEvt.fire();
                window.setTimeout(
                    $A.getCallback(function() {
                        $A.get('e.force:refreshView').fire();
                    }), 3000
                );

	        }
	    });
	    $A.enqueueAction(action);
	},
	
	clearSelectedValue : function(component, event, helper) {
	    component.set("v.isLookupValue", true);
	}
})