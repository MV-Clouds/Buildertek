({
	doInit : function(component, event, helper) {
        var record = component.get("v.record");
        var field = component.get("v.field");
        if(record) {
            component.set("v.value" , record[field]);
        }
	}
})