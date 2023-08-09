({
	goToURL : function(component, event, helper) {
		
       var curTab = event.currentTarget;
        var url = curTab.dataset.url;
       
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
           "url": url
         });
       navEvt.fire();
        
	}
})