({
	doInit: function(component, event, helper) {
          /* globals $ */
        
        
        var url = 'https://myview--partial--c.cs15.content.force.com/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_Jpg&versionId=068e0000000k6zI';
        component.set('v.bgImage', url); 
        var ImageUrl= component.get('v.bgImage');
        console.log(ImageUrl);
        
        var actionBase = component.get("c.getPrefix");
        actionBase.setCallback(this, function(response) {
            var state = response.getState();
            var baseUrlResponse = response.getReturnValue();

    	var numOfCards= component.get("v.numOfCards");

    	var autoPlay = Boolean(component.get("v.autoplay"));
    	var autoPlaySpeed = component.get("v.autoplaySpeed");

		var action = component.get("c.retrieveContent");
        action.setParams({"type":"Announcement"});
        action.setCallback(this, function(response) {
        	var state = response.getState();
            var cardContent = JSON.parse(response.getReturnValue());
		    component.set("v.cardContent",cardContent) ;
          
            });

            $A.enqueueAction(action);
        });
        $A.enqueueAction(actionBase);
        
	}
})