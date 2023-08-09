({
	initialEmail : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getInitialEmailBody");
	    action.setParams({
	        recordId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	           var result = response.getReturnValue();
	           //alert('Initial result --------> '+JSON.stringify(result));
	           if(result != undefined){
	               component.set("v.submittalIntialRec", result);  
	               component.set("v.IsInitialEmail", true); 
	               
	           }
	           
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	finalEmail : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getFinalEmailBody");
	    action.setParams({
	        recordId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	           var result = response.getReturnValue();
	           //alert('Final result --------> '+JSON.stringify(result));
	           if(result != undefined){
	               component.set("v.submittalFinalRec", result);
	               component.set("v.IsLastEmail", true); 
	           }
	        }
	    });
	    $A.enqueueAction(action);
	},
	
})