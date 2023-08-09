({
	doInit : function(component, event, helper) {
        component.set("v.Spinner",true);
        window.setTimeout(
            $A.getCallback(function() {
                component.set("v.Spinner", false); 
                $A.get("e.force:closeQuickAction").fire();
            }), 7000
        );
    }
})