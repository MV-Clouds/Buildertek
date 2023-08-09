({
    doinit : function(component, event, helper) {
        console.log(component.get("v.recordId"));
        var Id = window.location.href.split("=").pop()
        console.log(Id);
        component.set("v.announcementid",Id);
        helper.getAnnouncement(component,Id);
    },
    
    navigateToAllAnnouncements: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/all-announcements"
        });
        navEvt.fire();
    },
    navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
    
})