({
	scriptsLoaded : function(component, event, helper) {
        helper.fetchCalenderEvents(component, event, helper);
	},
    
    viewAll : function(component, event, helper) {
       var navEvt = $A.get("e.force:navigateToURL");
       navEvt.setParams({
           "url": "/all-event-calendar"
       });
       navEvt.fire();
    }
})