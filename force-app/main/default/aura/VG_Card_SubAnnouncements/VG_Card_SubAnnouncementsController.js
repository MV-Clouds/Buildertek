({
    doInit: function(component, event, helper) {
        
        var actionBase = component.get("c.getPrefix");	
        actionBase.setCallback(this, function(response) {
            var state = response.getState();
            var baseUrlResponse = response.getReturnValue();
            component.set("v.urlPrefix",baseUrlResponse) ;
            // alert(baseUrlResponse);
            //alert(component.get('v.recordId'));
        });
        
        
        $A.enqueueAction(actionBase);
    },
    goToURL: function(component, event, helper) {
        var curObj = event.currentTarget;
        var url = curObj.dataset.url;       
        var navEvt = $A.get("e.force:navigateToURL");
        navEvt.setParams({
            "url": url
        });
        navEvt.fire();
    },
    /* commented as it is not required after changing the code to work for right-click 
    navigateToDetail : function(component, event, helper) {		
		var curItem = event.currentTarget;
		var url = curItem.dataset.url;
		var navEvt = $A.get("e.force:navigateToURL");        
		navEvt.setParams({
		   "url": "/announcementdetail?id="+url
		});
		navEvt.fire();
     
     
   }, */
})