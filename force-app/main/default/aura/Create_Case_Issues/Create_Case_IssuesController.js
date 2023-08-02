({
	navigateToCmp : function(component, event, helper) {
        var recdid = component.get("v.recordId");
        console.log("--recdid in navigateToCmp--"+recdid);
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:LogIssuesCmp",
            componentAttributes: {
                recordId:recdid
            }
        });
        evt.fire();
    } 
})