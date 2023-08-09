({
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    navigateTotoparticles: function(component){
        var recordid = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/toparticles"
        });
        navEvt.fire();
    }
})