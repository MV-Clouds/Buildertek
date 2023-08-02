({
	doInit : function(component, event, helper) {
        alert("ok")
        var getId = component.get("v.Id1");
        alert(getId);
		var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({ "url":"/apex/buildertek__BT_Invoice?id=getId"}); 
        urlEvent.fire();
    } 
	})