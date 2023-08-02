({
	handleClick : function(component, event, helper) {
        var resourse = $A.get("$Label.c.Glazier_Resources");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": resourse
    });
    urlEvent.fire();
},
    handleClick1 : function(component, event, helper) {
        var resourse1 = $A.get("$Label.c.Low_Voltage_Resources");
    var urlEvent = $A.get("e.force:navigateToURL");
    urlEvent.setParams({
      "url": resourse1 
    });
    urlEvent.fire();
}
})