({
	doInit : function(component, event, helper) {
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:NewQuoteItemClone",
            componentAttributes: {
                recordId : component.get("v.recordId"),
                isproject : component.get("v.isproject")
            }
        });
        evt.fire();	
	}
})