({
	doInit: function(component, event, helper) {
		helper.getQuickLinks(component, helper);        		
	},
	
	goToURL: function(component, event, helper) {
		var selectedItem = event.currentTarget;
		var url = selectedItem.dataset.url;
		var navEvt = $A.get("e.force:navigateToURL");
		navEvt.setParams({
		"url": url
		});
		navEvt.fire();
	},
	
})