({
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    navigateToSiteManagement: function(component){
        var recordid = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/site-layout/Site_Layout__c/00B0h000009buJ1EAI"
        });
        navEvt.fire();
    }
})