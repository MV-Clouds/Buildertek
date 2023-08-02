({
	doInit : function(component, event, helper) {
		var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:BT_ShowPOs",
            componentAttributes: {
                recordId : component.get("v.recordId")
            }
        });
        evt.fire();	
	}
})