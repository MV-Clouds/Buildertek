({
	HrGroup : function(component, event, helper) {
		  var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            
           "url": "/s/group/CollaborationGroup/00BE0000003h4w9MAA"
        });
        navEvt.fire();
	}
})