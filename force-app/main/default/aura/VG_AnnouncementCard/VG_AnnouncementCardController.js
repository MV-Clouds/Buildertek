({    
	goToURL: function(component, event, helper) {
		var curObj = event.currentTarget;
        var url = component.get("v.actionURL");;
       
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
           "url": url
         });
       navEvt.fire();
	}
})