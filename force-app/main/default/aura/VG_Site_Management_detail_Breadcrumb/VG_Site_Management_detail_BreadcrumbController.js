({
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    navigateTositemanagement: function(component){
        var recordid = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/site-layout/Site_Layout__c/00B0h000009buJ1EAI"
        });
        navEvt.fire();
    },
    navigateTositedetails: function(component){
        var recordid = component.get("v.recordId");
        var action = component.get("c.getsitelayout");
        action.setParams({
            sitedetailId : recordid
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var res = response.getReturnValue();
                var navEvt = $A.get("e.force:navigateToURL");        
                navEvt.setParams({
                    "url": "/s/site-layout/"+res[0]+"/"+res[1]
                });
                navEvt.fire();
            }
        });
        $A.enqueueAction(action);
    }
})