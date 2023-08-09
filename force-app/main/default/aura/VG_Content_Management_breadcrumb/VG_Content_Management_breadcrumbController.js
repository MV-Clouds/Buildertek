({
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    navigateTocontentmanagement: function(component){
        var recordid = component.get("v.recordId");
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/ec-content/EC_Content__c/00B0h000009buIu"
        });
        navEvt.fire();
    }
})