({
	 navigateToHome: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/"
        });
        navEvt.fire();
    },
     navigateToGallery: function(component){
        var navEvt = $A.get("e.force:navigateToURL");        
        navEvt.setParams({
            "url": "/view-gallery"
        });
        navEvt.fire();
    }
})