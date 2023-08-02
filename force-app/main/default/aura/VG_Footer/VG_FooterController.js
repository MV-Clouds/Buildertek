({
	doInit : function(component, event, helper) {
	    var action = component.get("c.retrieveContent"); 
        action.setStorable();
        action.setParams({type:"Footer"});
        action.setCallback(this, function(response) {
           component.set("v.footerContent",JSON.parse(response.getReturnValue())) ; 
           
        });
        $A.enqueueAction(action);
	}
})